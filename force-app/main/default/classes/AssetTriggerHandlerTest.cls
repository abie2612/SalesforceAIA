@isTest
public class AssetTriggerHandlerTest {
    @isTest
    public static void updateSendDataOnWordPressTest(){
        try {
            Account acc = new Account(Name = 'test');
            INSERT acc;
            Test.setMock(HttpCalloutMock.class, new createAssetMock());
            
            Asset asset = new Asset(
                Name = 'testing',
                AccountId = acc.Id,
                Sale_Price__c = 12,
                Feedback__c = 10,
                Stars_Store_Feedback__c = 4,
                Brands_approved__c = 'brand 1, brand 2',
                Categories_Approved__c = 'category 1, category 2',
                Sales_History_All_Time__c = 4,
                Sales_History_Year_to_Date__c = 5,
                Overall_Units_Sold__c = 7,
                Marketplace__c = 'EU',
                Additional_Marketplaces__c = 'EU',
                Creation_Date__c = System.today()
            );
            INSERT asset;
            asset.Overall_Units_Sold__c= 72;
            asset.WordPress_AssetId__c = '22775';
            asset.Sold__c = true;
            Test.setMock(HttpCalloutMock.class, new createAssetMock());
            UPDATE asset;
            
            asset.Sold__c = false;
            UPDATE asset;
        } catch(Exception e){
            System.debug(e);
        }
    }
    
    @isTest
    public static void updateSendDataOnWordPressTest2(){
        try{
            Account acc = new Account(Name = 'test');
            INSERT acc;
            Test.setMock(HttpCalloutMock.class, new createAssetMock());
            
            Asset asset = new Asset(
                Name = 'testing',
                AccountId = acc.Id,
                Sale_Price__c = 12,
                Feedback__c = 10,
                Stars_Store_Feedback__c = 4,
                Brands_approved__c = 'brand 1, brand 2',
                Categories_Approved__c = 'category 1, category 2',
                Sales_History_All_Time__c = 4,
                Sales_History_Year_to_Date__c = 5,
                Overall_Units_Sold__c = 7,
                Marketplace__c = 'EU',
                Additional_Marketplaces__c = 'EU',
                Creation_Date__c = System.today()
            );
            INSERT asset;     
            AssetTriggerHandler.beforeInsertUpdate(new List<Asset>{asset}, null);
        } catch(Exception e){
            System.debug(e);
        }
    }
    
    @isTest
    public static void testSyncAssetToOpportunity(){
        try {
            Opportunity_Asset_Field_Mapping__c fieldMapping = new Opportunity_Asset_Field_Mapping__c(
                Name = 'Test Mapping',
                Opportunity_Field__c = 'Email_Address_on_Email_Account__c', 
                Asset_Field__c = 'Email_Address_on_Email_Account__c'
            );
            INSERT fieldMapping;
            Account acc = new Account(Name = 'test');
            INSERT acc;
            
            Asset asset = new Asset(
                Name = 'testing',
                AccountId = acc.Id,
                Sale_Price__c = 12,
                Feedback__c = 10,
                Stars_Store_Feedback__c = 4,
                Brands_approved__c = 'brand 1, brand 2',
                Categories_Approved__c = 'category 1, category 2',
                Sales_History_All_Time__c = 4,
                Sales_History_Year_to_Date__c = 5,
                Overall_Units_Sold__c = 7,
                Marketplace__c = 'EU',
                Additional_Marketplaces__c = 'EU',
                Creation_Date__c = System.today()
            );
            INSERT asset;
            
            asset.Email_Address_on_Email_Account__c = 'Updated Value';
            UPDATE asset;
            
        } catch(Exception e){
            System.debug(e);
        }
    }
    @IsTest(SeeAllData=true)
    public static void checkInsertResult(){
        Account acc = new Account(Name = 'test new');
        INSERT acc;
        Asset asset2 = new Asset(
            Name = 'testing new',
            AccountId = acc.Id,
            Sale_Price__c = 12,
            Feedback__c = 10,
            Stars_Store_Feedback__c = 4,
            Brands_approved__c = 'brand 1 brand 2',
            Categories_Approved__c = 'category 1 category 2',
            Sales_History_All_Time__c = 4,
            Sales_History_Year_to_Date__c = 5,
            Overall_Units_Sold__c = 7,
            Marketplace__c = 'US',
            Additional_Marketplaces__c = 'EU',
            Creation_Date__c = System.today()
        );
        
        Test.setMock(HttpCalloutMock.class, new createAssetMock());
        
        INSERT asset2;
    }
    
    @IsTest(SeeAllData=true)
    public static void insertWithoutAdditionalMarketplace(){
        Account acc = new Account(Name = 'test new');
        INSERT acc;
        
        Asset asset = new Asset(
            Name = 'testing new',
            AccountId = acc.Id,
            Sale_Price__c = 12,
            Feedback__c = 10,
            Stars_Store_Feedback__c = 4,
            Brands_approved__c = 'brand 1, brand 2',
            Categories_Approved__c = 'category 1, category 2',
            Sales_History_All_Time__c = 4,
            Sales_History_Year_to_Date__c = 5,
            Overall_Units_Sold__c = 7,
            Marketplace__c = 'US',
            Creation_Date__c = System.today()
        );
        
        Test.setMock(HttpCalloutMock.class, new createAssetMock());
        
        INSERT asset;
    }
    
    public class createAssetMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(201);
            res.setBody('{"id": 22775,"date":"2024-11-04T10:52:38","date_gmt":"2024-11-04T10:52:38","guid":{"rendered":"https://aia-assets.com/accounts/aia-0655/","raw":"https://aia-assets.com/accounts/aia-0655/"},"modified":"2024-11-04T10:52:38","modified_gmt":"2024-11-04T10:52:38","password":"","slug":"aia-0655"}');
            return res;
        }
    }
    
}