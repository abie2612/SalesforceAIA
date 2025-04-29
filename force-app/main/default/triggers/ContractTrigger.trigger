trigger ContractTrigger on Contract (before update) {
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            ContractTriggerHandler.createTask(Trigger.New, Trigger.OldMap);
        }
    }
}