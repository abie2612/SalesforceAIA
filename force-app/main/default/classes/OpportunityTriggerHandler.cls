public class OpportunityTriggerHandler {
    public static Id VENDOR_RECORDTYPEID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
    public static Id CUSTOMER_RECORDTYPEID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
    public static final String PAYMENT_DETAIL_ERROR = 'Complete payment details';
    public static final String CONTRACT_QUESTIONNAIRE_ERROR = 'Please complete Contract and Customer Questionnaire Stage first and then move forward.';
    public static final String ASSET_INTEGRATION_FROM_ASSET_TAKEOVER_ERROR = 'Opportunity Stage cannot be changed to Asset Integration, if Asset Takeover stage is not completed';
    public static final String ASSET_INTEGRATION_PAYMENT_ERROR = 'Opportunity Stage cannot be changed to Payment, if Asset Integration stage is not completed';
    public static final String CLOSED_WON_ASSET_INTEGRATION_ERROR = 'Opportunity Stage cannot be changed to Closed Won, if Asset Integration stage is not completed';
    public static final String CLOSED_WON_PAYMENT_BANK_DETAILS_ERROR = 'Opportunity Stage cannot be changed to Closed Won, until bank details are not submitted.';

    public static void updateOpportunityStage(List<Opportunity> opportunityList,Map<Id,Opportunity> opportunityMap){
        Set<Id> oppIdSet = new Set<Id>();
        for(Opportunity opportunity : opportunityList){
            if(opportunity.RecordTypeId == VENDOR_RECORDTYPEID){
                if((opportunity.Billing_Information_submitted_to_bank__c !=null && opportunityMap.get(opportunity.Id).Billing_Information_submitted_to_bank__c != opportunity.Billing_Information_submitted_to_bank__c) && (opportunity.Zelle_Email__c == null || opportunity.Bank_Account_Holder_Name__c == null || opportunity.Bank_Account_Number_1__c == null || opportunity.Bank_Account_Holder_Full_Address__c == null  || opportunity.Live_Takeover_Date__c == null || opportunity.Bank_Account_Routing_Number__c == null ||  opportunity.Invoice_No__c == null)){
                    opportunity.addError(PAYMENT_DETAIL_ERROR);
                }
                if((opportunity.Asset_Takeover_Completed__c == false && opportunity.StageName == 'Asset Integration' && opportunityMap.get(opportunity.Id).StageName != opportunity.StageName) || ((opportunity.Asset_Integration_Completed__c == false || opportunity.Asset_Takeover_Completed__c == false) && opportunity.StageName == 'Payment' && opportunityMap.get(opportunity.Id).StageName != opportunity.StageName) || ((opportunity.Asset_Integration_Completed__c == false || opportunity.Asset_Takeover_Completed__c == false || opportunity.Billing_Information_submitted_to_bank__c == null) && opportunity.StageName == 'Closed Won' && opportunityMap.get(opportunity.Id).StageName != opportunity.StageName )){
                    if(opportunity.StageName == 'Asset Integration'){
                        opportunity.addError(ASSET_INTEGRATION_FROM_ASSET_TAKEOVER_ERROR);
                    } else if(opportunity.StageName == 'Closed Won'){
                        if((opportunity.Asset_Integration_Completed__c == false || opportunity.Asset_Takeover_Completed__c == false)){
                            opportunity.addError(CLOSED_WON_ASSET_INTEGRATION_ERROR);
                        }else if(opportunity.Billing_Information_submitted_to_bank__c == null){
                            opportunity.addError(CLOSED_WON_PAYMENT_BANK_DETAILS_ERROR);
                        }
                    } else if(opportunity.StageName == 'Payment'){
                        opportunity.addError(ASSET_INTEGRATION_PAYMENT_ERROR);
                    }
                }
            }
            else if(opportunity.RecordTypeId == CUSTOMER_RECORDTYPEID){
                if(opportunity.StageName != 'Closed Lost' && opportunityMap.get(opportunity.Id).StageName == 'Contract and Customer Questionnaire' && opportunity.StageName != opportunityMap.get(opportunity.Id).StageName){
                    oppIdSet.add(opportunity.Id);
                } else if(opportunity.StageName == 'Delivery' && String.isNotBlank(opportunity.Marketplace__c) && (opportunity.Marketplace__c == 'US' || opportunity.Marketplace__c == 'UK')){
                    if(((opportunity.StageName != opportunityMap.get(opportunity.Id).StageName)  || (opportunity.Marketplace__c != opportunityMap.get(opportunity.Id).Marketplace__c)) || (opportunityMap != null && (opportunity.Merchant_Token__c != opportunityMap.get(opportunity.Id).Merchant_Token__c || opportunity.Email_Address_on_Email_Account__c != opportunityMap.get(opportunity.Id).Email_Address_on_Email_Account__c || opportunity.Email_Account_Password_Final__c != opportunityMap.get(opportunity.Id).Email_Account_Password_Final__c || opportunity.Email_QR_code__c != opportunityMap.get(opportunity.Id).Email_QR_code__c || opportunity.Store_Name__c != opportunityMap.get(opportunity.Id).Store_Name__c || opportunity.Amazon_Username__c != opportunityMap.get(opportunity.Id).Amazon_Username__c || opportunity.Store_Name__c != opportunityMap.get(opportunity.Id).Store_Name__c || opportunity.Amazon_Password__c != opportunityMap.get(opportunity.Id).Amazon_Password__c  ||  opportunity.Amazon_QR_Code__c != opportunityMap.get(opportunity.Id).Amazon_QR_Code__c || opportunity.Marketplace__c != opportunityMap.get(opportunity.Id).Marketplace__c || (opportunity.Marketplace__c == 'UK' && opportunity.Google_recovery_Phone_Number__c != opportunityMap.get(opportunity.Id).Google_recovery_Phone_Number__c)))){
                        opportunity.Delivery_PDF_Generated__c = true;
                    }
                }
            }
        }
        if(!oppIdSet.isEmpty()){
            for(Contract contract: [SELECT Id, Name, Opportunity__c, Status FROM Contract WHERE Opportunity__c IN: oppIdSet AND Status = 'Activated']){
                if(contract.Opportunity__c != null && oppIdSet.contains(contract.Opportunity__c)){
                    oppIdSet.remove(contract.Opportunity__c);
                }
            }
        }
        if(!oppIdSet.isEmpty()){
            for(Opportunity opp : opportunityList){
                if(oppIdSet.contains(opp.Id)){
                    opp.addError(CONTRACT_QUESTIONNAIRE_ERROR);
                }
            }
        }
    }
    
    //Method to run batch, if Customer's Opportunity StageName is updated to 'Delivery' OR if current Opportunity StageName is 'Delivery' and some fields of Opportunity are updated   
    public static void updateStageToDelivery(List<Opportunity> opportunityList,Map<Id,Opportunity> opportunityMap){
        Set<Id> opportunityDeliveryIds = new Set<Id>();
        
        for(Opportunity opportunity : opportunityList){
            if(opportunity.RecordTypeId == CUSTOMER_RECORDTYPEID && opportunity.StageName == 'Delivery' && String.isNotBlank(opportunity.Marketplace__c)){
                if(((opportunity.StageName != opportunityMap.get(opportunity.Id).StageName)  || (opportunity.Marketplace__c != opportunityMap.get(opportunity.Id).Marketplace__c)) || (opportunityMap != null && (opportunity.Merchant_Token__c != opportunityMap.get(opportunity.Id).Merchant_Token__c || opportunity.Email_Address_on_Email_Account__c != opportunityMap.get(opportunity.Id).Email_Address_on_Email_Account__c || opportunity.Email_Password__c != opportunityMap.get(opportunity.Id).Email_Password__c || opportunity.Email_QR_code__c != opportunityMap.get(opportunity.Id).Email_QR_code__c || opportunity.Store_Name__c != opportunityMap.get(opportunity.Id).Store_Name__c || opportunity.Store_Name__c != opportunityMap.get(opportunity.Id).Store_Name__c || opportunity.Amazon_Password__c != opportunityMap.get(opportunity.Id).Amazon_Password__c  ||  opportunity.Amazon_QR_Code__c != opportunityMap.get(opportunity.Id).Amazon_QR_Code__c || opportunity.Marketplace__c != opportunityMap.get(opportunity.Id).Marketplace__c || (opportunity.Marketplace__c == 'UK' && opportunity.Google_recovery_Phone_Number__c != opportunityMap.get(opportunity.Id).Google_recovery_Phone_Number__c)))){
                    opportunityDeliveryIds.add(opportunity.Id);
                }
            }
        }
        Map<Id,List<Id>> oppIdWithConDocumenMap = new Map<Id,List<Id>>();
        for(ContentDocumentLink conDocumentLink : [SELECT ContentDocument.Id, ContentDocument.Title, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:opportunityDeliveryIds AND ContentDocument.Title LIKE 'CUSTOPP%Account Delivery Pdf%' ORDER BY ContentDocument.CreatedDate DESC]){
            if(oppIdWithConDocumenMap != null  && oppIdWithConDocumenMap.containsKey(conDocumentLink.LinkedEntityId)){
                oppIdWithConDocumenMap.get(conDocumentLink.LinkedEntityId).add(conDocumentLink.ContentDocumentId);
            }else{
                oppIdWithConDocumenMap.put(conDocumentLink.LinkedEntityId, new List<Id>{conDocumentLink.ContentDocumentId});    
            }
        }
        
        if(!opportunityDeliveryIds.isEmpty()){
            Database.executeBatch(new AccountDeliveryPdfBatch(opportunityDeliveryIds, oppIdWithConDocumenMap),1);
        }    
    }
        
    public static void syncOpportunityToAsset(List<Opportunity> opportunityList, Map<Id, Opportunity> oldMap) {
        Map<String, String> customSettingMap = new Map<String, String>();
        List<Id> oppIdList = new List<Id>();
        String queryString = '';
        
        try{
            List<Opportunity_Asset_Field_Mapping__c> oppAssetField = Opportunity_Asset_Field_Mapping__c.getAll().values();
            for (Opportunity_Asset_Field_Mapping__c fieldName : oppAssetField) {
                customSettingMap.put(fieldName.Opportunity_Field__c, fieldName.Asset_Field__c);
                queryString += fieldName.Opportunity_Field__c + ', ';
            }
            if(String.isNotBlank(queryString) && customSettingMap != NULL && !customSettingMap.isEmpty()){
                queryString = queryString.removeEnd(', ');
                for (Opportunity opp : opportunityList) {
                    if(opp.RecordTypeId == VENDOR_RECORDTYPEID && opp.StageName == 'Closed Won'){
                        Opportunity oldOpp = oldMap.get(opp.Id);
                        for (String oppField : customSettingMap.keySet()) {
                            if (oldOpp != null && opp.get(oppField) != oldOpp.get(oppField)) {
                                oppIdList.add(opp.Id);
                            }
                        }
                    }
                }
            }
            if (!oppIdList.isEmpty()) {
                UtilityController.opportunityToAssetMapping(oppIdList,queryString,customSettingMap);
            }
        } catch(Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'OpportunityTriggerHandler');
            if(e != NULL) Database.insert(e);
        }
    }
}