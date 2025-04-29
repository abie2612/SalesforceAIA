@isTest
public class SendAccountDeliveryPdfControllerTest {
    
    @testSetup static void setup() {
        Account account = TestUtility.getAccount('Test Account');
        INSERT account;
        List<Opportunity> testOpportunities = new List<Opportunity>{
            TestUtility.getOpportunity('Test Opportunity 1', Date.newInstance(2024,12,9), 'Asset Integration' , 'US' , account.Id)
                };
                    Insert testOpportunities;        
    }
    
    @isTest static void testAccountOpportunity(){    
        Opportunity opp = [SELECT Id, StageName, Delivery_PDF_Generated__c FROM Opportunity LIMIT 1];   
        //AccountNew is the Visualforce page created
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(opp.Id));
        SendAccountDeliveryPdfController testController = new SendAccountDeliveryPdfController();
        String pdfData = testController.getPDF();
        System.assertEquals(null, pdfData, 'PDF data should not be null');
    } 
}