@isTest
public class UKAccountDeliveryPdfControllerTest {
    
    @testSetup
    static void setup() {
        Account account = TestUtility.getAccount('Test Account');
        INSERT account;
        
        Opportunity testOpp = TestUtility.getOpportunity('Test Opportunity 1',Date.newInstance(2024, 12, 9),'Asset Integration','US',account.Id);
        testOpp.Amazon_QR_Code__c = '<img src="some_qr_code.png">';
        INSERT testOpp;
    }
    
    @isTest
    static void UKAccDeliveryPdfMethod() {
        List<Opportunity> oppList = [SELECT Id, Amazon_QR_Code__c FROM Opportunity LIMIT 1];
        System.assert(oppList.size() > 0, 'No Opportunity found for testing.');
        
        PageReference pageRef = Page.UKAccountDeliveryPdf;
        pageRef.getParameters().put('id', String.valueOf(oppList[0].Id));
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
        UKAccountDeliveryPdfController testController = new UKAccountDeliveryPdfController(sc);
        Test.stopTest();
        
        System.assertNotEquals(testController.opp, null, 'Opportunity should be assigned.');
    }
}