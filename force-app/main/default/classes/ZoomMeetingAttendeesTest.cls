@isTest
public class ZoomMeetingAttendeesTest {
    @isTest static void testZoomMeetingAttendees(){
        Lead lead = TestUtility.getLead('Test','Lead','New','Test Company','Warm','test@gmail.com');
        lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        lead.LeadSource = 'Website';
        lead.Lead_Stage__c = 'New';
        INSERT lead;
        
        // Account
        Account acc = TestUtility.getAccount('Test ABC');
        INSERT acc;
        
        // Contact
        Contact con = TestUtility.getContact(acc, 'test', 'abc', 'test@test.com');
        INSERT con;
        
        // Event
        Event evt = TestUtility.getEvent('Test Event', Datetime.newInstance(2024, 8, 15, 10, 0, 0), Datetime.newInstance(2024, 8, 15, 11, 0, 0));
        INSERT evt;
        
        //Zoom Meeting Details
        Zoom_Meeting__c zoomMeeting = TestUtility.getZoomMeeting('Test Event', Datetime.newInstance(2024, 8, 15, 10, 0, 0), Datetime.newInstance(2024, 8, 15, 11, 0, 0), '86542829031', 'https://us06web.zoom.us/j/8654282903');
        zoomMeeting.Lead__c = lead.Id;
        INSERT zoomMeeting;
        
        //Meeting Participant
        Meeting_Participant__c meetingParticipant = TestUtility.getMeetingParticipant('54142','www.test.com');
        meetingParticipant.Meeting_Details__c = zoomMeeting.Id;
        meetingParticipant.Contact__c = con.Id;
        INSERT meetingParticipant;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ZoomMeeting/';  
        
        String jsonInput = '{"event":"meeting.participant_joined","payload":{"account_id":"r9rbz9WEQciA9ygTcsnV7A","object":{"duration":180,"start_time":"2022-03-05T06:16:41Z","timezone":"America/New_York","end_time":"2022-03-05T06:21:08Z","topic":"Test Meeting","id":"86542829031","participant":{"registrant_id":"54142", "email":"test@gmail.com"},"type":8,"uuid":"aLWYDFO2TJKZ75vXQSFA3Q==","host_id":"nLl1f43CTm-qra8hPKa4IQ"}},"event_ts":1646461268036}';
        
        req.requestBody = Blob.valueof(jsonInput);
        RestContext.request = req; 
        RestContext.response= res;
        
        Test.startTest();
        ZoomMeetingAttendees.zoomNotifications();
        Test.stopTest();
    }
    
    @isTest static void testZoomMeetingAttendees2(){
        Lead lead = TestUtility.getLead('Test','Lead','New','Test Company','Warm','test@gmail.com');
        lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        lead.LeadSource = 'Website';
        lead.Lead_Stage__c = 'New';
        INSERT lead;
        
        // Account
        Account acc = TestUtility.getAccount('Test ABC');
        INSERT acc;
        
        // Contact
        Contact con = TestUtility.getContact(acc, 'test', 'abc', 'test@test.com');
        INSERT con;
        
        // Event
        Event evt = TestUtility.getEvent('Test Event', Datetime.newInstance(2024, 8, 15, 10, 0, 0), Datetime.newInstance(2024, 8, 15, 11, 0, 0));
        INSERT evt;
        
        //Zoom Meeting Details
        Zoom_Meeting__c zoomMeeting = TestUtility.getZoomMeeting('Test Event', Datetime.newInstance(2024, 8, 15, 10, 0, 0), Datetime.newInstance(2024, 8, 15, 11, 0, 0), '86542829031', 'https://us06web.zoom.us/j/8654282903');
        zoomMeeting.Lead__c = lead.Id;
        INSERT zoomMeeting;
        
        //Meeting Participant
        Meeting_Participant__c meetingParticipant = TestUtility.getMeetingParticipant('54142','www.test.com');
        meetingParticipant.Meeting_Details__c = zoomMeeting.Id;
        meetingParticipant.Contact__c = con.Id;
        INSERT meetingParticipant;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ZoomMeeting/';  
        
        String jsonInput = '{"event":"endpoint.url_validation","payload":{"account_id":"r9rbz9WEQciA9ygTcsnV7A","plainToken":"77hdev8213732bd9"},"event_ts":1646461268036}';
        
        req.requestBody = Blob.valueof(jsonInput);
        RestContext.request = req; 
        RestContext.response= res;
        
        Test.startTest();
        ZoomMeetingAttendees.zoomNotifications();
        Test.stopTest();
    }
}