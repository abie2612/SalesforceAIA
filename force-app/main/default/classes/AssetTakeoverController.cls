public Without Sharing class AssetTakeoverController {
    @AuraEnabled(cacheable=false)
    public static Opportunity getOpp(String recordId) {
        if(String.isNotBlank(recordId)) {
            Opportunity opp = [SELECT Id, Amazon_QR_Code_Old__c, Email_QR_Code_Old__c, Email_Password__c, Email_Address_on_Email_Account__c, Email_Account_Password_Final__c, Email_Account_OTP_QR_File_Name__c, CallHippo_phone_number__c, Generated_new_CC_in_Mercury_Account__c, Credit_Card_Name__c, Credit_Card_Number__c, Expiry_Month__c, Expiry_Year__c, CVV__c, Address__c, TempFileName__c,FinalFileName__c,AmznFileName__c, Email_Account_OTP_QR_code_Final_Email__c, Temp_Gmail_QR_code__c, Vendor_PC__c, Accessed_Email_Account__c, Set_up_2SV_by_phone_and_created_QR_by_PC__c, Changed_Gmail_password__c, VPS1__c, Changed_Gmail_password_again_from_VPS__c, Removed_temp_2SV_QR_and_Added_new_One__c, Email_QR_code__c, Email_QR_Code_Takeover_2__c, Vendor_PC_Screenshare1__c, Added_2SV_QR_code_Temp__c, Changed_Login_Password__c, Amazon_Password__c, VPS2__c, Logged_into_the_Amazon_Account__c, Vendor_PC_Screenshare2__c,On_Payment_3_button_under_Fund_Available__c,On_Statement_beginning_balance_shows_0__c,Account_Type__c,Special_Account_Type__c, Existing_Email_Address_Included__c, Former_Email_Recovery_Phone_Number__c, Former_Amazon_Phone_Number__c FROM Opportunity WHERE Id =: recordId];
            if(opp != null && String.isBlank(opp.Email_QR_code__c)) {
                opp.Email_QR_code__c = '';
            }
            return opp;   
        }
        return null;
    }

    @AuraEnabled(cacheable=false)
    public static Opportunity getOTP(String recordId) {
        if(String.isNotBlank(recordId)) {
            Opportunity opp = [SELECT Id, Email_Account_OTP_QR_code_Final_Email__c FROM Opportunity WHERE Id =: recordId];
            return opp;   
        }
        return null;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getFieldHistory(String recordId) {
        Map<String, Object> mapOfFieldWithOldValue = new Map<String, Object>();
        if(String.isNotBlank(recordId)) {
            List<OpportunityFieldHistory> oppFieldHistories =[SELECT Id, OpportunityId, Field, OldValue, NewValue, CreatedDate FROM OpportunityFieldHistory WHERE OpportunityId =: recordId ORDER BY CreatedDate DESC];
            for(OpportunityFieldHistory ofh : oppFieldHistories){
                if(mapOfFieldWithOldValue != null && !mapOfFieldWithOldValue.containsKey(ofh.Field)){
                    mapOfFieldWithOldValue.put(ofh.Field, ofh.OldValue);
                }
            }
            System.debug(mapOfFieldWithOldValue);   
        }
        return mapOfFieldWithOldValue;
    }
    
    @AuraEnabled
    public static String getSubStage(String recordId){
        if(String.isNotBlank(recordId)){
            List<Opportunity> opp = [SELECT Id, Name, Sub_Stage__c FROM Opportunity WHERE Id =: recordId AND Sub_Stage__c != NULL];
            if(opp != null && !opp.isEmpty()) {
                return opp[0].Sub_Stage__c;
            }
            return 'VPS';
        }
        return null;
    }
    
    @AuraEnabled
    public static void changeSubStage(String recordId, String subStage, Boolean finalSave) {
        if(String.isNotBlank(recordId) && String.isNotBlank(subStage)) {
            Opportunity opp = new Opportunity(Id=recordId, Sub_Stage__c = subStage);
            if(finalSave){
                opp.Asset_Takeover_Completed__c = true;
                opp.StageName = 'Asset Integration';
                opp.Sub_Stage__c = '';
            }
            UPDATE opp; 
        }
    }
    
    @AuraEnabled
    public static void sendDatatoOpp(String recordId,String fieldValue){
        try {
            if(String.isNotBlank(recordId) && String.isNotBlank(fieldValue)){
                Opportunity opportunity = (Opportunity)JSON.deserialize(fieldValue,Opportunity.class);
                opportunity.Id = recordId;
                UPDATE opportunity;
            }
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void uploadQRCodes(String email, String password, Boolean existing, String recordId, String image1Data, String image2Data,String image3Data) {
        try {
            if(String.isNotBlank(recordId)) {
                Opportunity opp = [SELECT Id, Email_Address_on_Email_Account__c, Email_Account_Password_Final__c, Email_Account_OTP_QR_code_Final_Email__c, Temp_Gmail_QR_code__c, Email_QR_code__c, Temp_Amazon_2SV_QR_code__c FROM Opportunity WHERE Id =: recordId LIMIT 1];
                if(String.isNotBlank(image1Data)){
                    opp.Temp_Gmail_QR_code__c = image1Data;
                }
                if(String.isNotBlank(image2Data)){
                    opp.Email_QR_code__c = image2Data;
                }
                if(String.isNotBlank(image3Data)){
                    opp.Temp_Amazon_2SV_QR_code__c = image3Data;
                }
                if(existing){
                    opp.Email_Address_on_Email_Account__c = email;
                    opp.Email_Account_Password_Final__c = password;
                    opp.Email_Account_OTP_QR_code_Final_Email__c = opp.Email_QR_code__c;
                }
                UPDATE opp;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void uploadQRFromEmailAccount(String finalEmailQR, String filename, String recordId) {
        try {
            if(String.isNotBlank(recordId)) {
                Opportunity opp = [SELECT Id, Email_Account_OTP_QR_code_Final_Email__c FROM Opportunity WHERE Id =: recordId LIMIT 1];
                opp.Email_Account_OTP_QR_code_Final_Email__c = finalEmailQR != null ? '<p><img src="data:image/jpeg;base64,' + finalEmailQR + '" alt="rtaImage.jpeg"></img></p>' : null;
                if(String.isNotBlank(filename)){
                    opp.Email_Account_OTP_QR_File_Name__c = filename;
                } 
                UPDATE opp;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }    
}