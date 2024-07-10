/**
 * Created by CloudRoute on 14-12-2021.
 */

public with sharing class LC_ArticleBreadcrumbCtrl {

    @AuraEnabled
    public static lc_responseWrapper getRecordpath(String recordId, String Language) {
        lc_responseWrapper resWrap = new lc_responseWrapper();
        List<articleWrapper> articleWrapperList = new List<articleWrapper>();
        String ArticleName = recordId.replaceAll('-', '_');

        list<Knowledge__kav> knowRecord = [SELECT id,Title, UrlName FROM Knowledge__kav where UrlName = :recordId AND PublishStatus = 'Online' AND Language = :Language];
        List<Knowledge__DataCategorySelection> knwDataCategory = [SELECT Id, ParentId, DataCategoryGroupName, DataCategoryName FROM Knowledge__DataCategorySelection where ParentId = :knowRecord[0].Id];
        String ParentName = knwDataCategory[0].DataCategoryGroupName + '__c';

        String query = 'SELECT id, Title, UrlName FROM  Knowledge__kav where Language = :Language AND PublishStatus = \'Online\' WITH DATA CATEGORY ' + ParentName + ' AT ' + knwDataCategory[0].DataCategoryName + '__c'; System.debug('query: ' + query);
        List<Knowledge__kav> relatedArticle = Database.query(query);
        try {
            if (!knwDataCategory.isEmpty()) {
                for (Knowledge__DataCategorySelection kds : knwDataCategory) {
                    articleWrapper wrapper = new articleWrapper();
                    wrapper.articleName = kds.DataCategoryGroupName;
                    wrapper.articleLabel = kds.DataCategoryGroupName.replaceAll('_', ' ');
                    articleWrapperList.add(wrapper);

                    articleWrapper childWrapper = new articleWrapper();
                    childWrapper.articleName = kds.DataCategoryName;
                    childWrapper.articleLabel = kds.DataCategoryName.replaceAll('_', ' ');
                    childWrapper.isParent = true;
                    articleWrapperList.add(childWrapper);
                }
            }

            resWrap.isSuccess = true;
            resWrap.articlesList = articleWrapperList;
        } catch (Exception e) {
            resWrap.isSuccess = false;
            resWrap.ErrorMsg = e.getMessage();
        }
        return resWrap;

    }


    public class lc_responseWrapper {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String ErrorMsg;
        @AuraEnabled public List<articleWrapper> articlesList;
    }

    public class articleWrapper {
        @AuraEnabled public string articleLabel;
        @AuraEnabled public string articleName;
        @AuraEnabled public Boolean isParent;
    }

}