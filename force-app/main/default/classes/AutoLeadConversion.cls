/**
 * Created by yatishsalian on 25/05/21.
 */

public with sharing class AutoLeadConversion {
    //This Method created by CR_Ayushi
    //It will convert leads checked by checkbox
    @InvocableMethod
    public static void convertLeadByCheckbox(List<Id> leadIds) {
        try {
            Map<Id, String> mapOfLeadIdVsError = new Map<Id, String>();
            Map<String, String> mapOfLeadIdVsOwnerId = new Map<String, String>();
            List<Database.LeadConvert> leadsToBeConverted = new List<Database.LeadConvert>();

            List<Lead> leadsCurrent = [SELECT Id, Owner__c, OwnerId FROM Lead WHERE Id IN :leadIds];
            if (!leadsCurrent.isEmpty()) {
                for (Lead l : leadsCurrent) {
                    if (l.Owner__c != null) {
                        mapOfLeadIdVsOwnerId.put(l.Id, l.Owner__c);
                    } else {
                        mapOfLeadIdVsOwnerId.put(l.Id, l.OwnerId);
                    }
                }
            }

            LeadStatus leadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
            for (Id currentlead : leadIds) {
                Database.LeadConvert Leadconvert = new Database.LeadConvert();
                Leadconvert.setLeadId(currentlead);
                Leadconvert.setConvertedStatus(leadStatus.MasterLabel);
                if (mapOfLeadIdVsOwnerId.containsKey(currentlead)) {
                    Leadconvert.setOwnerId(mapOfLeadIdVsOwnerId.get(currentlead));
                }
                leadsToBeConverted.add(Leadconvert);
            }

            if (!leadsToBeConverted.isEmpty()) {
//                Database.DMLOptions dbDML = new Database.DMLOptions();
//                dbDML.DuplicateRuleHeader.allowSave = true;
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
            List<Lead> leadList = [Select id, Auto_Convert_Lead__c, Error_in_Lead_Conversion__c from Lead where id in:leadIds];
            for (Lead currentlead : leadList) {
                currentLead.Auto_Convert_Lead__c = false;
                currentLead.Error_in_Lead_Conversion__c = e.getMessage();
            }
            update leadList;
        }
    }
}