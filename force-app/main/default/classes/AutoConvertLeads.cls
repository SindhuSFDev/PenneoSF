Public without sharing class AutoConvertLeads {
    @InvocableMethod
    public static void convertLead(List<Id> leadIds) {
        Map<String, Event> mapOfLeadIdVsEvent = new Map<String, Event>();
        List<Event> eventList = [
                Select id,Event_Expiration_Date__c, OwnerId, WhoId
                from Event
                where whoId in:leadIds and type = 'Free Trial / Demo / Sandbox'
        ];
        List<Event> eventListOnsite = [
                Select id,Event_Expiration_Date__c, OwnerId, WhoId
                from Event
                where whoId in:leadIds and (type = 'On-Line/On-Site Meeting' OR Type = 'Q & A' OR Type = 'Quote')
        ];
        if (!eventList.isEmpty()) {
            for (Event event : eventList) {
                event.Event_Expiration_Date__c = null;
            }
            update eventList;

        }
        if (!eventListOnsite.isEmpty()) {
            for (Event event : eventListOnsite) {
                mapOfLeadIdVsEvent.put(event.WhoId, event);
            }
        }
        System.debug('mapOfLeadIdVsEvent: ' + mapOfLeadIdVsEvent);
        convertLeadList(leadIds, mapOfLeadIdVsEvent);

    }

    public static void convertLeadList(List<Id> leadIds, Map<String, Event> mapOfLeadIdVsEvent) {
        System.debug('mapOfLeadIdVsEvent: ' + mapOfLeadIdVsEvent);
        try {
            Map<Id, String> mapOfLeadIdVsError = new Map<Id, String>();
            LeadStatus leadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
            List<Database.LeadConvert> leadsToBeConverted = new List<Database.LeadConvert>();
            for (Id currentlead : leadIds) {
                Database.LeadConvert Leadconvert = new Database.LeadConvert();
                Leadconvert.setLeadId(currentlead);
                Leadconvert.setConvertedStatus(leadStatus.MasterLabel);
                if (!mapOfLeadIdVsEvent.isEmpty() && mapOfLeadIdVsEvent.containsKey(currentlead)) {
                    Leadconvert.setOwnerId(mapOfLeadIdVsEvent.get(currentlead).OwnerId);
                }
                leadsToBeConverted.add(Leadconvert);
            }

            if (!leadsToBeConverted.isEmpty()) {
                List<Database.LeadConvertResult> lcr = Database.convertLead(leadsToBeConverted);
                for (Database.LeadConvertResult result : lcr) {
                    System.debug('result: ' + result);
                    if (!result.success) {
                        //add error message on lead
                        System.debug('error: ' + result.errors);
                        System.debug('get error: ' + result.getErrors());
                        for (Integer j = 0; j < result.getErrors().size(); j++) {
                            System.debug((j + 1) + '. ' + result.getErrors()[j].getMessage());
                            mapOfLeadIdVsError.put(result.getLeadId(), 'Error Message: ' + result.getErrors()[j].getMessage());
                        }
                    }
                }
            }
            System.debug('mapOfLeadIdVsError: ' + mapOfLeadIdVsError);
            if (!mapOfLeadIdVsError.isEmpty()) {
                List<Lead> leads = [SELECT Id, Error_in_Lead_Conversion__c FROM Lead WHERE Id IN:mapOfLeadIdVsError.keyset()];
                for (Lead leadCurrent : leads) {
                    System.debug('mapOfLeadIdVsError.get(leadCurrent.Id): ' + mapOfLeadIdVsError.get(leadCurrent.Id));
                    leadCurrent.Auto_Convert_Lead__c = false;
                    leadCurrent.Error_in_Lead_Conversion__c = mapOfLeadIdVsError.get(leadCurrent.Id);
                }
                update leads;
            }
        } catch (Exception e) {
            List<Lead> leadList = [Select id, convert_Lead__c from Lead where id in:leadIds];
            for (Lead currentlead : leadList) {
                currentLead.convert_Lead__c = false;
                currentLead.Error_in_Lead_Conversion__c = e.getMessage();
            }
            update leadList;
        }
    }
}