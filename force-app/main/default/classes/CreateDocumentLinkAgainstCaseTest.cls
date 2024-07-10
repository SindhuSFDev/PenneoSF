@istest
public class CreateDocumentLinkAgainstCaseTest {

    @testSetup
    static void testSetup(){
        
         Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email',File_Upload_Id_For_Site_User__c='12345',isFileCreated__c=false); 
        insert cas;
        
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.Guest_Record_fileupload__c = '12345';
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;

    }
    @istest
    static void testexecute(){
        Test.startTest();
        String CRON_EXP = '0 0 0 15 3 ? *';
        System.schedule('ScheduleApexClassTest', CRON_EXP ,new CreateDocumentLinkAgainstCaseSchedule());
        Test.stopTest();
    }
}