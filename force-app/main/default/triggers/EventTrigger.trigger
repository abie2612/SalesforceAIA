trigger EventTrigger on Event (after insert, after update, before delete) {
	if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            EventTriggerHandler.onAfterInsert(Trigger.new);
        }
        else  if(Trigger.isUpdate){
            EventTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    if(Trigger.isBefore){
        if(Trigger.isDelete){
            EventTriggerHandler.onBeforeDelete(Trigger.old);
        }
    }
}