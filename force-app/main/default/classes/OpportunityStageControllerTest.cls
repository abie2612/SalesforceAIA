@isTest
public class OpportunityStageControllerTest {
    @testSetup static void setup() {
        Opportunity opportunity = TestUtility.getOpportunity('Test Opportunity',Date.newInstance(2024, 12, 9),'Asset Integration');
        INSERT opportunity;
    }
    
    @isTest static void testMethod1() {
        Opportunity opportunity = [SELECT Id,StageName,Sub_Stage__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        opportunity.Sub_Stage__c = 'Asset Integration';
        UPDATE opportunity;
        Test.StartTest();
        Opportunity opp = OpportunityStageController.getStageName(opportunity.Id);
        Test.StopTest();
        Assert.areEqual('Asset Integration',opp.StageName,'Opportunity stagename is not correct');
    }
}