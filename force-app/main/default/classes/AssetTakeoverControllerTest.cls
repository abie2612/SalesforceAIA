@isTest
public class AssetTakeoverControllerTest {
    @testSetup static void setup() {
        Opportunity opportunity = TestUtility.getOpportunity('Test Opportunity',Date.newInstance(2024, 12, 9),'Asset Takeover');
        INSERT opportunity;
    }
    
    @isTest static void getOppTest() {
        Opportunity opportunity = [SELECT Id,Email_QR_code__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        opportunity.Email_QR_code__c = 'test';
        opportunity.Email_Address_On_Live_Takeover__c = 'test@gmail.com';
        opportunity.Email_Password__c = 'test';
        opportunity.Amazon_Password__c = 'test';
        opportunity.CallHippo_phone_number__c = '71916112';
        opportunity.Amazon_QR_Code__c = 'test';
        UPDATE opportunity;
        Test.StartTest();
        AssetTakeoverController.getFieldHistory(opportunity.Id);
        Test.StopTest();
    }
    
    @isTest static void getFieldHistoryTest() {
        Opportunity opportunity = [SELECT Id,Email_QR_code__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        opportunity.Email_QR_code__c = '';
        UPDATE opportunity;
        Test.StartTest();
        Opportunity opp = AssetTakeoverController.getOpp(opportunity.Id);
        Test.StopTest();
        Assert.areEqual('', opp.Email_QR_code__c,'Final gmail QR code value is invalid');
    }
    
    @isTest static void getOTPTest() {
        Opportunity opportunity = [SELECT Id,Email_QR_code__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        opportunity.Email_QR_code__c = '';
        UPDATE opportunity;
        Test.StartTest();
        Opportunity opp = AssetTakeoverController.getOTP(opportunity.Id);
        Test.StopTest();
    }
    
    @isTest static void getSubStageTest() {
        Opportunity opportunity = [SELECT Id,Sub_Stage__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        opportunity.Sub_Stage__c = 'VPS';
        UPDATE opportunity;
        Test.StartTest();
        String vpsValue = AssetTakeoverController.getSubStage(opportunity.Id);
        Test.StopTest();
        Assert.areEqual('VPS',vpsValue ,'SubStage is not proper');
    }
    
    @isTest static void changeSubStageTest() {
        Opportunity opportunity = [SELECT Id,Sub_Stage__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        opportunity.Sub_Stage__c = 'Live Takeover';
        UPDATE opportunity;
        Test.StartTest();
        AssetTakeoverController.changeSubStage(opportunity.Id,opportunity.Sub_Stage__c, true);
        Opportunity opp = [SELECT Id,Sub_Stage__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        Test.StopTest();
        Assert.isNull(opp.Sub_Stage__c ,'SubStage is not proper');
    }
    
     @isTest static void sendDatatoOppTest(){
        Opportunity opportunity = [SELECT Id,Sub_Stage__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        opportunity.Sub_Stage__c = 'VPS';
        UPDATE opportunity;
        String jsonStringOpportunity = '{"Id":"12","Name":"Test Opportunity","Sub_Stage__c":"VPS"}';
        Test.StartTest();
        AssetTakeoverController.sendDatatoOpp(opportunity.Id,jsonStringOpportunity);
        Opportunity opp = [SELECT Id,Sub_Stage__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        Assert.areEqual('VPS', opp.Sub_Stage__c,'SubStage is not proper');
        Test.StopTest();
    }
    
     @isTest static void uploadQRCodesTest(){
        Opportunity opportunity = [SELECT Id, Email_Address_on_Email_Account__c,Email_Account_Password_Final__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        Test.StartTest();
        AssetTakeoverController.uploadQRCodes(opportunity.Email_Address_on_Email_Account__c,opportunity.Email_Account_Password_Final__c,true,opportunity.Id, 'test', 'test', 'test');
        Opportunity opp = [SELECT Id,Sub_Stage__c,FinalFileName__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        Test.StopTest();
    }
    
     @isTest static void uploadQRFromEmailAccountTest(){
        Opportunity opportunity = [SELECT Id, Email_Account_OTP_QR_code_Final_Email__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        Test.StartTest();
        AssetTakeoverController.uploadQRFromEmailAccount(null, 'Test',opportunity.id);
        Opportunity opp = [SELECT Id,Email_Account_OTP_QR_code_Final_Email__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        Assert.isNull(opp.Email_Account_OTP_QR_code_Final_Email__c,'Email_Account_OTP_QR_code_Final_Email__c is not valid');
        Test.StopTest();
    }
}