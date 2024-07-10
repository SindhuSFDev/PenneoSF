public class BusinessDays
{
    public static BusinessHours defaultHours
    {
        get
        {
            if (defaultHours == null)
                defaultHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
            return defaultHours;
        }
        private set;
    }

    public static Datetime add(Datetime pointer, Integer days)
    {
        pointer = BusinessHours.nextStartDate(defaultHours.Id, pointer);
        // make sure you're starting at a Datetime within BusinessHours

        for (Integer elapsed = 0; elapsed < days; elapsed++)
        {
            pointer = pointer.addDays(1);
            if (!BusinessHours.isWithin(defaultHours.Id, pointer))
                pointer = BusinessHours.nextStartDate(defaultHours.Id, pointer);
        }
        return pointer;
    }
}