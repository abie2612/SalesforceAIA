/*
* Author Name : Adam Chauhan
* Date        : 21/10/2024  
* Description : Insertng, Updating record in Wordpress corresponding to Salesforce Asset's Object Record
*/
public class BatchSendDataOnWordPress implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    public Set<Id> assetIds; 
    public String triggeringEvent;
    
    public BatchSendDataOnWordPress(Set<Id> assetIds,String triggeringEvent) {
        this.assetIds = assetIds;
        this.triggeringEvent=triggeringEvent;
    }
    public Database.QueryLocator start(Database.BatchableContext BC)
    {   
        String queryString;
        if(String.isNotBlank(triggeringEvent)){
            {
                queryString = 'SELECT Amazon_Asset_Name__c, Sale_Price__c,Feedback__c,Stars_Store_Feedback__c,Brands_approved__c,Categories_Approved__c,format(Sales_History_All_Time__c) saleHistoryAllTime,format(Sales_History_Year_to_Date__c) saleHistoryYearToDate, Overall_Units_Sold__c,Marketplace__c,Additional_Marketplaces__c,Creation_Date__c,Special_Account_Type__c, Delivered__c, WordPress_AssetId__c FROM Asset WHERE (Sale_Price__c != null AND Sold__c = false AND Paid_Deposit__c = false AND On_Hold__c = false AND Delivered__c = false) AND Is_Test__c = '+System.label.Test_Asset_On_Wordpress;
                if(!assetIds.isEmpty()) {
                    queryString += ' AND Id IN : assetIds'; 
                }
            }     
            return Database.getQueryLocator(queryString);
        }
        return null;
    }
    public void execute(Database.BatchableContext BC, List<Asset> astList)
    {
        try {
            Asset assetRecord = astList[0];
            String jsonBody = WordPressDataService.prepareWordPressJson(assetRecord);
            
            if(assetRecord != null && System.label.WordPress_EndPointURL != null && System.label.WordPress_AuthHeader != null){
                // For Inserting Account record in WordPress, corresponding to asset record in salesforce and update WordPress_AssetId__c
                if(triggeringEvent == 'Insert'){
                    Map<String, Object> assetData = new Map<String, Object>(); 
                    HttpResponse response = new HTTPCalloutCTRL().setEndPoint(System.label.WordPress_EndPointURL).setMethod('POST').setHeader(new Map<String, String>{'Authorization' => 'Basic '+System.label.WordPress_AuthHeader, 'Content-Type' => 'application/json'}).setBody(jsonBody).makeCallout();
                    if(response != NULL && String.isNotBlank(response.getBody())){
                        assetData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    }
                    if(assetData.containsKey('id')){
                        assetRecord.WordPress_AssetId__c = ''+assetData.get('id');
                        UPDATE assetRecord;
                    }
                // For Updating record in WordPress to further, corresponding to asset record in salesforce
                } else if(triggeringEvent == 'Update'){
                    HttpResponse response = new HTTPCalloutCTRL().setEndPoint(System.label.WordPress_EndPointURL+'/'+assetRecord.WordPress_AssetId__c).setMethod('POST').setHeader(new Map<String, String>{'Authorization' => 'Basic '+System.label.WordPress_AuthHeader, 'Content-Type' => 'application/json'}).setBody(jsonBody).makeCallout();
                }
            } 
        } catch (Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'BatchSendDataOnWordPress');
            if(e != NULL) Database.insert(e);
            System.debug('Error : ' + exp.getMessage());
        }
    }
    public void finish(Database.BatchableContext BC) {
        
    }
}