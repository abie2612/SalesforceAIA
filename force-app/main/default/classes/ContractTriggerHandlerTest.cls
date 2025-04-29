@isTest
public class ContractTriggerHandlerTest {
    @testSetup static void setup() {
        Account account = TestUtility.getAccount('Test Account');
        INSERT account;
        List<Opportunity> testOpportunities = new List<Opportunity>{
            TestUtility.getOpportunity('Test Opportunity 1', Date.newInstance(2024,12,9), 'Asset Integration' , 'US' , account.Id),
                TestUtility.getOpportunity('Test Opportunity 2', Date.newInstance(2024,12,19), 'Asset Integration' , 'UK' , account.Id)
                };
                    testOpportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        Insert testOpportunities;
        
        Contact contact = TestUtility.getContact(account,'new','contact','test@gmail.com');
        INSERT contact;
        Contract contract = TestUtility.getContract(account.Id,'Draft',Date.newInstance(2024, 12, 9),4);
        contract.Opportunity__c = testOpportunities[0].Id;
        INSERT contract;
    }
    
    @isTest static void TestMethod1() {
        Account account = [SELECT Id FROM Account LIMIT 1]; 
        Contact contact = [SELECT Id FROM Contact LIMIT 1]; 
        Contract cont = [SELECT Id,Status, Opportunity__c FROM Contract LIMIT 1];
        cont.Status = 'Activated';
        
        Test.StartTest();
        UPDATE cont;
        Test.StopTest();
    }
    @isTest static void TestMethod2() {
        Account account = [SELECT Id FROM Account LIMIT 1]; 
        Contact contact = [SELECT Id FROM Contact LIMIT 1]; 
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity 2' LIMIT 1];
        Contract cont = [SELECT Id,Status, Opportunity__c FROM Contract LIMIT 1];
        cont.Opportunity__c = opp.Id;
        cont.Status = 'Activated';
        
        Test.StartTest();
        UPDATE cont;
        Test.StopTest();
    }
    
}