@istest
public class QuoteTriggerHandlerTest {

    @istest
    private static void testQuoteTriggerHandler(){
        List<Quote> lstQuote = new List<Quote>();
        
        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', BillingState = 'Copenhagen', 
                                         BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                         BillingCountry = 'Denmark', Phone = '123456');
        
        
        insert objAccount;
        List<Contact> contactList = new List<contact>();
        //Then create a primary contact
		Contact c = new Contact();
		c.FirstName = 'Paul';
		c.LastName  = 'Test';
		c.AccountId = objAccount.id;
		c.MailingStreet = '298 S. Ringo Street';
		c.MailingCity = 'Little Rock';
        c.MailingCountry = 'Denmark';
		c.MailingState = 'Copenhagen';
		c.MailingPostalCode = '72201'; 
        c.Email = 'test@gmail.com';
        contactList.add(c);
		
		System.debug('created primary contact');
			
		//Then create another non-primary contact
		Contact ci = new Contact();
		ci.FirstName = 'Bob';
		ci.LastName  = 'Test';
		ci.AccountId = objAccount.id;
		ci.MailingStreet = '298 S. Ringo Street';
		ci.MailingCity = 'Little Rock';
		ci.MailingCountry = 'Denmark';
		ci.MailingState = 'Copenhagen';
		ci.MailingPostalCode = '72201'; 
        ci.Email = 'test@gmail.com';
        contactList.add(ci);
		insert contactList;
        
        Product2 objProduct = new Product2(Name = 'Test product1', family = 'Cafe');
        
        insert objProduct;
        
        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
                                                   Product2Id = objProduct.Id, IsActive = true);
        
        
        insert objPBE;
        
        Opportunity objOpp = new Opportunity(Name = 'Test Opp', 
                                             AccountId = objAccount.Id, 
                                             Bill_to_Customer__c = objAccount.Id,
                                             Type = 'Existing Business',
                                             StageName = 'Negotiation', 
                                             CloseDate = Date.today()+1,
                                             Send_Invoice_to_Email__c ='test@testg.com', 
                                             Billing_Date__c = Date.today());
        insert objOpp;
        
        List<OpportunityContactRole> opportunityContactRoleList = new List<OpportunityContactRole>();
        OpportunityContactRole ocr = new OpportunityContactRole();
		ocr.ContactId = contactList[0].Id;
		ocr.OpportunityId = objOpp.Id;
		ocr.IsPrimary = TRUE;
		ocr.Role = 'Penneo Admin';
        
        OpportunityContactRole ocr1 = new OpportunityContactRole();
		ocr1.ContactId = contactList[1].Id;
		ocr1.OpportunityId = objOpp.Id;
		ocr1.IsPrimary = TRUE;
		ocr1.Role = 'Send Invoice to';
        
        opportunityContactRoleList.add(ocr);
        opportunityContactRoleList.add(ocr1);
		insert opportunityContactRoleList;
        
        for(Integer i=0; i< 10 ; i++)
        {
            lstQuote.add(new Quote(OpportunityId = objOpp.Id, Name = 'Test Quote' + i, Pricebook2Id = Test.getStandardPricebookId(), Status = 'Draft',Billing_Date__c=system.today() +10));
        }
        insert lstQuote;
        for(Quote quote : lstQuote){
            quote.Status = 'Needs Review';
        }
        update lstQuote;
        delete lstQuote;
        undelete lstQuote;
        
    }
    
     
}