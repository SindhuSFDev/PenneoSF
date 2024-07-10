@istest
public class CreateQuotePDFControllerTest {

    @testSetup
    private static void testSetup(){
        List<Quote> lstQuote = new List<Quote>();
        
        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', BillingState = 'Copenhagen', 
                                         BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                         BillingCountry = 'Denmark', Phone = '123456');
        
        
        insert objAccount;
        
        
        Product2 objProduct = new Product2(Name = 'Test product1', family = 'Cafe');
        
        insert objProduct;
        
        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
                                                   Product2Id = objProduct.Id, IsActive = true);
        
        
        insert objPBE;
        
        Opportunity objOpp = new Opportunity(Name = 'Test Opp', AccountId = objAccount.Id, StageName = 'Verbal Confirmation', CloseDate = Date.today()+1);
        insert objOpp;
        
        for(Integer i=0; i< 10 ; i++)
        {
            lstQuote.add(new Quote(OpportunityId = objOpp.Id, Name = 'Test Quote' + i, Pricebook2Id = Test.getStandardPricebookId(), Status = 'In Review'));
        }
        insert lstQuote;
    }
    
    @isTest
    private static void testcreateQuotePDF(){
        Quote quote = [Select id from Quote Limit 1];
        String message = CreateQuotePDFController.createQuotePDF(quote.Id);
        System.assertEquals('success', message);
    }
    
    @isTest
    private static void testInit(){
        Quote quote = [Select id from Quote Limit 1];
        String message = CreateQuotePDFController.init(quote.Id);
        System.assertEquals('invalid', message);
        
        quote.Status = 'Approved';
        update quote;
        String message1 = CreateQuotePDFController.init(quote.Id);
        System.assertEquals('valid', message1);
    }
}