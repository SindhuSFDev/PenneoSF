@istest
public class FreeDemoTrialReminderScheduleTest {
   
    @testSetup
    private static void testSetup(){
         Lead objLead = new Lead( FirstName = 'Test', LastName = 'Sample', Company = 'Testing Sample Co',Email='test@test.com');  
        insert objLead;  
        
        Event e = new Event(
            Subject = 'Meeting',
            Type = 'Free Trial / Demo / Sandbox',
            Status__c = 'Not Started',
            WhoId = objLead.Id,
            StartDateTime = System.now(),
            EndDateTime = System.now() + 1
        );
        insert e;
        
    }
    
    
    @isTest
    public static void testsendEmailLead() {
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
        FreeDemoTrialReminderSchedule.sendEmailLead(creationActionList);
    }

}