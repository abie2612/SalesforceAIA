/*
    * Author Name : Adam Chauhan
    * Date        : 15/01/2025  
    * Description : Convert vendor leads if LeadSource value is 'Plan B' otherwise update lead records after 30 days using scheduler
    *System.schedule('Get Leads Created 30 Days before','0 30 21 * * ?', new BatchLeadConversion());
*/
public class BatchLeadConversion implements Database.Batchable<sObject>, Schedulable {
    private static final String VENDOR_RECORD_TYPE = 'Vendor';
    private static final String CUSTOMER_RECORD_TYPE = 'Customer';
    private static final String PLAN_B_LEAD_SOURCE = 'Plan B';
    private static final String UNQUALIFIED_STATUS = 'Unqualified';
    private static final String NO_RESPONSE_REASON = 'No Response';
    private static final String CLOSE_LOST_STAGE = 'Closed Lost';
    public Set<Id> setOfLeadIds = new Set<Id>();
    public BatchLeadConversion(Set<Id> leadIds) {
        this.setOfLeadIds = leadIds;
    }
    public BatchLeadConversion(){}
    
    public void execute(SchedulableContext SC) {
        Database.executebatch(new BatchLeadConversion(),1);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'SELECT Id, Company, LeadSource, Vendor_Unqualified_Reason__c, Customer_Unqualified_Reason__c,  Email, Lead_Stage__c,  RecordType.Name, IsConverted FROM Lead WHERE IsConverted = FALSE AND LeadSource != null';
        if(!Test.isRunningTest()){
            queryString += ' AND CreatedDate < ' + System.label.Days_for_Lead_Conversion;
        }
        if(!setOfLeadIds.isEmpty()){
            queryString += ' AND Id IN: setOfLeadIds';
        } 
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> leadList) {
        
        try{
            Set<String> setOfCompany = new Set<String>();
            Set<String> setOfEmails = new Set<String>();
            List<Lead> leadToBeUpdated = new List<Lead>();
            List<Lead> readyForConvert = new List<Lead>();
            List<Database.LeadConvert> leadConversions = new List<Database.LeadConvert>();
            List<Id> opportunityIds = new List<Id>();
            List<Opportunity> oppList = new List<Opportunity>();
            
            Map<String,Id> accountMap = new Map<String,Id>();
            Map<String,Id> contactMap = new Map<String,Id>();
            
            for(Lead ld : leadList){
                if(ld.RecordType.Name == 'Vendor' && ld.LeadSource == 'Plan B') {
                    setOfCompany.add(ld.Company);
                    if(String.isNotBlank(ld.Email)){
                        setOfEmails.add(ld.Email);
                    }
                    readyForConvert.add(ld);
                    
                } else if(ld.RecordType.Name == 'Customer' || ld.RecordType.Name == 'Vendor'){
                    //Calling method for updating lead records based on Lead Source
                    leadToBeUpdated.add(updateLeadData(ld));  
                }
            }
            
            if(!setOfCompany.isEmpty()){
                for(Account acc : [SELECT Id, Name FROM Account WHERE Name IN :setOfCompany]){
                    accountMap.put(acc.Name, acc.Id);
                }
            }
            if(!setOfEmails.isEmpty()){
                for(Contact con : [SELECT Id, Email FROM Contact WHERE Email IN :setOfEmails]){
                    contactMap.put(con.Email, con.Id);
                }
            }
            
            if(!readyForConvert.isEmpty()){
                List<LeadStatus> leadStatus= [SELECT Id, ApiName FROM LeadStatus WHERE IsConverted=true LIMIT 1];
                for(Lead lead : readyForConvert){
                    //Calling method for the Vendor lead Conversion having Lead Source 'Plan B'
                    leadConversions.add(readyForLeadConvert(lead, leadStatus, accountMap, contactMap));
                }
            }
            
            if(!leadConversions.isEmpty()){
                for(Database.LeadConvertResult result : Database.convertLead(leadConversions)){
                    if(result.isSuccess()){
                        Id oppId = result.getOpportunityId();
                        if(oppId != null){
                            opportunityIds.add(oppId);
                        }
                    }
                }
            }
            //After Vendor Lead Conversion, update opportunity Stage to 'Closed Lost'
            if(!opportunityIds.isEmpty()){
                Id vendorRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
                for(Opportunity opp : [SELECT Id, StageName, RecordTypeId FROM Opportunity WHERE Id IN: opportunityIds]){
                    opp.StageName = 'Closed Lost';
                    opp.Is_Converted_From_Vendor_Lead__c = true;
                    opp.recordTypeId = vendorRecordTypeId;
                    oppList.add(opp);
                }
            }
            
            if(!oppList.isEmpty()){
                UPDATE oppList;
            }
            
            if(!leadToBeUpdated.isEmpty()){
                UPDATE leadToBeUpdated;
            }
            
        }
        catch (Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'BatchLeadConversion');
            if(e != NULL) Database.insert(e);
            System.debug('Error : ' + exp.getMessage());
        }    
    }
    
    public void finish(Database.BatchableContext BC) {}
    
    private Lead updateLeadData(Lead ld) {
        if(ld.RecordType.Name == 'Vendor') {
            ld.Vendor_Unqualified_Reason__c = 'No Response';
        } else if(ld.RecordType.Name == 'Customer') {
            ld.Customer_Unqualified_Reason__c = 'No Response';
        }
        ld.Lead_Stage__c = 'Unqualified';
        ld.Status = 'Unqualified';
        return ld;
    }
    
    private Database.LeadConvert readyForLeadConvert(Lead ld, List<LeadStatus> ldStatus, Map<String,Id> accountMap, Map<String,Id> contactMap) {
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(ld.Id);
        if(!ldStatus.isEmpty()){
            lc.setConvertedStatus(ldStatus[0].ApiName);
        }
        if(accountMap != NULL && accountMap.containsKey(ld.Company)){
            lc.setAccountId(accountMap.get(ld.Company));
            if(contactMap != NULL && contactMap.containsKey(ld.Email)){
                lc.setContactId(contactMap.get(ld.Email));
            }
        }
        return lc;
    }
}