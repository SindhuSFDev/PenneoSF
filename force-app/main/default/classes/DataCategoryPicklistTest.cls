@IsTest
private class DataCategoryPicklistTest{

    @IsTest
	static void getDefaultValueTest(){
		DataCategoryPicklist dataCategory = new DataCategoryPicklist();
		VisualEditor.DataRow picklist = dataCategory.getDefaultValue();
        System.assertEquals(null, picklist);
	}

	@IsTest
	static void getValuesTest(){
		DataCategoryPicklist dataCategory = new DataCategoryPicklist();
		VisualEditor.DynamicPickListRows picklist = dataCategory.getValues();
        System.assertEquals(6, picklist.size());
	}
}