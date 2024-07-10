@IsTest
public class CaseTriggerHandler_Test{
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
		Case c = new Case();
		c.Status = 'New';
		c.Origin = 'Web';
		c.Contacted_Date_Time__c = Date.today();
		c.OwnerId = grp.Id;
        c.SuppliedEmail = 'test@case.com';
		insert c;
	}

	@IsTest
	public static void testBusinessHours(){
		Case caseObj = [SELECT Id
		                FROM Case
		                LIMIT 1];
		Contact testContact = [SELECT Id
		                       FROM Contact
		                       LIMIT 1];
		caseObj.Contacted_Date_Time__c = Date.today().addDays(1);
		caseObj.ContactId = testContact.Id;
		update caseObj;
	}

	@IsTest
	public static void testWithDenmark(){
		Case caseObj = [SELECT Id
		                FROM Case
		                LIMIT 1];
		Contact testContact = [SELECT Id
		                       FROM Contact
		                       LIMIT 1];
		caseObj.Country__c = 'Denmark';
		caseObj.ContactId = testContact.Id;
		update caseObj;
	}

	@isTest
	public static void sendEmailIfReceivedOnHolidayTest(){
		Case caseObj = [SELECT Id
		                FROM Case
		                LIMIT 1];
		CaseTriggerHandler.sendEmailIfReceivedOnHoliday(new Set<Id>{caseObj.Id});
		Integer invocations = Limits.getEmailInvocations();
		System.assertEquals(1, invocations);
	}
    
    @isTest
	public static void updateChildDetailsFromParentTest(){
		Case caseObj = [SELECT Id
		                FROM Case
		                LIMIT 1];
		Case c = new Case();
		c.Status = 'New';
		c.Origin = 'Web';
		c.Contacted_Date_Time__c = Date.today();
        c.SuppliedEmail = 'test@case.com';
        c.Type = 'Incident';
		insert c;
        
        caseObj.ParentId = c.Id;
        update caseObj;
	}
}