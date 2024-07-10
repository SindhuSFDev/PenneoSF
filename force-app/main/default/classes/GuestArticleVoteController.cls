public without sharing class GuestArticleVoteController{
	@AuraEnabled
	public static Boolean existsVoteResult(String articleVersionId, String guestUserId){
		System.debug('Article Name - '+articleVersionId+ ' Guest User - '+guestUserId);
		Integer voteCount = [SELECT COUNT()
		                     FROM GuestArticleVote__c
		                     WHERE Knowledge__r.URLName = :articleVersionId AND GuestUserId__c = :guestUserId];
		System.debug('Count - '+voteCount);
		return (voteCount > 0);
	}
 
	@AuraEnabled
	public static String vote(String articleURL,String language, String guestUserId, Boolean isUpvoted,String comments){
		System.debug('Params - '+language+ ' - '+articleURL+ ' - Comments - '+comments);
		String message;
		try{
			Knowledge__kav articleVote = [SELECT Id, Answer__c, Question__c,Title,UrlName FROM Knowledge__kav WHERE UrlName = :articleURL AND Language = :language AND PublishStatus = 'Online' LIMIT 1];
			insert new GuestArticleVote__c(Knowledge__c = articleVote.Id, GuestUserId__c = guestUserId, IsUpvoted__c = isUpvoted,Comments__c = comments);
			message ='Success';
		}catch(Exception e){
			System.debug('Error Message - '+e.getMessage());
			message = 'Failed';
		}	
		return message;	
	}

	@AuraEnabled
	public static Decimal getUpVoteCount(String articleVersionId){
		Decimal upvoteCount = [SELECT COUNT()
		                       FROM GuestArticleVote__c
		                       WHERE Knowledge__c = :articleVersionId AND IsUpvoted__c = true];
        return upvoteCount;
	}
}