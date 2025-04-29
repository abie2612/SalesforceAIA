/*
* Author Name : Adam Chauhan
* Date        : 6/09/2024       
* Desc.       : Generating Telegram pdf when asset is created.
*/
global class GeneratePdfRelatedToAssetBatch implements Database.Batchable<sObject>
{
    Set<Id> assetIds = new Set<Id>();
    public GeneratePdfRelatedToAssetBatch(Set<Id> assetIds){
        if(assetIds != null && !(assetIds.isEmpty())){
            this.assetIds = assetIds;
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id, Amazon_Asset_Name__c FROM Asset Where id =:assetIds';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Asset> assetList)
    {
        if(assetList != null && !assetList.isEmpty()){
            String recId = assetList[0].Id;
            PageReference pdfPage = Page.GeneratePdfRelatedToAssetVisualorcePage;
            if(String.isNotBlank(recId)){
                pdfPage.getParameters().put('id', recId);
                ContentVersion cv = new ContentVersion();
                cv.Title = assetList[0].Amazon_Asset_Name__c +' - Telegram Announcement';
                cv.PathOnClient = 'Asset.pdf';
                cv.VersionData = !Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('Test content');
                INSERT cv;
                
                ContentDocumentLink objContentDocumentLink = new ContentDocumentLink();
                objContentDocumentLink.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id=: cv.Id LIMIT 1].ContentDocumentId;
                objContentDocumentLink.ShareType = 'V';
                objContentDocumentLink.LinkedEntityId = recId;
                INSERT objContentDocumentLink;
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
}