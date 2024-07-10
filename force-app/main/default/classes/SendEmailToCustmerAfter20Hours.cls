public with sharing class SendEmailToCustmerAfter20Hours{
	@InvocableMethod()
	public static void sendEmailToCustomerAfter20Hours(List<Id> listOfCaseId){
		try{
			List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
			List<Case> caseList = [SELECT Id, ContactId, Contact.Email, Country__c
			                       FROM Case
			                       WHERE Id IN :listOfCaseId];
			OrgWideEmailAddress supportAddress = [SELECT Id, Address
			                                      FROM OrgWideEmailAddress 
			                                      WHERE Address = :Label.Support_Address];
			for (Case caseTemp : caseList){
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				if (caseTemp.Country__c == 'Denmark'){
					email.setTemplateId(Label.Auto_Response_Email_after_20_hour_Template_Id_Danish);
				} else{
					email.setTemplateId(Label.Auto_Response_Email_after_20_hour_Template_Id);
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
						System.debug('#--result--#' + result);
					}
				}
			}
		} catch (Exception e){
			System.debug('#--Exception--#' + e.getMessage());
		}
	}
}