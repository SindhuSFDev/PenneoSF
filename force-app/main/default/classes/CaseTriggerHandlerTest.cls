@isTest
public class CaseTriggerHandlerTest {
    
    @TestSetup
	static void testSetup(){
		Holiday_Send_Email__c holidaySendEmail = new Holiday_Send_Email__c();
		holidaySendEmail.Send_Email_on_Holiday__c = true;
		insert holidaySendEmail;
		Contact testContact = new Contact(LastName = 'Test', Email = 'test@gmail.com');
		insert testContact;
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
        
		 // Create Cases for testing
        List<Case> cases = new List<Case>();
        cases.add(new Case(
            Origin = 'Web',
            Status = 'New Case',
            CreatedDate = Datetime.now().addDays(-1), // Add a case created outside business hours
            OwnerId = grp.Id,
            ContactId = testContact.Id,
            Country__c = 'Denmark'
        ));
        cases.add(new Case(
            Origin = 'Web',
            Status = 'New Case',
            CreatedDate = Datetime.now().addDays(-1),
            OwnerId = grp.Id,
            Submitter_Email__c = 'test@example.com',
            Country__c = 'USA'
        ));
        insert cases;
	}
    
    @isTest
    static void testBeforeUpdate() {
        // Test Before Update
        List<Case> cases = [SELECT Id, CreatedDate, Contacted_Date_Time__c FROM Case];
        Test.startTest();
        for (Case caseObj : cases) {
            caseObj.Contacted_Date_Time__c = Datetime.now();
            caseObj.Type = 'task';
            caseObj.Category__c = 'Account creation';
            caseObj.Priority = 'No priority selected';
            caseObj.Platform_Plugin__c = 'Analytics';
            caseObj.Submitter_Email__c = 'test2@example.com';
        }
        update cases;
        Test.stopTest();

        // Assert Business_Hours__c field updated correctly
        for (Case caseObj : [SELECT Id, Business_Hours__c FROM Case]) {
            System.assert(caseObj.Business_Hours__c != null, 'Business_Hours__c should be updated.');
        }
    }

    /*@isTest
    static void testAfterInsert() {
        // Test After Insert
        List<Case> newCases = new List<Case>();
        newCases.add(new Case(
            Origin = 'Web',
            Status = 'New Case',
            OwnerId = [SELECT Id FROM Group WHERE Name = 'Case From Community'].Id,
          	Submitter_Email__c = 'test1@example.com',
            Country__c = 'Denmark'
        ));
        insert newCases;

        // Assert that child details from parent are updated
        for (Case caseOb : [SELECT Id, Non_Business_Hours_Creation_Time__c FROM Case WHERE Id IN :newCases]) {
            System.assert(caseOb.Non_Business_Hours_Creation_Time__c != null, 'Non_Business_Hours_Creation_Time__c should be updated.');
        }
    }*/

    @isTest
    static void testAfterUpdate() {
        // Test After Update
        List<Case> cases = [SELECT Id, Status, Type FROM Case WHERE Type = null];
        Test.startTest();
        for (Case caseObj : cases) {
            caseObj.Type = 'task';
            caseObj.Status = 'Solved';
            caseObj.Submitter_Email__c = 'test3@example.com';
            caseObj.Category__c = 'Account creation';
            caseObj.Priority = 'No priority selected';
            caseObj.Platform_Plugin__c = 'Analytics';
        }
        update cases;
        Test.stopTest();

        // Assert child cases status updated
        for (Case caseObj : [SELECT Id, (SELECT Id, Status FROM Cases) FROM Case WHERE Type = 'Incident']) {
            for (Case childCase : caseObj.Cases) {
                System.assertEquals('Solved', childCase.Status, 'Child case status should be updated to Solved.');
            }
        }
    }
    
    @isTest
    static void testUpdateChildDetailsFromParent() {
        // Test updateChildDetailsFromParent
        Case parentCase = new Case(
            Origin = 'Web',
            Status = 'New Case',
            Type = 'task',
            Category__c = 'Account creation',
            Platform_Plugin__c = 'Analytics',
            Priority = 'No priority selected',
            Submitter_Email__c = 'test981@example.com'
        );
        insert parentCase;
        
        Case childCase = new Case(
            Origin = 'Web',
            Type = 'task',
            Status = 'New Case',
            ParentId = parentCase.Id,
            Submitter_Email__c = 'test22@example.com'

        );
        insert childCase;
        
        Test.startTest();
        childCase.ParentId = parentCase.Id;
        update childCase;
        Test.stopTest();
        
        Case updatedChildCase = [SELECT Id, Type, Category__c, Platform_Plugin__c, Priority FROM Case WHERE Id = :childCase.Id];
        System.assertEquals('Incident', updatedChildCase.Type, 'Child case Type should be updated.');
        System.assertEquals('Technical', updatedChildCase.Category__c, 'Child case Category__c should be updated.');
        System.assertEquals('Plugin A', updatedChildCase.Platform_Plugin__c, 'Child case Platform_Plugin__c should be updated.');
        System.assertEquals('High', updatedChildCase.Priority, 'Child case Priority should be updated.');
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
        // Test updateChildDetailsFromParent
        Case parentCase = new Case(
            Origin = 'Web',
            Status = 'New Case',
            Type = 'task',
            Category__c = 'Account creation',
            Platform_Plugin__c = 'Analytics',
            Priority = 'No priority selected',
            Submitter_Email__c = 'test981@example.com'
        );
        insert parentCase;
        
        Case childCase = new Case(
            Origin = 'Web',
            Type = 'task',
            Status = 'New Case',
            ParentId = parentCase.Id,
            Submitter_Email__c = 'test22@example.com'

        );
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
    static void testAfterUnDelete() {
        // Test After UnDelete
        Case c = new Case(
            Origin = 'Web',
            Status = 'Closed',
            Submitter_Email__c = 'test29@example.com',
            Type = 'task'
        );
        insert c;
        delete c;
        
        Test.startTest();
        undelete c;
        Test.stopTest();
        
        // Assert that the case is restored and processed correctly
        Case undeletedCase = [SELECT Id, Status FROM Case WHERE Id = :c.Id];
        System.assertNotEquals('Closed', undeletedCase.Status, 'Undeleted case status should be restored.');
    }
}