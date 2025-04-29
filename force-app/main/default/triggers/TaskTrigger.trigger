trigger TaskTrigger on Task (before insert) {
	if(Trigger.isBefore && Trigger.isInsert){
        TaskTriggerHandler.beforeInsert(Trigger.New);
    }
}