trigger LeadTrigger on Lead (before update, after Update) {
    if(Trigger.isBefore && Trigger.isUpdate) {
        LeadTriggerHandler.onBeforeUpdate(Trigger.New, Trigger.OldMap);
    }
    if(Trigger.isAfter && Trigger.isUpdate) {
        LeadTriggerHandler.onAfterUpdate(Trigger.New, Trigger.OldMap);
    }
}