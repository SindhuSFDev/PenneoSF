@IsTest
private class UpdateCase4HoursTest {
    
    @TestSetup
    static void testSetup(){
        List<Case> listOfCases = TestDataFactory.createSampleCases();
    }

    @IsTest
    static void updateCase4HoursTest(){
        List<Case> listOfCases = [SELECT Id FROM Case];
        List<Id> listOfCaseId = new List<Id>();
        for (Case caseObj : listOfCases) {
            listOfCaseId.add(caseObj.Id);
        }
        UpdateCase4Hours.updateCase4Hours(listOfCaseId);
        System.assertEquals(5, [SELECT count() FROM Case WHERE After_4_Hours_Email__c != null]);
    }
}