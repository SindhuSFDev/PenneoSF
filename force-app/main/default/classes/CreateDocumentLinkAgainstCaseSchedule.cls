public class CreateDocumentLinkAgainstCaseSchedule Implements Schedulable
{
    public void execute(SchedulableContext sc)
    {
        callSchedule();
    }
    
    public void callSchedule(){
        CreateDocumentLinkAgainstCase documentTemp = new CreateDocumentLinkAgainstCase();
        Database.executeBatch(documentTemp);
    }
}