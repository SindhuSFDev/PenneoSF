/**
 * Created by yatishsalian on 20/07/21.
 */

public with sharing class EmailMessageTriggerHandler implements ITriggerHandler {
    public static Boolean EmailMessageTriggerHandlerDISABLED = false;

    public static void BeforeInsert(List<SObject> triggerNew) {
        //call before insert actions
    }

    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap) {
    }

    public static void BeforeDelete(Map<Id, Sobject> oldMap) {
        //call before delete actions
    }

    public static void AfterInsert(Map<Id, SObject> newMap) {
        //call onAfterInsert delete actions
        //Send emails to child cases from parent
        Map<Id, EmailMessage> newMapEmailMessage = (Map<Id, EmailMessage>) newMap;
        if (System.Label.SendEmailToChild == 'Yes') {
            sendEmailToChildCases(newMapEmailMessage);
        }
    }

    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap) {
        //call onAfterUpdate update actions

    }

    public static void AfterDelete(Map<Id, Sobject> oldMap) {
        //call onAfterDelete update actions
    }

    public static void AfterUnDelete(Map<Id, Sobject> newMap) {
        //call after onAfterUnDelete actions
    }

    public Boolean IsDisabled() {
        return EmailMessageTriggerHandlerDISABLED;
    }

    public static void sendEmailToChildCases(Map<Id, EmailMessage> newMap) {
        Set<String> msgIds = new Set<String>();
        Set<String> parentCaseIds = new Set<String>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<EmailMessage> insertEmailMessages = new List<EmailMessage>();

        OrgWideEmailAddress fromAddress = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'support@penneo.com' LIMIT 1];

        for (Id cId : newMap.keySet()) {
            //If Email is going from SF to Parent Case Contact
            if (newMap.get(cId).Incoming == false && newMap.get(cId).RelatedToId != null && String.valueOf(newMap.get(cId).RelatedToId).startsWith('500')) {
                parentCaseIds.add(newMap.get(cId).RelatedToId);
                System.debug('parentCaseIds: ' + parentCaseIds);

                //Has children
                //Type for Parent and Child should be Incident
                List<Case> casesList = [
                        SELECT Id, ContactId, AccountId, Type, (
                                SELECT Id, Status, ContactId, AccountId, Type, SuppliedEmail
                                FROM Cases
                                WHERE Type = 'Incident'
                        )
                        FROM Case
                        WHERE Id IN :parentCaseIds AND Type = 'Incident'
                ];
                System.debug('casesList: ' + casesList);
                if (!casesList.isEmpty()) {
                    for (Case c : casesList) {
                        if (!c.Cases.isEmpty()) {
                            for (Case child : c.Cases) {

                                //send email
                                List<String> sendTo = new List<String>();
                                sendTo.add(child.SuppliedEmail);

                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                mail.setToAddresses(sendTo);
                                mail.setSubject(newMap.get(cId).Subject);
                                mail.setToAddresses(new List<String>{
                                        child.SuppliedEmail
                                });

                                String refId = newMap.get(cId).TextBody;
                                String emailBody;
                                if (refId.contains('ref')) {
                                    String childId = child.Id;
                                    String parentId = c.Id;
                                    String newRefId = 'ref:_' + UserInfo.getOrganizationId().left(5) + UserInfo.getOrganizationId().mid(11, 4) + '._' + childId.left(5) + childId.mid(10, 5) + ':ref';
                                    String oldRefId = 'ref:_' + UserInfo.getOrganizationId().left(5) + UserInfo.getOrganizationId().mid(11, 4) + '._' + parentId.left(5) + parentId.mid(10, 5) + ':ref';
                                    emailBody = refId.replace(oldRefId, newRefId);
                                    System.debug('oldRefId: ' + oldRefId);
                                    System.debug('newRefId: ' + newRefId);
                                } else {
                                    emailBody = refId;
                                }
                                System.debug('refId: ' + refId);

                                mail.setHtmlBody(emailBody);
                                mail.setWhatId(child.Id);
                                //log emails on child cases
                                mail.setSaveAsActivity(true);
                                //Send emails from support@penneo.com
                                mail.setOrgWideEmailAddressId(fromAddress.Id);
                                mail.setReplyTo(fromAddress.Address);
                                mails.add(mail);

                                //create email message
                                EmailMessage em = new EmailMessage(FromAddress = fromAddress.Address,
                                        FromName = fromAddress.DisplayName,
                                        ToAddress = child.SuppliedEmail,
                                        Subject = newMap.get(cId).Subject,
                                        //TextBody = mapOfCaseIdVsMessage.get(c.Id),
                                        HtmlBody = emailBody,
                                        ParentId = child.Id,
                                        Status = '3');
                                // ActivityId = newTask[0].Id);
                                insertEmailMessages.add(em);
                            }
                            System.debug('mails: ' + mails);
                            if (!mails.isEmpty()) {
                                Messaging.sendEmail(mails);
                            }
                        }
                    }
                }
            }
        }
        //insert email message
        if (!insertEmailMessages.isEmpty()) {
            System.debug('insertEmailMessages: ' + insertEmailMessages);
            EmailMessageTriggerHandlerDISABLED = true;
            //insert insertEmailMessages;
        }
    }

}