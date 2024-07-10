/*
 Created on 19-11-2020

 */
public with sharing class CaseSendEmailOnboardingDansk{
	@InvocableMethod(label = 
	'sendEmailAfter20Hours')
	public static void sendEmailAfter20Hours(List<Id> ids){
		try{
			List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
			List<Case> caseList = [SELECT Id, ContactId, Contact.Email, Country__c
			                       FROM Case
			                       WHERE Id IN :ids];
			OrgWideEmailAddress supportAddress = [SELECT Id, Address
			                                      FROM OrgWideEmailAddress 
			                                      WHERE Address = :Label.Support_Address];
			for (Case caseTemp : caseList){
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				email.setTemplateId(Label.Onboarding_Dansk_After_20_Hours);
				email.setTargetObjectId(caseTemp.contactId);
                email.setWhatId(caseTemp.Id);
				email.setOrgWideEmailAddressId(supportAddress.Id);
				sendEmailList.add(email);
			}
			if (!sendEmailList.isEmpty()){
				List<Messaging.SendEmailResult> results = Messaging.sendEmail(sendEmailList);
				System.debug('#--results--#' + results);
				for (Messaging.SendEmailResult result : results){
					if (!result.isSuccess()){
						System.debug('#--error--# ' + result);
					}
				}
			}
		} catch (Exception e){
			System.debug('#--Exception--#' + e.getMessage());
		}
	}
}