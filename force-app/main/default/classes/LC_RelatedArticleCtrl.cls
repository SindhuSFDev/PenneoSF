/**
 * Created by CloudRoute on 13-12-2021.
 */

public without sharing class LC_RelatedArticleCtrl {

    @AuraEnabled
    public static List<Knowledge__kav> getRelatedArticle(String recordId, String Lang) {
        List<Knowledge__kav> relatedArticleNew = new List<Knowledge__kav>();
        String ArticleName = recordId.replaceAll('-', '_');

        list<Knowledge__kav> knowRecord = [
                SELECT id,Title, UrlName
                FROM Knowledge__kav
                where UrlName = :recordId AND PublishStatus = 'Online' AND Language = :Lang
        ];
        List<Knowledge__DataCategorySelection> knwDataCategory = [
                SELECT Id, ParentId, DataCategoryGroupName, DataCategoryName
                FROM Knowledge__DataCategorySelection
                where ParentId = :knowRecord[0].Id
                ORDER BY Parent.Sort_Order__c
        ];
        String ParentName = knwDataCategory[0].DataCategoryGroupName + '__c';
        String query = 'SELECT id, Title, UrlName FROM  Knowledge__kav where Language = :Lang AND PublishStatus = \'Online\' WITH DATA CATEGORY ' + ParentName + ' AT ' + knwDataCategory[0].DataCategoryName + '__c ORDER BY Sort_Order__c';
        System.debug('query: ' + query);
        List<Knowledge__kav> relatedArticle = Database.query(query);

        if (!relatedArticle.isEmpty()) {
            for (Knowledge__kav k : relatedArticle) {
                if (k.UrlName != recordId) {
                    relatedArticleNew.add(k);
                }
            }
        }
        System.debug('relatedArticleNew: ' + relatedArticleNew);
        return relatedArticleNew;
    }
}