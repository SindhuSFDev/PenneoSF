public class UpdateNewCaseReponseTimes {
    @InvocableMethod
    public static void updateNewResponseTimes(List<Id> listOfCaseId){
        Case caseObj = new Case();
        //caseObj.Count_8_Business_Hours__c = UtilityClass.getAddedBusinessHoursDateTime(System.now(), 9);
        //caseObj.Count_16_Business_Hours__c = UtilityClass.getAddedBusinessHoursDateTime(System.now(), 18);
        //caseObj.Count_32_Business_Hours__c = UtilityClass.getAddedBusinessHoursDateTime(System.now(), 36);
        //caseObj.Count_48_Business_Hours__c = UtilityClass.getAddedBusinessHoursDateTime(System.now(), 54);
        caseObj.Id = listOfCaseId[0];
        
        System.debug('#--Case-#' + caseObj);
        update caseObj;
    }
}