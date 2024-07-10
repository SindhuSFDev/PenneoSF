public with sharing class UpdateCaseForResponseEmail{
	@InvocableMethod
	public static void updateBuisnessHoursToSendEmail(List<Id> listOfCaseId){
		 Set<String> setOfCaseStatus = setOfCaseStatus(); 
		Set<String> setOfTag = setOfTag();
		List<Case> listOfCases = [SELECT Id, Status
		                          FROM Case
		                          WHERE Id IN :listOfCaseId AND Tag__c NOT IN :setOfTag AND (Status = :Label.Case_Picklist_Pending OR Status =:Label.Case_Picklist_New_Case OR Status ='Contacted')];
		for (Case caseObj : listOfCases){
			System.debug('#--case status--#' + caseObj.Status);
			caseObj.After_10_hours_Email_Date__c = UtilityClass.getAddedBusinessHoursDateTime(System.now(), Integer.valueOf(Label.Auto_Response_1));
			caseObj.After_20_hours_Email_Date__c = UtilityClass.getAddedBusinessHoursDateTime(System.now(), Integer.valueOf(Label.Auto_Response_2_In_hour));
			caseObj.After_30_hours_Email_Date__c = UtilityClass.getAddedBusinessHoursDateTime(System.now(), Integer.valueOf(Label.Auto_Response_3_In_hour));
		}
		System.debug('#--listOfCases-#' + listOfCases);
		update listOfCases;
	}

	 
    public static Set<String> setOfCaseStatus(){
	 Set<String> setOfString = new Set<String>();
	 setOfString.add(Label.Case_Picklist_New_Case);
	 //setOfString.add(Label.Case_Picklist_Contacted);
	 setOfString.add(Label.Case_Picklist_Pending);
	 return setOfString;
	 } 
	public static Set<String> setOfTag(){
		Set<String> setOfString = new Set<String>();
		setOfString.add(Label.Case_Tag_Dansk);
		setOfString.add(Label.Case_Tag_Eng);
		return setOfString;
	}
}