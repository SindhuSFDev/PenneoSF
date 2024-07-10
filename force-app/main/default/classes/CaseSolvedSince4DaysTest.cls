@IsTest
private class CaseSolvedSince4DaysTest {
    @TestSetup
    static void testSetup(){
        List<Case> listOfCases = TestDataFactory.createSampleCases();
    }
    
    @IsTest
    static void updateCaseSolvedSince4DaysTest(){
        List<Case> listOfCases = [SELECT Id FROM Case];
        List<Id> listOfCaseId = new List<Id>();
        for (Case caseObj : listOfCases) {
            listOfCaseId.add(caseObj.Id);
        }
        CaseSolvedSince4Days.updateCaseSolvedSince4Days(listOfCaseId);
        //System.assertEquals(5, [SELECT count() FROM Case WHERE Solved_Since_4_Days__c != null]);
    }
}