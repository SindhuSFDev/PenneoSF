@isTest
public class TaskTriggerHandler_Test {
    
    @TestSetup
    static void setup() {
        Test.startTest();
        Lead l = new Lead(
            FirstName = 'Test',
            LastName = 'New Lead',
            LeadSource = 'Inbound',
            Email = 'test@noreply.com',
            Company = 'Test Company'
        );
        insert l;
        Test.stopTest();
    }
    
    static testMethod void setFirstResponseTimeOnLeadTest() {
        Test.startTest();
        Lead l = [SELECT Id FROM Lead];
        Task t = new Task(
            Subject = 'Outbound answered call',
            CallType = 'Outbound',
            Status = 'Completed',
            WhoId = l.Id
        );
        insert t;
        Test.stopTest();
    }
    
    static testMethod void updatePhoneContactOnLeadToTrueTest1() {
        Test.startTest();
        Lead l = [SELECT Id FROM Lead];
        Task t = new Task(
            Subject = 'Outbound answered call',
            CallType = 'Outbound',
            Status = 'Completed',
            CallDurationInSeconds = 35,
            WhoId = l.Id
        );
        insert t;
        Test.stopTest();
    }
    
    static testMethod void updatePhoneContactOnLeadToTrueTest2() {
        Test.startTest();
        Lead l = [SELECT Id FROM Lead];
        Task t = new Task(
            Subject = 'Outbound answered call',
            CallType = 'Outbound',
            Status = 'Completed',
            CallDurationInSeconds = 20,
            WhoId = l.Id
        );
        insert t;
        t.Status = 'Successfully Completed';
        update t;
        Test.stopTest();
    }
    static testMethod void updateTaskCountIncreaseOnAccountProspectTest() {
        List<Account_Prospect__c> accountProspect = new List<Account_Prospect__c>();
        List<Task> tasklist = new List<Task>();
		Account_Prospect__c  accPro = new  Account_Prospect__c();
        accPro.Name = 'Test';
        accPro.VAT_Number__c = 'ABC123';
        accountProspect.add(accPro);
        insert accPro;
        
        
        Task task = new Task();
        task.Status='Completed';
        task.Subject='Call';
        task.WhatId = accPro.Id;
        tasklist.add(task);
        insert task;
        Test.startTest();
        TaskTriggerHandler.updateTaskCountIncreaseOnAccountProspect(tasklist);
        TaskTriggerHandler.updateTaskCountDecreaseOnAccountProspect(tasklist);
        Test.stopTest();
    }
}