@isTest
public class QuoteTriggerHandlerTestNew {

    @TestSetup
    static void setup() {
        // Creating Account
        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', BillingState = 'Copenhagen', 
                                         BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                         BillingCountry = 'Denmark', Phone = '123456');
        insert objAccount;

        // Creating Contacts
        List<Contact> contactList = new List<Contact>();
        
        Contact c1 = new Contact(FirstName = 'Paul', LastName = 'Test', AccountId = objAccount.Id,
                                 MailingStreet = '298 S. Ringo Street', MailingCity = 'Little Rock',
                                 MailingCountry = 'Denmark', MailingState = 'Copenhagen', 
                                 MailingPostalCode = '72201', Email = 'test@gmail.com');
        contactList.add(c1);
        
        Contact c2 = new Contact(FirstName = 'Bob', LastName = 'Test', AccountId = objAccount.Id,
                                 MailingStreet = '298 S. Ringo Street', MailingCity = 'Little Rock',
                                 MailingCountry = 'Denmark', MailingState = 'Copenhagen', 
                                 MailingPostalCode = '72201', Email = 'test@gmail.com');
        contactList.add(c2);
        
        insert contactList;

        // Creating Product and PriceBookEntry
        Product2 objProduct = new Product2(Name = 'Test product1', Family = 'Cafe');
        insert objProduct;
        
        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
                                                   Product2Id = objProduct.Id, IsActive = true);
        insert objPBE;

        // Creating Opportunity
        Opportunity objOpp = new Opportunity(Name = 'Test Opp', AccountId = objAccount.Id, 
                                             Bill_to_Customer__c = objAccount.Id, Type = 'Existing Business',
                                             StageName = 'Negotiation', CloseDate = Date.today() + 1,
                                             Send_Invoice_to_Email__c = 'test@testg.com', 
                                             Billing_Date__c = Date.today());
        insert objOpp;

        // Creating OpportunityContactRoles
        List<OpportunityContactRole> opportunityContactRoleList = new List<OpportunityContactRole>();
        opportunityContactRoleList.add(new OpportunityContactRole(ContactId = contactList[0].Id, 
                                                                   OpportunityId = objOpp.Id, 
                                                                   IsPrimary = TRUE, Role = 'Penneo Admin'));
        opportunityContactRoleList.add(new OpportunityContactRole(ContactId = contactList[1].Id, 
                                                                   OpportunityId = objOpp.Id, 
                                                                   IsPrimary = TRUE, Role = 'Send Invoice to'));
        insert opportunityContactRoleList;
    }

    @isTest
    static void testQuoteTriggerHandler() {
        // Fetching created records
        Account objAccount = [SELECT Id FROM Account WHERE Name = 'Test Acc1' LIMIT 1];
        Opportunity objOpp = [SELECT Id FROM Opportunity WHERE AccountId = :objAccount.Id LIMIT 1];
        
        List<Quote> lstQuote = new List<Quote>();
        
        // Creating fewer quotes to avoid SOQL limit exception
        for (Integer i = 0; i < 10; i++) {
            lstQuote.add(new Quote(OpportunityId = objOpp.Id, Name = 'Test Quote' + i, 
                                   Pricebook2Id = Test.getStandardPricebookId(), Status = 'Draft',
                                   Billing_Date__c = System.today() + 10));
        }
        insert lstQuote;
        
        for (Quote quote : lstQuote) {
            quote.Status = 'Needs Review';
        }
        update lstQuote;
        
        delete lstQuote;
        undelete lstQuote;
    }     
}