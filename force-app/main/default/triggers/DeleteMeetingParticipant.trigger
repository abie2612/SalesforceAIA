trigger DeleteMeetingParticipant on Meeting_Participant__c (before delete) {
    if(Trigger.isBefore && Trigger.isDelete){
        DeleteMeetingParticipantHandler.deleteParticipant(Trigger.Old);
    }
}