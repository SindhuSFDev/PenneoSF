public with sharing class UpdateCase4Hours{
	@InvocableMethod(Label = 
	'updateCase4Hours')
	public static void updateCase4Hours(List<Id> ids){
		try{
			List<Case> listOfCaseToUpdate = [SELECT Id, Status, Priority
			                                 FROM Case
			                                 WHERE Id IN :ids];
			for (Case caseObj : listOfCaseToUpdate){
				caseObj.After_4_Hours_Email__c = UtilityClass.getAddedBusinessHoursDateTime(System.now(), Integer.valueOf(Label.Send_Email_To_Owner_4_Hours));
			}
			if (listOfCaseToUpdate.size() > 0){
				update listOfCaseToUpdate;
			}
		} catch (Exception e){
			System.debug('#--Exception--#' + e.getMessage());
		}
	}
}