global class SendLightiningEmailTemplateLead {
    
    @InvocableMethod(label='Schedule_Emails_for_no_contact_leads')
    global static void sendEmailLead(List<LeadCreationAction> leadCreationActionList) {
        
        try{
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
        for(LeadCreationAction leadCreationAction : leadCreationActionList){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(leadCreationAction.templateId);
            email.setTargetObjectId(leadCreationAction.objectId);
            sendEmailList.add(email);
        }
        
        if(!sendEmailList.isEmpty()){
            system.debug('#---sendEmailList---#'+sendEmailList);
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(sendEmailList);
            system.debug('#--results--#'+results);
        }
        }
        catch(Exception e){
            system.debug('#---#'+e.getMessage()+'---'+e.getMessage());
        }
    }
}