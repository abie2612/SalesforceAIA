@isTest
private class AccountDeliveryPdfBatchTest {
    
    @testSetup
    static void setupTestData() {
        
        // Create Test Opportunities
        
        Opportunity opp = new Opportunity(Name='Test Opp 1', StageName='Ownership Transfer', Marketplace__c='US', Opportunity_Number_Text__c='OPP-001');            
        opp.CloseDate = System.Today();
        INSERT opp;
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'CUSTOPP-161- US Account Delivery Pdf';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        INSERT cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        // Create ContentDocumentLinks for Opportunities
        ContentDocumentLink docLinks = new ContentDocumentLink(LinkedEntityId = opp.Id, ContentDocumentId = conDocId, ShareType = 'V');
        insert docLinks;
    }
    
    @isTest
    static void testBatchExecution() {
        // Retrieve test opportunities
        Opportunity testOpportunities = [SELECT Id, Marketplace__c FROM Opportunity WHERE StageName = 'Ownership Transfer' LIMIT 1];
        ContentDocumentLink conDocumentLink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: testOpportunities.Id LIMIT 1];
        System.debug('conDocumentLink '+conDocumentLink);
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id, List<Id>> oppIdWithConDocumenMap = new Map<Id, List<Id>>();
        opportunityIds.add(testOpportunities.Id);
        oppIdWithConDocumenMap.put(testOpportunities.Id, new List<Id>{conDocumentLink.ContentDocumentId});
        
        System.debug('==== '+oppIdWithConDocumenMap);
        
        // Execute Batch
        Test.startTest();
        AccountDeliveryPdfBatch batch = new AccountDeliveryPdfBatch(opportunityIds, oppIdWithConDocumenMap);
        Integer batchSize = (Test.isrunningtest()) ? 100 : 1;
        Database.executeBatch(batch, batchSize);
        Test.stopTest();
        
    }
    
    @isTest
    static void testCreatePDFMethod() {
        Opportunity testOpp = [SELECT Id, Opportunity_Number_Text__c FROM Opportunity LIMIT 1];
        
        // Execute method
        Test.startTest();
        AccountDeliveryPdfBatch.createPDF(testOpp.Id, Page.USAccountDeliveryPdf, 'TestPDF.pdf');
        Test.stopTest();
        
        // Verify that ContentVersion is created
        ContentVersion cv = [SELECT Id, Title FROM ContentVersion WHERE Title = 'TestPDF.pdf' LIMIT 1];
        System.assertNotEquals(null, cv, 'ContentVersion should be created.');
    }    
}