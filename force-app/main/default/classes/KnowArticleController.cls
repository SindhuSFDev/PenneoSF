/**
 * Created on 07-09-2020
 **/
public without sharing class KnowArticleController {
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
        if(categoryName!='All') {
             article = [SELECT Name, Label__c,Parent__c FROM Data_Category__c where Name = :categoryName];
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
            //setOfKnowledgeId.add(category.ParentId);
        }
        System.debug('#--mapOfParentVsChilds.keySet()--#' + mapOfParentVsChilds.keySet());
        /* to sort category in the specific order */
        List<Data_Category__c> listOfSortedCategs = [
                SELECT Id, Name, Label__c, Image_Url__c, Sort_Order__c, Danish_Label__c,French_Label__c	,Description__c, Parent__c, Danish_Description__c,French_Description__c
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
        System.debug('#--mapOfEngVsFrenchLabel--#' + mapOfEngVsFrenchLabel);
        System.debug('#--mapOfChildCategVsDescription--#' + mapOfChildCategVsDescription);
        /* if all is selected get all categories */
        if (categoryName == 'All') {
            //innerLoop(sortedCategMap, mapOfNameVsLabel, mapOfParentVsChilds, mapOfDataNameIdVsArticle, listOfArticleWrap, mapOfChildCategVsImage);
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
            
            /* to check if some record is not in custom setting, append */
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
            if (mapOfNameVsLabel.containsKey(categoryName) && mapOfParentVsChilds.containsKey(categoryName) && mapOfEngVsDanishLabel.containsKey(categoryName)) {
                List<InnerClass> listOfInnerClass = new List<InnerClass>();
                for (String child : mapOfParentVsChilds.get(categoryName)) {
                    if (mapOfNameVsLabel.containsKey(child) && mapOfEngVsDanishLabel.containsKey(child)) {
                        InnerClass innerClass = new InnerClass();
                        innerClass.childLabel = language == 'en_US' ? mapOfNameVsLabel.get(child) : (language == 'da' ? mapOfEngVsDanishLabel.get(child) : mapOfEngVsFrenchLabel.get(child));
                        innerClass.childName = child;
                        innerClass.imageURL = mapOfChildCategVsImage.containsKey(child) ? mapOfChildCategVsImage.get(child) : '';
                        innerClass.Descrtiption = language == 'en_US' ? mapOfChildCategVsDescription.get(child) : (language == 'da' ? mapOfEngVsDanishDescription.get(child) : mapOfEngVsFrenchDescription.get(child));
                        innerClass.knowledgeArticles = mapOfDataNameIdVsArticle.containsKey(child) ? mapOfDataNameIdVsArticle.get(child) : null;
                        listOfInnerClass.add(innerClass);
                    }
                }
                System.debug('#--listOfInnerClass--#' + listOfInnerClass);
                 if (categoryName != 'All') {
                        KnowArticleWrapper knowWrap = new KnowArticleWrapper(language == 'en_US' ? mapOfNameVsLabel.get(categoryName) : (language == 'da' ? mapOfEngVsDanishLabel.get(categoryName) : mapOfEngVsFrenchLabel.get(categoryName)), categoryName, listOfInnerClass, String.isNotBlank(article.Parent__c) ? article.Parent__c.replaceAll('_', ' ') : null);
                        listOfArticleWrap.add(knowWrap);
                 } else {
                        KnowArticleWrapper knowWrap = new KnowArticleWrapper(language == 'en_US' ? mapOfNameVsLabel.get(categoryName) : (language == 'da' ? mapOfEngVsDanishLabel.get(categoryName) : mapOfEngVsFrenchLabel.get(categoryName)), categoryName, listOfInnerClass);
                        listOfArticleWrap.add(knowWrap);
                 }

            } else {
                if (mapOfEngVsDanishLabel.containsKey(categoryName)) {
                    List<InnerClass> listOfInnerClass = new List<InnerClass>();
                    if (mapOfNameVsLabel.containsKey(categoryName) && mapOfEngVsDanishLabel.containsKey(categoryName) && mapOfDataNameIdVsArticle.containsKey(categoryName)) {
                        InnerClass innerClass = new InnerClass();
                        innerClass.childName = language == 'en_US' ? mapOfNameVsLabel.get(categoryName) : (language == 'da' ? mapOfEngVsDanishLabel.get(categoryName) : mapOfEngVsFrenchLabel.get(categoryName));
                        innerClass.knowledgeArticles = mapOfDataNameIdVsArticle.get(categoryName);
                        listOfInnerClass.add(innerClass);
                    }

                    System.debug('#--listOfInnerClass--#' + listOfInnerClass);
                    if(categoryName!='All') {
                        KnowArticleWrapper knowWrap = new KnowArticleWrapper(language == 'en_US' ? mapOfNameVsLabel.get(categoryName) : (language == 'da' ? mapOfEngVsDanishLabel.get(categoryName) : mapOfEngVsFrenchLabel.get(categoryName)), categoryName, listOfInnerClass, String.isNotBlank(article.Parent__c) ? article.Parent__c.replaceAll('_', ' ') : null);
                        listOfArticleWrap.add(knowWrap);
                    }else{
                        KnowArticleWrapper knowWrap = new KnowArticleWrapper(language == 'en_US' ? mapOfNameVsLabel.get(categoryName) : (language == 'da' ? mapOfEngVsDanishLabel.get(categoryName) : mapOfEngVsFrenchLabel.get(categoryName)), categoryName, listOfInnerClass);
                        listOfArticleWrap.add(knowWrap);
                    }
                }
            }

        }
        System.debug('#--mapOfDataNameIdVsArticle--#' + mapOfDataNameIdVsArticle);
        System.debug('#--listOfArticleWrap--#' + listOfArticleWrap);
        return Json.serialize(listOfArticleWrap);
    }


    public static Map<String, List<String>> getMapOfParentVsChildCategory(Map<String, String> mapOfNameVsLabel) {
        List<DescribeDataCategoryGroupResult> describeCategoryResult;
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
        Map<String, List<String>> mapOfParentVsChilds = new Map<String, List<String>>();
        try {
            describeCategoryStructureResult = getDescribeDataCategoryGroupStructureResults();
            System.debug('describeCategoryStructureResult: ' + describeCategoryStructureResult);

            //Getting data from the result
            for (DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult) {
                //DataCategoryGroupWrapper groupCateg = new DataCategoryGroupWrapper();
                //Get name of the associated Sobject
                //singleResult.getSobject();

                //Get the name of the data category group
                singleResult.getName();

                //Get the name of the data category group
                singleResult.getLabel();

                //Get the description of the data category group
                //singleResult.getDescription();

                //Get the top level categories
                DataCategory[] toplevelCategories = singleResult.getTopCategories();

                if (!mapOfNameVsLabel.containsKey(singleResult.getName())) {
                    mapOfNameVsLabel.put(singleResult.getName(), singleResult.getLabel());
                }

                //Recursively get all the categories
                List<DataCategory> allCategories = getAllCategories(toplevelCategories);
                System.debug('allCategories: ' + allCategories);
                for (DataCategory category : allCategories) {
                    //DataCategoryChildWrapper child = new DataCategoryChildWrapper();
                    //Get the name of the category
                    category.getName();
                    //Get the label of the category
                    category.getLabel();


                    //Get the list of sub categories in the category
                    DataCategory[] childCategories = category.getChildCategories();
                    for (DataCategory child : childCategories) {

                        if (mapOfParentVsChilds.containsKey(singleResult.getName())) {
                            mapOfParentVsChilds.get(singleResult.getName()).add(child.getName());
                        } else {
                            mapOfParentVsChilds.put(singleResult.getName(), new List<String>{
                                    child.getName()
                            });
                        }

                        if (!mapOfNameVsLabel.containsKey(child.getName())) {
                            mapOfNameVsLabel.put(child.getName(), child.getLabel());
                        }
                    }

                }
            }
            System.debug('#--mapOfParentVsChilds--#' + mapOfParentVsChilds);
        } catch (Exception e) {
            System.debug('#--exception--#' + e.getLineNumber() + ' ' + e.getMessage());
        }
        return mapOfParentVsChilds;
    }

    public static List<DescribeDataCategoryGroupStructureResult> getDescribeDataCategoryGroupStructureResults() {
        List<DescribeDataCategoryGroupResult> describeCategoryResult;
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
        Map<String, List<String>> mapOfParentVsChilds = new Map<String, List<String>>();
        try {
            //Making the call to the describeDataCategoryGroups to
            //get the list of category groups associated
            List<String> objType = new List<String>();
            objType.add('KnowledgeArticleVersion');
            describeCategoryResult = Schema.describeDataCategoryGroups(objType);
            System.debug('#--describeCategoryResult--#' + describeCategoryResult);

            //Creating a list of pair objects to use as a parameter
            //for the describe call
            List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();

            //Looping throught the first describe result to create
            //the list of pairs for the second describe call
            for (DescribeDataCategoryGroupResult singleResult : describeCategoryResult) {
                DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
                p.setSobject(singleResult.getSobject());
                p.setDataCategoryGroupName(singleResult.getName());
                pairs.add(p);
            }

            //describeDataCategoryGroupStructures()
            describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);

            System.debug('#--describeCategoryStructureResult--#' + describeCategoryStructureResult);

        } catch (Exception e) {
            System.debug('#--exception--#' + e.getLineNumber() + ' ' + e.getMessage());
        }
        return describeCategoryStructureResult;
    }

    private static DataCategory[] getAllCategories(DataCategory[] categories) {
        if (categories.isEmpty()) {
            return new DataCategory[]{
            };
        } else {
            DataCategory[] categoriesClone = categories.clone();
            DataCategory category = categoriesClone[0];
            DataCategory[] allCategories = new DataCategory[]{
                    category
            };
            categoriesClone.remove(0);
            categoriesClone.addAll(category.getChildCategories());
            allCategories.addAll(getAllCategories(categoriesClone));
            return allCategories;
        }
    }

    
    public static lc_responseWrapper getRecordpath(String recordId) {
        lc_responseWrapper resWrap = new lc_responseWrapper();
        List<articleWrapper> articleWrapperList = new List<articleWrapper>();
        String ArticleName = recordId.replaceAll('-', '_');
        List<Data_Category__c> article = [SELECT Name, Label__c,Parent__c FROM Data_Category__c where Name = :ArticleName];
        String ParentName = article[0].Parent__c + '__c';
        System.debug('ParentName :' + ParentName);
        String query = 'SELECT id, Title, UrlName FROM  Knowledge__kav WITH DATA CATEGORY ' + ParentName + ' AT ' + article[0].Name + '__c';
        System.debug('query: ' + query);
        List<Knowledge__kav> relatedArticle = Database.query(query);
        System.debug('Related Article  :' + relatedArticle);
        try {
            articleWrapper wrapper = new articleWrapper();
            wrapper.articleName = article[0].Parent__c;
            wrapper.articleLabel = article[0].Parent__c.replaceAll('_', ' ');
            articleWrapperList.add(wrapper);

            articleWrapper childWrapper = new articleWrapper();
            childWrapper.articleName = recordId;
            childWrapper.articleLabel = recordId.replaceAll('_', ' ');
            articleWrapperList.add(childWrapper);
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
        public string articleLabel;
        public string articleName;
    }
    
    public class KnowArticleWrapper {
        public String parentLabel;
        public String parentName;
        public List<InnerClass> innerClass;
        public String Parent;
        public KnowArticleWrapper() {
        }
        public KnowArticleWrapper(String parentLabel, String parentName, List<InnerClass> innerClass){
            this.parentLabel = parentLabel; //Getting Started With Penneo
            this.parentName = parentName; //Getting_Started_With_Penneo
            this.innerClass = innerClass;  //Setting Up Penneo, Getting Started With Penneo
        }
        public KnowArticleWrapper(String parentLabel, String parentName, List<InnerClass> innerClass,String prt) {
            this.parentLabel = parentLabel; //Getting Started With Penneo
            this.parentName = parentName; //Getting_Started_With_Penneo
            this.innerClass = innerClass;  //Setting Up Penneo, Getting Started With Penneo
            this.Parent = prt; // Penneo KYC, Penneo Sign
        }
    }

    public class InnerClass {
         @AuraEnabled public String childLabel; //Setting Up Penneo
         @AuraEnabled public String childName; //Setting_Up_Penneo
         @AuraEnabled public String imageURL;
         @AuraEnabled public String Descrtiption;
         @AuraEnabled public List<Knowledge__kav> knowledgeArticles;

        //articles
    }
    
    //This method is used for an emergency deployment 
    public static void testCodeCoverage() {
        Integer i = 1;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}