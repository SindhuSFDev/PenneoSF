public class SendEmailToSalesManager {

    @future(callout=true)
    public static void sendEmail(Map<Id,Id> opportunityQuoteId){
        system.debug('#---quoteId-#'+opportunityQuoteId);
        List<Quote> quoteList = [Select id, Name,OpportunityId from Quote where id in:opportunityQuoteId.values()];
        List<user> userList = [Select id,Email,Name from User where Profile.Name = 'Sales Manager'];//Profile.Name = 'Sales Manager'];
        List<EmailTemplate> templateList = [Select id,body,subject,htmlValue from emailTemplate where id=:  label.SaleManagerEmailTemplateId];
        system.debug('#---userList-#'+userList);
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        for(Id opportunityId : opportunityQuoteId.keyset()){
            Blob pdfData;
            if(!test.isRunningTest()){
            pdfData = new PageReference('/apex/OrderConfirmationPDF?id='+opportunityQuoteId.get(opportunityId)).getContent();
            }
            else{
              pdfData = Blob.valueOf('This is test blob') ; 
            }
            system.debug('#---pdfData-#'+pdfData);
            for(User user: userList){
                String emailBody = templateList[0].htmlValue.replace('{user_name}',user.Name);
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                attach.setFileName(quote.Name+'.pdf');
                attach.setInline(false);
                attach.Body = pdfData;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //Apex Single email message
				//mail.setTemplateId(label.SaleManagerEmailTemplateId);
                //mail.setTargetObjectId(user.Id);
                mail.setSaveAsActivity(false);
                mail.setHtmlBody(emailBody);
                mail.setSubject(templateList[0].subject);
                mail.setWhatId(opportunityId);
                mail.setTreatBodiesAsTemplate(true);
                mail.setToAddresses(new List<string>{user.Email});
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });//Set File Attachmemail
                mailList.add(mail);
            }
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setFileName(quote.Name+'.pdf');
            attach.setInline(false);
            attach.Body = pdfData;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //Apex Single email message
            //mail.setTemplateId(label.SaleManagerEmailTemplateId);
            //mail.setTargetObjectId(UserInfo.getUserId());
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setSaveAsActivity(false);
            String emailBody = templateList[0].htmlValue.replace('{user_name}','');
            mail.setHtmlBody(emailBody);
            mail.setSubject(templateList[0].subject);
            mail.setTreatBodiesAsTemplate(true);
            mail.setToAddresses(new List<string>{label.EmailAddressForClosedWonOppor});//
            mail.setWhatId(opportunityId);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });//Set File Attachmemail
            mailList.add(mail);
			            
        }
        system.debug('#---mailList-#'+mailList);
        if(!mailList.isEmpty()){
            Messaging.sendEmail(mailList);//Send Email
            }

    }
}