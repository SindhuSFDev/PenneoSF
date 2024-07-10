@isTest
public class CreateContactPenneoSignUser_Test {
    @TestSetup
    static void testSetup(){
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
        c.SuppliedEmail = 'test@case.com';
        insert c;
    }
    
    @isTest
	public static void sendEmailIfReceivedOnHolidayTest(){
		Case caseObj = [SELECT Id FROM Case LIMIT 1];
		CreateContactPenneoSignUser.createPenneoSignContact(new List<Id>{caseObj.Id});
	}
}