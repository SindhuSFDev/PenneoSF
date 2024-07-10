public class CreateContactPenneoSignUser {
    @InvocableMethod(label='Create Contact')
    public static void createPenneoSignContact(List<Id> caseIds) {
        Set<String> caseEmails = new Set<String>();
        Set<String> contactEmails = new Set<String>();
        Set<String> penneoSignUserEmails = new Set<String>();
        Set<String> accountNames = new Set<String>();
        Map<String, Case> mapOfEmailVsCase = new Map<String, Case>();
        Map<String, Penneo_Sign_Users__c> mapOfEmailVsPenneoUser = new Map<String, Penneo_Sign_Users__c>();
        Map<String, String> mapOfNameVsAccId = new Map<String, String>();
        List<Contact> contactsToInsert = new List<Contact>();
        List<Case> casesToUpdate = new List<Case>();
        Map<String, String> mapOfEmailVsContactId = new Map<String, String>();
        Map<String, String> mapOfEmailVsAccountId = new Map<String, String>();
        
        List<Case> cases = [SELECT Id, SuppliedEmail FROM Case WHERE Id IN: caseIds];
        
        for (Case caseId : cases) {
            caseEmails.add(caseId.SuppliedEmail);
            mapOfEmailVsCase.put(caseId.SuppliedEmail, caseId);
        }
        
        List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE Email IN :caseEmails];
        if (!contacts.isEmpty()) {
            for (Contact c : contacts) {
                contactEmails.add(c.Email);
            }
        }
        
        List<Penneo_Sign_Users__c> penneoUsers = [SELECT Id, Real_Email__c, Full_Name__c, Account__c, Company_Name__c,
                                                  Active__c, Language__c, Penneo_Customer_ID__c, Penneo_Customer_Status__c, Penneo_UserId__c,
                                                  Roles__c, Penneo_Customer_Active__c FROM Penneo_Sign_Users__c WHERE Real_Email__c IN :caseEmails];
        if (!penneoUsers.isEmpty()) {
            for (Penneo_Sign_Users__c pu : penneoUsers) {
                if (!contactEmails.contains(pu.Real_Email__c)) {
                    penneoSignUserEmails.add(pu.Real_Email__c);
                    mapOfEmailVsPenneoUser.put(pu.Real_Email__c, pu);
                    accountNames.add(pu.Company_Name__c);
                }
            }
        }
        
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name IN :accountNames];
        if (!accounts.isEmpty()) {
            for (Account a : accounts) {
                mapOfNameVsAccId.put(a.Name, a.Id);
            }
        }
        
        for (String e : mapOfEmailVsPenneoUser.keySet()) {
            Penneo_Sign_Users__c puser = mapOfEmailVsPenneoUser.get(e);
            Contact c = new Contact();
            if(String.isNotBlank(puser.Full_Name__c)){
                if (puser.Full_Name__c.contains(' ')) {
                    c.FirstName = puser.Full_Name__c.split(' ')[0];
                    c.LastName = puser.Full_Name__c.split(' ')[1];
                } else {
                    c.LastName = puser.Full_Name__c;
                }
            }else{
                c.LastName = e;
            }
            c.Email = e;
            c.AccountId = puser.Account__c != null ? puser.Account__c : puser.Company_Name__c != null ? mapOfNameVsAccId.get(puser.Company_Name__c) : null;
            c.Penneo_Customer_Active__c = puser.Penneo_Customer_Active__c;
            c.Language__c = puser.Language__c;
            c.Penneo_Customer_ID__c = puser.Penneo_Customer_ID__c;
            c.Penneo_Customer_Status__c = puser.Penneo_Customer_Status__c;
            c.Penneo_User_ID__c = puser.Penneo_UserId__c;
            c.Penneo_User_Active__c = puser.Active__c;
            c.Penneo_User_Role__c = puser.Roles__c;
            contactsToInsert.add(c);
        }
        
        if (!contactsToInsert.isEmpty()) {
            System.debug('contactsToInsert: ' + contactsToInsert);
            insert contactsToInsert;
            for(Contact c : contactsToInsert){
                mapOfEmailVsContactId.put(c.Email, c.Id);
                mapOfEmailVsAccountId.put(c.Email, c.AccountId);
            }
            for(Case caseId : cases){
                if(mapOfEmailVsContactId.containsKey(caseId.SuppliedEmail)){
                    Case cupdate = new Case();
                    cupdate.Id = caseId.Id;
                    cupdate.ContactId = mapOfEmailVsContactId.get(caseId.SuppliedEmail);
                    cupdate.AccountId = mapOfEmailVsAccountId.get(caseId.SuppliedEmail);
                    casesToUpdate.add(cupdate);
                }
            }
        }
        if (!casesToUpdate.isEmpty()) {
            System.debug('casesToUpdate: ' + casesToUpdate);
            update casesToUpdate;
        }
    }
}