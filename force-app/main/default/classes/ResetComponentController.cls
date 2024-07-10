public class ResetComponentController {

    @AuraEnabled
    public static String resetGuestVoting(String recordId){
        try{
       List<GuestArticleVote__c > guestArticleList = [Select id from GuestArticleVote__c
                                                           where Knowledge__c  =:recordId];
        if(!guestArticleList.isEmpty()){
            delete guestArticleList;
        }
        
        return 'success';
        }
        catch(Exception e){
           return 'error'; 
        }
    
    }
}