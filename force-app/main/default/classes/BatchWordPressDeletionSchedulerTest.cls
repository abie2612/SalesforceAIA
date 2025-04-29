@isTest
public class BatchWordPressDeletionSchedulerTest {
    
    @testSetup 
    static void setupMethod(){
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
            Creation_Date__c = System.today(),
            WordPress_AssetId__c = '8971254',
            Is_Test__c = False,
            Delivered__c = True
        );
        INSERT asset;
    }
    
    @isTest
    public static void scheduleBatchExecute(){
        String cronExpr = '0 0 0 15 3 ? 2025';
        Test.startTest();
        BatchWordPressDeletionScheduler batch= new BatchWordPressDeletionScheduler();
        String jobId = System.schedule('myJobTestJobName', cronExpr, batch);
        batch.execute(null);
        Test.stopTest();
    }
    
    @isTest
    public static void emptyConstructorBatchExecute(){
        List<Asset> updateAsset = [SELECT Id,Overall_Units_Sold__c,Additional_Marketplaces__c FROM Asset WHERE Name='testing' LIMIT 1];
        BatchWordPressDeletionScheduler batch = new BatchWordPressDeletionScheduler();
        Test.setMock(HttpCalloutMock.class, new createAssetMock());
        Database.executeBatch(batch, 1);
    }
    
    @isTest
    public static void parameterizedConstructorBatchExecute(){
        List<Asset> updateAsset = [SELECT Id,Overall_Units_Sold__c,Additional_Marketplaces__c FROM Asset WHERE Name='testing' LIMIT 1];
        BatchWordPressDeletionScheduler batch = new BatchWordPressDeletionScheduler(new Set<Id>{updateAsset[0].Id}, true);
        Test.setMock(HttpCalloutMock.class, new createAssetMock());
        Database.executeBatch(batch, 1);
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