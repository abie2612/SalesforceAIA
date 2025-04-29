/*
* Author Name 		 : Adam Chauhan
* Date        		 : 6/09/2024
* Last Modified By	 : Axel Bagra
* Last Modified Date : 25/11/2024
*/
trigger AssetTrigger on Asset(before insert, before update, after insert, after update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert) {
            AssetTriggerHandler.beforeInsertUpdate(Trigger.new, null);
        } else if(Trigger.isUpdate) {
            AssetTriggerHandler.beforeInsertUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert) {
            AssetTriggerHandler.afterInsert(Trigger.new);
        } else if(Trigger.isUpdate) {
            AssetTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
            if(UtilityController.firstRun){
                UtilityController.firstRun = false;
                AssetTriggerHandler.syncAssetToOpportunity(Trigger.New,Trigger.oldMap);
            }
        } 
    }
}