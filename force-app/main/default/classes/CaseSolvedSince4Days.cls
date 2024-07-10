public with sharing class CaseSolvedSince4Days{
	@InvocableMethod(Label = 
	'updateCaseSolvedSince4Days')
	public static void updateCaseSolvedSince4Days(List<Id> ids){
		try{
			List<Case> listOfCaseToUpdate = [SELECT Id, Status
			                                 FROM Case
			                                 WHERE Id IN :ids];
			for (Case caseObj : listOfCaseToUpdate){
				caseObj.Solved_Since_4_Days__c = UtilityClass.getAddedBusinessHoursDateTime(System.now(), Integer.valueOf(Label.Case_Solved_Since_4_Days));
			}
			if (listOfCaseToUpdate.size() > 0){
				update listOfCaseToUpdate;
			}
		} catch (Exception e){
			System.debug('#--Exception--#' + e.getMessage());
		}
	}
}