@IsTest
private class SendEmailToOwnerAfter4HoursTest {
    @TestSetup
    static void testSetup(){
        List<Case> listOfCases = TestDataFactory.createSampleCases();
    }
    
    @IsTest
    static void sendEmailToOwnerTest(){
        List<Case> listOfCases = [SELECT Id FROM Case];
        List<Id> listOfCaseId = new List<Id>();
        for (Case caseObj : listOfCases) {
            listOfCaseId.add(caseObj.Id);
        }
        SendEmailToOwnerAfter4Hours.sendEmailToOwner(listOfCaseId);
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(1, invocations);
    }
    
    @IsTest
    static void sendEmailToOwnerQueueTest(){
        Group grp = [SELECT Id
                     FROM Group
                     WHERE Name = 'Case From Community' and Type = 'Queue'];    
        List<Case> listOfCases = [SELECT Id FROM Case];
        List<Id> listOfCaseId = new List<Id>();
        for (Case caseObj : listOfCases) {
            caseObj.OwnerId = grp.Id;
            listOfCaseId.add(caseObj.Id);
        }
        update listOfCases;
        SendEmailToOwnerAfter4Hours.sendEmailToOwner(listOfCaseId);
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(1, invocations);
        
    }
}