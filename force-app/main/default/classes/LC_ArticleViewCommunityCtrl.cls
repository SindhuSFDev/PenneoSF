public without sharing class LC_ArticleViewCommunityCtrl {

    @AuraEnabled
    public static List<Knowledge__kav> getArticleDetails(String recordId, String Lang) {
        List<Knowledge__kav> knowledge = [SELECT Id, Answer__c, Question__c,Title,UrlName FROM Knowledge__kav WHERE UrlName = :recordId AND Language = :Lang AND PublishStatus = 'Online' LIMIT 1];
        return knowledge;
    }

    @AuraEnabled
    public static List<Knowledge__kav> FindByTitle(String searchKey, String language) {

        List<Knowledge__kav> knowledArticles = new List<Knowledge__kav>();
        Set<String> kavId = new Set<String>();
        String status = 'Online';

        String query = 'SELECT Id, Title, UrlName FROM Knowledge__kav WHERE Title LIKE \'%' + searchKey + '%\' AND PublishStatus = \'' + status + '\' AND Language = \'' + language + '\' ORDER BY Title';
        System.debug('query: ' + query);
        List<Knowledge__kav> suggestedArticles = Database.query(query);
        knowledArticles.addAll(suggestedArticles);
        System.debug('knowledArticles: ' + knowledArticles);

        for (Knowledge__kav prod : suggestedArticles) {
            kavId.add(prod.Id);
        }

        String searchTerms = '';
        string soslQuery = '';
        String res = '';
        if (searchKey != Null) {
            List<String> searchLogicSplittedbySpace = searchKey.split(' ');
            for (String str : searchLogicSplittedbySpace) {
                searchTerms += '("' + str + '")';
                searchTerms += ' OR ';
            }
            res = searchTerms.removeEnd(' OR ');
            soslQuery = 'FIND \'' + String.escapeSingleQuotes(res) + '\' IN ALL FIELDS RETURNING Knowledge__kav';
        } else {
            soslQuery = 'FIND \'' + searchKey + '\' IN ALL FIELDS RETURNING Knowledge__kav';
        }
        List<List<Knowledge__kav>> prodSearch = search.query(soslQuery);
        List<String> prodIdList = new List<String>();
        for (Knowledge__kav prod : ((List<Knowledge__kav>) prodSearch[0])) {
            prodIdList.add(prod.Id);
        }

        if (prodIdList != null && !prodIdList.isEmpty()) {
            List<Knowledge__kav> knowledges = [
                    SELECT Id,Title,UrlName
                    FROM Knowledge__kav
                    WHERE Id IN :prodIdList AND PublishStatus = 'Online' AND Id NOT IN :kavId AND Language = :language
                    ORDER BY Title
            ];
            knowledArticles.addAll(knowledges);
            System.debug('knowledArticles: ' + knowledArticles);
        }
        return knowledArticles;
    }
}