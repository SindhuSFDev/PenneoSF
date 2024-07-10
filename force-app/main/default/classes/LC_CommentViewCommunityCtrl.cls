public without sharing class LC_CommentViewCommunityCtrl {

    @AuraEnabled
    public static List<Comment__c> getComments(String recordId) {
        System.debug('recordId: ' + recordId);
        List<Comment__c> Comment = [SELECT Id, Name, Comment__c,Knowledge__c, CreatedBy.Name, CreatedDate FROM Comment__c where Knowledge__r.UrlName = :recordId ORDER BY CreatedDate DESC];
        System.debug('Comment:' + Comment);
        return Comment;
    }

    @AuraEnabled
    public static Boolean saveComment(String recordId, String Comment) {
        try {
            Knowledge__kav knowledge = [SELECT Id, UrlName, Title FROM Knowledge__kav where UrlName = :recordId];

            Comment__c Com = new Comment__c();
            Com.Comment__c = Comment;
            Com.Knowledge__c = knowledge.Id;
            insert Com;
            System.debug('Com: ' + Com);

            return true;
        } catch (Exception e) {
            return false;
        }
    }
}