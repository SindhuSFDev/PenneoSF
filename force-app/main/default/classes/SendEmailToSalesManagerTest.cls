@istest
public class SendEmailToSalesManagerTest {

    @testSetup
    private static void testSetup(){
        List<Quote> lstQuote = new List<Quote>();
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Sales Manager' LIMIT 1];
        
     	User usr = new User(LastName = 'LIVESTON',
                           FirstName='Test',
                           Alias = 'test',
                           Email = 'test.liveston@asdf.com',
                           Username = 'test.liveston2@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr;
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
        
        Opportunity objOpp = new Opportunity(Name = 'Test Opp', AccountId = objAccount.Id, StageName = 'Negotiation', CloseDate = Date.today()+1,Send_Invoice_to_Email__c ='test@testg.com', Billing_Date__c = Date.today());
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
            lstQuote.add(new Quote(OpportunityId = objOpp.Id, Name = 'Test Quote' + i, Pricebook2Id = Test.getStandardPricebookId(), Status = 'Presented', Billing_Date__c=system.today() +10));
        }
        insert lstQuote;
        for(Quote quote : lstQuote){
            quote.Status = 'Accepted';
        }
        update lstQuote;
        
    }
    @istest
    private static void testsendEmail(){
        Quote quote = [Select id,name,OpportunityId from Quote Limit 1];
        Map<Id,Id> opportunityQuoteMap = new Map<id,id>();
        opportunityQuoteMap.put(quote.OpportunityId,quote.Id);
        SendEmailToSalesManager.sendEmail(opportunityQuoteMap);
    }
}