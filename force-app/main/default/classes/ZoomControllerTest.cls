@isTest 
public class ZoomControllerTest {
    @testSetup
    public static void testData(){
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
        INSERT zoomMeeting;
        
        //Meeting Participant
        Meeting_Participant__c meetingParticipant = TestUtility.getMeetingParticipant('54142','www.test.com');
        meetingParticipant.Contact__c = con.Id;
        INSERT meetingParticipant;
    }
    
    //Create Zoom Meeting Test Method
    @isTest
    public static void createZoomMeetingTest () {
        
		Event evt = [SELECT Id, Subject, StartDateTime, EndDateTime FROM Event WHERE Subject = 'Test Event' LIMIT 1];        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateMeetingCalloutMock());
        ZoomController.createZoomMeeting(evt);
        test.stopTest();
        Event updatedEvt = [SELECT Id, Subject, StartDateTime, EndDateTime, Zoom_Meeting_Details__c FROM Event WHERE Subject = 'Test Event' LIMIT 1];
        
        Assert.isNull(updatedEvt.Zoom_Meeting_Details__c, 'Zoom Meeting Details is empty');
    }
    
    //Update Zoom Meeting Test Method
    @isTest
    public static void updateZoomMeetingTest () {
        
        Event evt = [SELECT Id, Subject, StartDateTime, EndDateTime,Zoom_Meeting_Details__c,Zoom_Meeting_Details__r.Meeting_Id__c FROM Event WHERE Subject = 'Test Event' LIMIT 1];
        Zoom_Meeting__c zoomMeeting = [SELECT Id, Name, Meeting_URL__c, Meeting_Id__c, Start_Date_and_Time__c, Subject__c, End_Date_and_Time__c FROM Zoom_Meeting__c WHERE Subject__c = 'Test Event' LIMIT 1];
        evt.Subject='Updated Event';
        evt.Zoom_Meeting_Details__c = zoomMeeting.Id;
        UPDATE evt;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new UpdateMeetingCalloutMock());
        ZoomController.updateMeetingOnZoom(evt);
        test.stopTest();
        Zoom_Meeting__c updatedZoomMeeting = [SELECT Id, Name, Meeting_URL__c, Meeting_Id__c, Start_Date_and_Time__c, Subject__c, End_Date_and_Time__c FROM Zoom_Meeting__c WHERE Meeting_Id__c = '86542829031' LIMIT 1];
        Assert.areNotEqual(zoomMeeting.Subject__c, updatedZoomMeeting.Subject__c, 'Zoom Meeting is not updated.');
        Assert.areEqual(zoomMeeting.Start_Date_and_Time__c, updatedZoomMeeting.Start_Date_and_Time__c, 'Start date time must be same');
    }
    
    //Delete Zoom Meeting Test Method
    @isTest
    public static void deleteZoomMeetingTest () {
        
        Event evt = [SELECT Id, Subject, StartDateTime, EndDateTime,Zoom_Meeting_Details__c FROM Event WHERE Subject = 'Test Event' LIMIT 1];
        Zoom_Meeting__c zoomMeeting = [SELECT Id, Name, Meeting_URL__c, Meeting_Id__c, Start_Date_and_Time__c, Subject__c, End_Date_and_Time__c FROM Zoom_Meeting__c WHERE Subject__c = 'Test Event' LIMIT 1];
        evt.Zoom_Meeting_Details__c = zoomMeeting.Id;
        UPDATE evt;
        
        //DELETE evt;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DeleteMeetingCalloutMock());
        ZoomController.deleteMeetingOnZoom(zoomMeeting);
        test.stopTest();    
    }
    
    @isTest
    public static void addMeetingRegistrantTest () {
        Contact con = [SELECT Id, FirstName, LastName FROM Contact WHERE LastName='abc'];
        con.FirstName = null;
        UPDATE con;
               
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new addMeetingParticipantMock());
        ZoomController.addMeetingRegistrants(new List<String>{con.Id+',85746065'});
        test.stopTest();    
        
        Meeting_Participant__c mp = [SELECT Id, Name, Registrant_ID__c, Registrant_Meeting_URL__c, Contact__c FROM Meeting_Participant__c WHERE Contact__c =: con.Id];
        Assert.areEqual('54142', mp.Registrant_ID__c);
    }
    
    @isTest
    public static void addMeetingRegistrantTest2 () {
        Contact con = [SELECT Id, FirstName, LastName FROM Contact WHERE LastName='abc'];
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new UpdateMeetingCalloutMock());
        ZoomController.addMeetingRegistrants(new List<String>{con.Id+',228278221'});
        test.stopTest();    
    }
    
    @isTest
    public static void deleteMeetingRegistrantTest () {
        Contact con = [SELECT Id, Name FROM Contact WHERE LastName='abc'];
        ZoomController zc = new ZoomController();
        test.startTest();
        zc.deleteRegistrant('918212912','82917932139');
        test.stopTest();    
    }
    
    
    public class CreateMeetingCalloutMock implements HttpCalloutMock{
        
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(201);
            res.setBody('{"uuid":"/ELHSV5QTxOVxLnDfYzzTg==","id":86542829031,"host_id":"rVhvbY7iQp--9EiWRacvtg","host_email":"Israel@aia-assets.com","topic":"Test Event","type":2,"status":"waiting","start_time":"2024-02-05T14:30:00Z","duration":30,"timezone":"America/New_York","created_at":"2024-01-12T13:32:53Z","start_url":"https://us06web.zoom.us/s/86542829031?zak=eyJ0eXAiOiJKV1QiLCJzdiI6IjAwMDAwMSIsInptX3NrbSI6InptX28ybSIsImFsZyI6IkhTMjU2In0.eyJhdWQiOiJjbGllbnRzbSIsInVpZCI6InJWaHZiWTdpUXAtLTlFaVdSYWN2dGciLCJpc3MiOiJ3ZWIiLCJzayI6IjM4NjM2NTY1MzI1NjA1NzMyODciLCJzdHkiOjEwMCwid2NkIjoidXMwNiIsImNsdCI6MCwibW51bSI6Ijg2NTQyODI5MDMxIiwiZXhwIjoxNzA1MDczNTc0LCJpYXQiOjE3MDUwNjYzNzQsImFpZCI6ImVUYWVKdnBEUkZlSTFaNUhYUXNxWkEiLCJjaWQiOiIifQ.DkSk7rVBDKbTukTGfMWIIZxWDr9E9bjF5MHKT_-ZEog","join_url":"https://us06web.zoom.us/j/86542829031","registration_url":"https://us06web.zoom.us/meeting/register/tZIoc-ugrDIqGdUQcsWmb2TrVYrcW9t0AJ6X","settings":{"host_video":true,"participant_video":true,"cn_meeting":false,"in_meeting":false,"join_before_host":true,"jbh_time":0,"mute_upon_entry":false,"watermark":false,"use_pmi":false,"approval_type":0,"audio":"both","auto_recording":"none","enforce_login":false,"enforce_login_domains":"","alternative_hosts":"","alternative_host_update_polls":false,"close_registration":false,"show_share_button":true,"allow_multiple_devices":true,"registrants_confirmation_email":false,"waiting_room":true,"request_permission_to_unmute_participants":false,"global_dial_in_countries":["IL","US"],"global_dial_in_numbers":[{"country_name":"Israel","number":"+972 2 376 4509","type":"toll","country":"IL"},{"country_name":"Israel","number":"+972 2 376 4510","type":"toll","country":"IL"},{"country_name":"Israel","number":"+972 3 978 6688","type":"toll","country":"IL"},{"country_name":"US","city":"Washington DC","number":"+1 301 715 8592","type":"toll","country":"US"},{"country_name":"US","number":"+1 305 224 1968","type":"toll","country":"US"},{"country_name":"US","number":"+1 309 205 3325","type":"toll","country":"US"},{"country_name":"US","city":"Chicago","number":"+1 312 626 6799","type":"toll","country":"US"},{"country_name":"US","city":"Houston","number":"+1 346 248 7799","type":"toll","country":"US"},{"country_name":"US","number":"+1 360 209 5623","type":"toll","country":"US"},{"country_name":"US","number":"+1 386 347 5053","type":"toll","country":"US"},{"country_name":"US","number":"+1 507 473 4847","type":"toll","country":"US"},{"country_name":"US","number":"+1 564 217 2000","type":"toll","country":"US"},{"country_name":"US","number":"+1 646 931 3860","type":"toll","country":"US"},{"country_name":"US","number":"+1 669 444 9171","type":"toll","country":"US"},{"country_name":"US","city":"San Jose","number":"+1 669 900 6833","type":"toll","country":"US"},{"country_name":"US","number":"+1 689 278 1000","type":"toll","country":"US"},{"country_name":"US","number":"+1 719 359 4580","type":"toll","country":"US"},{"country_name":"US","city":"New York","number":"+1 929 205 6099","type":"toll","country":"US"},{"country_name":"US","number":"+1 253 205 0468","type":"toll","country":"US"},{"country_name":"US","city":"Tacoma","number":"+1 253 215 8782","type":"toll","country":"US"}],"registrants_email_notification":false,"meeting_authentication":false,"encryption_type":"enhanced_encryption","approved_or_denied_countries_or_regions":{"enable":false},"breakout_room":{"enable":false},"internal_meeting":false,"continuous_meeting_chat":{"enable":false,"auto_add_invited_external_users":false},"participant_focused_meeting":false,"push_change_to_calendar":false,"resources":[],"alternative_hosts_email_notification":false,"show_join_info":true,"device_testing":false,"focus_mode":false,"enable_dedicated_group_chat":false,"private_meeting":true,"email_notification":false,"host_save_video_order":false,"sign_language_interpretation":{"enable":false},"email_in_attendee_report":false},"pre_schedule":false}');
            return res;
        }
    }
    public class UpdateMeetingCalloutMock implements HttpCalloutMock{
        
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(204);
            res.setBody('{"uuid":"/ELHSV5QTxOVxLnDfYzzTg==","id":86542829031,"host_id":"rVhvbY7iQp--9EiWRacvtg","host_email":"Israel@aia-assets.com","topic":"Updated Event","type":2,"status":"waiting","start_time":"2024-02-05T15:30:00Z","duration":30,"timezone":"America/New_York","created_at":"2024-01-12T13:32:53Z","start_url":"https://us06web.zoom.us/s/86542829031?zak=eyJ0eXAiOiJKV1QiLCJzdiI6IjAwMDAwMSIsInptX3NrbSI6InptX28ybSIsImFsZyI6IkhTMjU2In0.eyJhdWQiOiJjbGllbnRzbSIsInVpZCI6InJWaHZiWTdpUXAtLTlFaVdSYWN2dGciLCJpc3MiOiJ3ZWIiLCJzayI6IjM4NjM2NTY1MzI1NjA1NzMyODciLCJzdHkiOjEwMCwid2NkIjoidXMwNiIsImNsdCI6MCwibW51bSI6Ijg2NTQyODI5MDMxIiwiZXhwIjoxNzA1MDczNTc0LCJpYXQiOjE3MDUwNjYzNzQsImFpZCI6ImVUYWVKdnBEUkZlSTFaNUhYUXNxWkEiLCJjaWQiOiIifQ.DkSk7rVBDKbTukTGfMWIIZxWDr9E9bjF5MHKT_-ZEog","join_url":"https://us06web.zoom.us/j/86542829031","registration_url":"https://us06web.zoom.us/meeting/register/tZIoc-ugrDIqGdUQcsWmb2TrVYrcW9t0AJ6X","settings":{"host_video":true,"participant_video":true,"cn_meeting":false,"in_meeting":false,"join_before_host":true,"jbh_time":0,"mute_upon_entry":false,"watermark":false,"use_pmi":false,"approval_type":0,"audio":"both","auto_recording":"none","enforce_login":false,"enforce_login_domains":"","alternative_hosts":"","alternative_host_update_polls":false,"close_registration":false,"show_share_button":true,"allow_multiple_devices":true,"registrants_confirmation_email":false,"waiting_room":true,"request_permission_to_unmute_participants":false,"global_dial_in_countries":["IL","US"],"global_dial_in_numbers":[{"country_name":"Israel","number":"+972 2 376 4509","type":"toll","country":"IL"},{"country_name":"Israel","number":"+972 2 376 4510","type":"toll","country":"IL"},{"country_name":"Israel","number":"+972 3 978 6688","type":"toll","country":"IL"},{"country_name":"US","city":"Washington DC","number":"+1 301 715 8592","type":"toll","country":"US"},{"country_name":"US","number":"+1 305 224 1968","type":"toll","country":"US"},{"country_name":"US","number":"+1 309 205 3325","type":"toll","country":"US"},{"country_name":"US","city":"Chicago","number":"+1 312 626 6799","type":"toll","country":"US"},{"country_name":"US","city":"Houston","number":"+1 346 248 7799","type":"toll","country":"US"},{"country_name":"US","number":"+1 360 209 5623","type":"toll","country":"US"},{"country_name":"US","number":"+1 386 347 5053","type":"toll","country":"US"},{"country_name":"US","number":"+1 507 473 4847","type":"toll","country":"US"},{"country_name":"US","number":"+1 564 217 2000","type":"toll","country":"US"},{"country_name":"US","number":"+1 646 931 3860","type":"toll","country":"US"},{"country_name":"US","number":"+1 669 444 9171","type":"toll","country":"US"},{"country_name":"US","city":"San Jose","number":"+1 669 900 6833","type":"toll","country":"US"},{"country_name":"US","number":"+1 689 278 1000","type":"toll","country":"US"},{"country_name":"US","number":"+1 719 359 4580","type":"toll","country":"US"},{"country_name":"US","city":"New York","number":"+1 929 205 6099","type":"toll","country":"US"},{"country_name":"US","number":"+1 253 205 0468","type":"toll","country":"US"},{"country_name":"US","city":"Tacoma","number":"+1 253 215 8782","type":"toll","country":"US"}],"registrants_email_notification":false,"meeting_authentication":false,"encryption_type":"enhanced_encryption","approved_or_denied_countries_or_regions":{"enable":false},"breakout_room":{"enable":false},"internal_meeting":false,"continuous_meeting_chat":{"enable":false,"auto_add_invited_external_users":false},"participant_focused_meeting":false,"push_change_to_calendar":false,"resources":[],"alternative_hosts_email_notification":false,"show_join_info":true,"device_testing":false,"focus_mode":false,"enable_dedicated_group_chat":false,"private_meeting":true,"email_notification":false,"host_save_video_order":false,"sign_language_interpretation":{"enable":false},"email_in_attendee_report":false},"pre_schedule":false}');
            return res;
        }
    }
    public class DeleteMeetingCalloutMock implements HttpCalloutMock{
        
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(204);
            return res;
        }
    }
    public class addMeetingParticipantMock implements HttpCalloutMock{
        
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(201);
            res.setBody('{"id": 85746065,"join_url": "https://example.com/j/11111","registrant_id": "fdgsfh2ey82fuh","start_time": "2021-07-13T21:44:51Z","topic": "My Meeting","occurrences": [{"duration": 60,"occurrence_id": "1648194360000","start_time": "2022-03-25T07:46:00Z","status": "available"}],"participant_pin_code": 380303}');
            return res;
        }
    }
    
}