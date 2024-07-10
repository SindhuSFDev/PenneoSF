public with sharing class UpdateCasePendingHours{
	@InvocableMethod(Label = 
	'updateCasePendingHours')
	public static void updateCasePendingHours(List<Id> ids){
		try{
			List<Case> listOfCaseToUpdate = [SELECT Id, Status, Priority
			                                 FROM Case
			                                 WHERE Id IN :ids];
			for (Case caseObj : listOfCaseToUpdate){
				caseObj.After_20_Hours_Pending__c = UtilityClass.getAddedBusinessHoursDateTime(System.now(), Integer.valueOf(Label.Send_Email_After_20_Pending_Hours));
			}
			if (listOfCaseToUpdate.size() > 0){
				update listOfCaseToUpdate;
			}
		} catch (Exception e){
			System.debug('#--Exception--#' + e.getMessage());
		}
	}
}