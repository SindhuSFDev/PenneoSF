@istest
public class BusinessDaysUpdateTest {

    @testSetup
    public static void testSetup(){
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
    public static void testbusinessDaysUpdateOutbound(){
        List<Lead> leadList = [Select id,FirstName,LastName,Company,Email from Lead];
        List<Event> eventList = [Select id,StartDateTime,EndDateTime,WhoId,OwnerId from Event];
        List<LeadCreationAction> creationActionList = new List<LeadCreationAction>();
        for(Lead lead : leadList){
            LeadCreationAction creationAction = new LeadCreationAction();
            creationAction.eventEndDate = eventList[0].EndDateTime;
            creationAction.objectId = eventList[0].WhoId;
            creationAction.eventId  = eventList[0].Id;
            creationAction.OwnerId = eventList[0].OwnerId;
            creationActionList.add(creationAction);
        }
        BusinessDaysUpdate.businessDaysUpdateOutbound(creationActionList);
    }
}