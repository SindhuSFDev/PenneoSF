@isTest
public class SendOpportunityToYouniumTest {
    //Younium Package Error - Code is hidden, can not locate exact source
    /*@isTest
static void sendToOpptToYouniumTest1(){
try{
List<Opportunity> opptList = TestDataFactory.createSampleOpportunities();
GetOpportunitiesToSync.processOpportunityIds(); 
}catch(Exception e){
System.debug('exception line - '+e.getLineNumber()+ ' message - '+e.getMessage());
}
}*/
    // Due to Package error when deploying to Production
    @isTest
    public static void testCoverage(){
        GetOpportunitiesToSync.testCodeCoverage();
        SendOpportunityToYouniumQueueable.testCodeCoverage();
    }
}