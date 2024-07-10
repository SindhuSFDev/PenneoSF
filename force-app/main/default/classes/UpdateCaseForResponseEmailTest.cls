@IsTest
private class UpdateCaseForResponseEmailTest {

    @TestSetup
    static void testSetup(){
        List<Case> listOfCases = TestDataFactory.createSampleCases();
    }
    
    @IsTest
    static void updateBuisnessHoursToSendEmailTest(){
        List<Case> listOfCases = [SELECT Id FROM Case];
        List<Id> listOfCaseId = new List<Id>();
        for (Case caseObj : listOfCases) {
            listOfCaseId.add(caseObj.Id);
        }
        UpdateCaseForResponseEmail.updateBuisnessHoursToSendEmail(listOfCaseId);
        //System.assertEquals(3, [SELECT count() FROM Case WHERE After_20_hours_Email_Date__c != null]);
    }
    
    @isTest
    static void updateNewCaseResponseTimes(){
        List<Case> listOfCases = [SELECT Id FROM Case];
        List<Id> listOfCaseId = new List<Id>();
        for (Case caseObj : listOfCases) {
            listOfCaseId.add(caseObj.Id);
        }
        UpdateNewCaseReponseTimes.updateNewResponseTimes(listOfCaseId);
        //System.assertEquals(3, [SELECT count() FROM Case WHERE After_20_hours_Email_Date__c != null]);
    }
}