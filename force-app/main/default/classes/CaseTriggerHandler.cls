public class CaseTriggerHandler implements ITriggerHandler {
    public static void BeforeInsert(List<SObject> triggerNew) {
        //call before insert actions
    }
    
    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap) {
        Map<Id, Case> newMapCase = (Map<Id, Case>) newMap;
        Map<Id, Case> oldMapCase = (Map<Id, Case>) oldMap;
        if (!newMap.isEmpty()) {
            updateBusinessHours(newMapCase, oldMapCase);
            checkIfReceivedOnHoliday((Map<Id, Case>) newMap, (Map<Id, Case>) oldMap);
        }
    }
    
    public static void BeforeDelete(Map<Id, Sobject> oldMap) {
        //call before delete actions
    }
    
    public static void AfterInsert(Map<Id, SObject> newMap) {
        //call onAfterInsert delete actions
        //createPenneoSignContact((Map<Id, Case>) newMap);
        updateChildDetailsFromParent((Map<Id, Case>) newMap, null);
    }
    
    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap) {
        //call onAfterUpdate update actions
        // to send an email to user when Case is received on holidays
        //checkIfReceivedOnHoliday((Map<Id, Case>)newMap, (Map<Id, Case>)oldMap);
        
        //Update Status on Child Cases
        updateRelatedCaseStatus((Map<Id, Case>) newMap, (Map<Id, Case>) oldMap);
        updateChildDetailsFromParent((Map<Id, Case>) newMap, (Map<Id, Case>) oldMap);
    }
    
    public static void AfterDelete(Map<Id, Sobject> oldMap) {
        //call onAfterDelete update actions
    }
    
    public static void AfterUnDelete(Map<Id, Sobject> newMap) {
        //call after onAfterUnDelete actions
    }
    
    public Boolean IsDisabled() {
        return false;
    }
    
    public static void updateBusinessHours(Map<Id, Case> newMapCase, Map<Id, Case> oldMapCase) {
        if (!newMapCase.isEmpty()) {
            for (Id caseObj : newMapCase.keySet()) {
                if (newMapCase.get(caseObj).Contacted_Date_Time__c != null && newMapCase.get(caseObj).Contacted_Date_Time__c != oldMapCase.get(caseObj).Contacted_Date_Time__c) {
                    Decimal businessHrs = UtilityClass.calculateBusinessHours(newMapCase.get(caseObj).CreatedDate, newMapCase.get(caseObj).Contacted_Date_Time__c);
                    newMapCase.get(caseObj).Business_Hours__c = businessHrs;
                }
            }
        }
    }
    
    public static void checkIfReceivedOnHoliday(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap) {
        //Get BusinessHours
        BusinessHours defaultBH = [
            SELECT Id
            FROM BusinessHours
            WHERE IsActive = true AND Name = 'Copenhague Business Hours'
            Limit 1
        ];
        Group grp = [
            SELECT Id
            FROM Group
            WHERE Name = 'Case From Community' and Type = 'Queue'
        ];
        Holiday_Send_Email__c holidaySendEmail = Holiday_Send_Email__c.getOrgDefaults();
        Set<Id> setOfCaseId = new Set<Id>();
        for (Case caseObj : newCaseMap.values()) {
            //if (holidaySendEmail.Send_Email_on_Holiday__c && caseObj.Origin == 'Web' && caseObj.OwnerId == grp.Id && caseObj.ContactId != null && caseObj.ContactId != oldCaseMap.get(caseObj.Id).ContactId && !BusinessHours.isWithin(defaultBH.id, caseObj.CreatedDate)){
            if (!BusinessHours.isWithin(defaultBH.id, caseObj.CreatedDate) && caseObj.Non_Business_Hours_Creation_Time__c == null) {
                //setOfCaseId.add(caseObj.Id);
                caseObj.Non_Business_Hours_Creation_Time__c = caseObj.CreatedDate;
            }
        }
        //sendEmailIfReceivedOnHoliday(setOfCaseId);
    }
    
    public static void sendEmailIfReceivedOnHoliday(Set<Id> setOfCaseId) {
        List<Case> listOfCases = [
            SELECT Id, ContactId, Country__c, Contact.Email, SuppliedEmail
            FROM Case
            WHERE Id IN :setOfCaseId
        ];
        List<EmailTemplate> emailTemplates = [
            SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
            FROM EmailTemplate
            WHERE Name = 'Case Submitted On Holiday(Denmark)' OR Name = 'Case Submitted On Holiday(Not Denmark)'
            ORDER BY Name
        ];
        OrgWideEmailAddress noreplyAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = :Label.No_Reply_Address];
        List<String> listDenMark = new List<String>();
        List<String> listNotDenMark = new List<String>();
        List<Messaging.SingleEmailMessage> listOfDenmarkMail = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> listOfNotDenmarkMail = new List<Messaging.SingleEmailMessage>();
        for (Case caseObj : listOfCases) {
            if (caseObj.Country__c == 'Denmark') {
                listDenMark.add(caseObj.SuppliedEmail);
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(caseObj.ContactId);
                message.setTemplateID(emailTemplates[0].Id);
                message.setWhatId(caseObj.Id);
                message.toAddresses = listDenMark;
                message.setOrgWideEmailAddressId(noreplyAddress.Id);
                listOfDenmarkMail.add(message);
            } else {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                listNotDenMark.add(caseObj.SuppliedEmail);
                message.setTargetObjectId(caseObj.ContactId);
                message.setTemplateID(emailTemplates[1].Id);
                message.setWhatId(caseObj.Id);
                message.toAddresses = listNotDenMark;
                message.setOrgWideEmailAddressId(noreplyAddress.Id);
                listOfNotDenmarkMail.add(message);
            }
        }
        if (listOfDenmarkMail.size() > 0) {
            Messaging.sendEmail(listOfDenmarkMail, false);
        }
        if (listOfNotDenmarkMail.size() > 0) {
            Messaging.sendEmail(listOfNotDenmarkMail, false);
        }
    }
    
    public static void updateRelatedCaseStatus(Map<Id, Case> newMap, Map<Id, Case> oldMap) {
        List<Case> caseToUpdate = new List<Case>();
        List<Case> caseList = [SELECT Id, Status, Type, (SELECT Id, Status FROM Cases) FROM Case WHERE Id IN :newMap.values()];
        for (Case c : caseList) {
            if (c.Status != oldMap.get(c.id).Status && c.Type == 'Incident' && c.Status == 'Solved') {
                for (Case child : c.Cases) {
                    child.Status = 'Solved';
                    caseToUpdate.add(child);
                }
            }
        }
        if (!caseToUpdate.isEmpty()) {
            update caseToUpdate;
        }
    }    
    
    //Developer Name: Cloudroute Solutions
    //Description: This is method will update details on child case from parent case
    private static void updateChildDetailsFromParent(Map<Id, Case> newMap, Map<Id, Case> oldMap) {
        List<Case> casesToUpdate = new List<Case>();
        Set<Id> childCasesIds = new Set<Id>();
        Set<Id> parentCasesIds = new Set<Id>();
        Map<Id, Case> mapOfIdVsParentCase = new Map<Id, Case>();
        
        for(Id caseId : newMap.KeySet()){
            if(oldMap != null){
            if(newMap.get(caseId).ParentId != oldMap.get(caseId).ParentId 
               && newMap.get(caseId).ParentId != null){
                   parentCasesIds.add(newMap.get(caseId).ParentId);
                   childCasesIds.add(caseId);
               }
            }else{
                if(newMap.get(caseId).ParentId != null){
                   parentCasesIds.add(newMap.get(caseId).ParentId);
                   childCasesIds.add(caseId);
               }
            }
        }
        
        List<Case> parentCases = [SELECT Id, Type, Category__c, Platform_Plugin__c, Priority 
                                  FROM Case WHERE Id IN :parentCasesIds];
        for(Case c : parentCases){
            mapOfIdVsParentCase.put(c.Id, c);
        }
        
        for(Id caseId : childCasesIds){
            if(mapOfIdVsParentCase.get(newMap.get(caseId).ParentId).Type == 'Incident'){
                Case updateCase = new Case();
                updateCase.Type = mapOfIdVsParentCase.get(newMap.get(caseId).ParentId).Type;
                updateCase.Category__c = mapOfIdVsParentCase.get(newMap.get(caseId).ParentId).Category__c;
                updateCase.Platform_Plugin__c = mapOfIdVsParentCase.get(newMap.get(caseId).ParentId).Platform_Plugin__c;
                updateCase.Priority = mapOfIdVsParentCase.get(newMap.get(caseId).ParentId).Priority;
                updateCase.Id = caseId;
                casesToUpdate.add(updateCase);
            }
        }
        
        if(!casesToUpdate.isEmpty()){
            update casesToUpdate;
        }
    }
}