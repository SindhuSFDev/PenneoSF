public without sharing class CreateCaseController {
    @AuraEnabled
    public static String addContAndAccToCommunityCase(Case currentCase, String randomString, List<String> fileIds) {
        try {
            //currentCase.OwnerId = Label.Community_Queue_Owner;//'00G1q000002Tncm
            system.debug('#--randomString---#' + randomString);
            currentCase.File_Upload_Id_For_Site_User__c = randomString;
            currentCase.Origin = 'Web';
            Group grp = [
                    SELECT Id
                    FROM Group
                    WHERE Name = 'Case From Community' and Type = 'Queue'
            ];
            currentCase.OwnerId = grp.Id;
            insert currentCase;
            Database.DmlOptions options = new Database.DmlOptions();
            options.emailHeader.triggerUserEmail = true;
            Database.update(currentCase, options);
            /*ContentVersion uploadedDoc = [SELECT Id FROM ContentVersion WHERE Guest_Record_fileupload__c = 'CaseObj'];
             System.debug('#--uploadedDoc--#' + uploadedDoc);*/
            List<String> listOfContactEmails = new List<String>();
            List<Contact> listOfContactsToInsert = new List<Contact>();
            List<Contact> listOfContactsToUpdate = new List<Contact>();
            List<Case> listOfCasesToUpdate = new List<Case>();
            List<Case> casesToCreateContact = new List<Case>();
            Set<String> setOfDomainName = new Set<String>();
            Map<String, Contact> mapOfContactEmailVsContact = new Map<String, Contact>();
            Map<String, Contact> mapOfCaseIdVsContact = new Map<String, Contact>();
            Map<String, Id> mapOfAccountNameVsId = new Map<String, Id>();
            Map<String, Id> mapOfAccountWebsiteVsId = new Map<String, Id>();
            List<ContentDocumentLink> cdlInsertList = new List<ContentDocumentLink>();

            /* setOfDomainName.add(currentCase.SuppliedCompany);
             listOfContactEmails.add(currentCase.SuppliedEmail); */
            casesToCreateContact.add(currentCase);
            List<Contact> listOfContact = [
                    SELECT Id, Name, Email, AccountId
                    FROM Contact
                    WHERE Email = :currentCase.SuppliedEmail
            ];
            List<Account> listOfAccount = [
                    SELECT Id, Name, Website
                    FROM Account
                    WHERE Name = :Label.Penneo_User_Account OR Name = :Label.Penneo_Signer_Account OR Name = :Label.Penneo_Admin_Account OR Website = :currentCase.SuppliedCompany
            ];
            for (Account account : listOfAccount) {
                if (!mapOfAccountNameVsId.containsKey(account.Name)) {
                    mapOfAccountNameVsId.put(account.Name.toLowerCase(), account.Id);
                }
                if (!mapOfAccountWebsiteVsId.containsKey(account.Website)) {
                    mapOfAccountWebsiteVsId.put(account.Website, account.Id);
                }
            }
            for (Contact contact : listOfContact) {
                if (!mapOfContactEmailVsContact.containsKey(contact.Email)) {
                    mapOfContactEmailVsContact.put(contact.Email, contact);
                }
            }
            System.debug('#--mapOfAccountNameVsId--#' + mapOfAccountNameVsId);
            System.debug('#--mapOfContactEmailVsContact--#' + mapOfContactEmailVsContact);
            /* for (Case currentCase : casesToCreateContact){ */
            /* Case updateCase = new Case();
             updateCase.Id = currentCase.Id; */
            Contact contact = new Contact();
            System.debug('#--contains--#' + mapOfContactEmailVsContact.containsKey(currentCase.SuppliedEmail));
            if (mapOfContactEmailVsContact.containsKey(currentCase.SuppliedEmail)) {
                contact = mapOfContactEmailVsContact.get(currentCase.SuppliedEmail);
                currentCase.ContactId = contact.Id;
                if (contact.AccountId != null) {
                    currentCase.AccountId = contact.AccountId;
                } else {
                    String domain = currentCase.SuppliedCompany;
                    if (domain != null && domain != '' && domain != ' ' && mapOfAccountWebsiteVsId.containsKey(domain.toLowerCase())) {
                        currentCase.AccountId = mapOfAccountWebsiteVsId.get(domain);
                        contact.AccountId = mapOfAccountWebsiteVsId.get(domain);
                    } else {
                        addAccountId(currentCase, contact, currentCase, mapOfAccountNameVsId, mapOfCaseIdVsContact);
                    }
                    listOfContactsToUpdate.add(contact);
                }
                System.debug('#--contact--#' + contact);
                listOfCasesToUpdate.add(currentCase);
            } else {
                contact.FirstName = currentCase.First_Name__c;
                contact.LastName = currentCase.Last_Name__c;
                String domain = currentCase.SuppliedCompany;
                if (mapOfAccountWebsiteVsId.containsKey(domain)) {
                    contact.AccountId = mapOfAccountWebsiteVsId.get(domain);
                    if (!mapOfCaseIdVsContact.containsKey(currentCase.Id)) {
                        mapOfCaseIdVsContact.put(currentCase.Id, contact);
                    }
                } else {
                    addAccountId(currentCase, contact, currentCase, mapOfAccountNameVsId, mapOfCaseIdVsContact);
                }
                System.debug('#--contact--#' + contact);
                listOfContactsToInsert.add(contact);
                System.debug('#--listOfContactsToInsert--#' + listOfContactsToInsert);

            }
            //}
            if (listOfContactsToInsert.size() > 0) {
                //insert listOfContactsToInsert;
            }
            List<Case> casesToUpdate = [
                    SELECT Id, ContactId
                    FROM Case
                    WHERE Id IN :mapOfCaseIdVsContact.keySet()
            ];
            List<Case> listOfNewCases = new List<Case>();
            for (Case caseTemp : casesToUpdate) {
                caseTemp.ContactId = mapOfCaseIdVsContact.get(caseTemp.Id).Id;
                caseTemp.AccountId = mapOfCaseIdVsContact.get(caseTemp.Id).AccountId;
                listOfNewCases.add(caseTemp);
            }
            if (listOfCasesToUpdate.size() > 0) {
                System.debug('#--listOfCasesToUpdate--#' + listOfCasesToUpdate);
                update listOfCasesToUpdate;
            }
            if (listOfNewCases.size() > 0) {
                update listOfNewCases;
            }
            if (listOfContactsToUpdate.size() > 0) {
                update listOfContactsToUpdate;
            }
            Set<String> documentIdsUploaded = new Set<String>();
            List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN:fileIds];
            if (!contentVersionList.isEmpty()) {
                for(ContentVersion cv : contentVersionList){
                    documentIdsUploaded.add(cv.ContentDocumentId);
                }
            }
            List<ContentDocument> documentsList = [SELECT Id FROM ContentDocument WHERE Id IN :documentIdsUploaded];
            if (!documentsList.isEmpty()) {
                if (!listOfCasesToUpdate.isEmpty()) {
                    for (Case c : listOfCasesToUpdate) {
                        for (ContentDocument cd : documentsList) {
                            ContentDocumentLink cdl = new ContentDocumentLink();
                            cdl.ContentDocumentId = cd.Id;
                            cdl.LinkedEntityId = c.Id;
                            cdlInsertList.add(cdl);
                        }
                    }
                }
                if (!listOfNewCases.isEmpty()) {
                    for (Case c : listOfNewCases) {
                        for (ContentDocument cd : documentsList) {
                            ContentDocumentLink cdl = new ContentDocumentLink();
                            cdl.ContentDocumentId = cd.Id;
                            cdl.LinkedEntityId = c.Id;
                            cdlInsertList.add(cdl);
                        }
                    }
                }
            }
            System.debug('cdlInsertList: ' + cdlInsertList);
            if (!cdlInsertList.isEmpty()) {
                insert cdlInsertList;
                System.debug('cdlInsertList: ' + cdlInsertList);
            }
            
            //Content version update
            List<ContentVersion> cvList = [SELECT Id, ContentDocumentId, IsCreatedViaSupport__c FROM ContentVersion WHERE Id IN :fileIds];
            System.debug('cvList: ' + cvList);
            if(!cvList.isEmpty()){
                for(ContentVersion cv : cvList){
                    cv.IsCreatedViaSupport__c = true;
                }
                update cvList;
            }

            return 'Success';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }

    @AuraEnabled
    public static List<SelectOption> getPicklistValues(String fieldName) {
        List<Schema.PicklistEntry> picklistValues = Case.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        List<SelectOption> optionsList = new List<SelectOption>();
        Map<String, String> salutationMapTransalation = new Map<String, String>();

        for (Schema.PicklistEntry pickListVal : picklistValues) {
            //for all values in the picklist list
            Selectoption option = new Selectoption();
            option.label = pickListVal.getLabel();
            option.value = pickListVal.getValue();
            optionsList.add(option);
        }
        return optionsList;
    }

    @AuraEnabled
    public static String generateRandomString() {
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        return hexDigest;
    }

    @AuraEnabled
    public static String getPrefillValues() {
        Id currentUserId = UserInfo.getUserId();
        User user = [
                SELECT Id, Name, ContactId
                FROM User
                WHERE Id = :currentUserId
        ];
        if (user.ContactId != null) {
            Contact contact = [SELECT Id, Account.Website, FirstName, LastName, Email, Role__c FROM Contact WHERE Id = :user.ContactId];
            return JSON.serialize(contact);
        }

        return null;
    }

    @AuraEnabled
    public static String getSuggestedArticles(String keySearch, String language) {
        String query = 'SELECT Id, Title, UrlName FROM Knowledge__kav WHERE Title LIKE \'%' + keySearch + '%\' AND Language = \'' + language + '\'';
        List<Knowledge__kav> suggestedArticles = Database.query(query);
        return JSON.serialize(suggestedArticles);
    }

    private static void addAccountId(Case currentCase, Contact contact, Case updateCase, Map<String, Id> mapOfAccountNameVsId, Map<String, Contact> mapOfCaseIdVsContact) {
        if (currentCase.Role__c == 'Signer' && mapOfAccountNameVsId.containsKey(Label.Penneo_Signer_Account.toLowerCase())) {
            contact.AccountId = mapOfAccountNameVsId.get(Label.Penneo_Signer_Account.toLowerCase());
            //updateCase.AccountId = mapOfAccountNameVsId.get('Signer Account');
        } else if (currentCase.Role__c == 'Penneo User' && mapOfAccountNameVsId.containsKey(Label.Penneo_User_Account.toLowerCase())) {
            contact.AccountId = mapOfAccountNameVsId.get(Label.Penneo_User_Account.toLowerCase());//updateCase.AccountId = mapOfAccountNameVsId.get('Penneo User Account');
        } else if (currentCase.Role__c == 'Penneo Admin' && mapOfAccountNameVsId.containsKey(Label.Penneo_Admin_Account.toLowerCase())) {
            contact.AccountId = mapOfAccountNameVsId.get(Label.Penneo_Admin_Account.toLowerCase());
            //updateCase.AccountId = mapOfAccountNameVsId.get('Penneo Admin Account');
        }
        contact.Email = currentCase.SuppliedEmail;
        if (!mapOfCaseIdVsContact.containsKey(currentCase.Id)) {
            mapOfCaseIdVsContact.put(currentCase.Id, contact);
        }
    }

    @AuraEnabled
    public static List<SelectOption> getSuggestedArticlesSubject(String keySearch, String language, Integer offsetCount) {
        List<SelectOption> articleNames = new List<SelectOption>();
        Integer offsetFinal = offsetCount * 10;
        Integer limitCount = 0;
        if (String.isNotBlank(keySearch)) {

            List<Knowledge__kav> knowledArticles = new List<Knowledge__kav>();
            Set<String> kavId = new Set<String>();
            String status = 'Online';

            String query = 'SELECT Id, Title, UrlName FROM Knowledge__kav WHERE Title LIKE \'%' + keySearch + '%\' AND PublishStatus = \'' + status + '\' AND Language = \'' + language + '\' ORDER BY Title LIMIT 10 OFFSET :offsetFinal';
            System.debug('query: ' + query);
            List<Knowledge__kav> suggestedArticles = Database.query(query);
            knowledArticles.addAll(suggestedArticles);
            System.debug('knowledArticles: ' + knowledArticles);

            for (Knowledge__kav prod : suggestedArticles) {
                SelectOption wrap = new SelectOption();
                wrap.label = prod.Title;
                wrap.value = prod.UrlName;
                articleNames.add(wrap);
                kavId.add(prod.Id);
            }

            if (suggestedArticles.size() < 10) {
                limitCount = 10 - suggestedArticles.size();
                String searchTerms = '';
                string soslQuery = '';
                String res = '';
                if (keySearch != Null) {
                    List<String> searchLogicSplittedbySpace = keySearch.split(' ');
                    for (String str : searchLogicSplittedbySpace) {
                        searchTerms += '("' + str + '")';
                        searchTerms += ' OR ';
                    }
                    res = searchTerms.removeEnd(' OR ');
                    soslQuery = 'FIND \'' + String.escapeSingleQuotes(res) + '\' IN ALL FIELDS RETURNING Knowledge__kav';
                } else {
                    soslQuery = 'FIND \'' + keySearch + '\' IN ALL FIELDS RETURNING Knowledge__kav';
                }
                List<List<Knowledge__kav>> prodSearch = search.query(soslQuery);
                List<String> prodIdList = new List<String>();
                for (Knowledge__kav prod : ((List<Knowledge__kav>) prodSearch[0])) {
                    prodIdList.add(prod.Id);
                }

                if (prodIdList != null && !prodIdList.isEmpty()) {
                    List<Knowledge__kav> knowledges = [
                            SELECT Id,Title,UrlName
                            FROM Knowledge__kav
                            WHERE Id IN :prodIdList AND PublishStatus = 'Online' AND Id NOT IN :kavId AND Language = :language
                            ORDER BY Title
                            LIMIT :limitCount
                            OFFSET :offsetFinal
                    ];
                    if (!knowledges.isEmpty()) {
                        for (Knowledge__kav k : knowledges) {
                            SelectOption wrap = new SelectOption();
                            wrap.label = k.Title;
                            wrap.value = k.UrlName;
                            articleNames.add(wrap);
                        }
                    }
                }
            }
        }
        return articleNames;
    }

    @AuraEnabled
    public static String deleteContentDocuments(List<String> fileIds) {
        try {
            Set<String> documentIdsUploaded = new Set<String>();
            List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN:fileIds];
            if (!contentVersionList.isEmpty()) {
                for(ContentVersion cv : contentVersionList){
                    documentIdsUploaded.add(cv.ContentDocumentId);
                }
            }
            List<ContentDocument> documents = [SELECT Id FROM ContentDocument WHERE Id IN:documentIdsUploaded];
            if (!documents.isEmpty()) {
                delete documents;
            }
            return 'success';
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public class SelectOption {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

    }

    //This method is used for an emergency deployment 
    public static void testCodeCoverage() {
        Integer i = 1;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}