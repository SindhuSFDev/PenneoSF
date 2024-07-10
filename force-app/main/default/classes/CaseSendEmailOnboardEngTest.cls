@IsTest
private class CaseSendEmailOnboardEngTest {
    @TestSetup
    static void testSetup(){
        List<Case> listOfCases = TestDataFactory.createSampleCases();
    }
    
    @IsTest
    static void SendEmailToCustomerIfnoResponseFoundTest(){
        List<Case> listOfCases = [SELECT Id
                                  FROM Case];
        List<Id> listOfCaseId = new List<Id>();
        for (Case caseObj : listOfCases){
            listOfCaseId.add(caseObj.Id);
        }
        CaseSendEmailOnboardingEng.sendEmailAfter20Hours(listOfCaseId);
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(1, invocations);
    }
}