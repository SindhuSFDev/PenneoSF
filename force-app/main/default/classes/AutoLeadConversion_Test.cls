@isTest
public class AutoLeadConversion_Test {
    @testSetup
    private static void testSetup(){
        Lead objLead = new Lead( FirstName = 'Test', LastName = 'Sample', Company = 'Testing Sample Co',Email='test@test.com');  
        insert objLead;  
        
        Event event = new Event();
        event.whoId= objLead.id;
        event.StartDateTime=system.today();
        event.EndDateTime=system.today()+5;
        event.type = 'Free Trial / Demo / Sandbox';
        insert event;
    }
    @isTest
    private static void testconvertLead(){
        List<Id> leadIds = new List<Id>();
        List<Lead> leadList = [Select id,Email from Lead];
        Event event = new Event();
        event.whoId= leadList[0].id;
        event.StartDateTime=system.today();
        event.EndDateTime=system.today()+5;
        event.type = 'On-Line/On-Site Meeting';
        insert event;
        for(Lead lead : leadList){
            leadIds.add(lead.Id);
        }
        AutoLeadConversion.convertLeadByCheckbox(leadIds); 
    }
    @isTest
    private static void testconvertLead2(){
        List<Id> leadIds = new List<Id>();
        List<Lead> leadList = [Select id,Email from Lead];
        for(Lead lead : leadList){
            leadIds.add(lead.Id);
        }
        AutoLeadConversion.convertLeadByCheckbox(leadIds); 
    }
    @isTest
    private static void testconvertLeadWithError(){
        List<Id> leadIds = new List<Id>();
        List<Lead> leadList = [Select id,Email,LastName from Lead];
        
        
        for(Lead lead : leadList){
            leadIds.add(lead.Id);
        }
        AutoLeadConversion.convertLeadByCheckbox(leadIds); 
    }
}