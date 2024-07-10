/**
 * Created by ayushi.d@cloudroute.in on 21-10-2020.
 */
public with sharing class UtilityClass {
    public static BusinessHours defaultHours {
        get {
            if (defaultHours == null)
                defaultHours = [
                        SELECT Id
                        FROM BusinessHours
                        WHERE IsActive = true AND Name = 'Copenhague Business Hours'
                ];
            return defaultHours;
        }
        private set;
    }

    public static Decimal calculateBusinessHours(Datetime startDate, Datetime endDate) {
        Decimal result = BusinessHours.diff(defaultHours.Id, startDate, endDate);
        Decimal resultingHours = result / (60 * 60 * 1000);
        return resultingHours;
    }

    public static Decimal calculateBusinessHoursLead(Datetime startDate, Datetime endDate) {
        BusinessHours defaultHoursLead = [SELECT Id FROM BusinessHours WHERE IsActive = true AND Name = 'Lead Inbound Business Hours'];
        Decimal result = BusinessHours.diff(defaultHoursLead.Id, startDate, endDate);
        Decimal resultingHours = result / (60 * 60 * 1000);
        return resultingHours;
    }

    public static DateTime getAddedBusinessHoursDateTime(DateTime startDate, Integer intervalInHour) {
        DateTime result = BusinessHours.addGmt(defaultHours.Id, startDate, getHoursInMilliseconds(intervalInHour));
        return result;
    }

    public static Long getHoursInMilliseconds(Integer hours) {
        return hours * 60 * 60 * 1000;
    }
}