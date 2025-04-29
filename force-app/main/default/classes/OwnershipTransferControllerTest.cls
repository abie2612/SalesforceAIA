@isTest
public class OwnershipTransferControllerTest {
    
    @testSetup
    static void setupTestData() {
        Account acc = TestUtility.getAccount('Test ABC');
        INSERT acc;
        Opportunity custOpp = TestUtility.getOpportunity('Test Customer Opportunity',Date.newInstance(2024, 12, 9),'Ownership Transfer','US',acc.Id);
        Id cusOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        custOpp.RecordTypeId = cusOppRecordTypeId;
        custOpp.Sub_Stage__c = 'Help Tickets';
        INSERT custOpp;
        
        // Create Related Contract for File Retrieval Test
        Contract testContract = new Contract(
            Opportunity__c = custOpp.Id,
            Status = 'Draft'
        );
        INSERT testContract;
        testContract.Status = 'Activated';
        UPDATE testContract;
    }

    @isTest
    static void testGetSubStage() {
        Opportunity testOpp = [SELECT Id, Sub_Stage__c FROM Opportunity LIMIT 1];

        Test.startTest();
        String subStage = OwnershipTransferController.getSubStage(testOpp.Id);
        Test.stopTest();

        System.assertEquals('Help Tickets', subStage, 'Sub-stage should be correctly retrieved');
    }

    @isTest
    static void testGetOpp() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        Opportunity opp = OwnershipTransferController.getOpp(testOpp.Id);
        Test.stopTest();

        System.assertNotEquals(null, opp, 'Opportunity should not be null');
        System.assertEquals(testOpp.Id, opp.Id, 'Fetched Opportunity should match test Opportunity');
    }

    @isTest
    static void testChangeSubStage() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        OwnershipTransferController.changeSubStage(testOpp.Id, 'Tax and Legal Entity', false);

        Opportunity updatedOpp = [SELECT Id, Sub_Stage__c FROM Opportunity WHERE Id = :testOpp.Id];
        System.assertEquals('Tax and Legal Entity', updatedOpp.Sub_Stage__c, 'Sub-stage should be updated');

        OwnershipTransferController.changeSubStage(testOpp.Id, 'Email Account Credential Check', true);
        Test.stopTest();

        updatedOpp = [SELECT Id, Sub_Stage__c, StageName, Ownership_Transfer_Completed__c FROM Opportunity WHERE Id = :testOpp.Id];
        System.assertEquals('Payment', updatedOpp.StageName, 'Stage should be set to Payment');
        System.assertEquals(true, updatedOpp.Ownership_Transfer_Completed__c, 'Ownership Transfer should be completed');
    }

    @isTest
    static void testSaveData() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];

        String base64File = EncodingUtil.base64Encode(Blob.valueOf('Test File Content'));
        String filename = 'TestFile.pdf';

        Test.startTest();
        OwnershipTransferController.saveData(base64File, filename, testOpp.Id, 'file1', 'DepositMethod');
        OwnershipTransferController.saveData(base64File, filename, testOpp.Id, 'file1', 'ChargeMethod');
        OwnershipTransferController.saveData(base64File, filename, testOpp.Id, 'file1', 'TaxAndLegal');
        OwnershipTransferController.saveData(base64File, filename, testOpp.Id, 'file1', 'SellerProfile');
        OwnershipTransferController.saveData(base64File, filename, testOpp.Id, 'file1', 'BuyerProfile');
        Test.stopTest();

        List<ContentVersion> cvList = [SELECT Id FROM ContentVersion WHERE Title = :filename];
        System.assertNotEquals(0, cvList.size(), 'File should be inserted');

        List<ContentDocumentLink> cdlList = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :testOpp.Id];
        System.assertNotEquals(0, cdlList.size(), 'Content link should be created');
    }

    @isTest
    static void testGetRelatedFilesByRecordId() {
        Contract testContract = [SELECT Id, Opportunity__c FROM Contract LIMIT 1];

        Test.startTest();
        Map<ID, String> files = OwnershipTransferController.getRelatedFilesByRecordId(testContract.Opportunity__c);
        Test.stopTest();

        System.assertNotEquals(null, files, 'File map should not be null');
    }
}