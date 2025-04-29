/*
 * Author : 
 * Createdate :
*/
trigger OpportunityTrigger on Opportunity (before update, after update) {
    if(Trigger.isBefore && Trigger.isUpdate){
        OpportunityTriggerHandler.updateOpportunityStage(Trigger.New,Trigger.oldMap);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){    
        OpportunityTriggerHandler.updateStageToDelivery(Trigger.New,Trigger.oldMap);
        if(UtilityController.firstRun){
            UtilityController.firstRun = false;
            OpportunityTriggerHandler.syncOpportunityToAsset(Trigger.New,Trigger.oldMap);
        }
    }
}