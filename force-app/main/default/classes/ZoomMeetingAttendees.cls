/*
* Author Name : Abhishek Bagra
* Date        : 14/10/2024
* Company     : Anavclouds Software Solutions
* Desc.       : Zoom Webhook Handler when a participant joined zoom meeting.
*/

@RestResource(urlMapping='/ZoomMeeting/*')
global without sharing class ZoomMeetingAttendees {
    private static final String UUID  = 'uuid';
    private static final String EVENT  = 'event';
    private static final String PAYLOAD  = 'payload';
    private static final String OBJECTSTR  = 'object';
    private static final String ACCOUNTID  = 'account_id';
    private static final String MEETINGID  = 'id';
    private static final String TYPE  = 'type';
    private static final String EMAIL  = 'email';
    private static final String PARTICIPANT  = 'participant';
    private static final String REGISTRANTID  = 'registrant_id';
    private static final String PLAINTEXT  = 'plainToken';
    private static final String EVENTRESPONSE  = 'endpoint.url_validation';
    private static final String PARTICIPANTJOINED  = 'meeting.participant_joined';
    @httpPost
    global static void zoomNotifications(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonStr = req.requestBody.toString();
        Map<String,Object> responseGetBody = (Map<String,Object>) JSON.deserializeUntyped(req.requestBody.toString());
        String eventStr = responseGetBody.containsKey(EVENT) ? '' + responseGetBody.get(EVENT) : '';
        if(eventStr == EVENTRESPONSE) {
            if(responseGetBody.containsKey(PAYLOAD) && responseGetBody.get(PAYLOAD) != NULL) {
                Map<String,Object> payloadMap = (Map<String,Object>) responseGetBody.get(PAYLOAD);
                if(payloadMap.containsKey(PLAINTEXT) && payloadMap.get(PLAINTEXT) != NULL) {
                    String key = '' + payloadMap.get(PLAINTEXT);
                    Blob blobSignature = Crypto.generateMac('hmacSHA256', Blob.valueOf(key), Blob.valueOf('78VYwEc-TR6ef0lRe8uLtw'));
                    String hexConvertedValue = EncodingUtil.convertToHex(blobSignature);
                    String resp = '{ "plainToken": "' + key + '", "encryptedToken": "' + hexConvertedValue + '" }';
                    res.responseBody = Blob.valueOf(resp);
                    System.debug('responseBody '+res.responseBody);
                    res.statusCode = 200;
                }
            }
        }else if(jsonStr.containsIgnoreCase(PARTICIPANTJOINED)){
            Map<String,Object> mapOfJSON = (Map<String,Object>) JSON.deserializeUntyped(jsonStr);
            
            if(mapOfJSON.containsKey(EVENT) && mapOfJSON.get(EVENT)+'' == PARTICIPANTJOINED && mapOfJSON.containsKey(PAYLOAD)){
                Map<String,Object> mapOfPayload = (Map<String,Object>) mapOfJSON.get(PAYLOAD);
                if(mapOfPayload.containsKey(OBJECTSTR) && mapOfPayload.get(OBJECTSTR)+'' != ''){
                    Map<String,Object> mapOfObject = (Map<String,Object>) mapOfPayload.get(OBJECTSTR);
                    String meetingId = mapOfObject.containsKey(MEETINGID) ? mapOfObject.get(MEETINGID)+'' : '';
                    Map<String,Object> mapOfParticipant = (Map<String,Object>) mapOfObject.get(PARTICIPANT);
                    String registrantID = mapOfParticipant.containsKey(REGISTRANTID) ? mapOfParticipant.get(REGISTRANTID)+'' : '';
                    String joineeEmail = mapOfParticipant.containsKey(EMAIL) ? mapOfParticipant.get(EMAIL)+'' : '';
                    
                    if(String.isNotBlank(meetingId) && String.isNotBlank(registrantID)){
                        List<Meeting_Participant__c> meetingParticipants = [SELECT Id, Registrant_ID__c, Meeting_Details__c, Meeting_Details__r.Lead__c FROM Meeting_Participant__c WHERE Meeting_Id__c =:meetingId AND Registrant_ID__c =:registrantID AND Meeting_Details__c != null AND Meeting_Details__r.Lead__c != null LIMIT 1];
                        Id leadId;
                        if(meetingParticipants != null && meetingParticipants.size()==1){
                            leadId = meetingParticipants[0].Meeting_Details__r.Lead__c;
                        } else if(String.isNotBlank(joineeEmail)){
                            List<Zoom_Meeting__c> zoomMeeting = [SELECT Id, Name, Lead__c, Lead__r.Email, Meeting_Id__c FROM Zoom_Meeting__c WHERE Meeting_Id__c =:meetingId AND Lead__c != null AND Lead__r.Email =:joineeEmail LIMIT 1];
                            if(zoomMeeting != null && zoomMeeting.size()==1){
                                leadId = zoomMeeting[0].Lead__c;
                            } 
                        }
                        if(String.isNotBlank(leadId)){
                            List<Lead> leadToBeUpdated = [SELECT Id, Name, LeadSource, Lead_Stage__c FROM Lead WHERE Id =:leadId AND LeadSource != null AND Lead_Stage__c != null LIMIT 1];
                            if(!leadToBeUpdated.isEmpty() && leadToBeUpdated[0].Lead_Stage__c == 'Booked a Meeting'){
                                leadToBeUpdated[0].Lead_Stage__c = 'Came to a Meeting';
                                UPDATE leadToBeUpdated;
                            }
                        }
                    }
                }
            }
        }
    }
}