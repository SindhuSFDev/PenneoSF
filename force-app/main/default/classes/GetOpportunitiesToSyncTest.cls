@isTest
public class GetOpportunitiesToSyncTest {
    
    @testSetup
    static void setupTestData() {
        // Create Account
        Account acc1 = new Account(Name = 'Test Account 1', Younium__Y_Synch_to_Younium__c = false);
        Account acc2 = new Account(Name = 'Test Account 2', Younium__Y_Synch_to_Younium__c = true);
        insert new List<Account>{ acc1, acc2 };
        
        // Create Opportunities
        Opportunity opp1 = new Opportunity(
            Name = 'Test Opportunity 1',
            StageName = 'Closed Won',
            Type = 'New Business',
            Younium__Is_Synched_To_Younium__c = false,
            WentThruClosedWonTrigger__c = true,
            CloseDate = Date.today(),
            AccountId = acc1.Id
        );
        
        Opportunity opp2 = new Opportunity(
            Name = 'Test Opportunity 2',
            StageName = 'Closed Won',
            Type = 'New Business',
            Younium__Is_Synched_To_Younium__c = false,
            WentThruClosedWonTrigger__c = true,
            CloseDate = Date.today(),
            AccountId = acc2.Id
        );

        Opportunity opp3 = new Opportunity(
            Name = 'Test Opportunity 3',
            StageName = 'Closed Won',
            Type = 'Upsell', // This one should be excluded by Type != 'Upsell'
            Younium__Is_Synched_To_Younium__c = false,
            WentThruClosedWonTrigger__c = true,
            CloseDate = Date.today(),
            AccountId = acc1.Id
        );

        insert new List<Opportunity>{ opp1, opp2, opp3 };
    }
    
    @isTest
    static void testExecute() {
        // Execute the schedulable class
        Test.startTest();
        GetOpportunitiesToSync schedulable = new GetOpportunitiesToSync();
        schedulable.execute(null);
        Test.stopTest();
    }
    
    /*@isTest
    static void testExecute1() {
        // Execute the schedulable class
        Test.startTest();
        GetOpportunitiesToSync schedulable = new GetOpportunitiesToSync();
        schedulable.execute(null);
        Test.stopTest();
        
        // Verify account updates
        Account updatedAccount = [SELECT Id, Younium__Y_Synch_to_Younium__c FROM Account WHERE Name = 'Test Account 2'];
        System.assert(updatedAccount.Younium__Y_Synch_to_Younium__c, 'Account 1 should have Younium__Y_Synch_to_Younium__c set to true');
        
        // Verify opportunities were passed to queueable
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Younium__Is_Synched_To_Younium__c = false AND Younium__YouniumOrderId__c = null];
        System.assertEquals(3, oppList.size(), 'Two opportunities should have been passed to the queueable class');
    }*/
}