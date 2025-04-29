public class ContractTriggerHandler { 
    
    private static final String TASK_DESCRIPTION = 'Add details to bank for wire transfer';
    
    public static void createTask(List<Contract> newContractList, Map<Id, Contract> oldMap) {
        Map<Id, Contract> oppIdWithContract = new Map<Id, Contract>();
        Map<Id,Id> customerOppIdWithContract = new Map<Id,Id>();
        
        
        for(Contract cont : newContractList) {
            if(oldMap.keySet().contains(cont.Id) && cont.Status != oldMap.get(cont.Id).Status
               && (cont.Status == 'Activated') && cont.Opportunity__c != null){
                   oppIdWithContract.put(cont.Opportunity__c, cont);
               }
        } 
        
        List<Task> taskToBeCreated = new List<Task>();
        List<Opportunity> oppToBeUpdated = new List<Opportunity>();
        String userIdForTaskAssignment = System.Label.User_Id_of_Yehudit;
        try{
            if(!oppIdWithContract.keySet().isEmpty()){
                Map<Id, Opportunity> mapOfOppIdAndOpp = new Map<Id, Opportunity>([SELECT Id, Name, RecordType.Name, Opportunity_Number_Text__c FROM Opportunity WHERE ID IN:oppIdWithContract.keySet()]);
                for(Id oppId: oppIdWithContract.keySet()){
                    if(mapOfOppIdAndOpp.get(oppId).RecordType.Name == 'Vendor') {
                        if(oppIdWithContract.containsKey(oppId) && oppIdWithContract.get(oppId) != null){
                            Contract c = oppIdWithContract.get(oppId);
                            Opportunity opp = new Opportunity(Id = oppId, Legal_Entity_Name__c = c.Seller_Full_Name__c, Legal_Entity_Address__c = c.Seller_Full_Address__c, Merchant_Token__c = c.Amazon_Merchant_Token__c, Amazon_Login_Email_Address__c = c.Amazon_Login_Email_Address__c, Bank_Account_Holder_Name__c = c.Bank_Account_Holder_Name__c, Bank_Account_Holder_Full_Address__c = c.Bank_Account_Holder_Full_Address__c, Bank_Account_Number_1__c = String.valueOf(c.Bank_Account_Number__c), Bank_Account_Routing_Number__c = c.Bank_Routing_number__c, Store_Name__c = c.Amazon_Store_Name__c);
                            oppToBeUpdated.add(opp);
                        }
                        Task newTask = new Task(Subject=(mapOfOppIdAndOpp.containsKey(oppId) && mapOfOppIdAndOpp.get(oppId)!= null ? mapOfOppIdAndOpp.get(oppId).Opportunity_Number_Text__c +' ' : '') +'Add bank account details to Chase to be able to transfer payment to Vendor immediately upon takeover',
                                                WhatId=oppId, Description= TASK_DESCRIPTION, OwnerId = userIdForTaskAssignment != null ? userIdForTaskAssignment : userInfo.getUserId(),
                                                ActivityDate = date.today());
                        taskToBeCreated.add(newTask);
                    } else if(mapOfOppIdAndOpp.get(oppId).RecordType.Name == 'Customer'){
                        if(oppIdWithContract.containsKey(oppId) && oppIdWithContract.get(oppId) != null){
                            Contract c = oppIdWithContract.get(oppId);
                            Opportunity opp = new Opportunity(Id = oppId, Customer_Questionnaire__c = c.Customer_Questionnaire__c);
                            customerOppIdWithContract.put(c.Id,opp.Id);
                            oppToBeUpdated.add(opp);
                        }
                    }
                }  
            }
        } catch (Exception exp) {
                Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'ContractTriggerHandler');
                if(e != NULL) Database.insert(e);
                System.debug('Error : ' + exp.getMessage());
            }
        
        if(!oppToBeUpdated.isEmpty()){
            try{
                UPDATE oppToBeUpdated;
            } catch (Exception exp) {
                Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'ContractTriggerHandler');
                if(e != NULL) Database.insert(e);
                System.debug('Error : ' + exp.getMessage());
            }
        }
        
        if(!taskToBeCreated.isEmpty()){
            try{
                INSERT taskToBeCreated;
            } catch (Exception exp) {
                Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'ContractTriggerHandler');
                if(e != NULL) Database.insert(e);
                System.debug('Error : ' + exp.getMessage());
            }
        }
    }
}