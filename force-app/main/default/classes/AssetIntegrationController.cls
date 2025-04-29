public withOut sharing class AssetIntegrationController {
    @AuraEnabled
    public static Opportunity getOpp(String recordId){
        if(String.isNotBlank(recordId)){
            Opportunity opp = [SELECT Id, Amazon_Login_Email_Address__c, Bank_Account_Number_last_three_digits__c, Legal_Entity_Address__c, Bank_Account_name__c, Legal_Entity_Name__c, Bank_Account_Address__c, Legal_Entity_Owner_Status__c, Bank_Account_Marketplaces__c, Legal_Entity_Street__c, Card_Name__c, Legal_Entity_City__c, Credit_Card_last_four_digits__c, Legal_Entity_Country__c, Credit_Card_Street__c, Legal_Entity_State_Province__c, Credit_Card_City__c, Legal_Entity_Zip_Postal_Code__c, Credit_Card_State_Province__c, Contact_person_first_name__c, Credit_Card_Zip_Postal_Code__c, Contact_person_middle_name_opt__c, Credit_Card_Country__c, Contact_person_last_name__c, Credit_Card_Address__c, Phone_Number__c, Creation_Date__c, Marketplace__c, Additional_Marketplaces__c, US_Citizen_Owner__c, Amazon_Account_Type__c, Subscription_Plan__c, Account_Type__c, Owner_Status__c, Merchant_Token__c, Special_Account_Type__c, Fulfillment__c,Recent_Sales_Within_3_months__c,Prime_Memebership_Expiration__c,Brand_Registry__c,Gift_card_balance__c,INFORM_Verifications_passed__c,INFORM_Verification_passed_date__c,Tax_Info_complete__c,Listings_Status__c,Health_Assurance_Score__c,Positive_Feedback_USA__c, Txn_1_year_file_name__c, Txn_2_year_file_name__c , Sales_report_file_name__c ,AmznQRFileNameFinal__c, ChargeFileName__c, AccFileName__c, CommentFileName__c, VPS3__c,Amazon_QR_Code__c,Charge_Methods_screenshot__c,Account_Health_Dashboard_Screenshot__c,Accessed_Amazon_Account_1__c, Put_account_into_vacation_mode__c, Added_2SV_QR_code_Final__c, Changed_phone_number_in_login_settings__c, Added_AIA_as_a_user_in_Amazon_Account__c, Remove_existing_users_from_permissions__c, Disabled_Third_party_developer_and_apps__c, Changed_charge_method_to_Mercury_cc__c, Removed_all_existing_cc_s__c, Took_Screenshot_of_updated_charge_method__c, Changed_All_Notification_Email_addresses__c, Changed_Contact_Info_email_phone__c, Removed_FBM_listings__c, Paused_all_active_ad_campaigns__c,Noted_performance_notifications__c,Took_screenshot_of_Acc_Health_Dashboard__c,Existing_account_health_violations__c,Accessed_Buyer_Account__c,Removed_all_subscriptions__c,Returned_to_Seller_Account__c,Asset_purchased_with_Pesticide_approval__c,AIA_has_opened_Pesticide_category__c,On_Statement_beginning_balance_shows_0__c,On_Payment_3_button_under_Fund_Available__c,Account_payment_schedule__c,Earliest_account_statement_date__c,Add_ASINs_to_check_brands_or_categories__c,Check_for_HAZMAT_storage__c,Retrieved_sales_history_data__c,Sales_History_Year_to_Date__c,Sales_History_2_Years_to_Date__c,Sales_History_All_Time__c,Units_Sold_Year_to_Date__c,Unit_Sold_2_Years_to_Date__c,Overall_Units_Sold__c,IPI__c,Sub_Stage__c, Email_Address_On_Live_Takeover__c, Amazon_Password__c, Temp_Amazon_2SV_QR_code__c, Date_of_Last_Sale__c, Latest_Orders_File_Name__c FROM Opportunity WHERE Id =: recordId];
            if(opp.Sub_Stage__c == null){
                opp.Sub_Stage__c = 'Asset Integration';
            }
            RETURN opp;
        }
        RETURN null;
    }

    @AuraEnabled
    public static void uploadScreenShot(String firstBase64,String secondBase64,String thirdBase64,String fourthBase64,String recordId,Boolean imageLink1Check,Boolean imageLink2Check,Boolean imageLink3Check,Boolean imageLink4Check, String filename1, String filename2, String filename3, String filename4 ,Boolean pausedAllActiveAdCampaigns) {
       try {
        String imageLink1 = firstBase64;
        String imageLink2 = secondBase64 != null ? '<p><img src="data:image/jpeg;base64,' + secondBase64 + '" alt="rtaImage.jpeg"></img></p>' : null;
        String imageLink3 = thirdBase64 != null ? '<p><img src="data:image/jpeg;base64,' + thirdBase64 + '" alt="rtaImage.jpeg"></img></p>' : null;
        String imageLink4 = fourthBase64 != null ? '<p><img src="data:image/jpeg;base64,' + fourthBase64 + '" alt="rtaImage.jpeg"></img></p>' : null;
        if(String.isNotBlank(recordId)){
            Opportunity opp = [SELECT Id, AmznQRFileNameFinal__c, ChargeFileName__c, AccFileName__c, CommentFileName__c, Amazon_QR_Code__c, Charge_Methods_screenshot__c, Account_Health_Dashboard_Screenshot__c FROM Opportunity WHERE Id =: recordId];
            if(imageLink1Check){
                opp.Amazon_QR_Code__c = imageLink1;
            }
            if(imageLink2Check){
                opp.Charge_Methods_screenshot__c = imageLink2;
                if(String.isNotBlank(filename2)){
                    opp.ChargeFileName__c = filename2;
                }
            }
            if(imageLink3Check){
                opp.Account_Health_Dashboard_Screenshot__c = imageLink3;
                if(String.isNotBlank(filename3)){
                    opp.AccFileName__c = filename3;
                }
            }
            if(imageLink4Check){
                if(String.isNotBlank(filename4)){
                    opp.CommentFileName__c = 'Existing Violation - '+ filename4;
                }
            }
            UPDATE opp;
        }
    } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void sendingSubStage(String firstStage,String recordId) {
        try {
            if(String.isNotBlank(recordId)){
                Opportunity opp = [SELECT Id,Sub_Stage__c, Asset_Integration_Completed__c FROM Opportunity WHERE Id =: recordId];
                if(String.isNotBlank(firstStage)){
                    opp.Sub_Stage__c = firstStage;
                }
                UPDATE opp;
            }   
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void sendDatatoOpp(String recordId,String booleanFieldValue){
        if(String.isNotBlank(booleanFieldValue) && String.isNotBlank(recordId)){
            Opportunity opportunity = (Opportunity)JSON.deserialize(booleanFieldValue,Opportunity.class);
            opportunity.Id = recordId;
            UPDATE opportunity;
        }
    }

    @AuraEnabled
    public static void accountTypeMethod(String recordId,Boolean assetIntegrate){
        if(String.isNotBlank(recordId)){
            Opportunity opportunity = [SELECT Id,Account_Type__c,Asset_Integration_Completed__c FROM Opportunity WHERE Id =: recordId];
            opportunity.Asset_Integration_Completed__c = assetIntegrate;
            UPDATE opportunity;
        }
    }

    @AuraEnabled
    public static void saveData(String fileBase64, String filename, String recordId, String file) {
        
        if(String.isNotBlank(fileBase64) && String.isNotBlank(filename) && String.isNotBlank(recordId)) {
            ContentVersion cv = createContentVersion(fileBase64, filename);
            if(cv!= NULL) {
                createContentLink(new Set<String>{cv.Id}, recordId, file, filename);
            }
            
        }
    }

    private static ContentVersion createContentVersion(String file1Base64, String file1name) {
        ContentVersion cv = new ContentVersion(VersionData = EncodingUtil.base64Decode(file1Base64),
                                               Title = file1name,
                                               PathOnClient = file1name
                                              );  
        try {
            INSERT cv;
            return cv;
        } catch(DMLException e) {
            return null;
        }
    }
    
    private static void createContentLink(Set<String> contentVersionIds, String recordId, String file, String filename) {
        try {
            if(!contentVersionIds.isEmpty()) {
                List<ContentVersion> contentVersionList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds];
                List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
                contentDocumentLinkList.add(new ContentDocumentLink(ContentDocumentId = contentVersionList[0].ContentDocumentId, LinkedEntityId = recordId, ShareType = 'V'));
                INSERT contentDocumentLinkList;
            }
            if(String.isNotBlank(file) && (file == 'file1' || file == 'file2' || file == 'file3' || file == 'file4')){
                Opportunity opp;
                if(file == 'file1'){
                    opp = new Opportunity(Id=recordId, Txn_1_year_file_name__c = filename);
                } else if(file == 'file2'){
                    opp = new Opportunity(Id=recordId, Txn_2_year_file_name__c = filename);
                } else if(file == 'file3'){
                    opp = new Opportunity(Id=recordId, Sales_report_file_name__c = filename);
                } else if(file == 'file4'){
                    opp = new Opportunity(Id=recordId, Latest_Orders_File_Name__c = filename);
                }
                UPDATE opp;
            }
        } catch(DMLException e) {
            System.debug(e);
        }
    }
}