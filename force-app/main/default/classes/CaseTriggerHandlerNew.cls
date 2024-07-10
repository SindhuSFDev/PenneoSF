@isTest
public class CaseTriggerHandlerNew {
    @testSetup
    static void setupTestData() {
        // Setup necessary test data
  		Holiday_Send_Email__c holidaySendEmail = new Holiday_Send_Email__c();
		holidaySendEmail.Send_Email_on_Holiday__c = true;
		insert holidaySendEmail;
		Contact testContact = new Contact(LastName = 'Test', Email = 'test@gmail.com');
		insert testContact;

        // Create a Group (Queue)
       Group grp = [SELECT Id
		             FROM Group
		             WHERE Name = 'Case From Community' and Type = 'Queue'];
        
        Penneo_Sign_Users__c penneoUser = new Penneo_Sign_Users__c(
            Name = 'Test',                              // Penneo Sign Users Name
            Full_Name__c = 'Test Case',                   // Full Name
            Real_Email__c = 'test@case.com',              // Real Email
            Onboarding_Campaign_QUalification__c = true,  // Onboarding Campaign Qualification
            Email_1_Onboarding_Campaign__c = true,        // Email 1 - Onboarding Campaign
            Email_2_Onboarding_Campaign__c = false,       // Email 2 - Onboarding Campaign
            Email_3_Onboarding_Campaign__c = false       // Email 3 - Onboarding Campaign
        );
        insert penneoUser;
        
        // Create Case Records
        Case parentCase = new Case(
            Origin = 'Web',
            Status = 'New Case',
            CreatedDate = Datetime.now().addDays(-1), // Add a case created outside business hours
            OwnerId = grp.Id,
            ContactId = testContact.Id,
            Country__c = 'Denmark',
            Subject = 'Parent Case', 
            Type = 'Incident');
        insert parentCase;

        Case childCase = new Case(Status = 'New', Origin = 'Web', Subject = 'Child Case', Submitter_Email__c = 'test@example.com',ParentId = parentCase.Id);
        insert childCase;
    }

    @isTest
    static void testBeforeInsert() {
        // Test BeforeInsert trigger
        List<Case> cases = new List<Case>{
            new Case(Subject = 'New Case', Status = 'New', Origin = 'Web')
        };
        Test.startTest();
        CaseTriggerHandler.BeforeInsert(cases);
        Test.stopTest();

        // Validate the outcomes
        // Add your assertions here
    }

    @isTest
    static void testBeforeUpdate() {
        // Retrieve the test data
        Case existingCase = [SELECT Id, Subject, Status, Origin FROM Case LIMIT 1];

        // Update the case
        existingCase.Status = 'Updated';

        Map<Id, SObject> newMap = new Map<Id, SObject>{ existingCase.Id => existingCase };
        Map<Id, SObject> oldMap = new Map<Id, SObject>{ existingCase.Id => existingCase };

        Test.startTest();
        CaseTriggerHandler.BeforeUpdate(newMap, oldMap);
        Test.stopTest();

        // Validate the outcomes
        for (Case caseObj : [SELECT Id, Business_Hours__c FROM Case]) {
            System.assert(caseObj.Business_Hours__c == null, 'Business_Hours__c should be updated.');
        }
    }

    @isTest
    static void testAfterInsert() {
        // Test AfterInsert trigger
        Case newCase = new Case(Subject = 'After Insert Case', Status = 'New Case', Origin = 'Web', Submitter_Email__c = 'test@example.com');
        insert newCase;

        Map<Id, SObject> newMap = new Map<Id, SObject>{ newCase.Id => newCase };

        Test.startTest();
        CaseTriggerHandler.AfterInsert(newMap);
        Test.stopTest();

        // Validate the outcomes
        // Add your assertions here
    }

    @isTest
    static void testAfterUpdate() {
        // Retrieve the test data
        Case existingCase = [SELECT Id, Subject, Status, Origin FROM Case LIMIT 1];

        // Update the case
        existingCase.Status = 'Solved';

        Map<Id, SObject> newMap = new Map<Id, SObject>{ existingCase.Id => existingCase };
        Map<Id, SObject> oldMap = new Map<Id, SObject>{ existingCase.Id => existingCase };

        Test.startTest();
        CaseTriggerHandler.AfterUpdate(newMap, oldMap);
        Test.stopTest();

        // Validate the outcomes
        for (Case caseObj : [SELECT Id, (SELECT Id, Status FROM Cases) FROM Case WHERE Type = 'Incident']) {
            for (Case childCase : caseObj.Cases) {
                System.assertEquals('Solved', childCase.Status, 'Child case status should be updated to Solved.');
            }
        }
    }

    @isTest
    static void testCheckIfReceivedOnHoliday() {
        // Retrieve the test data
        Case newCase = [SELECT Id, Subject, Status, Origin, CreatedDate, Non_Business_Hours_Creation_Time__c FROM Case LIMIT 1];

        Map<Id, Case> newCaseMap = new Map<Id, Case>{ newCase.Id => newCase };
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();

        Test.startTest();
        CaseTriggerHandler.checkIfReceivedOnHoliday(newCaseMap, oldCaseMap);
        Test.stopTest();

        // Validate the outcomes
        // Add your assertions here
    }

    @isTest
    static void testUpdateRelatedCaseStatus() {
        // Retrieve the test data
        Case parentCase = [SELECT Id, Subject, Status, Origin, Submitter_Email__c FROM Case WHERE Type = 'Incident' LIMIT 1];
        Case childCase = new Case(Status = 'New Case', Submitter_Email__c = 'test@example.com', Origin = 'Web', Subject = 'Child Case', ParentId = parentCase.Id);
        insert childCase;

        parentCase.Status = 'Solved';
        update parentCase;

        Map<Id, Case> newMap = new Map<Id, Case>{ parentCase.Id => parentCase };
        Map<Id, Case> oldMap = new Map<Id, Case>{ parentCase.Id => [SELECT Id, Status FROM Case WHERE Id = :parentCase.Id] };

        Test.startTest();
        CaseTriggerHandler.updateRelatedCaseStatus(newMap, oldMap);
        Test.stopTest();

        // Validate the outcomes
        // Add your assertions here
    }

    @isTest
    static void testUpdateChildDetailsFromParent() {
        // Retrieve the test data
        Case parentCase = [SELECT Id, Subject, Status, Origin, Submitter_Email__c FROM Case WHERE Type = 'Incident' LIMIT 1];
        Case childCase = new Case(Status = 'New Case', Origin = 'Web', Submitter_Email__c = 'test@example.com', Subject = 'Child Case', ParentId = parentCase.Id);
        insert childCase;

        Map<Id, Case> newMap = new Map<Id, Case>{ childCase.Id => childCase };
        Map<Id, Case> oldMap = new Map<Id, Case>{};

        Test.startTest();
        CaseTriggerHandler.updateChildDetailsFromParent(newMap, oldMap);
        Test.stopTest();

        // Validate the outcomes
        // Add your assertions here
    }
}