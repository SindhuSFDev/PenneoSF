public class CreateDocumentLinkAgainstCase implements Database.Batchable<SObject>{
    
	public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator('Select id,File_Upload_Id_For_Site_User__c '+
                                      ' from Case where isFileCreated__c = false and File_Upload_Id_For_Site_User__c != null');
   }
 
   public void execute(Database.BatchableContext BC, List<Case> scope){
       try{
       Map<String ,Id> fileVsCaseId = new Map<String,Id>();
       for(Case caseTemp : scope){
           caseTemp.isFileCreated__c = true;
           fileVsCaseId.put(caseTemp.File_Upload_Id_For_Site_User__c, caseTemp.Id);
       }
       
      List<ContentVersion> contVersionList = [Select id,Guest_Record_fileupload__c,ContentDocumentId 
                                          from contentVersion where Guest_Record_fileupload__c in: fileVsCaseId.keyset()];
       system.debug('#--contVersionList---#'+contVersionList);
       List<ContentDocumentLink> documentList = new List<ContentDocumentLink>();
       for(ContentVersion version : contVersionList){
           if(String.isNotEmpty(version.Guest_Record_fileupload__c) && fileVsCaseId.containsKey(version.Guest_Record_fileupload__c)){
               ContentDocumentLink document = new ContentDocumentLink();
               document.LinkedEntityId = fileVsCaseId.get(version.Guest_Record_fileupload__c);
               document.ContentDocumentId = version.ContentDocumentId;
               documentList.add(document);
           }
       }
       
       if(!documentList.isEmpty()){
           insert documentList;
           update scope;
       }
       
       
       }catch(Exception e){
           system.debug('#---#'+e.getMessage());
       }
    }
 
   public void finish(Database.BatchableContext BC){
   }
}