@isTest
public class OppLineSyncTriggerTest {

    @testSetup
    static void setupTestData() {
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
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
            UnitPrice = 100,
            Discount = 0
        );
        insert oli;
      
    }

    @isTest
    static void testOppLineSyncTrigger_Insert() {
        // Fetch the setup data
        Opportunity opp = [SELECT Id, SyncedQuoteId FROM Opportunity LIMIT 1];
       /* opp.SyncedQuoteId = [SELECT Id FROM Quote LIMIT 1].Id;
        update opp;*/ // Sync the Quote to the Opportunity

        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Product2Id = :product.Id LIMIT 1];

        // Simulate insert of OpportunityLineItem
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 2,
            UnitPrice = 200,
            Discount = 10
        );
        
        Test.startTest();
        insert oli;
        Test.stopTest();
        
        // Verify that the OpportunityLineItem was created
        OpportunityLineItem insertedOli = [SELECT Id, Quantity, UnitPrice, Discount FROM OpportunityLineItem WHERE Id = :oli.Id];
        System.assertEquals(2, insertedOli.Quantity, 'Quantity should match.');
        System.assertEquals(200, insertedOli.UnitPrice, 'UnitPrice should match.');
        System.assertEquals(10, insertedOli.Discount, 'Discount should match.');
    }

    @isTest
    static void testOppLineSyncTrigger_Update() {
        // Fetch the setup data
        OpportunityLineItem oli = [SELECT Id, OpportunityId, Quantity, UnitPrice, Discount FROM OpportunityLineItem LIMIT 1];
        
        Test.startTest();
        
        // Update the OpportunityLineItem
        oli.Quantity = 3;
        oli.UnitPrice = 300;
        oli.Discount = 15;
        update oli;
        
        Test.stopTest();
    }

    @isTest
    static void testOppLineSyncTrigger_NoSync() {
        // Fetch the setup data
        OpportunityLineItem oli = [SELECT Id, OpportunityId FROM OpportunityLineItem LIMIT 1];
        
        Test.startTest();
        
        // Update the OpportunityLineItem without syncing the Quote
        oli.Quantity = 4;
        oli.UnitPrice = 400;
        oli.Discount = 20;
        update oli;
        
        Test.stopTest();
    }
}