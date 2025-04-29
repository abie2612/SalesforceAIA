public class LeadTriggerHandler {
    //onBeforeUpdate
    public static void onBeforeUpdate(List<Lead> newleadList, Map<Id,Lead> oldMap) {
        Set<String> selectedProductIds = new Set<String>();
        for(Lead lead : newleadList){
            if((lead.IsConverted != oldMap.get(lead.Id).IsConverted) && lead.IsConverted){
                lead.Lead_Stage__c = 'Converted';
                
            }
            if(lead.Rating != oldMap.get(lead.Id).Rating && (lead.Rating == 'Hot' || lead.Rating == 'Cold')){
                if(lead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Customer').getRecordTypeId() && lead.Selected_Product__c != null){
                    selectedProductIds.add( lead.Selected_Product__c );
                }
            } 
        }
        List<Opportunity> opportunityList = [SELECT Id,Name,Opportunity_Number_Text__c,Selected_Product__c 
                                             FROM Opportunity
                                             WHERE Selected_Product__c IN : selectedProductIds AND  StageName NOT IN ('Closed Won', 'Closed Lost' ) AND Opportunity_Number_Text__c != Null];
        
        Map< String, String> oppotunityDataMap = new  Map< String, String >();
        
        for( Opportunity opp : opportunityList ){
                oppotunityDataMap.put( opp.Selected_Product__c, opp.Opportunity_Number_Text__c  );
        }        
        
        if( opportunityList.size()>0 ){
            for( Lead lead : newleadList ){
                if( oppotunityDataMap.containsKey( lead.Selected_Product__c ) ){
                    lead.addError( 'Selected Product is already assosciated with open opportunity ' + oppotunityDataMap.get( lead.Selected_Product__c ) );
                }
            }
        }
    }
    
    //onAfterUpdate
    public static void onAfterUpdate(List<Lead> newleadList, Map<Id,Lead> oldMap) {
        List<Lead> leadList = new List<Lead>();
        Set<String> companyNames = new Set<String>();
        Set<String> listOfEmails = new Set<String>();
        for(Lead lead : newleadList){
            if(lead.Rating != oldMap.get(lead.Id).Rating && (lead.Rating == 'Cold' || lead.Rating == 'Hot')){
                leadList.add(lead);
                if(lead.Company != null){
                    companyNames.add(lead.Company);
                }
                if(lead.Email != null){
                    listOfEmails.add(lead.Email);
                }
            }
        }
        
        Map<String, Account> existingAccountsMap = new Map<String, Account>();
        Map<String, Contact> existingContactsMap = new Map<String, Contact>();
        
        if (!companyNames.isEmpty()) {
            for (Account acc : [SELECT Id, Name FROM Account WHERE Name IN :companyNames]) {
                existingAccountsMap.put(acc.Name, acc);
            }
        }
        
        if (!listOfEmails.isEmpty()) {
            for (Contact con : [SELECT Id, Email FROM Contact WHERE Email IN :listOfEmails]) {
                existingContactsMap.put(con.Email, con);
            }
        }
        
        LeadStatus convertStatus = [SELECT Id, ApiName FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        List<Opportunity> updateOpportunityList = new List<Opportunity>();
        List<Account> updatedAccountList = new List<Account>();
        Map<Id, Id> mapAccIdAndOppId = new Map<Id, Id>();
        String stage;
        String name;
        for (Lead lead : leadList) {
            stage = name = '';
            String email = lead.Email;
            Account existingAccount = existingAccountsMap.get(lead.Company);
            Contact existingContact = existingContactsMap.get(lead.Email);
            Id accRecordType;
            Id oppRecordType;
            Boolean isVendorLead = false;
            
            if(lead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Customer').getRecordTypeId()){
                oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            } else if(lead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Vendor').getRecordTypeId()){
                isVendorLead = true;
                oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
            }
            if(lead.Rating=='Cold'){
                stage= 'Closed Lost';
            } else if(lead.Rating=='Hot'){
                if(isVendorLead){
                    stage = 'Contract and ID';
                }else{
                    stage = 'Contract and Customer Questionnaire';
                }
                name = String.isBlank(lead.FirstName) ? lead.LastName : lead.FirstName +' '+ lead.LastName;
            }
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lead.id);
            lc.setConvertedStatus(convertStatus.ApiName);
            if(existingAccount != null) {
                lc.setAccountId(existingAccount.Id);
                if(existingContact != null) {
                    lc.setContactId(existingContact.Id);
                }
            }
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Opportunity opp = new Opportunity(Id=lcr.getOpportunityId(), StageName=stage, RecordTypeId= oppRecordType);
            if(isVendorLead){
                opp.Is_Converted_From_Vendor_Lead__c = true;
            }
            mapAccIdAndOppId.put(lcr.getAccountId(),lcr.getOpportunityId());
            updatedAccountList.add(new Account(Id=lcr.getAccountId(), Email_Address__c= email));
            updateOpportunityList.add(opp);
        }
        
        List<Contact> updatedConList = new List<Contact>();
        if(!mapAccIdAndOppId.values().isEmpty()){
            Map<Id, Map<Id, List<Id>>> mapOfOppIdAndZoomIdContactIds = new Map<Id, Map<Id, List<Id>>>();
            Set<Id> zoomMeetingIds = new Set<Id>();
            
            for (Opportunity opp : [SELECT Id, (SELECT Id, Zoom_Meeting_Details__c FROM Events WHERE Zoom_Meeting_Details__c != null ORDER BY CreatedDate DESC LIMIT 1) FROM Opportunity WHERE Id IN :mapAccIdAndOppId.values()]) {
                if (!opp.Events.isEmpty()) {
                    Id zoomMeetingId = opp.Events[0].Zoom_Meeting_Details__c;
                    zoomMeetingIds.add(zoomMeetingId);
                    if (!mapOfOppIdAndZoomIdContactIds.containsKey(opp.Id)) {
                        mapOfOppIdAndZoomIdContactIds.put(opp.Id, new Map<Id, List<Id>>{zoomMeetingId => new List<Id>()});
                    }
                }
            }
            
            for(Zoom_Meeting__c zoom : [SELECT Id, (SELECT Contact__c FROM Meeting_Participants__r) FROM Zoom_Meeting__c WHERE Id IN :zoomMeetingIds]){
                for(Id oppId : mapOfOppIdAndZoomIdContactIds.keySet()){
                    if (mapOfOppIdAndZoomIdContactIds.get(oppId).containsKey(zoom.Id)) {
                        for (Meeting_Participant__c participant : zoom.Meeting_Participants__r) {
                            mapOfOppIdAndZoomIdContactIds.get(oppId).get(zoom.Id).add(participant.Contact__c);
                        }
                    }
                }
            }
            
            for (Id accId : mapAccIdAndOppId.keySet()) {
                Id opportunityId = mapAccIdAndOppId.get(accId);
                if (mapOfOppIdAndZoomIdContactIds.containsKey(opportunityId)) {
                    Map<Id, List<Id>> zoomIdContactMap = mapOfOppIdAndZoomIdContactIds.get(opportunityId);
                    List<Id> contactIds = new List<Id>();
                    for (List<Id> ids : zoomIdContactMap.values()) {
                        contactIds.addAll(ids);
                    }
                    for(Id conId : contactIds){
                        Contact con = new Contact(Id=conId, AccountId= accId);
                        updatedConList.add(con);
                    }
                }
            }
        }
        
        if(!updatedConList.isEmpty()){
            try{
                UPDATE updatedConList;
            }
            catch (Exception exp) {
                Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'LeadTriggerHandler');
                if(e != NULL) Database.insert(e);
                System.debug('Error Updating Contacts: ' + exp.getMessage());
            }
        }
        
        if(!updatedAccountList.isEmpty()){
            try{
                UPDATE updatedAccountList;
            }
            catch (Exception exp) {
                Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'LeadTriggerHandler');
                if(e != NULL) Database.insert(e);
                System.debug('Error Updating Accounts: ' + exp.getMessage());
            }
        }
        
        if(!updateOpportunityList.isEmpty()){
            try{
                UPDATE updateOpportunityList;
            }
            catch (Exception exp) {
                Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'LeadTriggerHandler');
                if(e != NULL) Database.insert(e);
                System.debug('Error Updating opportunities: ' + exp.getMessage());
            }
        }
    }
}