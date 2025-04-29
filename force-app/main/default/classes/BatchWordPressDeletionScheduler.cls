/*
* Author Name : Adam Chauhan
* Date        : 28/01/2025  
* Description : Scheduling Deletion of Account record in Wordpress corresponding to updation of Salesforce Asset's 'Delivered__c' field. If we check 'Delivered__c' then corresponding Account record in Wordpress will be delete after days given in  custom label 'Date_of_Asset_Sold'
* System.schedule('Delete WordPress Record','0 30 25 * * ?', new BatchWordPressDeletionScheduler());
*/

public class BatchWordPressDeletionScheduler implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable {
    Set<Id> setOfAssetIds = new Set<Id>();
    Boolean instantDelete = false;
    List<Asset> assetToBeUpdated = new List<Asset>();
    public BatchWordPressDeletionScheduler(Set<Id> assetIds, Boolean instantDelete) {
        this.setOfAssetIds = assetIds;
        this.instantDelete = instantDelete;
    }
    public BatchWordPressDeletionScheduler(){}
    
    public void execute(SchedulableContext SC) {
        Database.executebatch(new BatchWordPressDeletionScheduler(),1);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {  
        String queryString = 'SELECT Id, WordPress_AssetId__c FROM Asset WHERE WordPress_AssetId__c != NULL AND Is_Test__c = '+System.label.Test_Asset_On_Wordpress;
        if(!instantDelete){
            queryString += ' AND (Delivered__c = true AND Asset_Sold_Date__c = ' + String.valueOf(Date.today().addDays(-(Integer.valueof(System.label.Date_of_Asset_Sold)))).removeEnd(' 00:00:00')+')';
        }
		if(!setOfAssetIds.isEmpty()){
            queryString += ' AND Id IN: setOfAssetIds';
        }
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<Asset> assetList) {
        try{
            Asset assetRecord = assetList[0];
            if(System.label.WordPress_AuthHeader != NULL){
                HttpResponse response = new HTTPCalloutCTRL().setEndPoint(System.label.WordPress_EndPointURL+'/'+assetRecord.WordPress_AssetId__c).setMethod('DELETE').setHeader(new Map<String, String>{'Authorization' => 'Basic '+System.label.WordPress_AuthHeader}).makeCallout();
                if(response != null && (response.getStatusCode() == 200 || response.getStatusCode() == 201)){
                    assetRecord.WordPress_AssetId__c = '';
                    assetToBeUpdated.add(assetRecord);
                }
             }
        }
        catch (Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'BatchWordPressDeletionScheduler');
            if(e != NULL) Database.insert(e);
        }    
    }
    
    public void finish(Database.BatchableContext BC) {
        if(!assetToBeUpdated.isEmpty()){
            UPDATE assetToBeUpdated;
        }
    } 
}