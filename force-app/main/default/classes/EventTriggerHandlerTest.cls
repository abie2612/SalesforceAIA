@isTest 
public class EventTriggerHandlerTest {
    @IsTest
    public static void onAfterInsertTest(){
        // Event
        Event evt = TestUtility.getEvent('Test Event', Datetime.newInstance(2024, 5, 15, 10, 0, 0), Datetime.newInstance(2024, 5, 15, 11, 0, 0));
        INSERT evt;
       	
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateMeetingCalloutMock());
        test.stopTest();
        Event updatedEvt = [SELECT Id, Subject, StartDateTime, EndDateTime, Zoom_Meeting_Details__c FROM Event WHERE Subject = 'Test Event' LIMIT 1];
        
        Assert.isNotNull(updatedEvt.Zoom_Meeting_Details__c, 'Zoom Meeting Details is empty');
    }
    
    @IsTest
    public static void onAfterUpdateTest(){
        Zoom_Meeting__c zoomMeeting = TestUtility.getZoomMeeting('Test Event', Datetime.newInstance(2024, 5, 15, 10, 0, 0), Datetime.newInstance(2024, 5, 15, 11, 0, 0), '86542829031', 'https://us06web.zoom.us/j/8654282903');
        INSERT zoomMeeting;
        Event evt = TestUtility.getEvent('Test Event', Datetime.newInstance(2024, 5, 15, 10, 0, 0), Datetime.newInstance(2024, 5, 15, 11, 0, 0));
        evt.Zoom_Meeting_Details__c = zoomMeeting.Id;
        INSERT evt;
        
        evt.Subject = 'Updated Event';
        UPDATE evt;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new UpdateMeetingCalloutMock());
        test.stopTest();
        
        Zoom_Meeting__c updatedZoomMeeting = [SELECT Id, Name, Meeting_URL__c, Meeting_Id__c, Start_Date_and_Time__c, Subject__c, End_Date_and_Time__c FROM Zoom_Meeting__c WHERE Meeting_Id__c = '86542829031' LIMIT 1];
        Assert.areEqual('Updated Event', updatedZoomMeeting.Subject__c, 'Zoom Meeting is not updated.');
        Assert.isNotNull(updatedZoomMeeting.Start_Date_and_Time__c, 'Start date time must be same');
    }
    
    @IsTest
    public static void onAfterDeleteTest(){
        // Event
        Event evt = TestUtility.getEvent('Test Event', Datetime.newInstance(2024, 5, 15, 10, 0, 0), Datetime.newInstance(2024, 5, 15, 11, 0, 0));
        
        //Zoom Meeting Details
        Zoom_Meeting__c zoomMeeting = TestUtility.getZoomMeeting('Test Event', Datetime.newInstance(2024, 5, 15, 10, 0, 0), Datetime.newInstance(2024, 5, 15, 11, 0, 0), '86542829031', 'https://us06web.zoom.us/j/8654282903');
        INSERT zoomMeeting;
        
        evt.Zoom_Meeting_Details__c = zoomMeeting.Id;
        INSERT evt;
        
        DELETE evt;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DeleteMeetingCalloutMock());
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
}