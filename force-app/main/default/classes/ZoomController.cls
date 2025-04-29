public class ZoomController {
    public static String endPointUrl = System.Label.End_Point_Url;
    // Create Zoom Meeting
    public static void createZoomMeeting(Event newEvent) {
        try 
        {
            String userId = System.Label.Zoom_Host_Id;
            if(newEvent != NULL && newEvent.StartDateTime != NULL && newEvent.EndDateTime != NULL)
            {
                DateTime startDate = ConvertTimeZoneService.convertDateTimeToOtherTimeZone(newEvent.StartDateTime, ConvertTimeZoneService.EST, 'GMT');
                DateTime endDate = ConvertTimeZoneService.convertDateTimeToOtherTimeZone(newEvent.EndDateTime, ConvertTimeZoneService.EST, 'GMT');
                
                // Calculate Durations
                Long milliseconds = newEvent.EndDateTime.getTime() - newEvent.StartDateTime.getTime();
                Long seconds = milliseconds / 1000;
                Long minutes = seconds / 60;
                
                String jsonbody = getCreateMeetingJSONBody(newEvent, startDate, endDate, 'America/New_York',String.valueOf(minutes));
                System.debug('JSON Request Body ## ' + jsonbody);
                
                // Create Meeting
                HttpResponse response = new HTTPCalloutCTRL().setEndPoint(endPointUrl +'/users/'+userId + '/meetings').setMethod('POST').setBody(jsonbody).makeCallout();
                System.debug('Response : ' + response.getBody());
                
                if(response.getStatusCode() == 201) 
                {
                    Map<String, Object> meetingData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    
                    if(meetingData != NULL && meetingData.size()>0) 
                    {
                        Zoom_Meeting__c meetingDetails = createZoomMeetingDetails(meetingData, newEvent);
                        newEvent.Zoom_Meeting_Details__c = meetingDetails.Id;
                        UPDATE newEvent;
                    }
                } else {
                    Exception__c ex = new Exception__c(Controller_Method_Name__c = 'ZoomController', Exception_Message__c = response.getBody(), Type__c = 'Zoom');
                    if(ex != NULL) Database.insert(ex);
                }
            }
        } Catch(Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp, 'Zoom', 'ZoomController.createZoomMeeting()');
            if(e != NULL) Database.insert(e);
        }
    }
    
    private static Zoom_Meeting__c createZoomMeetingDetails(Map<String, Object> meetingData, Event evt) {
        if(meetingData.containsKey('id') && meetingData.containsKey('join_url')){
            Zoom_Meeting__c zoomMeeting = new Zoom_Meeting__c();
            zoomMeeting.Meeting_Id__c = ''+meetingData.get('id');
            zoomMeeting.Meeting_URL__c = ''+meetingData.get('join_url');
            zoomMeeting.Subject__c = evt.Subject;
            zoomMeeting.Start_Date_and_Time__c = evt.StartDateTime;
            zoomMeeting.End_Date_and_Time__c = evt.EndDateTime;
            if(evt.WhoId != null && String.valueOf(evt.WhoId).startsWith('00Q')){
                zoomMeeting.Lead__c = evt.WhoId;
            }
            INSERT zoomMeeting;
            return zoomMeeting;
        }
        else{
            Exception__c ex = new Exception__c(Controller_Method_Name__c = 'ZoomController.createZoomMeetingDetails()', Type__c = 'Zoom');
            if(ex != NULL) Database.insert(ex);
            return null;
        }        
    }
    
    // Update Meeting On Zoom Application
    public static void updateMeetingOnZoom(Event newEvent) {
        if(newEvent.StartDateTime != NULL && newEvent.EndDateTime != NULL && newEvent.Subject != null)
        {
            DateTime startDate = ConvertTimeZoneService.convertDateTimeToOtherTimeZone(newEvent.StartDateTime, ConvertTimeZoneService.EST, 'GMT');
            DateTime endDate = ConvertTimeZoneService.convertDateTimeToOtherTimeZone(newEvent.EndDateTime, ConvertTimeZoneService.EST, 'GMT');
            
            // Calculate Durations
            Long milliseconds = newEvent.EndDateTime.getTime() - newEvent.StartDateTime.getTime();
            Long seconds = milliseconds / 1000;
            Long minutes = seconds / 60;
            
            String jsonbody = getCreateMeetingJSONBody(newEvent, startDate, endDate, 'America/New_York',String.valueOf(minutes));
            System.debug('JSON Request Body : ' + jsonbody);
            
            String meetingId = newEvent.Zoom_Meeting_Details__r.Meeting_Id__c;
            
            HttpResponse response = new HTTPCalloutCTRL().setEndPoint(endPointUrl + '/meetings/'+meetingId).setMethod('PATCH').setBody(jsonbody).makeCallout();
            System.debug('Response : ' + response);
            if(response.getStatusCode() == 204) 
            {
                updateZoomMeetingDetails(meetingId, newEvent);
            } else {
                Exception__c ex = new Exception__c(Controller_Method_Name__c = 'ZoomController.updateMeetingOnZoom()', Exception_Message__c = response.getBody(), Type__c = 'Zoom');
                if(ex != NULL) Database.insert(ex);
            }
        }
    }
    
    private static void updateZoomMeetingDetails(String meetingId, Event evt) {
        if(meetingId != null){
            Zoom_Meeting__c zoomMeeting = [SELECT Id, Name, Meeting_URL__c, Meeting_Id__c FROM Zoom_Meeting__c WHERE Meeting_Id__c =: meetingId];
            zoomMeeting.Subject__c = evt.Subject;
            zoomMeeting.Start_Date_and_Time__c = evt.StartDateTime;
            zoomMeeting.End_Date_and_Time__c = evt.EndDateTime;
            UPDATE zoomMeeting;
        }
        else{
            Exception__c ex = new Exception__c(Controller_Method_Name__c = 'ZoomController.updateZoomMeetingDetails()', Type__c = 'Zoom');
            if(ex != NULL) Database.insert(ex);
        }        
    }
    
    public static void deleteMeetingOnZoom(Zoom_Meeting__c  deletedEventMeetingDetails) {
        try{
            if(deletedEventMeetingDetails.Meeting_Id__c != NULL)
            {            
                String meetingIdToBeDeleted = deletedEventMeetingDetails.Meeting_Id__c;
                HttpResponse response = new HTTPCalloutCTRL().setEndPoint(endPointUrl + '/meetings/'+meetingIdToBeDeleted).setMethod('DELETE').makeCallout();
                System.debug('Response : ' + response);
                if(response.getStatusCode() == 204) 
                {
					System.debug('Zoom Meeting Has Been Deleted');
                } else {
                    Exception__c ex = new Exception__c(Controller_Method_Name__c = 'ZoomController', Exception_Message__c = response.getBody(), Type__c = 'Zoom');
                    if(ex != NULL) Database.insert(ex);
                }
            }
        }
        Catch(Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp, 'Zoom', 'ZoomController.deleteMeetingOnZoom()');
            if(e != NULL) Database.insert(e);
        }
    }
    
    //Apex Method Called from Flow Add Meeting Participant
    
    @invocableMethod(label='Add Meeting Participant Apex Action' description='Call Apex method to create meeting participant')
    public static void addMeetingRegistrants (List<String> conAndMeetingId){
        if(conAndMeetingId != null){
            List<String> res = conAndMeetingId[0].split(',', 2);
            if(res.size()>0){
                String conId = res[0];
                String meetingId = res[1];
                addMeetingRegistrants(conId, meetingId);
            }
        }
    }
    
    // Add Meetings Registrants
    public static void addMeetingRegistrants(String contactId, String meetingId) 
    {
        try {
            if(String.isNotBlank(contactId) && String.isNotBlank(meetingId)) {
                meetingId= meetingId.replaceAll( '\\s+', '');
                List<Contact> conList = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :contactId LIMIT 1];
                System.debug('conList '+conList);
                Contact con = new Contact();
                if(conList.size()>0) {
                    con = conList[0];
                    String email = con.Email != null ? con.Email : null;
                    String firstName;
                    String lastName;
                    if(con.FirstName == null){
                        firstName = con.LastName != null ? con.LastName : null;
                        lastName = '';
                    } else{
                        firstName = con.FirstName != null ? con.FirstName : null;
                        lastName = con.LastName != null ? con.LastName : null;
                    }
                    String body = '{"email": "' + email + '","first_name": "' + firstName + '","last_name": "' + lastName + '"}';
                    System.debug('Body : ' + body);
                    
                    System.debug('endpoint '+endPointUrl +'/meetings/'+meetingId + '/registrants');
                    HttpResponse response = new HTTPCalloutCTRL().setEndPoint(endPointUrl +'/meetings/'+meetingId + '/registrants').setMethod('POST').setBody(body).makeCallout(); 
                    System.debug('response '+response);
                    if(response.getStatusCode() == 201) 
                    {
                        MeetingRegistrantsWrapper registrantWrp = (MeetingRegistrantsWrapper) JSON.deserialize(response.getBody(),MeetingRegistrantsWrapper.class);
                        
                        System.debug('Response Body : ' + registrantWrp);
                        if(registrantWrp != NULL) 
                        {
                            // Creating Meeting Participant
                            Meeting_Participant__c participant = new Meeting_Participant__c();
                            participant.Registrant_ID__c = registrantWrp.registrant_id != NULL ? registrantWrp.registrant_id : '';
                            participant.Registrant_Meeting_URL__c = registrantWrp.join_url != NULL ? registrantWrp.join_url : '';
                            participant.Contact__c = contactId;
                            if(registrantWrp.Id != NULL &&  registrantWrp.join_url != NULL){
                                System.debug('Join URL : ' + registrantWrp.join_url);
                                Zoom_Meeting__c meetingDetails = [SELECT Id, Name, Meeting_URL__c, Meeting_Id__c FROM Zoom_Meeting__c 
                                                                  WHERE Meeting_Id__c =: registrantWrp.Id];
                                participant.Meeting_Details__c = meetingDetails.Id;
                            }
                            System.debug('participant '+participant);
                            Database.insert(participant);
                        }
                    } else {
                        Exception__c e = new Exception__c(Exception_Message__c = response.getStatusCode() + response.getBody(), Type__c = 'Zoom', Controller_Method_Name__c = 'ZoomController.addMeetingRegistrants()');
                        INSERT e;
                        UtilityController.sendEmailNotification(e);
                    }
                }
            }
        } Catch(Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp,'Zoom');
            if(e != NULL) Database.insert(e);
            UtilityController.sendEmailNotification(e);
        }
    }
	
    public void deleteRegistrant(String registrantId, String meetingId) {
        try {
            if(String.isNotBlank(registrantId) && String.isNotBlank(meetingId)) {
                HttpResponse response = new HTTPCalloutCTRL().setEndPoint(endPointUrl +'/meetings/'+meetingId + '/registrants/' + registrantId).setMethod('DELETE').makeCallout();
                System.debug('Response Body Delete : ' + response);
            }
        } catch(Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp,'Zoom');
            if(e != NULL) Database.insert(e);
            UtilityController.sendEmailNotification(e);
        }
    }
    
    private static String getCreateMeetingJSONBody(Event newEvent, DateTime startDate, DateTime endDate, String timezone, String duration) {
        String subject;
        if(String.isNotBlank(newEvent.Subject) && newEvent.Subject.contains('"')){
            subject = newEvent.Subject.replace('"', '\\"');
        } else {
            subject = newEvent.Subject;
        }
        String body = '{"topic": "' + subject + '", "default_password": false, "type": 2, "duration":'+ duration + ', "settings": {"use_pmi":false,"alternative_hosts_email_notification":false, "join_before_host": true, "jbh_time": 15, "approval_type": 0, "allow_multiple_devices": true, "auto_recording": false,"close_registration": false, "email_notification": false, "host_video": true, "in_meeting": false, "mute_upon_entry": false, "participant_video": true, "private_meeting": true, "registrants_confirmation_email": false, "registrants_email_notification": false, "registration_type": 1, "show_share_button": true, "use_pmi": false, "waiting_room": false, "watermark": false }, "recurrence": { "end_date_time": "' + endDate.format('yyyy-MM-dd\'T\'HH:mm:SS\'Z\'') + '", "type": 2 }, "start_time": "' + startDate.format('yyyy-MM-dd\'T\'HH:mm:SS\'Z\'') + '", "timezone": "' + timezone + '"}';
        return body;
    }
    
    public class MeetingRegistrantsWrapper {
        public String registrant_id 	{get; set;}
        public String id 				{get; set;}
        public String topic 			{get; set;}
        public String start_time 		{get; set;}
        public String join_url 			{get; set;}
    }
}