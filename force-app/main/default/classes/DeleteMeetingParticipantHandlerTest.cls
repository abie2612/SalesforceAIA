@isTest
public class DeleteMeetingParticipantHandlerTest {
	@testSetup
    public static void testData(){
        //Zoom Meeting Details
        Zoom_Meeting__c zoomMeeting = TestUtility.getZoomMeeting('Test Event', Datetime.newInstance(2024, 5, 15, 10, 0, 0), Datetime.newInstance(2024, 5, 15, 11, 0, 0), '86542829031', 'https://us06web.zoom.us/j/8654282903');
        INSERT zoomMeeting;
        
        //Meeting Participant
        Meeting_Participant__c mp = TestUtility.getMeetingParticipant('918212912', '82917932139');
        mp.Meeting_Details__c = zoomMeeting.Id;
        INSERT mp;
    }
    
    @isTest
    public static void deleteMeetingParticipant(){
        Meeting_Participant__c mp = [SELECT Id, Name, Registrant_ID__c, Registrant_Meeting_URL__c FROM Meeting_Participant__c mp WHERE Registrant_ID__c = '918212912'];
        
        DELETE mp;
    }
}