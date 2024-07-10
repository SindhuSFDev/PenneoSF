@isTest
public class EventTriggerHandler_Test {
    
    @TestSetup
    static void setup() {
        try{
            Test.startTest();
            Younium__Younium_Legal_Entity__c entityLegal = new Younium__Younium_Legal_Entity__c(Name = 'Penneo A/S',Younium__ID__c = '0d0c6127-faf6-49c4-084c-08da81c96743');
            insert entityLegal;
            Account acc = new Account(
                Name = 'Test Account 1',
                Website = 'test@noreply.com',
                Phone = '9876543210',
                VAT_Number__c = '12345',
                BillingCity = 'Mumbai',
                Industry = 'Agriculture',
                Younium__Legal_entity__c = entityLegal.Id
            );
            insert acc;
            Contact con = new Contact(
                LastName = 'Test Contact 1',
                Email = 'test2@gmail.com'
            );
            insert con;
            
            Opportunity opp = new Opportunity(
                Name = 'Test Opportunity',
                AccountId = acc.Id,
                Bill_to_Customer__c = acc.Id,
                Type = 'Existing Business',
                StageName = 'Discovering',
                CloseDate = System.today(),
                LeadSource = 'Inbound',
                Inbound_Lead_Type__c = 'Phone Lead',
                Penneo_Solution__c ='Penneo Sign'
            );
            insert opp;
            
            Lead l = new Lead(
                FirstName = 'Test',
                LastName = 'New Lead',
                LeadSource = 'Inbound',
                Email = 'test@noreply.com',
                Company = 'Test Company',
                Inbound_Lead_Type__c = 'Phone Lead'
            );
            insert l;
            Test.stopTest();
            
        }catch(Exception e){
            System.debug('Error Line - '+e.getLineNumber());
            System.debug('Error Message - '+e.getMessage());
        }
    }
    
    static testMethod void updateOpportunityStageToNegotiationTest1() {
        Test.startTest();
        Contact con = [SELECT Id FROM Contact];
        Opportunity opp = [SELECT Id FROM Opportunity];
        system.debug('Opp: '+opp);
        Event e = new Event(
            Subject = 'Meeting',
            Type = 'On-Line/On-Site Meeting',
            Status__c = 'Not Started',
            WhoId = con.Id,
            WhatId = opp.Id,
            StartDateTime = System.now(),
            EndDateTime = System.now() + 1
        );
        insert e;
        try{
            e.Status__c = 'Successfully Completed';
            update e;
        }
        catch(Exception ex){}
        Test.stopTest();
    }
    
    static testMethod void updateOpportunityStageToNegotiationTest2() {
        Test.startTest();
        Contact con = [SELECT Id FROM Contact];
        Opportunity opp = [SELECT Id FROM Opportunity];
        opp.Billing_Date__c = Date.today() + 10;
        update opp;
        Event e = new Event(
            Subject = 'Meeting',
            Type = 'On-Line/On-Site Meeting',
            Status__c = 'Not Started',
            WhoId = con.Id,
            WhatId = opp.Id,
            StartDateTime = System.now(),
            EndDateTime = System.now() + 1
        );
        insert e;
        e.Status__c = 'Successfully Completed';
        update e;
        Test.stopTest();
    }
    
    static testMethod void validateOnEventDateChangeTest() {
        Test.startTest();
        Contact con = [SELECT Id FROM Contact];
        Opportunity opp = [SELECT Id FROM Opportunity];
        Event e = new Event(
            Subject = 'Meeting',
            Type = 'On-Line/On-Site Meeting',
            Status__c = 'Not Started',
            WhoId = con.Id,
            WhatId = opp.Id,
            StartDateTime = System.now(),
            EndDateTime = System.now() + 1
        );
        insert e;
        try{
            e.StartDateTime = System.now() + 1;
            update e;
        }
        catch(Exception ex){}
        Test.stopTest();
    }
    
    static testMethod void updateLeadStatusToQualifyingTest() {
        Test.startTest();
        Lead l = [SELECT Id FROM Lead];
        Event e = new Event(
            Subject = 'Meeting',
            Type = 'Qualification M',
            Status__c = 'Not Started',
            WhoId = l.Id,
            StartDateTime = System.now(),
            EndDateTime = System.now() + 1
        );
        insert e;
        Test.stopTest();
    }
    
    static testMethod void updateEventCountOnOpportunityTest() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity];
        Event e = new Event(
            Subject = 'Meeting',
            Type = 'Quote',
            Status__c = 'Successfully Completed',
            WhatId = opp.Id,
            StartDateTime = System.now(),
            EndDateTime = System.now() + 1
        );
        insert e;
        Test.stopTest();
    }
    static testMethod void updateEventDecreaseCountOnAccountProspectTest() {
        List<Account_Prospect__c> accountProspect = new List<Account_Prospect__c>();
        List<Event> eventlist = new List<Event>();
		Account_Prospect__c  accPro = new  Account_Prospect__c();
        accPro.Name = 'Test';
        accPro.VAT_Number__c = 'ABC123';
        accountProspect.add(accPro);
        insert accPro;
        
        Event ev = new Event();
        ev.Type ='Other';
        ev.Subject = 'Call';
        ev.WhatId = accPro.Id;
        ev.StartDateTime = System.now();
        ev.EndDateTime = System.now()+1;
        insert ev;
        eventlist.add(ev);
        
        Test.startTest();
        EventTriggerHandler.updateEventDecreaseCountOnAccountProspect(eventlist);
        Test.stopTest();
    }
    
}