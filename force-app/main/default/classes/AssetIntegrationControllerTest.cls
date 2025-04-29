@isTest
public class AssetIntegrationControllerTest {
    @testSetup static void setup() {
        Opportunity opportunity = TestUtility.getOpportunity('Test Opportunity',Date.newInstance(2024, 12, 9),'Asset Integration');
        INSERT opportunity;
    }
    
    @isTest static void getOppTest() {
        Opportunity opportunity = [SELECT Id,StageName,Sub_Stage__c,VPS3__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        opportunity.VPS3__c = True;
        UPDATE opportunity;
        Test.StartTest();
        Opportunity opp = AssetIntegrationController.getOpp(opportunity.Id);
        Test.StopTest();
        Assert.isTrue(opp.VPS3__c,'Result is wrong');
    }
    
    @isTest static void uploadScreenShotTest(){
        Opportunity opportunity = [SELECT Id,StageName,Sub_Stage__c,Paused_all_active_ad_campaigns__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        opportunity.Paused_all_active_ad_campaigns__c = True;
        UPDATE opportunity;
        Test.StartTest();
        AssetIntegrationController.uploadScreenShot(null,null,null,null,opportunity.Id,true,true,true,true,'filename1','filename2','filename3','filename4',opportunity.Paused_all_active_ad_campaigns__c);
        Test.StopTest();
        Opportunity opp = [SELECT Id,Paused_all_active_ad_campaigns__c,Amazon_QR_Code__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        Assert.isNull(opp.Amazon_QR_Code__c,'Image is not inserted properly');
    }
    
    @isTest static void sendingSubStageTest(){
        Opportunity opportunity = [SELECT Id,Sub_Stage__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        opportunity.Sub_Stage__c = 'Asset Integration';
        UPDATE opportunity;
        Test.StartTest();
        AssetIntegrationController.sendingSubStage(opportunity.Sub_Stage__c,opportunity.Id);
        Test.StopTest();
        Opportunity opp = [SELECT Id,Sub_Stage__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        Assert.areEqual('Asset Integration', opp.Sub_Stage__c,'SubStage is not proper');
    }
    
    @isTest static void sendDatatoOppTest(){
        Opportunity opportunity = [SELECT Id,Sub_Stage__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        opportunity.Sub_Stage__c = 'Asset Integration';
        UPDATE opportunity;
        String jsonStringOpportunity = '{"Id":"12","Name":"Test Opportunity","Sub_Stage__c":"Asset Integration"}';
        Test.StartTest();
        AssetIntegrationController.sendDatatoOpp(opportunity.Id,jsonStringOpportunity);
        Opportunity opp = [SELECT Id,Sub_Stage__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        Assert.areEqual('Asset Integration', opp.Sub_Stage__c,'Record is not updated properly');
        Test.StopTest();
    }
    
    @isTest static void accountTypeMethodTest(){
        Opportunity opportunity = [SELECT Id,Sub_Stage__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        opportunity.Sub_Stage__c = 'Account Type Analysis';
        UPDATE opportunity;
        Test.StartTest();
        AssetIntegrationController.accountTypeMethod(opportunity.Id,true);
        Opportunity opp = [SELECT Id,Sub_Stage__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        Assert.areEqual('Account Type Analysis', opp.Sub_Stage__c,'Record is not updated properly');
        Test.StopTest();
    }
    
    @isTest static void saveDataTest(){
        Opportunity opportunity = [SELECT Id,Sub_Stage__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        Test.StartTest();
        AssetIntegrationController.saveData('Test','Test', opportunity.Id,'file1');
        Test.StopTest();
    }
}