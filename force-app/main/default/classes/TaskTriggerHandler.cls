public without sharing class TaskTriggerHandler implements ITriggerHandler {
    //This method will handle before insert method
    public void beforeInsert(List<SObject> newItems) {
    }
    
    //This method will handle before update event
    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
    }
    
    //This method handles after insert event
    public void afterInsert(Map<Id, SObject> newMap) {
        setFirstResponseTimeOnLead(null, (List<Task>) newMap.values());
        updatePhoneContactOnLeadToTrue(null, (List<Task>) newMap.values());
        updateTaskCountIncreaseOnAccountProspect((List<Task>) newMap.values());
    }
    
    //This method handles after update event
    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        updatePhoneContactOnLeadToTrue((Map<Id, Task>) oldMap, (List<Task>) newMap.values());
    }
    
    //This will handle before delete event
    public void beforeDelete(Map<Id, SObject> oldMap) {
    }
    
    //This method handles after delete event
    public void afterDelete(Map<Id, SObject> oldMap) {
        updateTaskCountDecreaseOnAccountProspect((List<Task>) oldMap.values());
    }
    
    //This method handles after undelete event
    public void afterUndelete(Map<Id, SObject> newMap) {
    }
    
    public Boolean IsDisabled() {
        //Check if Triggers are enabled
        return false;
    }
    
    private void updatePhoneContactOnLeadToTrue(Map<Id,Task> oldTaskMap,List<Task> newTaskList) {
        System.debug('In');
        Set<Id> leadIdSet = new Set<Id>();
        for(Task t : newTaskList) {
            System.debug('t.CallDurationInSeconds: '+t.CallDurationInSeconds);
            if(t.Subject != null && 
               t.WhoId != null &&
               t.Subject.contains('Outbound answered call') &&
               t.CallType == 'Outbound' &&
               ((oldTaskMap == null && t.Status == 'Completed' && t.CallDurationInSeconds > 30) ||
               (oldTaskMap != null && t.Status == 'Successfully Completed' && t.Status != oldTaskMap.get(t.Id).Status) ||
               (oldTaskMap != null && t.Status == 'Completed' && t.CallDurationInSeconds > 30 && t.CallDurationInSeconds != oldTaskMap.get(t.Id).CallDurationInSeconds))
               ){
                   String whoId = t.WhoId;
                   if(whoId.startsWith('00Q')) leadIdSet.add(t.WhoId);
               }
        }
        
        if(!leadIdSet.isEmpty()){
            SYstem.debug('leadIdSet: '+leadIdSet);
            List<Lead> leadListToUpdate = [SELECT Id 
                                           FROM Lead 
                                           WHERE Id IN :leadIdSet 
                                           AND Phone_Contact__c = false
                                           AND LeadSource = 'Inbound'];
            for(Lead l : leadListToUpdate){
                l.Phone_Contact__c = true;
            }
            
            if(!leadListToUpdate.isEmpty()){
                update leadListToUpdate;
            }
        }        
    }
    
    private void setFirstResponseTimeOnLead(Map<Id,Task> oldTaskMap,List<Task> newTaskList) {
        System.debug('In');
        Map<Id,Task> leadIdVsEventMap = new Map<Id,Task>();
        for(Task t : newTaskList) {
            if(t.Subject != null && 
               t.WhoId != null &&
               (t.Subject.contains('Outbound answered call') || t.Subject.contains('Outbound unanswered call')) &&
               t.CallType == 'Outbound'
              ){
                   String whoId = t.WhoId;
                   if(whoId.startsWith('00Q')) leadIdVsEventMap.put(t.WhoId,t);
               }
        }
        
        if(!leadIdVsEventMap.isEmpty()){
            SYstem.debug('leadIdVsEventMap: '+leadIdVsEventMap);
            List<Lead> leadListToUpdate = [SELECT Id 
                                           FROM Lead 
                                           WHERE Id IN :leadIdVsEventMap.keySet()
                                           AND LeadSource = 'Inbound'
                                           AND First_Response_Time__c = null];
            for(Lead l : leadListToUpdate){
                l.First_Response_Time__c = leadIdVsEventMap.get(l.Id).CreatedDate;
                l.OwnerId = leadIdVsEventMap.get(l.Id).OwnerId;
            }
            
            if(!leadListToUpdate.isEmpty()){
                update leadListToUpdate;
            }
        }        
    }
    // Created By: Cloudroute 26/09/2023
    public static void updateTaskCountIncreaseOnAccountProspect(List<Task> newTaskList) {
        Set<Id> taskIds = new Set<Id>();
        if(!newTaskList.isEmpty()){
            for(Task task : newTaskList){
                taskIds.add(task.WhatId);
            }
        }
       
		system.debug('Task Ids: '+newTaskList);
        if(!taskIds.isEmpty()){
            //List<Account_Prospect__c> accountProspectToUpdate = [SELECT Id, Task_Count__c,Call_Count__c FROM Account_Prospect__c WHERE Id IN :taskIds];
            Map<Id,Account_Prospect__c> accountProspectToUpdate = new Map<Id,Account_Prospect__c>([SELECT Id, Task_Count__c,Call_Count__c,Email_Count__c FROM Account_Prospect__c WHERE Id IN :taskIds]);
            List<Account_Prospect__c> accountProspectlist = new List<Account_Prospect__c>();
            for(Task task : newTaskList){
                if(accountProspectToUpdate.containskey(task.WhatId)){
                    Account_Prospect__c accountProspect = new Account_Prospect__c();
                    accountProspect.Id = task.WhatId;
                    system.debug('TaskSubType:' +task.TaskSubtype);
                    if(task.TaskSubtype == 'Email'){
                       accountProspect.Email_Count__c = accountProspectToUpdate.get(task.WhatId).Email_Count__c +1;
                    }else if(task.TaskSubtype == 'Call'){
                       accountProspect.Call_Count__c = accountProspectToUpdate.get(task.WhatId).Call_Count__c +1;
                    }else{
                        accountProspect.Task_Count__c = accountProspectToUpdate.get(task.WhatId).Task_Count__c +1;
                    }
                    accountProspectlist.add(accountProspect);
                }
            }
            if(!accountProspectlist.isEmpty()){
                update accountProspectlist;
            }
            
        }
    }
    // Created By: Cloudroute 26/09/2023  
    public static void updateTaskCountDecreaseOnAccountProspect(List<Task> oldTaskList) {
         Set<Id> taskIds = new Set<Id>();
         if(!oldTaskList.isEmpty()){
          	for(Task task : oldTaskList){
                taskIds.add(task.WhatId);
            }
        }
        system.debug('Task IDs: '+taskIds);
        if(!taskIds.isEmpty()){
            //List<Account_Prospect__c> accountProspectToUpdate = [SELECT Id, Task_Count__c,Call_Count__c FROM Account_Prospect__c WHERE Id IN :taskIds];
            Map<Id,Account_Prospect__c> accountProspectToUpdate = new Map<Id,Account_Prospect__c>([SELECT Id, Task_Count__c,Call_Count__c,Email_Count__c FROM Account_Prospect__c WHERE Id IN :taskIds]);
            List<Account_Prospect__c> accountProspectlist = new List<Account_Prospect__c>();
            for(Task task : oldTaskList){
                system.debug('Tasksubtype: '+task.TaskSubtype);
                if(accountProspectToUpdate.containskey(task.WhatId)){
                    Account_Prospect__c accountProspect = new Account_Prospect__c();
                    accountProspect.Id = task.WhatId;
                    system.debug('Tasksubtype: '+task.TaskSubtype);
                    if(task.TaskSubtype == 'Email'){
                        
                        if(accountProspectToUpdate.get(task.WhatId).Email_Count__c > 0){
                            accountProspect.Email_Count__c = accountProspectToUpdate.get(task.WhatId).Email_Count__c -1;
                        }
                     }else if(task.TaskSubtype == 'Call'){
                        if(accountProspectToUpdate.get(task.WhatId).Call_Count__c > 0){
                            accountProspect.Call_Count__c = accountProspectToUpdate.get(task.WhatId).Call_Count__c -1;
                        }
                        
                    }
                    else{
                        if(accountProspectToUpdate.get(task.WhatId).Task_Count__c > 0){
                            accountProspect.Task_Count__c = accountProspectToUpdate.get(task.WhatId).Task_Count__c -1;
                        }
                    }
                    accountProspectlist.add(accountProspect);
                }
            }
            if(!accountProspectlist.isEmpty()){
                update accountProspectlist;
            }
            
        }
        
    }
}