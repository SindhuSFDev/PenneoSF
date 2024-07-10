public without sharing class QuoteTriggerHandler implements ITriggerHandler {
    //This method will handle before insert method
    public void beforeInsert(List<SObject> newItems) {
    }
    
    //This method will handle before update event
    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
    }
    
    //This method handles after insert event
    public void afterInsert(Map<Id, SObject> newMap) {
    }
    
    //This method handles after update event
    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        //updateOpportunityStageToClosedWon((Map<Id,Quote>) oldMap, (List<Quote>) newMap.values());
    }
    
    //This will handle before delete event
    public void beforeDelete(Map<Id, SObject> oldMap) {
    }
    
    //This method handles after delete event
    public void afterDelete(Map<Id, SObject> oldMap) {
    }
    
    //This method handles after undelete event
    public void afterUndelete(Map<Id, SObject> newMap) {
    }
    
    public Boolean IsDisabled() {
        //Check if Triggers are enabled
        return false;
    }
    
    /*******************************************************************************
* @author       KG
* @date         August 2020
* @description  Update Opportunity Stage to Closed Won When Quote is Accepted
* 				or New Contract
*******************************************************************************/
    //Commenting this code because the requirement has changed now it is not needed
    
    /*private void updateOpportunityStageToClosedWon(Map<Id,Quote> oldQuoteMap,List<Quote> newQuoteList) {
        //Set of Id to store all Opportunity Ids
        Map<Id,Quote> opportunityQuoteMap = new Map<Id,Quote>();
        Map<Id,Id> opportunityQuoteIdMap = new Map<Id,Id>();
        Set<Id> quoteId = new Set<Id>();
        //Iterate over all Quote which are being updated
        for(Quote quoterecord : newQuoteList) {
            //Check if an Quote is Accepted
            if(oldQuoteMap != null && 
               ((quoterecord.Status == 'Accepted' || quoterecord.Status == 'New Contract') &&
                oldQuoteMap.get(quoterecord.Id).Status != quoterecord.Status)) {
                    system.debug('-Inside-3');
                    opportunityQuoteMap.put(quoterecord.OpportunityId,quoterecord);
                    opportunityQuoteIdMap.put(quoterecord.OpportunityId,quoterecord.Id);
                    quoteId.add(quoterecord.Id);
                }
        }
        
        if(!opportunityQuoteMap.isEmpty()) {
            List<Opportunity> opportunityList = [SELECT Id, StageName,Send_Invoice_to_Email__c,
                                                 (SELECT Id 
                                                  FROM OpportunityContactRoles 
                                                  WHERE Role = 'Penneo Admin')
                                                 FROM Opportunity 
                                                 WHERE Id IN :opportunityQuoteMap.keySet()];
            
            system.debug('-Inside-2');
            if(!opportunityList.isEmpty()) {
                List<Opportunity> opportunityListToUpdate = new List<Opportunity>();
                for(Opportunity opportunityrecord : opportunityList) {
                    if((opportunityQuoteMap.get(opportunityrecord.Id).Status == 'Accepted' &&
                        opportunityrecord.StageName == 'Negotiation') ||
                       (opportunityQuoteMap.get(opportunityrecord.Id).Status == 'New Contract' &&
                        opportunityQuoteMap.get(opportunityrecord.Id).DPA_to_be_revised__c &&
                        opportunityrecord.StageName == 'DPA Negotiation / Review')){
                            system.debug('#--opportunityrecord.OpportunityContactRoles--#'+opportunityrecord.OpportunityContactRoles.size());
                            if(opportunityrecord.Send_Invoice_to_Email__c == null){
                                opportunityQuoteMap.get(opportunityrecord.Id)
                                    .addError('Send Invoice to Email of Opportunity field is required');
                            }
                            if(opportunityrecord.OpportunityContactRoles.size() == 1) {
                                Opportunity opp = new Opportunity();
                                opp.Id = opportunityrecord.Id;
                                opp.StageName = 'Closed Won';
                                opportunityListToUpdate.add(opp);
                            }else {
                                opportunityQuoteMap.get(opportunityrecord.Id)
                                    .addError('Required Opportunity Contact Roles Missing');
                            }
                        }
                }
                system.debug('-Inside-1');
                if(!opportunityListToUpdate.isEmpty()) {
                    //Update the OpportunityList
                    system.debug('#--opportunityListToUpdate---#'+opportunityListToUpdate);
                    update opportunityListToUpdate;
                    if(!quoteId.isEmpty()){
                        SendEmailToSalesManager.sendEmail(opportunityQuoteIdMap);
                    }
                }       
            }
        }
    }*/
}