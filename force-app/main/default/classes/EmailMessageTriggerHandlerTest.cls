@isTest
public class EmailMessageTriggerHandlerTest {
    @istest
    public static void testData(){
        
        Account acc = new Account(
            Name = 'Test',                                                                                             // Account Name
            Phone = '1234567890',                                                                                                                  // Phone
            VAT_Number__c = '12344',                                                                                                               // VAT Number
            Software_Platform__c = 'No software platform',                                                                                         // Software Platform
            Industry = 'Accounting',                                                                                                               // Industry
            Old_Pricing_Model__c = false,                                                                                                          // Old Pricing Model
            Send_Invoice_to_email2__c = 'test@gmail.com',                                                                                  // Send Invoice to email
            Auto_Close_Penneo_Accounts__c = false,                                                                                                 // Auto Close Penneo Accounts
            Convert_Lead__c = false,                                                                                                // Credit Hold (IO)
            Sync_to_Netsuite__c = false,                                                                                                           // Sync to Netsuite
            Inactive_in_Netsuite__c = false                                                                                                       // Inactive in Netsuite
        );
        insert acc;
        
        Contact con = new Contact(
            LastName = 'Test',
            AccountId = acc.Id,                   // Account Name
            Email = 'test@gmail.com',                  // Email
            Phone = '1234567890',                              // Phone
            Outdated_Contact_Information__c = false,           // Outdated Contact Information
            Send_To_Pardot_Nurtuting_Campaign__c = false,      // Send To Pardot - Nurtuting Campaign
            HasOptedOutOfEmail = false,                        // Email Opt Out
            pi__pardot_hard_bounced__c = false,                // Pardot Hard Bounced
            Convert_Lead__c = false                           // Convert Lead
        );
        insert con;
        
        Case case1 = new Case(
            ContactId = con.Id,
            AccountId = acc.Id,
            Type = 'Incident',
            Status = 'New Case',
            Origin = 'Phone',
            Priority = 'High',
            SuppliedEmail = 'ayushi.d@cloudroute.in'
        );
        insert case1;
        
        Case case2 = new Case(
            ContactId = con.Id,
            AccountId = acc.Id,
            Type = 'Incident',
            Status = 'New Case',
            Origin = 'Phone',
            Priority = 'High',
            ParentId = case1.Id,
            SuppliedEmail = 'ayushi.d@cloudroute.in'
        );
        insert case2;
        
        String caseId = case1.Id;
        
        //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = false;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        String newRefId = 'ref:_' + UserInfo.getOrganizationId().left(5) + UserInfo.getOrganizationId().mid(11, 4) + '._' + caseId.left(5) + caseId.mid(10, 5) + ':ref';
        email.HtmlBody = 'Test email body '+ newRefId;
        //email.TextBody = 'Test email body '+ newRefId;
        email.ParentId = case1.Id; 
        email.RelatedToId = case1.Id;
        insert email;
    }   
}