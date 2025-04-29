@isTest
public class LeadTriggerHandlerTest {
    @testSetup static void setup() {
        List<Lead> leadLists = new List<Lead>();
        Lead customerLead = TestUtility.getLead('Test','Lead','New','Test Company','Warm','test@gmail.com');
        customerLead.LeadSource = 'Other';
        leadLists.add(customerLead);
        Id vendorRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        leadLists.add(new Lead(Company = 'Test Company', LastName = 'Test', LeadSource = 'Plan B', Email = 'vendor@test.com', RecordTypeId = vendorRecordTypeId));
        INSERT leadLists;

        Opportunity opportunity = TestUtility.getOpportunity('Test Lead 1',Date.newInstance(2024, 12, 9),'Asset Integration');
        INSERT opportunity;
        Account acc = TestUtility.getAccount('Test Company');
        INSERT acc;
        Zoom_Meeting__c zoomMeeting = TestUtility.getZoomMeeting('Email',Date.newInstance(2024, 12, 9),Date.newInstance(2024, 12, 9),'1245','www.amazon.com');
        INSERT zoomMeeting;
        Event event = TestUtility.getEvent(Date.newInstance(2024, 12, 9),25,Date.newInstance(2024, 12, 9));
        event.WhoId = leadLists[0].Id;
        event.Zoom_Meeting_Details__c = zoomMeeting.Id;
        INSERT event;
    }
    
    @isTest static void updateCustomerLead() {
        List<Lead> leadList = new List<Lead>();
        Map<Id,Lead> mapLead = new Map<Id,Lead>();
        Lead newLead = [SELECT Id,Rating FROM Lead WHERE Name='Test Lead' LIMIT 1];
        mapLead.put(newLead.Id,newLead);
        newLead.Rating = 'Cold';
        newLead.VPS_Timezone__c = 'test';
        newLead.Location_for_VPS_City__c = 'test';
        newLead.Location_for_VPS_Country__c = 'test';
        UPDATE newLead;
        leadList.add(newLead);
        Test.StartTest();
        LeadTriggerHandler.onAfterUpdate(leadList,mapLead);
        Lead resultLead = [SELECT Id,Rating FROM Lead WHERE lastName='Lead' LIMIT 1];
        Test.StopTest();
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name='Test Lead 1' LIMIT 1];
        Zoom_Meeting__c zoomMeeting = [SELECT Id FROM Zoom_Meeting__c LIMIT 1];
        Event event = [SELECT Id FROM Event LIMIT 1];
        Account account = [SELECT Id FROM Account WHERE Name='Test Company' LIMIT 1];
        Contact contact = [SELECT Id,lastName,Email FROM Contact WHERE lastName='Lead' LIMIT 1];
        Assert.areEqual('test@gmail.com', contact.Email, 'Lead Conversion is not correct');
    }
    @isTest static void updateVendorLead() {
        List<Lead> leadList = new List<Lead>();
        Map<Id,Lead> mapLead = new Map<Id,Lead>();
        Lead newLead = [SELECT Id,Rating FROM Lead WHERE Name='Test' LIMIT 1];
        mapLead.put(newLead.Id,newLead);
        newLead.Rating = 'Cold';
        newLead.VPS_Timezone__c = 'test';
        newLead.Location_for_VPS_City__c = 'test';
        newLead.Location_for_VPS_Country__c = 'test';
        UPDATE newLead;
        leadList.add(newLead);
        Test.StartTest();
        LeadTriggerHandler.onAfterUpdate(leadList,mapLead);
        Lead resultLead = [SELECT Id,Rating FROM Lead WHERE Name='Test' LIMIT 1];
        Test.StopTest();
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name='Test Lead 1' LIMIT 1];
        Zoom_Meeting__c zoomMeeting = [SELECT Id FROM Zoom_Meeting__c LIMIT 1];
        Event event = [SELECT Id FROM Event LIMIT 1];
        Account account = [SELECT Id FROM Account WHERE Name='Test Company' LIMIT 1];
        Contact contact = [SELECT Id,lastName,Email FROM Contact WHERE Name='Test' LIMIT 1];
        Assert.areEqual('vendor@test.com', contact.Email, 'Lead Conversion is not correct');
    }
}