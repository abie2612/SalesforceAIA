public with sharing class SendAccountDeliveryPdfController {
    public Id RecordId {get;set;}    
    public String getPDF(){
        RecordId = ApexPages.currentPage().getParameters().get('Id');
        Set<Id> conDocumentIds = new Set<Id>();
        if(RecordId != NULL){
            Opportunity opportunity = [SELECT Id, Name, Sent_Delivery_Email__c, Opportunity_Number_Text__c, Marketplace__c, Asset_Number__c FROM Opportunity WHERE Id =: RecordId LIMIT 1];
            
            String pdfName = opportunity.Opportunity_Number_Text__c +'- '+opportunity.Marketplace__c+' Account Delivery Pdf';
            for(ContentDocumentLink conDocumentLink : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: RecordId]){
                conDocumentIds.add(conDocumentLink.ContentDocumentId);
            }
            
            List<ContentVersion> contentVersion = [SELECT Id, Title, VersionData FROM ContentVersion WHERE ContentDocumentId IN: conDocumentIds AND Title =: pdfName];
            if(!contentVersion.isEmpty()){
                return 'data:application/pdf;base64,'+EncodingUtil.base64Encode(contentVersion[0].VersionData);
            }
        }
        return null;
    }
}