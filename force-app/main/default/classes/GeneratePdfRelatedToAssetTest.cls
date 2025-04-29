@isTest
public class GeneratePdfRelatedToAssetTest {
    @testSetup static void setupMethod(){
        Account acc = new Account(Name = 'test');
        INSERT acc;
    }
    @isTest static void assetTriggerMethod(){
        Account account = [SELECT Id FROM Account WHERE Name='test' LIMIT 1];
        List<Asset> assetlist = new List<Asset>(); 
        Asset asset = new Asset(
            Name = 'testing',
            AccountId = account.Id,
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
        assetlist.add(asset);
        INSERT assetlist;   
        assetlist[0].Name = 'test update';
        UPDATE assetlist;
    } 
    @isTest static void assetControllerMethod(){
        Account acct1 = [SELECT Id FROM Account WHERE Name='test' LIMIT 1];
        List<Asset> asslist1 = new List<Asset>(); 
        Asset asset = new Asset(
            Name = 'testing',
            AccountId = acct1.Id,
            Sale_Price__c = 12,
            Feedback__c = 10,
            Stars_Store_Feedback__c = 4,
            Brands_approved__c = 'test 1,test 2,test 3,test 4,test 5,test 7',
            Categories_Approved__c = 'test 1,test 2,test 3,test 4,test 5,test 7',
            Sales_History_All_Time__c = 4,
            Sales_History_Year_to_Date__c = 5,
            Overall_Units_Sold__c = 7,
            Marketplace__c = 'EU',
            Additional_Marketplaces__c = 'EU',
            Creation_Date__c = System.today()
        );
        asslist1.add(asset);
        insert asslist1;
        
        PageReference pdfPage = Page.GeneratePdfRelatedToAssetVisualorcePage;
        Test.setCurrentPage(pdfPage);
        pdfPage.getParameters().put('id', asslist1[0].Id);
        ApexPages.StandardController standardController = new ApexPages.StandardController(asslist1[0]);
        GeneratePdfRelatedToAsset generateAssetPdfController = new GeneratePdfRelatedToAsset(standardController);
        pdfPage = generateAssetPdfController.savePdf();
        Assert.isNotNull(pdfPage, 'Result is not proper');        
    } 
    
}