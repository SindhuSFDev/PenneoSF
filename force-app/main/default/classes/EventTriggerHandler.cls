public without sharing class EventTriggerHandler implements ITriggerHandler {
    
    
    //This method will handle before insert method
    public void beforeInsert(List<SObject> newItems) {
    }
    
    //This method will handle before update event
    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        validateOnEventDateChange((Map<Id,Event>) oldMap, (List<Event>) newMap.values());
    }
    
    //This method handles after insert event
    public void afterInsert(Map<Id, SObject> newMap) {
        // updateOpportunityStageToNegotiation(null, (List<Event>) newMap.values());
        updateLeadStatusToQualifying(null, (List<Event>) newMap.values());
        updateEventCountOnOpportunity(null, (List<Event>) newMap.values());
        updateEventIncreaseCountOnAccountProspect((List<Event>) newMap.values());
        
        
        //recordIdToEventCount = new Map<Id, Integer>();
        
        // Collect the parent record IDs (e.g., Contact or Account IDs) associated with the events
        
    }
    
    //This method handles after update event
    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        updateEventCountOnOpportunity((Map<Id,Event>) oldMap, (List<Event>) newMap.values());
        
    }
    
    //This will handle before delete event
    public void beforeDelete(Map<Id, SObject> oldMap) {
        
    }
    
    //This method handles after delete event
    public void afterDelete(Map<Id, SObject> oldMap) {
        updateEventDecreaseCountOnAccountProspect((List<Event>) oldMap.values());
    }
    
    
    //This method handles after undelete event
    public void afterUndelete(Map<Id, SObject> newMap) {
    }
    
    public Boolean IsDisabled() {
        //Check if Triggers are enabled
        return false;
    }
    
    /*******************************************************************************
* @author       KG
* @date         August 2020
* @description  Method to Update Opportunity Stage to Negotiation When an Event
* 			   is created by Sales Rep of On-Line/On-Site Meeting Type & with
* 			   Successfully Completed status
*******************************************************************************/
    //Commenting this code because the requirement has changed now it is not needed
    /*public static void updateOpportunityStageToNegotiation(Map<Id,Event> oldEventMap,List<Event> newEventList) {
//Set of Id to store all Opportunity Ids
Map<Id,Event> opportunityEventMap = new Map<Id,Event>();

//Iterate over all Events which are being updated
for(Event eventrecord : newEventList) {
//Check if an Event is created by Sales Rep of On-Line/On-Site Meeting Type & with Successfully Completed status
if((oldEventMap == null || 
(oldEventMap != null && oldEventMap.get(eventrecord.Id).Status__c != eventrecord.Status__c)) && 
eventrecord.WhatId != null &&
eventrecord.Type == 'On-Line/On-Site Meeting' &&
eventrecord.Status__c == 'Successfully Completed'
) {
opportunityEventMap.put(eventrecord.WhatId,eventrecord);
}
}

if(!opportunityEventMap.isEmpty()) {
List<Opportunity> opportunityList = [SELECT Id, LeadSource, Bill_to_Customer__c,
Type, Account.VAT_Number__c,
Account.Phone, Account.BillingAddress, Account.Industry
FROM Opportunity 
WHERE Id IN :opportunityEventMap.keySet() AND StageName = 'Discovering'];

if(!opportunityList.isEmpty()) {
List<Opportunity> opportunityListToUpdate = new List<Opportunity>();
for(Opportunity opportunityrecord : opportunityList) {
if(opportunityrecord.LeadSource != null &&
opportunityrecord.Bill_to_Customer__c != null &&
opportunityrecord.Type != null &&
opportunityrecord.Account.VAT_Number__c != null &&
opportunityrecord.Account.Phone != null &&
opportunityrecord.Account.BillingAddress != null &&
opportunityrecord.Account.Industry != null) {
Opportunity opp = new Opportunity();
opp.Id = opportunityrecord.Id;
opp.StageName = 'Negotiation';
opportunityListToUpdate.add(opp);
}else {
opportunityEventMap.get(opportunityrecord.Id)
.addError('Required Fields Missing on Opportunity & Account: Lead Source, Type, End User, VAT Number, Phone, Billing Address, Industry');
}
}
if(!opportunityListToUpdate.isEmpty()) {
//Update the OpportunityList
update opportunityListToUpdate;
}       
}
}
}*/
    
    private void updateLeadStatusToQualifying(Map<Id,Event> oldEventMap,List<Event> newEventList) {
        System.debug('In');
        Set<Id> leadIdSet = new Set<Id>();
        for(Event e : newEventList) {
            if(e.WhoId != null &&
               e.Type == 'Qualification M'
              ){
                  String whoId = e.WhoId;
                  if(whoId.startsWith('00Q')) leadIdSet.add(e.WhoId);
              }
        }
        
        if(!leadIdSet.isEmpty()){
            SYstem.debug('leadIdSet: '+leadIdSet);
            List<Lead> leadListToUpdate = [SELECT Id 
                                           FROM Lead 
                                           WHERE Id IN :leadIdSet 
                                           AND Phone_Contact__c = false
                                           AND LeadSource = 'Inbound'
                                           AND Status = 'Creation'];
            for(Lead l : leadListToUpdate){
                l.Status = 'Qualifying';
            }
            
            if(!leadListToUpdate.isEmpty()){
                update leadListToUpdate;
            }
        }   
    }
    
    private void validateOnEventDateChange(Map<Id,Event> oldEventMap,List<Event> newEventList) {
        for(Event e : newEventList) {
            if(oldEventMap != null && (
                e.StartDateTime != oldEventMap.get(e.Id).StartDateTime ||
                e.EndDateTime != oldEventMap.get(e.Id).EndDateTime)) {
                    e.addError('You Cannot Update Event Start or End Date');
                }
        }
    }
    
    public static void updateEventCountOnOpportunity(Map<Id,Event> oldEventMap,List<Event> newEventList) {
        //Set of Id to store all Opportunity Ids
        Map<Id,Event> opportunityEventMap = new Map<Id,Event>();
        
        //Iterate over all Events which are being updated
        for(Event eventrecord : newEventList) {
            //Check if an Event is created by Sales Rep of On-Line/On-Site Meeting Type & with Successfully Completed status
            if((oldEventMap != null && oldEventMap.get(eventrecord.Id).Status__c != eventrecord.Status__c) && 
               eventrecord.WhatId != null &&
               (eventrecord.Type == 'Q & A' || eventrecord.Type == 'Quote') &&
               eventrecord.Status__c == 'Successfully Completed'
              ) {
                  opportunityEventMap.put(eventrecord.WhatId,eventrecord);
              }else if(eventrecord.WhatId != null &&
                       (eventrecord.Type == 'Q & A' || eventrecord.Type == 'Quote' || eventrecord.Type == 'On-Line/On-Site Meeting') &&
                       eventrecord.Status__c == 'Successfully Completed'
                      ){
                          opportunityEventMap.put(eventrecord.WhatId,eventrecord);
                      }
        }
        
        if(!opportunityEventMap.isEmpty()) {
            List<Opportunity> opportunityList = [SELECT Id, Type, Quote_Meetings_Held__c, QA_Meetings_Held__c, Online_onsite_Meetings_Held__c
                                                 FROM Opportunity 
                                                 WHERE Id IN :opportunityEventMap.keySet()];
            
            if(!opportunityList.isEmpty()) {
                List<Opportunity> opportunityListToUpdate = new List<Opportunity>();
                for(Opportunity opportunityrecord : opportunityList) {
                    Opportunity opp = new Opportunity();
                    opp.Id = opportunityrecord.Id;
                    if(opportunityEventMap.containsKey(opportunityrecord.Id)){
                        String typeEve = opportunityEventMap.get(opportunityrecord.Id).Type;
                        if(typeEve == 'Q & A'){
                            opp.QA_Meetings_Held__c = opportunityrecord.QA_Meetings_Held__c != null ? opportunityrecord.QA_Meetings_Held__c + 1: 1;
                        }
                        if(typeEve == 'Quote'){
                            opp.Quote_Meetings_Held__c = opportunityrecord.Quote_Meetings_Held__c != null ? opportunityrecord.Quote_Meetings_Held__c + 1: 1;
                        }
                        if(typeEve == 'On-Line/On-Site Meeting'){
                            opp.Online_onsite_Meetings_Held__c = opportunityrecord.Online_onsite_Meetings_Held__c != null ? opportunityrecord.Online_onsite_Meetings_Held__c + 1: 1;
                        }
                    }
                    opportunityListToUpdate.add(opp);
                }
                if(!opportunityListToUpdate.isEmpty()) {
                    //Update the OpportunityList
                    update opportunityListToUpdate;
                }       
            }
        }
    }
      //Created By: Cloudroute 26/09/2023
    public static void updateEventIncreaseCountOnAccountProspect(List<Event> newEventList) {
        Set<Id> eventIds = new Set<Id>();
        if(!newEventList.isEmpty()){
            for(Event event : newEventList){
                eventIds.add(event.WhatId);
            }
        }
        
        system.debug('Event Ids: '+newEventList);
        if(!eventIds.isEmpty()){
            
            Map<Id,Account_Prospect__c> accountProspectToUpdate = new Map<Id,Account_Prospect__c>([SELECT Id,Event_Count__c FROM Account_Prospect__c WHERE Id IN :eventIds]);
            List<Account_Prospect__c> accountProspectlist = new List<Account_Prospect__c>();
            for(Event event : newEventList){
                if(accountProspectToUpdate.containskey(event.WhatId)){
                    Account_Prospect__c accountProspect = new Account_Prospect__c();
                    accountProspect.Id = event.WhatId;
                    accountProspect.Event_Count__c = accountProspectToUpdate.get(event.WhatId).Event_Count__c +1;
                    accountProspectlist.add(accountProspect);
                }
            }
            if(!accountProspectlist.isEmpty()){
                update accountProspectlist;
            }
            
        }
        
    }
    //Created By: Cloudroute 26/09/2023
    public static void updateEventDecreaseCountOnAccountProspect(List<Event> oldEventList) {
        Set<Id> eventIds = new Set<Id>();
        if(!oldEventList.isEmpty()){
            for(Event event : oldEventList){
                eventIds.add(event.WhatId);
            }
        }
        system.debug('Event IDs: '+eventIds);
        if(!eventIds.isEmpty()){
            
            Map<Id,Account_Prospect__c> accountProspectToUpdate = new Map<Id,Account_Prospect__c>([SELECT Id,Event_Count__c FROM Account_Prospect__c WHERE Id IN :eventIds]);
            List<Account_Prospect__c> accountProspectlist = new List<Account_Prospect__c>();
            for(Event event : oldEventList){
                if(accountProspectToUpdate.containskey(event.WhatId)){
                    Account_Prospect__c accountProspect = new Account_Prospect__c();
                    accountProspect.Id = event.WhatId;
                    if(accountProspectToUpdate.get(event.WhatId).Event_Count__c > 0){
                        accountProspect.Event_Count__c = accountProspectToUpdate.get(event.WhatId).Event_Count__c -1;
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