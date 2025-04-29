public Without sharing class OwnershipTransferController {
    @AuraEnabled
    public static String getSubStage(String recordId){
        if(String.isNotBlank(recordId)){
            List<Opportunity> opp = [SELECT Id, Name, Sub_Stage__c FROM Opportunity WHERE Id =: recordId AND Sub_Stage__c != NULL];
            if(opp != null && !opp.isEmpty()) {
                return opp[0].Sub_Stage__c;
            }
            return 'Help Tickets';
        }
        return null;
    }

    @AuraEnabled(cacheable=false)
    public static Opportunity getOpp(String recordId) {
        if(String.isNotBlank(recordId)) {
            Opportunity opp = [SELECT Id, Accessed_Amazon_Account__c, Open_Help_ticket_1__c, Primary_Contact_Verification__c, Business_Primary_Contact_Verification__c, Take_screenshot_of_Tax_Information__c, Received_Amazon_s_response__c, Reply_to_Help_ticket_1__c, Open_Help_ticket_2__c, Email_Address_on_Email_Account__c, Amazon_Password__c, Amazon_QR_Code__c, Change_Tax_Information__c, Legal_Entity_Contains__c, Tax_Information_Screenshot_File_Name__c, Access_Deposit_Methods__c, Current_Deposit_Method_Name__c, Current_Deposit_Method_Address__c, Current_Deposit_Method_Last_3_Digits__c, Current_Deposit_Method_Marketplaces__c, Access_Manage_Deposit_Methods_Page__c,Add_New_Deposit_Method__c, Bank_Verification_Required__c, Previous_Bank_Accounts_Deleted__c, Manage_Deposit_Methods_Old__c, Manage_Deposit_Methods_New_File_Name__c, Access_Account_profile_information__c, Change_Store_Name_Link_Marketplaces__c, Rename_Store_in_Global_Accounts__c, Change_Notifications_Email__c, Updated_Address_for_Returns__c, Returns_Address__c, Business_Address__c, Returns_Address_City__c, Business_Address_City__c, Returns_Address_State__c, Business_Address_State__c, Returns_Address_Zip__c, Business_Address_Zip__c, Returns_Address_Country__c,Returns_Address_Phone_Number__c, Business_Address_Phone_Number__c, Updated_Address_of_Auto_Removals__c, Delete_all_Your_Info_and_Policies__c, Delete_all_FBM_Listings__c, Added_product__c, Changed_Business_Address__c, Address_Verification_Required__c, Address_Verification_File_Name__c, Access_Charge_Methods__c, Current_Charge_Method_Name__c, Current_Charge_Method_Address__c, Current_Charge_Method_Last_3_Digits__c, Current_Charge_Method_Marketplaces__c, Access_Manage_Charge_Methods_Page__c, Add_New_Charge_Method__c, Charge_Methods_Page_File_Name__c, Charge_Methods_Page_New_File_Name__c, Access_Buyer_Account__c, Close_Business_Account__c, Change_Login_Name__c, Change_Account_Profile_Name__c, Remove_Other_Profiles__c, Deleted_all_other_Deposit_Methods__c, Deleted_All_other_Charge_Methods__c, Deleted_All_other_Addresses__c, Access_Seller_Account__c, Check_for_New_Addresses_only__c, Check_for_New_Credit_Card_only__c, Logout_and_in_of_Amazon_to_check_PW_QR__c, Access_Email_Account__c, Change_Email_account_name__c,  Remove_Email_Forwarding_Roles__c, Empty_mailbox_and_trash__c, Logout_and_in_to_Email_check_PW_and_QR__c, Change_Legal_Entity_Information__c, All_Existing_Addresses_File_Name__c FROM Opportunity WHERE Id =: recordId];
            return opp;   
        }
        return null;
    }

    @AuraEnabled
    public static void changeSubStage(String recordId, String subStage, Boolean finalSave) {
        if(String.isNotBlank(recordId) && String.isNotBlank(subStage)) {
            Opportunity opp = new Opportunity(Id=recordId, Sub_Stage__c = subStage);
            if(finalSave){
                opp.StageName = 'Payment';
                opp.Ownership_Transfer_Completed__c = true;
                opp.Sub_Stage__c = '';
            }
            UPDATE opp; 
        }
    }

    @AuraEnabled
    public static void saveData(String fileBase64, String filename, String recordId, String file, String subStage) {
        
        if(String.isNotBlank(fileBase64) && String.isNotBlank(filename) && String.isNotBlank(recordId)) {
            ContentVersion cv = createContentVersion(fileBase64, filename);
            if(cv!= NULL) {
                createContentLink(new Set<String>{cv.Id}, recordId, file, filename, subStage);
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
    
    private static void createContentLink(Set<String> contentVersionIds, String recordId, String file, String filename, String subStage) {
        try {
            if(!contentVersionIds.isEmpty()) {
                List<ContentVersion> contentVersionList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds];
                List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
                contentDocumentLinkList.add(new ContentDocumentLink(ContentDocumentId = contentVersionList[0].ContentDocumentId, LinkedEntityId = recordId, ShareType = 'V'));
                INSERT contentDocumentLinkList;
            }
            if(String.isNotBlank(subStage) && subStage=='DepositMethod'){
                if(String.isNotBlank(file) && (file == 'file1' || file == 'file3')){
                    Opportunity opp;
                    if(file == 'file1'){
                        opp = new Opportunity(Id=recordId, Manage_Deposit_Methods_Old__c = filename);
                    } else if(file == 'file3'){
                        opp = new Opportunity(Id=recordId, Manage_Deposit_Methods_New_File_Name__c = filename);
                    }
                    UPDATE opp;
                } 
            } else if(String.isNotBlank(subStage) && subStage=='ChargeMethod'){
                if(String.isNotBlank(file) && (file == 'file1' || file == 'file2')){
                    Opportunity opp;
                    if(file == 'file1'){
                        opp = new Opportunity(Id=recordId, Charge_Methods_Page_File_Name__c = filename);
                    } else if(file == 'file2'){
                        opp = new Opportunity(Id=recordId, Charge_Methods_Page_New_File_Name__c = filename);
                    }
                    UPDATE opp;
                } 
            } else if(String.isNotBlank(subStage) && subStage=='TaxAndLegal'){
                if(String.isNotBlank(file) && (file == 'file1')){
                    Opportunity opp;
                    if(file == 'file1'){
                        opp = new Opportunity(Id=recordId, Tax_Information_Screenshot_File_Name__c = filename);
                    }
                    UPDATE opp;
                }
            } else if(String.isNotBlank(subStage) && subStage=='SellerProfile'){
                if(String.isNotBlank(file) && (file == 'file1')){
                    Opportunity opp;
                    if(file == 'file1'){
                        opp = new Opportunity(Id=recordId, Address_Verification_File_Name__c = filename);
                    }
                    UPDATE opp;
                }
            } else if(String.isNotBlank(subStage) && subStage=='BuyerProfile'){
                if(String.isNotBlank(file) && (file == 'file1')){
                    Opportunity opp;
                    if(file == 'file1'){
                        opp = new Opportunity(Id=recordId, All_Existing_Addresses_File_Name__c = filename);
                    }
                    UPDATE opp;
                }
            }
            
        } catch(DMLException e) {
            System.debug(e);
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<ID, String> getRelatedFilesByRecordId(String recordId) {
        // Get record file IDs        
        List<Contract> latestContract = [SELECT Id FROM Contract WHERE Opportunity__c = :recordId AND Status = 'Activated' ORDER BY CreatedDate DESC LIMIT 1];
        if(latestContract == null || latestContract.isEmpty()) {
            return null;
        }
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: latestContract[0].Id];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
    
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
            FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
        return mapIdTitle;
    }
}