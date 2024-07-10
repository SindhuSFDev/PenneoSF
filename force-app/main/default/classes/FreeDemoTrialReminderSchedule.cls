global class FreeDemoTrialReminderSchedule {
    
    @InvocableMethod(label='FreeDemoTrialReminderEmail')
    global static void sendEmailLead(List<LeadCreationAction> leadCreationActionList) {
        try{
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
        for(LeadCreationAction leadCreationAction : leadCreationActionList){
            String objectName = String.valueOf(leadCreationAction.objectId.getsobjecttype());
            if(objectName =='Lead' || objectName=='Contact'){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(objectName == 'Lead' ? label.Free_Demo_Trial_Reminder_Email_Lead : label.Free_Demo_Trial_Reminder_Email_Contact);
                email.setTargetObjectId(leadCreationAction.objectId);
                sendEmailList.add(email);
            }
        }
        if(!sendEmailList.isEmpty()){
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(sendEmailList);
        }
        }catch(Exception e){
            system.debug('#----#'+e.getStackTraceString()+'23'+e.getMessage());
        }
    }
}