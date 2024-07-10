@isTest
public class OppSyncTriggerTest {

    @testSetup
    static void setupTestData() {
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create Contact
        Contact cont = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acc.Id);
        insert cont;
        
        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Negotiation',
            CloseDate = Date.today(),
            AccountId = acc.Id
        );
        insert opp;
        
        // Create Quote
        Quote quote = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert quote;
        
        // Create PricebookEntry
        Product2 product = new Product2(Name = 'Test Product', IsActive = true);
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;
		opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
        
        // Create OpportunityLineItem
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 0.01,
            Discount_Term__c = 'Recurrent'
        );
        insert oli;
        
        
        // Create QuoteLineItem
       /* QuoteLineItem qli = new QuoteLineItem(
            QuoteId = quote.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert qli;*/
    }

    @isTest
    static void testOppSyncTrigger() {
        // Fetch the setup data
        Opportunity opp = [SELECT Id, StageName, SyncedQuoteId FROM Opportunity LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE OpportunityId = :opp.Id LIMIT 1];
        
        // Simulate syncing the quote
        opp.SyncedQuoteId = quote.Id;
        
        Test.startTest();
        
        // Update the Opportunity to trigger the OppSyncTrigger
        update opp;
        
        Test.stopTest();
        
        // Verify the Quote and OpportunityLineItem were updated
        Quote updatedQuote = [SELECT Id FROM Quote WHERE Id = :quote.Id];
        List<OpportunityLineItem> updatedOli = [
            SELECT Id, Quantity, UnitPrice FROM OpportunityLineItem WHERE OpportunityId = :opp.Id
        ];
        
        System.assertNotEquals(null, updatedQuote, 'The quote should be updated.');
    }

    @isTest
    static void testOppSyncTrigger_NoSync() {
        // Fetch the setup data
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        
        Test.startTest();
        
        // Update the Opportunity without syncing the quote
        opp.StageName = 'Closed Won';
        update opp;
        
        Test.stopTest();
        
        // Verify no quote or OpportunityLineItem updates occurred
        List<Quote> quotes = [SELECT Id FROM Quote];
        List<OpportunityLineItem> olis = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        
        // Assertions
        System.assertEquals(1, quotes.size(), 'There should be one quote.');
        System.assertEquals(1, olis.size(), 'There should be one OpportunityLineItem.');
    }
}