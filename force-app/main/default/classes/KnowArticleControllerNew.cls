public without sharing class KnowArticleControllerNew {
    @AuraEnabled
    public static String displayArticlesCategoryWise(String categoryName, String language) {
        Map<String, List<Knowledge__kav>> mapOfDataNameIdVsArticle = new Map<String, List<Knowledge__kav>>();
        Set<String> sortedCategMap = new Set<String>();
        Set<String> setOfIdNotInSorted = new Set<String>();
        List<KnowArticleWrapper> listOfArticleWrap = new List<KnowArticleWrapper>();
        Map<String, String> mapOfChildCategVsImage = new Map<String, String>();
        Map<String, String> mapOfChildCategVsDescription = new Map<String, String>();
        Map<String, String> mapOfNameVsLabel = new Map<String, String>();
        Map<String, List<String>> mapOfParentVsChilds = getMapOfParentVsChildCategory(mapOfNameVsLabel);
        Map<String, String> mapOfEngVsDanishLabel = new Map<String, String>();
        Map<String, String> mapOfEngVsDanishDescription = new Map<String, String>();
        Map<String, String> mapOfEngVsFrenchLabel = new Map<String, String>();
        Map<String, String> mapOfEngVsFrenchDescription = new Map<String, String>();
        Data_Category__c article = new Data_Category__c();
        if (categoryName != 'All') {
            article = [SELECT Name, Label__c, Parent__c FROM Data_Category__c WHERE Name = :categoryName];
        }

        System.debug('#--categoryName--#' + categoryName);
        System.debug('#--mapOfNameVsLabel--#' + mapOfNameVsLabel);
        List<Knowledge__DataCategorySelection> dataCategorySelection = [
            SELECT Id, ParentId, Parent.Title, DataCategoryName, Parent.UrlName, Parent.Sort_Order__c
            FROM Knowledge__DataCategorySelection
            WHERE Parent.PublishStatus = 'Online' AND Parent.Language = :language
            ORDER BY Parent.Sort_Order__c
        ];
        System.debug('#--knowledgeArticles--#' + dataCategorySelection.size() + ' ' + dataCategorySelection);
        for (Knowledge__DataCategorySelection category : dataCategorySelection) {
            Knowledge__kav knowArticle = new Knowledge__kav();
            knowArticle.Id = category.ParentId;
            knowArticle.Title = category.Parent.Title;
            knowArticle.UrlName = category.Parent.UrlName;
            if (mapOfDataNameIdVsArticle.containsKey(category.DataCategoryName)) {
                mapOfDataNameIdVsArticle.get(category.DataCategoryName).add(knowArticle);
            } else {
                mapOfDataNameIdVsArticle.put(category.DataCategoryName, new List<Knowledge__kav>{
                    knowArticle
                });
            }
        }
        System.debug('#--mapOfParentVsChilds.keySet()--#' + mapOfParentVsChilds.keySet());
        List<Data_Category__c> listOfSortedCategs = [
            SELECT Id, Name, Label__c, Image_Url__c, Sort_Order__c, Danish_Label__c, Description__c, Parent__c, Danish_Description__c, French_Label__c, French_Description__c
            FROM Data_Category__c
            ORDER BY Sort_Order__c
        ];
        for (Data_Category__c category : listOfSortedCategs) {
            if (category.Sort_Order__c != null) {
                sortedCategMap.add(category.Name);
            }
            if (category.Sort_Order__c == null && category.Image_Url__c != null) {
                if (!mapOfChildCategVsImage.containsKey(category.Name)) {
                    mapOfChildCategVsImage.put(category.Name, category.Image_Url__c);
                }
            }
            if (!mapOfEngVsDanishLabel.containsKey(category.Name)) {
                mapOfEngVsDanishLabel.put(category.Name, category.Danish_Label__c);
            }
            if (!mapOfChildCategVsDescription.containsKey(category.Name)) {
                mapOfChildCategVsDescription.put(category.Name, category.Description__c);
            }
            if (!mapOfEngVsDanishDescription.containsKey(category.Name)) {
                mapOfEngVsDanishDescription.put(category.Name, category.Danish_Description__c);
            }
            if (!mapOfEngVsFrenchLabel.containsKey(category.Name)) {
                mapOfEngVsFrenchLabel.put(category.Name, category.French_Label__c);
            }
            if (!mapOfEngVsFrenchDescription.containsKey(category.Name)) {
                mapOfEngVsFrenchDescription.put(category.Name, category.French_Description__c);
            }
        }
        System.debug('#--sortedCategMap--#' + sortedCategMap);
        System.debug('#--mapOfChildCategVsImage--#' + mapOfChildCategVsImage);
        System.debug('#--mapOfEngVsDanishLabel--#' + mapOfEngVsDanishLabel);
        System.debug('#--mapOfChildCategVsDescription--#' + mapOfChildCategVsDescription);
        if (categoryName == 'All') {
            for (String parent : sortedCategMap) {
                if (mapOfNameVsLabel.containsKey(parent) && mapOfParentVsChilds.containsKey(parent) && mapOfEngVsDanishLabel.containsKey(parent)) {
                    List<InnerClass> listOfInnerClass = new List<InnerClass>();
                    for (String child : mapOfParentVsChilds.get(parent)) {
                        if (mapOfNameVsLabel.containsKey(child) && mapOfEngVsDanishLabel.containsKey(child)) {
                            InnerClass innerClass = new InnerClass();
                            innerClass.childName = child;
                            innerClass.childLabel = language == 'en_US' ? mapOfNameVsLabel.get(child) : (language == 'da' ? mapOfEngVsDanishLabel.get(child) : mapOfEngVsFrenchLabel.get(child));
                            innerClass.imageURL = mapOfChildCategVsImage.containsKey(child) ? mapOfChildCategVsImage.get(child) : '';
                            innerClass.Descrtiption = language == 'en_US' ? mapOfChildCategVsDescription.get(child) : (language == 'da' ? mapOfEngVsDanishDescription.get(child) : mapOfEngVsFrenchDescription.get(child));
                            innerClass.knowledgeArticles = mapOfDataNameIdVsArticle.containsKey(child) ? mapOfDataNameIdVsArticle.get(child) : null;
                            listOfInnerClass.add(innerClass);
                        }
                    }

                    if (categoryName != 'All') {
                        KnowArticleWrapper knowWrap = new KnowArticleWrapper(language == 'en_US' ? mapOfNameVsLabel.get(parent) : (language == 'da' ? mapOfEngVsDanishLabel.get(parent) : mapOfEngVsFrenchLabel.get(parent)), parent, listOfInnerClass, String.isNotBlank(article.Parent__c) ? article.Parent__c.replaceAll('_', ' ') : null);
                        listOfArticleWrap.add(knowWrap);
                    } else {
                        KnowArticleWrapper knowWrap = new KnowArticleWrapper(language == 'en_US' ? mapOfNameVsLabel.get(parent) : (language == 'da' ? mapOfEngVsDanishLabel.get(parent) : mapOfEngVsFrenchLabel.get(parent)), parent, listOfInnerClass);
                        listOfArticleWrap.add(knowWrap);
                    }
                }
            }

            for (String parent : mapOfParentVsChilds.keySet()) {
                if (!sortedCategMap.contains(parent)) {
                    if (mapOfNameVsLabel.containsKey(parent) && mapOfEngVsDanishLabel.containsKey(parent)) {
                        List<InnerClass> listOfInnerClass = new List<InnerClass>();
                        for (String child : mapOfParentVsChilds.get(parent)) {
                            if (mapOfNameVsLabel.containsKey(child) && mapOfEngVsDanishLabel.containsKey(child)) {
                                InnerClass innerClass = new InnerClass();
                                innerClass.childName = child;
                                innerClass.childLabel = language == 'en_US' ? mapOfNameVsLabel.get(child) : (language == 'da' ? mapOfEngVsDanishLabel.get(child) : mapOfEngVsFrenchLabel.get(child));
                                innerClass.imageURL = mapOfChildCategVsImage.containsKey(child) ? mapOfChildCategVsImage.get(child) : '';
                                innerClass.Descrtiption = language == 'en_US' ? mapOfChildCategVsDescription.get(child) : (language == 'da' ? mapOfEngVsDanishDescription.get(child) : mapOfEngVsFrenchDescription.get(child));
                                innerClass.knowledgeArticles = mapOfDataNameIdVsArticle.containsKey(child) ? mapOfDataNameIdVsArticle.get(child) : null;
                                listOfInnerClass.add(innerClass);
                            }
                        }
                        if (categoryName != 'All') {
                            KnowArticleWrapper knowWrap = new KnowArticleWrapper(language == 'en_US' ? mapOfNameVsLabel.get(parent) : (language == 'da' ? mapOfEngVsDanishLabel.get(parent) : mapOfEngVsFrenchLabel.get(parent)), parent, listOfInnerClass, String.isNotBlank(article.Parent__c) ? article.Parent__c.replaceAll('_', ' ') : null);
                            listOfArticleWrap.add(knowWrap);
                        } else {
                            KnowArticleWrapper knowWrap = new KnowArticleWrapper(language == 'en_US' ? mapOfNameVsLabel.get(parent) : (language == 'da' ? mapOfEngVsDanishLabel.get(parent) : mapOfEngVsFrenchLabel.get(parent)), parent, listOfInnerClass);
                            listOfArticleWrap.add(knowWrap);
                        }
                    }
                }
            }
        } else {
            if (mapOfParentVsChilds.containsKey(categoryName)) {
                List<InnerClass> listOfInnerClass = new List<InnerClass>();
                for (String child : mapOfParentVsChilds.get(categoryName)) {
                    //List<InnerClass> listOfInnerClass = new List<InnerClass>();
                    if (mapOfNameVsLabel.containsKey(child) && mapOfEngVsDanishLabel.containsKey(child)) {
                        InnerClass innerClass = new InnerClass();
                        innerClass.childName = child;
                        innerClass.childLabel = language == 'en_US' ? mapOfNameVsLabel.get(child) : (language == 'da' ? mapOfEngVsDanishLabel.get(child) : mapOfEngVsFrenchLabel.get(child));
                        innerClass.imageURL = mapOfChildCategVsImage.containsKey(child) ? mapOfChildCategVsImage.get(child) : '';
                        innerClass.Descrtiption = language == 'en_US' ? mapOfChildCategVsDescription.get(child) : (language == 'da' ? mapOfEngVsDanishDescription.get(child) : mapOfEngVsFrenchDescription.get(child));
                        innerClass.knowledgeArticles = mapOfDataNameIdVsArticle.containsKey(child) ? mapOfDataNameIdVsArticle.get(child) : null;
                        listOfInnerClass.add(innerClass);
                    }
                }
            //}
            KnowArticleWrapper knowWrap = new KnowArticleWrapper(language == 'en_US' ? mapOfNameVsLabel.get(categoryName) : (language == 'da' ? mapOfEngVsDanishLabel.get(categoryName) : mapOfEngVsFrenchLabel.get(categoryName)), categoryName, listOfInnerClass, String.isNotBlank(article.Parent__c) ? article.Parent__c.replaceAll('_', ' ') : null);
            listOfArticleWrap.add(knowWrap);
        }
        }
        return JSON.serialize(listOfArticleWrap);
    }

    public static Map<String, List<String>> getMapOfParentVsChildCategory(Map<String, String> mapOfNameVsLabel) {
        Map<String, List<String>> mapOfParentVsChild = new Map<String, List<String>>();
        for (Data_Category__c category : [SELECT Id, Name, Label__c, Danish_Label__c, French_Label__c, Parent__c FROM Data_Category__c]) {
            if (!mapOfParentVsChild.containsKey(category.Parent__c)) {
                mapOfParentVsChild.put(category.Parent__c, new List<String>());
            }
            mapOfParentVsChild.get(category.Parent__c).add(category.Name);
            mapOfNameVsLabel.put(category.Name, category.Label__c);
        }
        return mapOfParentVsChild;
    }

    public class KnowArticleWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public List<InnerClass> listOfInnerClass;
        @AuraEnabled
        public String parentName;

        public KnowArticleWrapper(String label, String name, List<InnerClass> listOfInnerClass) {
            this.label = label;
            this.name = name;
            this.listOfInnerClass = listOfInnerClass;
        }

        public KnowArticleWrapper(String label, String name, List<InnerClass> listOfInnerClass, String parentName) {
            this.label = label;
            this.name = name;
            this.listOfInnerClass = listOfInnerClass;
            this.parentName = parentName;
        }
    }

    public class InnerClass {
        @AuraEnabled
        public String childName;
        @AuraEnabled
        public String childLabel;
        @AuraEnabled
        public String imageURL;
        @AuraEnabled
        public String Descrtiption;
        @AuraEnabled
        public List<Knowledge__kav> knowledgeArticles;
    }
}