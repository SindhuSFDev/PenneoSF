@istest
public class GuestArticleVoteControllerTest {

    @testSetup
    static void testSetup(){
        Knowledge__kav k = new Knowledge__kav(URLName = 'Apex-Test-URLName',title='test'); 
        Insert k; 
        GuestArticleVote__c article = new GuestArticleVote__c();
        article.GuestUserId__c = '2345678';
        article.IsUpvoted__c = true;
        article.Knowledge__c = k.Id;
        insert article;
       // system.debug('URl: '+k.UrlName);
    }
    @istest
    static void testexistsVoteResult(){
        Knowledge__kav k = [Select id from Knowledge__kav]; 
        GuestArticleVoteController.existsVoteResult(k.id,'2345678');
    }
    
   @istest
    static void testvote(){
        Knowledge__kav k = [Select id from Knowledge__kav]; 
        GuestArticleVoteController.vote('Apex-Test-URLName',k.id,'tete',true,'hbyu');
    }
    
    @istest
    static void testgetUpVoteCount(){
        Knowledge__kav k = [Select id from Knowledge__kav]; 
        GuestArticleVoteController.getUpVoteCount(k.id);
    }
}