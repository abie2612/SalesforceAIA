@isTest 
public class OpportunityTriggerHandlerTest {
    @TestSetup
    public static void unitTestMethod(){
        Account acc = TestUtility.getAccount('Test ABC');
        INSERT acc;
        
        Opportunity venOpp = TestUtility.getOpportunity('Test Opportunity',Date.newInstance(2024, 12, 9),'Asset Takeover','US',acc.Id);
        Id vendOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        venOpp.RecordTypeId = vendOppRecordTypeId;
        Opportunity custOpp = TestUtility.getOpportunity('Test Customer Opportunity',Date.newInstance(2024, 12, 9),'Contract and Customer Questionnaire','US',acc.Id);
        Id cusOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        custOpp.RecordTypeId = cusOppRecordTypeId;
        INSERT new List<Opportunity>{venOpp,custOpp};   
    }
    
    
    @isTest
    public static void unitTestMethod1(){
        Opportunity opp = [SELECT Id, Name, StageName, Asset_Takeover_Completed__c, Asset_Integration_Completed__c FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        opp.Asset_Takeover_Completed__c = false;
        opp.StageName = 'Asset Integration';
        Test.startTest();
        try{
            UPDATE opp;
        }
        catch(DMLException e){
            System.debug(e);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void vendorClosedWonCase1Test(){
        Opportunity opp = [SELECT Id, Name, StageName, Asset_Takeover_Completed__c, Asset_Integration_Completed__c FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        opp.Asset_Takeover_Completed__c = false;
        opp.StageName = 'Closed Won';
        Test.startTest();
        try{
            UPDATE opp;
        }
        catch(DMLException e){
            System.debug(e);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void vendorClosedWonCase2Test(){
        Opportunity opp = [SELECT Id, Name, StageName, Asset_Takeover_Completed__c, Asset_Integration_Completed__c FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        opp.Asset_Takeover_Completed__c = false;
        opp.StageName = 'Closed Won';
        opp.Billing_Information_submitted_to_bank__c = null;
        opp.Asset_Integration_Completed__c = true;
        opp.Asset_Takeover_Completed__c = true;
        Test.startTest();
        try{
            UPDATE opp;
        }
        catch(DMLException e){
            System.debug(e);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void vendorPaymentTest(){
        Opportunity opp = [SELECT Id, Name, StageName, Asset_Takeover_Completed__c, Asset_Integration_Completed__c FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        opp.Asset_Takeover_Completed__c = false;
        opp.StageName = 'Payment';
        Test.startTest();
        try{
            UPDATE opp;
        }
        catch(DMLException e){
            System.debug(e);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void customerRecordTypeTest(){
        Opportunity opp = [SELECT Id, Name, StageName, Asset_Takeover_Completed__c, Asset_Integration_Completed__c FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        opp.RecordTypeId = oppRecordTypeId;
        opp.Asset_Takeover_Completed__c = false;
        opp.StageName = 'Delivery';
        opp.Ownership_Transfer_Completed__c = true;
        Test.startTest();
        try{
            UPDATE opp;
        }
        catch(DMLException e){
            System.debug(e);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void unitTestMethod2(){
        Opportunity opp = [SELECT Id, Name, StageName, Asset_Takeover_Completed__c, Asset_Integration_Completed__c FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        opp.Asset_Integration_Completed__c = false;
        opp.StageName = 'Invoice';
        
        Test.startTest();
        try{
            UPDATE opp;
        }
        catch(DMLException e){
            System.debug(e);
        }
        
        Test.stopTest();
    }
    
    @isTest
    public static void unitTestMethod3(){
        Opportunity opp = [SELECT Id, Name, StageName, Asset_Takeover_Completed__c, Asset_Integration_Completed__c FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        opp.Asset_Integration_Completed__c = false;
        opp.StageName = 'Invoice';
        
        Test.startTest();
        try{
            UPDATE opp;
        }
        catch(DMLException e){
            System.debug(e);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void updateCustomerOpportunity(){
        Opportunity opp = [SELECT Id, Name, StageName, Asset_Takeover_Completed__c, Asset_Integration_Completed__c FROM Opportunity WHERE Name = 'Test Customer Opportunity' LIMIT 1];
        opp.StageName = 'Invoice';
        Test.startTest();
        try{
            UPDATE opp;
        }
        catch(DMLException e){
            System.debug(e);
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSyncOpportunityToAsset() {
        Test.startTest();
        Opportunity_Asset_Field_Mapping__c fieldMapping = new Opportunity_Asset_Field_Mapping__c(
            Name = 'Test Mapping',
            Opportunity_Field__c = 'Email_Address_on_Email_Account__c', 
            Asset_Field__c = 'Email_Address_on_Email_Account__c'
        );
        INSERT fieldMapping;
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test ABC'];
        Opportunity testOpportunity = TestUtility.getOpportunity('Test Opportunity',Date.newInstance(2024, 12, 9),'Closed Won','US',acc.Id);
        Id vendOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        testOpportunity.RecordTypeId = vendOppRecordTypeId;
        testOpportunity.Creation_Date__c = System.today();
        testOpportunity.Brands_approved__c = 'brand 1 brand 2';
        testOpportunity.Purchase_Price__c = 100;
        INSERT testOpportunity;
        Asset testAsset = new Asset(
            Name = 'Test Asset',
            AccountId = acc.Id,
            Opportunity__c = testOpportunity.Id,
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
            Creation_Date__c = System.today(),
            Email_Address_on_Email_Account__c = 'Value' 
        );
        INSERT testAsset;
        
        testOpportunity.Email_Address_on_Email_Account__c = 'Updated Value';
        UPDATE testOpportunity;
        
        Test.stopTest();
        
        Asset updatedAsset = [SELECT Id, Email_Address_on_Email_Account__c FROM Asset WHERE Opportunity__c = :testOpportunity.Id LIMIT 1];
        System.assertEquals('Updated Value', updatedAsset.Email_Address_on_Email_Account__c, 'Asset field should match updated Opportunity field');
    }
    
}