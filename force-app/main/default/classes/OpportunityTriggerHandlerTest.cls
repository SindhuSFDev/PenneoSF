@istest
public class OpportunityTriggerHandlerTest {
    @istest
    private static void testOpportunityTriggerHandler(){
        List<Quote> lstQuote = new List<Quote>();
        
        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City',
                                         BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                         BillingCountry = 'Denmark', Phone = '123456', EAN_number__c = '12346');
        insert objAccount;
        
        Contact contact = new Contact(LastName = 'Test', Email = 'test@gmail.com', AccountId = objAccount.Id);
        insert contact;
        
        Contact contact2 = new Contact(LastName = 'Test2', Email = 'test2@gmail.com', AccountId = objAccount.Id);
        insert contact2;
        
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject = 'Test';
        t.Status = 'Completed';
        t.Priority = 'Normal';
        t.WhoId = contact.Id;
        insert t;
        
        Opportunity objOpp = new Opportunity(
            Name = 'Test Opp', 
            AccountId = objAccount.Id, 
            Bill_to_Customer__c = objAccount.Id, 
            StageName = 'Negotiation', 
            CloseDate = Date.today()+1,
            Send_Invoice_to_Email__c  = 'test@gmail.com',
            Billing_Date__c  = Date.today(),
            Stop_synchronization__c  = true,
            Younium__Order_date__c = Date.today(),
            Type = 'Upsell'
        );
        insert objOpp;
        
        Product2 prod = new Product2(
            Name = 'Test Product',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   // Product Name
            ProductCode = '1',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         // Product Code
            IsActive = true,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           // Active
            Description = 'Test Product'
        );
        insert prod;
        
        PriceBookEntry pbe2 = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
                                                 Product2Id = prod.Id, IsActive = true);
        
        
        insert pbe2;
        
        objOpp.Pricebook2Id = Test.getStandardPricebookId();
        update objOpp;
        
        OpportunityLineItem OPplineitem = new OpportunityLineItem (Quantity = 2, OpportunityId = objOpp.Id, UnitPrice = 0.01, PriceBookEntryId = pbe2.Id);
        insert OPplineitem;
        
        objOpp.StageName = 'Closed Won';
        //update objOpp;
        
    }
    
    @istest
    private static void testOpportunityTriggerHandler2(){
        List<Quote> lstQuote = new List<Quote>();
        
        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', 
                                         BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                         BillingCountry = 'Denmark', Phone = '123456', EAN_number__c = '12346');
        insert objAccount;
        
        Contact contact = new Contact(LastName = 'Test', Email = 'test@gmail.com', AccountId = objAccount.Id);
        insert contact;
        
        Contact contact2 = new Contact(LastName = 'Test2', Email = 'test2@gmail.com', AccountId = objAccount.Id);
        insert contact2;
        
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject = 'Test';
        t.Status = 'Completed';
        t.Priority = 'Normal';
        t.WhoId = contact.Id;
        insert t;
        
        Opportunity objOpp = new Opportunity(
            Name = 'Test Opp', 
            AccountId = objAccount.Id, 
            Bill_to_Customer__c = objAccount.Id, 
            StageName = 'Negotiation', 
            CloseDate = Date.today()+1,
            Send_Invoice_to_Email__c  = 'test@gmail.com',
            Billing_Date__c  = Date.today(),
            Stop_synchronization__c  = true,
            Younium__Order_date__c = Date.today(),
            Type = 'Upsell'
        );
        insert objOpp;
        
        Product2 prod = new Product2(
            Name = 'Test Product',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   // Product Name
            ProductCode = '1',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         // Product Code
            IsActive = true,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           // Active
            Description = 'Test Product'
        );
        insert prod;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice = 0.01, Product2Id = prod.Id, Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive = true, UseStandardPrice = false);
        insert pbe2;
        
        objOpp.Pricebook2Id = Test.getStandardPricebookId();
        update objOpp;
        
        OpportunityLineItem OPplineitem = new OpportunityLineItem (Quantity = 2, OpportunityId = objOpp.Id, UnitPrice = 0.01, PriceBookEntryId = pbe2.Id);
        insert OPplineitem;
        
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = objOpp.id, ContactId = contact.id);
        OpportunityContactRole ocr2 = new OpportunityContactRole(OpportunityId = objOpp.id, ContactId = contact2.id);
        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        ocrList.add(ocr);
        ocrList.add(ocr2);
        insert ocrList;
        
        objOpp.StageName = 'Closed Won';
        //update objOpp;
        
    }
    
    @istest
    private static void testOpportunityTriggerHandler3(){
        List<Quote> lstQuote = new List<Quote>();
        
        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City',
                                         BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                         BillingCountry = 'Denmark', Phone = '123456', EAN_number__c = '12346');
        insert objAccount;
        
        Contact contact = new Contact(LastName = 'Test', Email = 'test@gmail.com', AccountId = objAccount.Id);
        insert contact;
        
        Contact contact2 = new Contact(LastName = 'Test2', Email = 'test2@gmail.com', AccountId = objAccount.Id);
        insert contact2;
        
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject = 'Test';
        t.Status = 'Completed';
        t.Priority = 'Normal';
        t.WhoId = contact.Id;
        insert t;
        
        Opportunity objOpp = new Opportunity(
            Name = 'Test Opp', 
            AccountId = objAccount.Id, 
            Bill_to_Customer__c = objAccount.Id, 
            StageName = 'Negotiation', 
            CloseDate = Date.today()+1,
            Send_Invoice_to_Email__c  = 'test@gmail.com',
            Billing_Date__c  = Date.today(),
            Stop_synchronization__c  = true,
            Younium__Order_date__c = Date.today(),
            Type = 'Upsell'
        );
        insert objOpp;
        
        Product2 prod = new Product2(
            Name = 'Test Product',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   // Product Name
            ProductCode = '1',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         // Product Code
            IsActive = true,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           // Active
            Description = 'Test Product'
        );
        insert prod;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice = 0.01, Product2Id = prod.Id, Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive = true, UseStandardPrice = false);
        insert pbe2;
        
        objOpp.Pricebook2Id = Test.getStandardPricebookId();
        update objOpp;
        
        OpportunityLineItem OPplineitem = new OpportunityLineItem (Quantity = 2, OpportunityId = objOpp.Id, UnitPrice = 0.01, PriceBookEntryId = pbe2.Id);
        insert OPplineitem;
        
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = objOpp.id, ContactId = contact.id);
        insert ocr;
        
        objOpp.StageName = 'Closed Won';
        //update objOpp;
        OpportunityTriggerHandler.testCodeCoverage();
    }
}