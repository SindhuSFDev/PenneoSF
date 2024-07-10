@istest
public class ResetComponentControllerTest {

    @testSetup
    static void testSetup(){
        Knowledge__kav k = new Knowledge__kav(URLName = 'Apex-Test-URLName',title='test '); 
        Insert k; 
        GuestArticleVote__c article = new GuestArticleVote__c();
        article.GuestUserId__c = '2345678';
         article.IsUpvoted__c = true;
         article.Knowledge__c = k.Id;
        insert article;
    }
    @istest
    static void resetGuestVoting(){
        Knowledge__kav k = [Select id from Knowledge__kav]; 
         
        ResetComponentController.resetGuestVoting(k.id);
    }
}