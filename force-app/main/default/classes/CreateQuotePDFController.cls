public without sharing class CreateQuotePDFController {
    
    @AuraEnabled
    public static String init(String recordID){
        try {
            Quote qt = [SELECT Id, Status FROM Quote WHERE Id =: recordID];
            List<String> invalidQuoteStatus = Label.OrderConfirmationPDF_Invalid_Quote_Status.split(';');
            if(invalidQuoteStatus.contains(qt.Status)) {
                return 'invalid';
            } else {
                return 'valid';
            }
        }catch (Exception e) {
            system.debug('## Error :'+e.getMessage()+' @ Line : '+e.getLineNumber());
            return 'error';
        }
    }
    
    @AuraEnabled
    public static string createQuotePDF(String recordID){
        try {
            Quote qt = [SELECT Id, Name FROM Quote WHERE Id =: recordID];
            PageReference pge = new PageReference('/apex/OrderConfirmationPDF?id='+recordID);
            Blob b;
            if(Test.isRunningTest()) { 
                b = blob.valueOf('Unit.Test');
            } else {
                b = pge.getContentAsPDF();
            }
            
            
            QuoteDocument qd = new QuoteDocument();
            qd.QuoteId = qt.Id;
            qd.document = b;
            insert qd;
            
            return 'success';
            
        }catch (Exception e) {
            system.debug('## Error :'+e.getMessage()+' @ Line : '+e.getLineNumber());
            return 'error';
        }
    }
}