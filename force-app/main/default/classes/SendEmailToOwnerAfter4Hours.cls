public with sharing class SendEmailToOwnerAfter4Hours{
	@InvocableMethod(label = 
	'sendEmailToOwner')
	public static void sendEmailToOwner(List<Id> ids){
		List<Case> caseList = new List<Case>();
		try{
			Set<String> setOfOwnerId = new Set<String>();
			List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
			caseList = [SELECT Id, OwnerId, Contact.Email, Country__c, Owner.Email
			            FROM Case
			            WHERE Id IN :ids];
			OrgWideEmailAddress noreplyAddress = [SELECT Id, Address
			                                      FROM OrgWideEmailAddress 
			                                      WHERE Address = :Label.No_Reply_Address];
			Map<String, List<String>> mapOfOwnerIdVsListOfCaseId = new Map<String, List<String>>();
			for (Case caseTemp : caseList){
				String ownerId = caseTemp.OwnerId;
				if (ownerId.startsWith('005')){
					//owner is user
					String whoId = caseTemp.OwnerId;
					String templateId = Label.Urgent_Case_Last_Update_Since_4_Hours;
					String whatId = caseTemp.Id;
					Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, whoId, whatId);
					//email.setTemplateId(Label.Urgent_Case_Last_Update_Since_4_Hours);
					//email.setTargetObjectId(caseTemp.OwnerId);
					email.setSaveAsActivity(false);
					email.setOrgWideEmailAddressId(noreplyAddress.Id);
					//email.setWhatId(caseTemp.Id);
					sendEmailList.add(email);
				} else if (ownerId.startsWith('00G')){
					//owner is queue
					setOfOwnerId.add(caseTemp.OwnerId);
					if (mapOfOwnerIdVsListOfCaseId.containsKey(caseTemp.OwnerId)){
						mapOfOwnerIdVsListOfCaseId.get(caseTemp.OwnerId).add(caseTemp.Id);
					} else{
						mapOfOwnerIdVsListOfCaseId.put(caseTemp.OwnerId, new List<String>{caseTemp.Id});
					}
				}
			}
			if (setOfOwnerId.size() > 0){
				Set<Id> setOfUserId = new Set<Id>();
				Map<String, Set<String>> mapOfGroupIdVsMemberId = new Map<String, Set<String>>();
				List<GroupMember> listOfGroupMembers = [SELECT UserOrGroupId, GroupId
				                                        From GroupMember
				                                        WHERE GroupId IN :setOfOwnerId];
				for (GroupMember groupMem : listOfGroupMembers){
					String groupMemId = groupMem.UserOrGroupId;
					if (groupMemId.startsWith('005')){
						setOfUserId.add(groupMem.UserOrGroupId);
					}
					if (mapOfGroupIdVsMemberId.containsKey(groupMem.GroupId)){
						mapOfGroupIdVsMemberId.get(groupMem.GroupId).add(groupMem.UserOrGroupId);
					} else{
						mapOfGroupIdVsMemberId.put(groupMem.GroupId, new Set<String>{groupMem.UserOrGroupId});
					}
				}
				List<User> listOfUsers = [SELECT Id, Email
				                          FROM User
				                          WHERE Id IN :setOfUserId];
				System.debug('#--listOfUsers--#' + listOfUsers);
				for (Case caseObj : caseList){
					if (mapOfGroupIdVsMemberId.containsKey(caseObj.OwnerId)){
						for (String userId : mapOfGroupIdVsMemberId.get(caseObj.OwnerId)){
							String whoId = userId;
							String templateId = Label.Urgent_Case_Last_Update_Since_4_Hours;
							String whatId = caseObj.Id;
							Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, whoId, whatId);
							//email.setTemplateId(Label.Urgent_Case_Last_Update_Since_4_Hours);
							//email.setTargetObjectId(caseTemp.OwnerId);
							email.setSaveAsActivity(false);
							email.setOrgWideEmailAddressId(noreplyAddress.Id);
							//email.setWhatId(caseTemp.Id);
							sendEmailList.add(email);
						}

					}
				}
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