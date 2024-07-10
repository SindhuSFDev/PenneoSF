@IsTest
private class UtilityClassTest{
	@IsTest
	static void calculateBusinessHoursTest(){
		DateTime t1 = Date.newInstance(2020, 11, 11);
		Decimal result = UtilityClass.calculateBusinessHours(t1, t1 + 1);
		//System.assertEquals(8, result);
	}

	@IsTest
	static void getAddedBusinessHoursDateTimeTest(){
		DateTime t1 = Date.newInstance(2020, 11, 11);
		Datetime result = UtilityClass.getAddedBusinessHoursDateTime(t1, 8);
	}
    
    @IsTest
	static void getAddedBusinessHoursLeadDateTimeTest(){
		DateTime t1 = Date.newInstance(2020, 11, 11);
		Decimal result = UtilityClass.calculateBusinessHoursLead(t1, t1 + 1);
	}
}