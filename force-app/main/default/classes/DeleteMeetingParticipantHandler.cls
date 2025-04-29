public with sharing class DeleteMeetingParticipantHandler {
    public static void deleteParticipant(List<Meeting_Participant__c> listMeetingParticipant){
        Database.executeBatch(new BatchDeleteMeetingParticipant(listMeetingParticipant), 1);
    }
}