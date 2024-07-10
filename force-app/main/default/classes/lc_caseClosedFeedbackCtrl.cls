/**
 * Created by ayushi.d@cloudroute.in on 26-10-2020.
 */

public without sharing class lc_caseClosedFeedbackCtrl {

    @AuraEnabled
    public static responseWrapper getCaseDetails(String caseId) {
        responseWrapper wrapObj = new responseWrapper();
        List<Case> caseList = [SELECT Id, Submitter_Email__c, Case_Closed_Feedback__c, ContactId FROM Case WHERE Id = :caseId LIMIT 1];
        if (!caseList.isEmpty()) {
            if (caseList[0].Case_Closed_Feedback__c != null) {
                wrapObj.isSuccess = false;
                wrapObj.errorMsg = System.Label.feedbackAlreadySubmitted;
            } else {
                wrapObj.isSuccess = true;
            }
        } else {
            wrapObj.isSuccess = false;
            wrapObj.errorMsg = System.Label.errorMessageCaseFeedback;
        }
        return wrapObj;
    }

    @AuraEnabled
    public static responseWrapper saveCaseResponse(String response, String caseId, String comment) {
        responseWrapper wrapObj = new responseWrapper();
        try {
            List<Case> caseList = [SELECT Id, Submitter_Email__c, Case_Closed_Feedback__c, ContactId FROM Case WHERE Id = :caseId LIMIT 1];
            if (!caseList.isEmpty()) {
                caseList[0].Case_Closed_Feedback__c = response;
                caseList[0].Case_Feedback_Comments__c = comment;
                update caseList[0];
            }
            wrapObj.isSuccess = true;
            wrapObj.errorMsg = System.Label.successMsgCaseFeedback;
        } catch (Exception e) {
            wrapObj.isSuccess = false;
            wrapObj.errorMsg = e.getMessage();
        }
        return wrapObj;
    }

    @InvocableMethod
    public static void SendAttachmentOnSubmit(List<String> caseId) {
        try {
            List<Case> cases = [SELECT Id, ContactId FROM Case WHERE Id = :caseId[0] LIMIT 1];
            List<EmailTemplate> emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Case Closed Feedback Template' LIMIT 1];

            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemplate[0].Id, cases[0].ContactId, caseId[0]);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
                    mail
            }, false);
            System.debug('results: ' + results);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage() + ' at line: ' + ex.getLineNumber());
        }
    }

    public class responseWrapper {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String errorMsg;
    }
}