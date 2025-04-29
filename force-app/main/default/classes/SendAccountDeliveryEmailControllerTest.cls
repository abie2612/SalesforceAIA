@isTest
public class SendAccountDeliveryEmailControllerTest {
    @testSetup static void setup() {
        Account account = TestUtility.getAccount('Test Account');
        INSERT account;
        
        Asset asset = TestUtility.getAsset('testing', account.Id, 12, 10,  4, 'brand 1, brand 2', 'category 1, category 2', 4, 5, 7, 'EU', 'EU', System.today());
        asset.Account_Type__c = 'Special';
        INSERT asset;
        Product2 pduct = TestUtility.getProduct(asset.Id,'Test Product');
        pduct.Sale_Price__c = 1;
        pduct.Amazon_Asset__c = asset.Id;
        INSERT pduct;
        
        Asset asset2 = TestUtility.getAsset('testing', account.Id, 12, 10,  4, 'brand 1, brand 2', 'category 1, category 2', 4, 5, 7, 'EU', 'EU', System.today());
        asset2.Account_Type__c = 'Standard';
        INSERT asset2;
        Product2 pduct2 = TestUtility.getProduct(asset2.Id,'Test Product');
        pduct2.Sale_Price__c = 1;
        pduct2.Amazon_Asset__c = asset2.Id;
        INSERT pduct2;
        
        Id priceBookID = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = priceBookID, Product2Id = pduct.Id, UnitPrice = 1, IsActive = true);
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = priceBookID, Product2Id = pduct2.Id, UnitPrice = 1, IsActive = true);
        INSERT new List<PricebookEntry>{standardPrice, standardPrice2};
            
        List<Opportunity> testOpportunities = new List<Opportunity>{
            TestUtility.getOpportunity('Test Opportunity 1', Date.newInstance(2024,12,9), 'Delivery' , 'US' , account.Id),
                TestUtility.getOpportunity('Test Opportunity 2', Date.newInstance(2024,12,19), 'Delivery' , 'UK' , account.Id)
                };
                    testOpportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        testOpportunities[0].Selected_Product__c = pduct.Id;
        testOpportunities[1].Selected_Product__c = pduct2.Id;
        testOpportunities[0].Pricebook2id = priceBookID;
        testOpportunities[1].Pricebook2id = priceBookID;
        testOpportunities[0].Ownership_Transfer_Completed__c = true;
        testOpportunities[1].Ownership_Transfer_Completed__c = true;
        Insert testOpportunities;        
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = testOpportunities[0].Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = testOpportunities[1].Id;
        cdl2.ContentDocumentId = conDocId;
        cdl2.shareType = 'V';
        
        INSERT new List<ContentDocumentLink>{cdl, cdl2};
        
        Contact contact = TestUtility.getContact(account,'new','contact','test@gmail.com');
        INSERT contact;
        Contract contract = TestUtility.getContract(account.Id,'Draft',Date.newInstance(2024, 12, 9),4);
        contract.Opportunity__c = testOpportunities[0].Id;
        INSERT contract;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = contact.Id;
        ocr.OpportunityId = testOpportunities[0].Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        
        OpportunityContactRole ocr2 = new OpportunityContactRole();
        ocr2.ContactId = contact.Id;
        ocr2.OpportunityId = testOpportunities[1].Id;
        ocr2.IsPrimary = TRUE;
        ocr2.Role = 'Decision Maker';

		INSERT new List<OpportunityContactRole>{ocr, ocr2};
    }
    
    @isTest static void sendingEmailTest2() {
        List<Opportunity> oppList = [SELECT Id, Opportunity_Number_Text__c, Marketplace__c, Asset_Number__c,Selected_Product__r.Amazon_Asset__r.Account_Type__c  FROM Opportunity LIMIT 2];
        oppList[1].Asset_Number__c = '12';
        UPDATE oppList;
        ContentVersion conVersion = [SELECT Id, Title  FROM ContentVersion LIMIT 1];
        conVersion.Title = oppList[1].Opportunity_Number_Text__c +'- '+oppList[1].Marketplace__c+' Account Delivery Pdf';
        UPDATE conVersion;
        SendAccountDeliveryEmailController.sendingEmail(oppList[1].Id);
    }
    
    @isTest static void checkDeliveryEmailTest() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        SendAccountDeliveryEmailController.checkDeliveryEmail(opp.Id);
    }
    
    @isTest static void checkDeliveryEmailTest2() {
        Opportunity opp = [SELECT Id, Delivery_PDF_Generated__c FROM Opportunity LIMIT 1];
       	opp.Delivery_PDF_Generated__c = true;
        opp.Marketplace__c = 'US';
        UPDATE opp;
        SendAccountDeliveryEmailController.checkDeliveryEmail(opp.Id);
    }
    
    @isTest static void checkDeliveryEmailTest3() {
        Opportunity opp = [SELECT Id, Delivery_PDF_Generated__c FROM Opportunity LIMIT 1];
       	opp.Delivery_PDF_Generated__c = false;
        opp.Sent_Delivery_Email__c = false;
        opp.Marketplace__c = 'US';
        UPDATE opp;
        SendAccountDeliveryEmailController.checkDeliveryEmail(opp.Id);
    }
    
    @isTest static void checkDeliveryEmailTest4() {
        Opportunity opp = [SELECT Id, Delivery_PDF_Generated__c FROM Opportunity LIMIT 1];
       	opp.Delivery_PDF_Generated__c = false;
        opp.Sent_Delivery_Email__c = true;
        opp.Email_Sent_Date__c = Date.today();
        opp.Marketplace__c = 'US';
        UPDATE opp;
        SendAccountDeliveryEmailController.checkDeliveryEmail(opp.Id);
    }
    
    @isTest static void checkDeliveryEmailWithBlankMarPlace() {
        Opportunity opp = [SELECT Id, Marketplace__c, StageName FROM Opportunity LIMIT 1];
        opp.Marketplace__c = '';
        opp.StageName = 'Delivery';
        UPDATE opp;
        SendAccountDeliveryEmailController.checkDeliveryEmail(opp.Id);
    }
    
    @isTest static void checkDeliveryEmailWithDeliveryPdfGenerated() {
        Opportunity opp = [SELECT Id, StageName, Delivery_PDF_Generated__c FROM Opportunity LIMIT 1];
        opp.StageName = 'Delivery';
        opp.Delivery_PDF_Generated__c = false;
        UPDATE opp;
        SendAccountDeliveryEmailController.checkDeliveryEmail(opp.Id);
    }
    
    @isTest static void checkDeliEmailWithPdfGeneratedAndSentDate() {
        Opportunity opp = [SELECT Id, StageName, Delivery_PDF_Generated__c, Sent_Delivery_Email__c, Email_Sent_Date__c FROM Opportunity LIMIT 1];
        opp.StageName = 'Delivery';
        opp.Delivery_PDF_Generated__c = false;
        opp.Sent_Delivery_Email__c = true;
        opp.Email_Sent_Date__c = System.Today();
        UPDATE opp;
        SendAccountDeliveryEmailController.checkDeliveryEmail(opp.Id);
    }
    
    @isTest static void sendingEmailTest() {
        Opportunity opp = [SELECT Id, Opportunity_Number_Text__c, Marketplace__c, Asset_Number__c  FROM Opportunity LIMIT 1];
        opp.Asset_Number__c = '12';
        UPDATE opp;
        ContentVersion conVersion = [SELECT Id, Title  FROM ContentVersion LIMIT 1];
        conVersion.Title = opp.Opportunity_Number_Text__c +'- '+opp.Marketplace__c+' Account Delivery Pdf';
        UPDATE conVersion;
        SendAccountDeliveryEmailController.sendingEmail(opp.Id);
    }
    
}