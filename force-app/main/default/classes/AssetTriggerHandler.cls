/*
* Author Name 			: Adam Chauhan
* Date        			: 21/10/2024     
* Last Modified By		: Axel Bagra
* Last Modified Date 	: 25/11/2024
*/

public class AssetTriggerHandler {
    
    // On Before Insert and Update
    public static void beforeInsertUpdate(List<Asset> newAssets, Map<Id,Asset> oldAssetMap) {
        try{
            for(Asset asset: newAssets){
                if(oldAssetMap == null || (oldAssetMap != null && (oldAssetMap.get(asset.Id).Brands_approved__c != asset.Brands_approved__c))){
                    if(String.isNotBlank(asset.Brands_approved__c) && asset.Brands_approved__c.contains(',')){
                        List<String> brands = asset.Brands_approved__c.split(',');
                        Asset.Number_of_Additional_Approved_Brands__c = brands != null && brands.size()>49 ? brands.size() - 49 : 0;
                    } else{
                        Asset.Number_of_Additional_Approved_Brands__c = 0;
                    }
                }
                if(oldAssetMap == null || (oldAssetMap != null && (oldAssetMap.get(asset.Id).Categories_Approved__c != asset.Categories_Approved__c))){
                    if(String.isNotBlank(asset.Categories_Approved__c) && asset.Categories_Approved__c.contains(',')){
                        List<String> categories = asset.Categories_Approved__c.split(',');
                        Asset.Number_of_Additional_Open_Categories__c = categories != null && categories.size()>49 ? categories.size() - 49 : 0;
                    } else{
                        Asset.Number_of_Additional_Open_Categories__c = 0;
                    }
                }
                if((oldAssetMap == null && asset.Delivered__c == true) || (asset.Delivered__c == true && oldAssetMap.get(asset.Id).Delivered__c != True)){
                    asset.Asset_Sold_Date__c = System.today();
                }
            }
        } catch (Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'AssetTriggerHandler');
            if(e != NULL) Database.insert(e);
            System.debug('Error : ' + exp.getMessage());
        }
    }
    
    // On After Insert
    public static void afterInsert(List<Asset> newAssets) {
        Set<Id> assetIds = new Set<Id>();
        //Passing asset records having 'WordPress_AssetId__c' to Batch 'BatchSendDataOnWordPress on Insert'
        try{
            for(Asset asset: newAssets) {
                assetIds.add(asset.Id);
            }
            if(!assetIds.isEmpty()){
                Database.executeBatch(new GeneratePdfRelatedToAssetBatch(assetIds),1);
                Database.executeBatch(new BatchSendDataOnWordPress(assetIds,'Insert'),1);
            }
        } catch (Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'AssetTriggerHandler');
            if(e != NULL) Database.insert(e);
            System.debug('Error : ' + exp.getMessage());
        }
    }
    
    // On After Update
    public static void afterUpdate(List<Asset> newAssets, Map<Id,Asset> oldAssets) {
        Set<Id> assetIds = new Set<Id>();
        Set<Id> assetToBeDeletedFromWordpress = new Set<Id>();
        Set<Id> assetToBeInsertedOnWordpress = new Set<Id>();
        Set<String> wordPressAssetId = new Set<String>();
        //Passing asset records having 'WordPress_AssetId__c' to Batch 'BatchSendDataOnWordPress on Update'
        try {
            for(Asset asset: newAssets) {
                if(String.isNotBlank(asset.WordPress_AssetId__c)){
                    if((asset.Sale_Price__c == null && oldAssets.get(asset.Id).Sale_Price__c != null) || (asset.Sold__c && !oldAssets.get(asset.Id).Sold__c) || (asset.Paid_Deposit__c && !oldAssets.get(asset.Id).Paid_Deposit__c) || (asset.On_Hold__c && !oldAssets.get(asset.Id).On_Hold__c)){
                        assetToBeDeletedFromWordpress.add(asset.Id);
                    } else{
                        assetIds.add(asset.Id); 
                    }
                } else{
                    if((!asset.Sold__c && !asset.Paid_Deposit__c && !asset.On_Hold__c && !asset.Delivered__c && asset.Sale_Price__c != null) && ((!asset.Sold__c && oldAssets.get(asset.Id).Sold__c) || (!asset.Paid_Deposit__c && oldAssets.get(asset.Id).Paid_Deposit__c) || (!asset.On_Hold__c && oldAssets.get(asset.Id).On_Hold__c) || (!asset.Delivered__c && oldAssets.get(asset.Id).Delivered__c) || (asset.Sale_Price__c != null && oldAssets.get(asset.Id).Sale_Price__c == null) )){
                        assetToBeInsertedOnWordpress.add(asset.Id);
                    }
                }
                
            }
            if(!assetToBeDeletedFromWordpress.isEmpty()){
                Database.executeBatch(new BatchWordPressDeletionScheduler(assetToBeDeletedFromWordpress, true),1);        
            }
            if(!assetToBeInsertedOnWordpress.isEmpty()){
                Database.executeBatch(new BatchSendDataOnWordPress(assetToBeInsertedOnWordpress,'Insert'),1);        
            }
            if(!assetIds.isEmpty()){
                Database.executeBatch(new BatchSendDataOnWordPress(assetIds,'Update'),1);        
            }
        } catch (Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'AssetTriggerHandler');
            if(e != NULL) Database.insert(e);
            System.debug('Error : ' + exp.getMessage());
        }
    }
    
    public static void syncAssetToOpportunity(List<Asset> assetList, Map<Id, Asset> oldMap) {
        Map<String, String> customSettingMap = new Map<String, String>();
        List<Id> astIdList = new List<Id>();
        String queryString = '';
        
        try{
            List<Opportunity_Asset_Field_Mapping__c> oppAssetField = Opportunity_Asset_Field_Mapping__c.getAll().values();
            for (Opportunity_Asset_Field_Mapping__c fieldName : oppAssetField) {
                customSettingMap.put(fieldName.Asset_Field__c, fieldName.Opportunity_Field__c);
                queryString += fieldName.Asset_Field__c + ', ';
            }
            
            if(String.isNotBlank(queryString) && customSettingMap != NULL && !customSettingMap.isEmpty()){
                queryString = queryString.removeEnd(', ');
                for (Asset ast : assetList) {
                    Asset oldAsset = oldMap.get(ast.Id);
                    for (String astField : customSettingMap.keySet()) {
                        if (oldAsset != null && ast.get(astField) != oldAsset.get(astField)) {
                            astIdList.add(ast.Id);
                        }
                    }
                }
            }
            if (!astIdList.isEmpty()) {
                UtilityController.assetToOpportunityMapping(astIdList,queryString,customSettingMap);
            }
        } catch(Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'AssetTriggerHandler');
            if(e != NULL) Database.insert(e);
            System.debug('Error : ' + exp.getMessage());
        }
    }
    
}