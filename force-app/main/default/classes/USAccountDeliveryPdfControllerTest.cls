@isTest
public class USAccountDeliveryPdfControllerTest {
   
    @testSetup
    static void setup() {
        Account account = TestUtility.getAccount('Test Account');
        INSERT account;
       
        Opportunity testOpp = TestUtility.getOpportunity('Test Opportunity 1',Date.newInstance(2024, 12, 9),'Asset Integration','US',account.Id);
        testOpp.Amazon_QR_Code__c = '<img src="some_qr_code.png">';
        INSERT testOpp;
    }

    @isTest
    static void USAccDeliveryPdfMethod() {
        List<Opportunity> oppList = [SELECT Id, Amazon_QR_Code__c FROM Opportunity LIMIT 1];
        System.assert(oppList.size() > 0, 'No Opportunity found for testing.');
       
        PageReference pageRef = Page.USAccountDeliveryPdf; 
        pageRef.getParameters().put('id', String.valueOf(oppList[0].Id));
        Test.setCurrentPage(pageRef);
       
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
        USAccountDeliveryPdfController testController = new USAccountDeliveryPdfController(sc);
        Test.stopTest();

        System.assertNotEquals(testController.opp, null, 'Opportunity should be assigned.');
           }
}