/**
 * Created by ayushi.d@cloudroute.in on 21-10-2020.
 */

public class LeadTriggerHandler implements ITriggerHandler {
    public static void BeforeInsert(List<SObject> triggerNew) {

    }
    public void beforeUpdate(Map<id, SObject> newMap, Map<id, SObject> oldMap) {
        Map<Id, Lead> newMapLead = (Map<Id, Lead>) newMap;
        Map<Id, Lead> oldMapLead = (Map<Id, Lead>) oldMap;
        if (!newMap.isEmpty()) {
            updateBusinessHours(newMapLead, oldMapLead);
        }
    }

    public static void BeforeDelete(Map<Id, SObject> oldMap) {
    }

    public static void afterInsert(Map<Id, SObject> newMap) {
    }

    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
    }

    public static void AfterDelete(Map<Id, SObject> oldMap) {
    }


    public static void AfterUnDelete(Map<Id, SObject> newMap) {
    }

    public Boolean IsDisabled() {
        return false;
    }

    public static void updateBusinessHours(Map<Id, Lead> newMapLead, Map<Id, Lead> oldMapLead) {
        if (!newMapLead.isEmpty()) {
            for (Id leadObj : newMapLead.keySet()) {
                if (newMapLead.get(leadObj).First_Response_Time__c != null && newMapLead.get(leadObj).First_Response_Time__c != oldMapLead.get(leadObj).First_Response_Time__c) {
                    if (System.Label.LeadBusinessHours_Disable == 'Yes') {
                        Decimal businessHrs = UtilityClass.calculateBusinessHoursLead(newMapLead.get(leadObj).CreatedDate, newMapLead.get(leadObj).First_Response_Time__c);
                        newMapLead.get(leadObj).Business_Hours__c = businessHrs;
                    } else {
                        Decimal businessHrs = UtilityClass.calculateBusinessHours(newMapLead.get(leadObj).CreatedDate, newMapLead.get(leadObj).First_Response_Time__c);
                        newMapLead.get(leadObj).Business_Hours__c = businessHrs;
                    }
                }
            }
        }
    }

}