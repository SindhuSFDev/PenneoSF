@isTest
public class BusinessDaysTest {

    @isTest
    static void testAddBusinessDaysWithinBusinessHours() {
        // Test adding business days when starting within business hours
        Datetime startDate = Datetime.newInstance(2023, 7, 3, 10, 0, 0); // Monday, 10 AM
        Integer daysToAdd = 3;

        Test.startTest();
        Datetime resultDate = BusinessDays.add(startDate, daysToAdd);
        Test.stopTest();

        // Expected result: Thursday, 10 AM
        Datetime expectedDate = Datetime.newInstance(2023, 7, 6, 10, 0, 0);
        System.assertEquals(expectedDate, resultDate, 'The result date should be the expected date after adding business days.');
    }

    @isTest
    static void testAddBusinessDaysOutsideBusinessHours() {
        // Test adding business days when starting outside business hours
        Datetime startDate = Datetime.newInstance(2023, 7, 2, 22, 0, 0); // Sunday, 10 PM
        Integer daysToAdd = 3;

        Test.startTest();
        Datetime resultDate = BusinessDays.add(startDate, daysToAdd);
        Test.stopTest();

        // Expected result: Thursday, 9 AM (business hours start time)
        Datetime expectedDate = Datetime.newInstance(2023, 7, 6, 9, 0, 0);
    }

    @isTest
    static void testAddBusinessDaysSpanningWeekend() {
        // Test adding business days spanning a weekend
        Datetime startDate = Datetime.newInstance(2023, 7, 6, 10, 0, 0); // Thursday, 10 AM
        Integer daysToAdd = 2;

        Test.startTest();
        Datetime resultDate = BusinessDays.add(startDate, daysToAdd);
        Test.stopTest();

        // Expected result: Monday, 10 AM
        Datetime expectedDate = Datetime.newInstance(2023, 7, 10, 10, 0, 0);
    }

}