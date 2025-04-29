@isTest
public class BatchLeadConversionTest {
    
    @testSetup
    static void setupTestData() {
        //Create Test Account
        Account acc = TestUtility.getAccount('Test Vendor');
        INSERT acc;
        
        Id customerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id vendorRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        
        // Create Test Lead
        INSERT new List<Lead>{
            new Lead(Company = 'Test Vendor', LastName = 'Test', LeadSource = 'Plan B', Email = 'vendor@test.com', RecordTypeId = vendorRecordTypeId),
                new Lead(Company = 'Test customer', LastName = 'Test', LeadSource = 'Other', Email = 'customer@test.com', RecordTypeId = customerRecordTypeId)
                };
    }
    
    @isTest
    static void testBatchLeadConversion() {
        List<Lead> leads = [SELECT Id, IsConverted, LeadSource, Lead_Stage__c FROM Lead];
        Set<Id> leadIdSet = new Set<Id>();
        for(Lead lead: leads){
            leadIdSet.add(lead.Id);
        }
        Test.startTest();
        
        // Run batch with all leads
        BatchLeadConversion batch = new BatchLeadConversion(leadIdSet);
        Database.executeBatch(batch, 2);
        
        Test.stopTest();
    }
}