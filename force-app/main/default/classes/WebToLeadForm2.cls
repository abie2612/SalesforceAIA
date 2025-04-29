/*
* Author Name : Abhishek Bagra
* Date        : 6/20/2024 
* Description : Web Service to create Vendor lead from website (Form 2)
*/
@RestResource(urlMapping='/WebToLeadForm2/*')
global class WebToLeadForm2 {
    @HttpPost
    global static string doPost() {
        try {
            String leadSourceValue = System.Label.SellerForm2LeadSource;
            Map<String, String> requestParams = RestContext.request.params;
            Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
            Lead ld = new Lead();
            ld.RecordTypeId = recordTypeId;
            ld.FirstName = requestParams.get('your-first-name');
            ld.LastName = requestParams.get('your-last-name');
            ld.Email = requestParams.get('your-email');
            ld.Phone = requestParams.get('your-phone');
            ld.Account_s_date_of_registration__c = requestParams.get('dat')!= null ? Date.valueOf(requestParams.get('dat')):null;
            ld.How_Many_Seller_Feedbacks__c = requestParams.get('your-sss');
            ld.Is_your_account_PROFESSIONAL__c = requestParams.get('radio-433') == 'yes' ? true : false ;
            ld.Your_account_always_been_professional__c = requestParams.get('radio-43') == 'yes' ? true : false ;
            ld.Is_this_account_opened_by_US_Citizen__c = requestParams.get('radio-4') == 'yes' ? true : false ;
            String s = requestParams.get('your-marketplace');
            if(String.isNotBlank(s)){
                if(s.contains(',')){
                    s = s.replaceAll(',', ';');
                }
                ld.Which_Marketplace__c = s;
            }
            ld.Additional_information__c = requestParams.get('add');
            ld.Agree_to_receive_educational_newsletters__c = requestParams.get('acceptance-504') == '' ? false : true ;
            ld.LeadSource = leadSourceValue;
            ld.Account_Type__c = 'Individual';
            ld.Company = requestParams.get('your-first-name') + ' ' + requestParams.get('your-last-name');
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            ld.setOptions(dmo);
            if(!Test.isRunningTest()){
                INSERT ld;
            }
            return '{"Status":"OK"}';
        } catch(Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp, 'Web To Lead 2', 'WebToLeadForm2.doPost()');
            if(e != NULL){ 
                Database.insert(e);
                UtilityController.sendEmailNotification(e);
            }
            return '{"Status":"ERROR"}';
        }
    }
}