@isTest
public class LeadTriggerHandler_Test {
    
    @isTest
    public static void testBusinessHours(){
        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.Company = 'Cloudroute Solutions';
        l.First_Response_Time__c = Date.today();
        insert l;
        l.First_Response_Time__c = Date.today().addDays(1);
        update l;
    }
}