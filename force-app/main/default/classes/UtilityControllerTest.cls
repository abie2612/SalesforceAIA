@isTest
public class UtilityControllerTest {
    @testSetup static void setup() {
        Exception__c exceptionData = TestUtility.getException('Controller Method Test','Lead','hello everyone');
        INSERT exceptionData;
        
        Account acc = TestUtility.getAccount('Test ABC');
        INSERT acc;
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
    }
    
    @isTest static void sendEmailNotificationTest() {
        Exception__c exceptionData = [SELECT Id,Name,Type__c,Controller_Method_Name__c,Exception_Message__c FROM Exception__c LIMIT 1];
        Test.StartTest();
        UtilityController.sendEmailNotification(exceptionData);
        UtilityController.getExceptionData(new DMLException('My DML EXCEPTION'),'DML Exception');
        UtilityController.getExceptionData(new DMLException('My DML EXCEPTION'),'DML Exception','Zoom Controller');
        Test.StopTest();
        Exception__c exceptionTest = [SELECT Id,Exception_Message__c FROM Exception__c LIMIT 1];
        Assert.areEqual('hello everyone',exceptionTest.Exception_Message__c,'Exception is not correct');
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
}