/*
* Author : AnavClouds Softwares Solutions (3 Jan 2024)
* Description : This batch is using for delete zoom meeting details
*/
public class BatchDeleteMeetingParticipant implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    List<Meeting_Participant__c> MeetingPartitcipants = new List<Meeting_Participant__c>();
    
    public BatchDeleteMeetingParticipant(List<Meeting_Participant__c> meetingParticipantList) {
        this.MeetingPartitcipants = meetingParticipantList;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'SELECT Id FROM User LIMIT 1';
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<User> user) {
        for(Meeting_Participant__c mp : MeetingPartitcipants){
            try {
                new ZoomController().deleteRegistrant(mp.Registrant_ID__c, mp.Meeting_Id__c);
            }
            catch(Exception exp) {
                Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'BatchDeleteMeetingParticipant.execute()');
                if(e != NULL) Database.insert(e);
            }
        } 
    }
    
    public void finish(Database.BatchableContext BC) {}
    
}