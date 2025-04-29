public without sharing class LeadStagePathController {
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getLeadStages(String recordId){
        Map<String, List<String>> result = new Map<String, List<String>>();
        Schema.sObjectField dependToken = Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap().get('Lead_Stage__c');
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =(control.getType() == Schema.DisplayType.Boolean ? null : control.getPicklistValues());
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
        {
            List<String> base64chars = String.valueOf (((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
            for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
            {
                Object controlValue = ( controlEntries == null ? (Object) (index == 1) : (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null));
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0) 
                    continue;
                if (!dependentPicklistValues.containsKey(controlValue)){
                    dependentPicklistValues.put( controlValue, new List<String>() );
                }
                dependentPicklistValues.get(controlValue).add(entry.getLabel());
            }
        }
        if(String.isNotBlank(recordId)){
            List<Lead> leadRecord = [SELECT Id, LeadSource, Lead_Stage__c FROM Lead WHERE Id =: recordId];
            if(leadRecord != null && leadRecord.size()>0 && String.isNotBlank(leadRecord[0].LeadSource)){
                result.put('DependentStages', dependentPicklistValues.get(leadRecord[0].LeadSource));
                System.debug(result);
                return result;
            } else{
                return null;
            }
        }
        return null;
    }

    @AuraEnabled
    public static void updateLeadStage(String updatedStage, String recordId){
        try {
            if(String.isNotBlank(recordId) && String.isNotBlank(updatedStage)){
                Lead updatedLead = new Lead(Id = recordId, Lead_Stage__c= updatedStage);
                UPDATE updatedLead;
            }
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
}