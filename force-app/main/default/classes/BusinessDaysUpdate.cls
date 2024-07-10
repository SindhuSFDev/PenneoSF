global class BusinessDaysUpdate {
    
    @InvocableMethod(label='ExpirationDateUpdate')
    global static void businessDaysUpdateOutbound(List<LeadCreationAction> leadCreationActionList) {
        Id objectId = leadCreationActionList[0].objectId;
        String objectName = String.valueOf(objectId.getsobjecttype());
        if(objectName == 'Lead' || objectName == 'Contact'){
            String query = 'SELECT Id FROM ';
            query += objectName == 'Lead' ? 'Lead ': 'Contact ';
            query += 'WHERE Id = :objectId';
            List<SObject> sObjectList = Database.query(query);
            if(!sObjectList.isEmpty()){
                leadCreationActionList[0].templateId = objectName == 'Lead' ? label.WelcomeEmail : label.WelcomeEmailContact; 
                SendLightiningEmailTemplateLead.sendEmailLead(leadCreationActionList);
                createFollowUpTask(leadCreationActionList[0]);
                Date dateTemp = system.today();
                Integer expirationDays = leadCreationActionList[0].noOfExpirationdays != null ?Integer.valueOf(leadCreationActionList[0].noOfExpirationdays) : 3;
                Datetime dueDate = BusinessDays.add(dateTemp, expirationDays);
                Event event1 = [Select id,Event_Expiration_Date__c from Event where id=:leadCreationActionList[0].eventId ];
                System.debug('#--event--#'+event1.Event_Expiration_Date__c);
                Event event = new Event();
                event.Id = leadCreationActionList[0].eventId;
                event.Event_Expiration_Date__c = dueDate;
                update event;
                Event event2 = [Select id,Event_Expiration_Date__c from Event where id=:leadCreationActionList[0].eventId ];
                System.debug('#--event--#'+event2.Event_Expiration_Date__c);
            }
        }
    }
    
    private static void createFollowUpTask(LeadCreationAction leadCreationActionList){
        Task task = new Task();
        DateTime dT = leadCreationActionList.eventEndDate;
        task.ActivityDate = date.newinstance(dT.year(), dT.month(), dT.day());
        task.OwnerId = leadCreationActionList.OwnerId;
        task.Priority = 'Normal';
        task.status = 'Started';
        task.Subject = 'Follow Up Task';
        task.WhoId = leadCreationActionList.objectId;
        if(leadCreationActionList.eventRelatedToId != ''){
            task.WhatId = leadCreationActionList.eventRelatedToId;
        }
        insert task;
    }
}