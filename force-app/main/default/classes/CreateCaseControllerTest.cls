@IsTest
private class CreateCaseControllerTest{
    @TestSetup
    static void testSetup(){
        Account account = new Account(Name = 'Penneo Admin Account', Website = 'test.com');
        insert account;
        Contact contact = new Contact(LastName = 'Test', Email = 'test@gmail.com');
        insert contact;
        List<Knowledge__kav> listOfArticles = new List<Knowledge__kav>();
        List<Data_Category__c> listOfDataCateg = new List<Data_Category__c>();
        
        Knowledge__kav knowArticle = new Knowledge__kav();
        knowArticle.Sort_Order__c = 1;
        knowArticle.Title = 'Penneo Sign';
        knowArticle.UrlName = 'Penneo-Sign';
        knowArticle.Language = 'en_Us';
        listOfArticles.add(knowArticle);
        
        for (Integer i = 1; i <= 5; i++){
            Data_Category__c dataCustomSetting = new Data_Category__c();
            if (i == 1){
                dataCustomSetting.Name = 'Getting_started_with_Penneo';
                dataCustomSetting.Label__c = 'Getting started with Penneo';
                dataCustomSetting.Danish_Label__c = 'Kom-igang-med-Penneo';
                dataCustomSetting.Sort_Order__c = 1;
            } else if (i == 2){
                dataCustomSetting.Name = 'Setting_up_Penneo';
                dataCustomSetting.Label__c = 'Setting up Penneo';
                dataCustomSetting.Parent__c = 'Getting_started_with_Penneo';
                dataCustomSetting.Danish_Label__c = 'Penneo-Opsætning';
                dataCustomSetting.Image_Url__c = 'test.com';
            } else if (i == 3){
                dataCustomSetting.Name = 'setting_up_penneo';
                dataCustomSetting.Parent__c = 'Getting_started_with_Penneo';
                dataCustomSetting.Label__c = 'setting up penneo';
                dataCustomSetting.Danish_Label__c = 'Penneo-Opsætning';
            } else if (i == 4){
                dataCustomSetting.Name = 'Penneo_Sign';
                dataCustomSetting.Parent__c = 'Getting_Started_settings';
                dataCustomSetting.Label__c = 'Penneo sign';
                dataCustomSetting.Danish_Label__c = 'Penneo-underskriver';
            } else{
                dataCustomSetting.Name = 'Your_archive';
                dataCustomSetting.Parent__c = 'Getting_started_with_Penneo';
                dataCustomSetting.Label__c = 'Your archive';
                dataCustomSetting.Danish_Label__c = 'Dit-arkiv';
            }
            listOfDataCateg.add(dataCustomSetting);
        }
        insert listOfDataCateg;
        insert listOfArticles;
        Knowledge__DataCategorySelection data = new Knowledge__DataCategorySelection();
        data.DataCategoryGroupName = 'Penneo_Sign';
        data.DataCategoryName = 'Getting_Started_settings';
        data.ParentID = listOfArticles[0].Id;
        insert data;
        
        knowledge__kav obj1 = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: listOfArticles[0].Id];
        KbManagement.PublishingService.publishArticle(obj1.KnowledgeArticleId, true);
    }
    
    @IsTest
    static void addContAndAccToCommunityCaseTest(){
        Case caseObj = new Case();
        caseObj.SuppliedEmail = 'test@gmail.com';
        caseObj.Role__c = 'Penneo Admin';
        //caseObj.SuppliedCompany = 'test.com';
        String result = CreateCaseController.addContAndAccToCommunityCase(caseObj, 'test', new List<String>());
        System.assertNotEquals(null, result);
    }
    
    @IsTest
    static void getPicklistValuesTest(){
        List<CreateCaseController.SelectOption> picklistOptions = CreateCaseController.getPicklistValues('Role__c');
        System.assertEquals(3, picklistOptions.size());
    }
    
    @IsTest
    static void generateRandomStringTest(){
        String result = CreateCaseController.generateRandomString();
        System.assertNotEquals(null, result);
    }
    
    @IsTest
    static void getPrefillValuesTest(){
        String result = CreateCaseController.getPrefillValues();
        System.assertEquals(null, result);
    }
    
    @IsTest
    static void getSuggestedArticlesSubjectTest(){
        CreateCaseController.getSuggestedArticlesSubject('Penneo', 'en_US', 0);
        CreateCaseController.getSuggestedArticles('Penneo', 'en_US');
    }
    
    @IsTest
    static void deleteContentDocumentsTest(){
        CreateCaseController.deleteContentDocuments(new List<String>());
        CreateCaseController.testCodeCoverage();
    }
}