@IsTest
private class UpdateCasePendingHoursTest {
    @TestSetup
    static void testSetup(){
        List<Case> listOfCases = TestDataFactory.createSampleCases();
    }
    
    @IsTest
    static void updateCasePendingHoursTest(){
        List<Case> listOfCases = [SELECT Id FROM Case];
        List<Id> listOfCaseId = new List<Id>();
        for (Case caseObj : listOfCases) {
            listOfCaseId.add(caseObj.Id);
        }
        UpdateCasePendingHours.updateCasePendingHours(listOfCaseId);
        System.assertEquals(5, [SELECT count() FROM Case WHERE After_20_Hours_Pending__c != null]);
    }
}