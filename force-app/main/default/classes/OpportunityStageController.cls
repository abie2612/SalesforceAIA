public withOut sharing class OpportunityStageController {
    @AuraEnabled
    public static Opportunity getStageName(String recordId){
        if(String.isNotBlank(recordId)){
            Opportunity opp = [SELECT Id,StageName,Sub_Stage__c, RecordType.Name FROM Opportunity WHERE Id =: recordId];
            System.debug('Opportunity:'+ opp);
            RETURN opp;
        }
        System.debug('Opportunity: NULL');
        RETURN null;
    }
}