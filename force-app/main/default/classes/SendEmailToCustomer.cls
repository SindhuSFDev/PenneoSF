global class SendEmailToCustomer{
	@InvocableMethod(label = 
	'SendEmailToCustomerIfnoResponse')
	global static void SendEmailToCustomerIfnoResponseFound(List<Id> ids){
		try{
			List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
			List<Case> caseList = [Select id, contactId, contact.Email, Country__c
			                       from Case
			                       where id in :ids];
			OrgWideEmailAddress supportAddress = [SELECT Id, Address
			                                      FROM OrgWideEmailAddress 
			                                      WHERE Address = :Label.Support_Address];
			for (Case caseTemp : caseList){
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				if (caseTemp.Country__c == 'Denmark'){
					email.setTemplateId(Label.Auto_Response_Email_after_20_hour_Template_Id_Danish);
				} else{
					email.setTemplateId(label.Auto_Response_Email_after_1_hour_Template_Id);
				}
				email.setTargetObjectId(caseTemp.contactId);
				email.setWhatId(caseTemp.Id);
				email.setOrgWideEmailAddressId(supportAddress.Id);
				sendEmailList.add(email);

			}
			if (!sendEmailList.isEmpty()){
				List<Messaging.SendEmailResult> results = Messaging.sendEmail(sendEmailList);
				for (Messaging.SendEmailResult result : results){
					if (!result.isSuccess()){
						System.debug('result ' + result);
					}
				}
			}
		} catch (Exception e){
			system.debug('#----#' + e.getStackTraceString()+'23' + e.getMessage());
		}
	}
}