/**
* @description       : 
* @author            : Adam
* @group             : 
* @last modified on  : 08-27-2024
* @last modified by  : Axel Bagra
**/
public class ProductListController {
    
    //Retrieves product data from the Product2 object with specific fields.
    @AuraEnabled
    public static Map<String,Object> getProductData(String leadId) {
        Map<String,Object> result = new Map<String,Object>();
        try {
            Boolean checkTestRecord = checkTestRecordMethod(leadId);
            
            result.put('STATUS', 'SUCCESS');
            List<Product2> products = [SELECT Id, Amazon_Asset__r.Amazon_Asset_Name__c,Non_Amazon_Platform__c,Amazon_Account_Type__c,Sale_Price__c,Account_Type__c,Special_Account_Type__c,Creation_Date__c,Earliest_account_statement_date__c,Marketplace__c,Additional_Marketplaces__c,US_Citizen_Owner__c,Feedback__c,Stars_Store_Feedback__c,Positive_Feedback_USA__c,Health_Assurance_Score__c,IPI__c,Categories_Approved__c,Brands_approved__c,ASINs_approved__c,Refurbished__c,Hazmat__c,Hazmat_Aerosol_Storage_Limit__c,Hazmat_Flammable_Storage_Limit__c,Non_Standard_Inventory_Limits__c,Fulfillment__c,Brand_Registry__c,Eligible_for_Amazon_Loan__c,SFP_Eligible__c,Sales_History_All_Time__c,Recent_Sales_Within_12_months__c,Recent_Sales_Within_3_months__c,Sales_History_Year_to_Date__c,Sales_History_2_Years_to_Date__c,Overall_Units_Sold__c,LLC_Asset__c FROM Product2 WHERE Is_Sold__c = False AND  Amazon_Asset__c != null AND Is_Test__c =: checkTestRecord AND Sale_Price__c != NULL];
            result.put('PRODUCTS', products);
        } catch(Exception e) {
            result.put('STATUS', 'ERROR');
            result.put('ERROR', e.getMessage());
        }
        return result;
    }
    
    
    //Sends an email to a lead regarding a specific product
    @AuraEnabled public static Map<String,Object> sendEmail(String productId, String leadId, Boolean createNewProductProposal) {
        try{
            if(String.isNotBlank(productId) && String.isNotBlank(leadId)){
                //Fetch email template
                List<EmailTemplate> emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='Asset_match_email_template' LIMIT 1];
                if(emailTemplate.isEmpty()){
                    return errorMap('Email Template Not Found');
                }
                //Fetch lead details
                List<Lead> leadList = [SELECT Id, Name, Email FROM Lead WHERE Id =: leadId LIMIT 1];
                if(leadList.isEmpty() || String.isBlank(leadList[0].Email)){
                    return errorMap('Lead not found or Email is blank');
                }
                //Construct and send the email
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{leadList[0].Email});
                mail.setTargetObjectId(leadId);
                mail.setSaveAsActivity(false);
                mail.setUseSignature(true);
                mail.setWhatId(productId);
                mail.setTemplateId(emailTemplate[0].Id);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail},false);
                if(createNewProductProposal == true){
                    createProductLeadProposal(productId,leadId);
                }
                return successMap('Email has been Sent');
            }
            return errorMap('Email not sent');
        } catch (Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'ProductListController');
            if(e != NULL) Database.insert(e);
            System.debug('Error : ' + exp.getMessage());
            return errorMap('Email not sent');
        }
    }
    
    //Filters and retrieves product data based on the search criteria
    @AuraEnabled(cacheable=true)
    public static List<Product2> getFilterProducts(String objSearchProducts, String leadId){
        try{            
            String priorQueryString ='SELECT Amazon_Asset__r.Amazon_Asset_Name__c, ';
            String subsequentQueryString =' WHERE ';
            Boolean checkTestRecord = checkTestRecordMethod(leadId);
            if(String.isNotBlank(objSearchProducts)){
                //Deserialize and process filter criteria
                Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(objSearchProducts);
                if(jsonMap != null && !jsonMap.keySet().isEmpty()){
                    for(String str : jsonMap.KeySet()){
                        if (String.isNotBlank(''+jsonMap.get(str))) {
                            priorQueryString += str+', ';
                            String modifiedFilter = ''+jsonMap.get(str);
                            if(((''+jsonMap.get(str)).startswith('(') && (''+jsonMap.get(str)).endsWith(')'))  && (str != 'Feedback__c') && (str != 'Overall_Units_Sold__c') && str != 'RecentSales' && str != 'Health_Assurance_Score__c' && str != 'LLC_Asset__c'){
                                modifiedFilter = modifiedFilter.replace('(', '(\'').replace(')', '\')').replaceAll(', ' , '\',\'');
                                subsequentQueryString += str +' IN' +modifiedFilter+' AND ';
                            }else if(str != 'Feedback__c' && str != 'Overall_Units_Sold__c' && str != 'RecentSales' && str != 'Health_Assurance_Score__c' && str != 'LLC_Asset__c'){
                                subsequentQueryString += str +' LIKE \'%' +jsonMap.get(str)+'%\' AND ';
                            }else if(str == 'Health_Assurance_Score__c'){
                                subsequentQueryString += str +' = '+ (Decimal.valueOf(modifiedFilter.replace('+',''))+' AND ');
                            }else if(str == 'RecentSales'){
                                if(modifiedFilter.contains('3 Months') && !modifiedFilter.contains('12 Months')){
                                    subsequentQueryString += ' Recent_Sales_Within_3_months__c != NULL AND ';
                                }else if(modifiedFilter.contains('12 Months') && !modifiedFilter.contains('3 Months') ){
                                    subsequentQueryString += ' Recent_Sales_Within_12_months__c != NULL AND ';
                                }else if(modifiedFilter.contains('3 Months') && modifiedFilter.contains('12 Months')){
                                    subsequentQueryString += ' (Recent_Sales_Within_3_months__c != NULL OR Recent_Sales_Within_12_months__c != NULL) AND ';
                                }
                            }else if(str == 'LLC_Asset__c'){
                                subsequentQueryString += str +' = '+ modifiedFilter +' AND ';
                            }else{
                                if(str == 'Feedback__c' || str == 'Overall_Units_Sold__c'){
                                    subsequentQueryString += str +' >= '+ (Decimal.valueOf(modifiedFilter.replace('+',''))+' AND ');
                                }
                            }
                        }
                    } 
                }
            }
            priorQueryString = priorQueryString.removeEnd(', ').replace('RecentSales','Recent_Sales_Within_3_months__c,Recent_Sales_Within_12_months__c') +' FROM Product2 ';
            if(subsequentQueryString != ' WHERE ' &&  String.isNotBlank(subsequentQueryString)){
                subsequentQueryString = subsequentQueryString.removeEnd('AND ');
                String fullQuery = priorQueryString + subsequentQueryString + ' AND Amazon_Asset__c != null AND Is_Sold__c = False AND Sale_Price__c != NULL AND Is_Test__c = '+ checkTestRecord;
                return Database.query(fullQuery);
            }else{
                String fullQuery = priorQueryString + ' WHERE Amazon_Asset__c != null AND Is_Sold__c = False AND Sale_Price__c != NULL AND Is_Test__c = '+ checkTestRecord;
                return Database.query(fullQuery);
            }
        } catch (Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'ProductListController');
            if(e != NULL) Database.insert(e);
            System.debug('Error : ' + exp.getMessage());
            return null;
        }
    }    
    
    //Check Product Lead Proposal record
    @AuraEnabled
    public static Map<String, Object> checkProductLeadProposal(String productId,String leadId){
        List<Product_Lead_Proposal__c> existingProposal = [SELECT Id, Lead__c, Product__c FROM Product_Lead_Proposal__c WHERE Lead__c =: leadId AND Product__c =: productId LIMIT 1];
        if(!existingProposal.isEmpty()){
            return confirmMap('The email regarding this product has already been sent to lead. Do you want to send it again?');
        }else{
            return successMap('Success');
        }
    }

    //Create Product Lead Proposal record
    private static void createProductLeadProposal(String productId,String leadId){
        INSERT new Product_Lead_Proposal__c(Lead__c = leadId, Product__c = productId);
    }
    
    //Fetch lead to know test record or not
    private static Boolean checkTestRecordMethod(String leadId){
        List<Lead> leadList = [SELECT Id, Is_Test__c FROM Lead WHERE Id =: leadId LIMIT 1];
        return leadList[0].Is_Test__c;
    }
    
    //Generate a error response map
    private static Map<String, Object> errorMap(String msg){
        Map<String, Object> result = new Map<String, Object>();
        result.put('STATUS', 'error');
        result.put('MSG', msg);
        return result;
    }

    //Generate a confirm response map
    private static Map<String, Object> confirmMap(String msg){
        Map<String, Object> result = new Map<String, Object>();
        result.put('STATUS', 'confirm');
        result.put('MSG', msg);
        return result;
    }
    
    //Generate a success response map
    private static Map<String, Object> successMap(String msg){
        Map<String, Object> result = new Map<String, Object>();
        result.put('STATUS', 'success');
        result.put('MSG', msg);
        return result;
    }
}