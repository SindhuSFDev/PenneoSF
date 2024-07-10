@IsTest
public class CaseClosedFeedbackCtrlTest {
    
    @TestSetup
    static void testSetup(){
        Contact testContact = new Contact(LastName = 'Test');
        insert testContact;
        Case caseObj = new Case(Subject = 'Test', Case_Closed_Feedback__c = 'Good', ContactId = testContact.Id);
        insert caseObj;
    }

    @IsTest
    static void getCaseDetailsTest(){
        Case caseObj = [SELECT Id FROM Case LIMIT 1];
        lc_caseClosedFeedbackCtrl.responseWrapper responeWrapper = lc_caseClosedFeedbackCtrl.getCaseDetails(caseObj.Id);
        System.assertEquals(false, responeWrapper.isSuccess);
    }

    @IsTest
    static void saveCaseResponseTest(){
        Case caseObj = [SELECT Id FROM Case LIMIT 1];
        lc_caseClosedFeedbackCtrl.responseWrapper responeWrapper = lc_caseClosedFeedbackCtrl.saveCaseResponse('Good', caseObj.Id, 'Test');
        System.assertEquals(true, responeWrapper.isSuccess);
    }

    @IsTest
    static void sendAttachmentOnSubmitTest(){
        Case caseObj = [SELECT Id FROM Case LIMIT 1];
        lc_caseClosedFeedbackCtrl.SendAttachmentOnSubmit(new List<String>{caseObj.Id});
    }
}