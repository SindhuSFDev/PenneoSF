@IsTest
public class TestDataFactory{
    @IsTest
    public static List<Case> createSampleCases(){
        system.debug('in sample case');
        List<Case> listOfCases = [SELECT Id, Subject
                                  FROM Case];
        if (!listOfCases.isEmpty()){
            return listOfCases;
        } else{
            List<Case> listOfCasesToInsert = new List<Case>();
            Contact cont = new Contact(LastName = 'Test Contact', Email = 'test@test.com');
            insert cont;
            for (Integer key = 0; key < 5; key++){
                Case caseObj = new Case();
                caseObj.Subject = 'Test' + key;
                
                caseObj.Priority = 'High';
                caseObj.ContactId = cont.Id;
                if (key < 3){
                    caseObj.Status = 'pending';
                    caseObj.Country__c = 'Denmark';
                } else{
                    caseObj.Status = 'open';
                    caseObj.Country__c = 'India';
                }
                listOfCasesToInsert.add(caseObj);
            }
            insert listOfCasesToInsert;
            return listOfCasesToInsert;
        }
    }
    
    public static List<Opportunity> createSampleOpportunities(){
        List<Opportunity> opptList = new List<Opportunity>();
        
        Account acc = new Account();
        acc.Name = 'Penneo Test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Opportunity 1';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today() + 30;
        opp.LeadSource = 'Inbound';
        opp.StageName = 'Preparation';
        opp.Type = 'New Business';
        opp.Penneo_Solution__c = 'Penneo Sign';
        opptList.add(opp);
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Opportunity 2';
        opp1.AccountId = acc.Id;
        opp1.CloseDate = System.today() + 30;
        opp1.LeadSource = 'Inbound';
        opp1.StageName = 'Preparation';
        opp1.Type = 'Upsell';
        opp1.Penneo_Solution__c = 'Penneo Sign';
        opptList.add(opp1);
        
        insert opptList;
        return opptList;      
    }   
}