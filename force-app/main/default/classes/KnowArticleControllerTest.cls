@IsTest
private class KnowArticleControllerTest{
	@TestSetup
	static void testSetup(){
		List<Knowledge__kav> listOfArticles = new List<Knowledge__kav>();
		List<Data_Category__c> listOfDataCateg = new List<Data_Category__c>();
		for (Integer i = 1; i <= 10; i++){
			Knowledge__kav knowArticle = new Knowledge__kav();
			knowArticle.Sort_Order__c = i;
			if (i <= 5){
				knowArticle.Title = 'Administration of Login';
				knowArticle.UrlName = 'Administration' + i;
				knowArticle.Language = 'en_Us';
			} else{
				knowArticle.Title = 'Setup guide (Admin)';
				knowArticle.UrlName = 'Setup' + i;
				knowArticle.Language = 'da';
			}
			listOfArticles.add(knowArticle);
		}
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
	}

	@IsTest
	public static void displayArticlesCategoryWiseAllTest(){
		Test.startTest();
		String result = KnowArticleController.displayArticlesCategoryWise('All', 'en_Us');
		Test.stopTest();
		//System.assertNotEquals(null, result);
	}

	@IsTest
	public static void displayArticlesCategoryWiseTest(){
		Test.startTest();
		String result = KnowArticleController.displayArticlesCategoryWise('Penneo_Sign', 'en_Us');
		Test.stopTest();
        KnowArticleController.testCodeCoverage();
		//System.assertNotEquals(null, result);
	}
}