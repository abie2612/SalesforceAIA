@isTest
public class ProductListControllerTest {
    @testSetup
    public static void leadRecord(){
        Account acc = TestUtility.getAccount('Test Account');
        INSERT acc;
        Lead ld = TestUtility.getLead('Test','Lead','New','Test Company','Hot','test@gmail.com');
        INSERT ld;
        Asset asset = TestUtility.getAsset('testing', acc.Id, 12, 10,  4, 'brand 1, brand 2', 'category 1, category 2', 4, 5, 7, 'EU', 'EU', System.today());
        INSERT asset;
        Product2 pduct = TestUtility.getProduct(asset.Id,'Test Product');
        pduct.Sale_Price__c = 1;
        INSERT pduct;
    }
    
    @isTest
    public static void getProductDataTest(){
        Lead ld = [SELECT Id FROM Lead WHERE FirstName='Test' LIMIT 1];
        ProductListController.getProductData(ld.Id);
    }
    
    @isTest
    public static void getProductDataExceptionTest(){
        try{
            ProductListController.getProductData(null);
        } catch(Exception e){
            System.debug(e);
        }
    }
    
    @isTest
    public static void sendEmailTest(){
        Lead ld = [SELECT Id FROM Lead WHERE FirstName ='Test' LIMIT 1];
        Product2 pduct = [SELECT Id FROM Product2 LIMIT 1];
        ProductListController.sendEmail(pduct.Id,ld.Id,true);
    }
    
    @isTest
    public static void sendEmailTestWithoutLead(){
        Lead ld = [SELECT Id, Email FROM Lead WHERE FirstName ='Test' LIMIT 1];
        ld.Email = '';
        UPDATE ld;
        Product2 pduct = [SELECT Id FROM Product2 LIMIT 1];
        ProductListController.sendEmail(pduct.Id,ld.Id,true);
    }
    
    @isTest
    public static void checkProductLeadProposalTest(){
        Lead ld = [SELECT Id, Email FROM Lead WHERE FirstName ='Test' LIMIT 1];
        Product2 pduct = [SELECT Id FROM Product2 LIMIT 1];
        ProductListController.checkProductLeadProposal(pduct.Id,ld.Id);
    }
    
    
    @isTest
    public static void getFilterProducts3MonthSaleTest(){
        try{
            Lead ld = [SELECT Id FROM Lead WHERE FirstName ='Test' LIMIT 1];
            String objProduct = '{"Amazon_Asset__r.Amazon_Asset_Name__c":"testing","Health_Assurance_Score__c":'+4+',"RecentSales":"3 Months","LLC_Asset__c":'+True+',"Overall_Units_Sold__c":'+8+'}';
            ProductListController.getFilterProducts(objProduct, ld.Id);
        } catch(Exception e){
            System.debug(e);
        }
    }
    
     @isTest
    public static void getFilterProducts12MonthSaleTest(){
        try{
            Lead ld = [SELECT Id FROM Lead WHERE FirstName ='Test' LIMIT 1];
            String objProduct = '{"Amazon_Asset__r.Amazon_Asset_Name__c":"testing","Health_Assurance_Score__c":'+4+',"RecentSales":"12 Months","LLC_Asset__c":'+True+',"Overall_Units_Sold__c":'+8+'}';
            ProductListController.getFilterProducts(objProduct, ld.Id);
        } catch(Exception e){
            System.debug(e);
        }
    }

     @isTest
    public static void getFilterProducts3And12MonthSaleTest(){
        try{
            Lead ld = [SELECT Id FROM Lead WHERE FirstName ='Test' LIMIT 1];
            String objProduct = '{"Amazon_Asset__r.Amazon_Asset_Name__c":"testing","Health_Assurance_Score__c":'+4+',"RecentSales":"3 Months,12 Months","LLC_Asset__c":'+True+',"Overall_Units_Sold__c":'+8+'}';
            ProductListController.getFilterProducts(objProduct, ld.Id);
        } catch(Exception e){
            System.debug(e);
        }
    }
}