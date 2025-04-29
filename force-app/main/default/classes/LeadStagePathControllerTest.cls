@isTest
public class LeadStagePathControllerTest {
    @testSetup static void setup() {
        Lead lead = TestUtility.getLead('Test','Lead','New','Test Company','Warm','test@gmail.com');
        lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        lead.LeadSource = 'Web';
        INSERT lead;
    }
    @isTest static void getPicklistValuesTest() {
        Lead newLead = [SELECT Id,Rating FROM Lead WHERE Name='Test Lead' LIMIT 1];
        
        Test.StartTest();
        LeadStagePathController.getLeadStages(newLead.Id);
        Test.StopTest();
    }
    @isTest static void updateLeadStageTest() {
        Lead newLead = [SELECT Id,Rating, RecordType.Name FROM Lead WHERE Name='Test Lead' LIMIT 1];
		System.debug(newLead);        
        Test.StartTest();
        LeadStagePathController.updateLeadStage('Lead Responded',newLead.Id);
        Test.StopTest();
    }
}