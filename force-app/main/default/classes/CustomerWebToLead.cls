@RestResource(urlMapping='/CustomerWebToLead/*')
global class CustomerWebToLead {
    @HttpPost
    global static string doPost() {
        createLead(RestContext.request.params);
        return '{"Status":"OK"}';
    }
    
    // Creating Lead From Web Form
    static void createLead(Map<String, String> mapOfLeadData) {
        try {
            Lead leadInsert = new Lead();
            leadInsert.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            
            Map<String, String> fieldMap = new Map<String, String>{
                'FirstName' => 'FirstName',
                'LastName' => 'LastName',
                'Email' => 'Email',
                'TelephoneNumber' => 'Phone',
                'FBAorFBM' => 'Will_you_be_selling_FBA_or_FBM__c',
                'StoreReviews' => 'How_Many_Store_Reviews__c',
                'HearAboutAIA' => 'How_Did_You_Hear_About_AIA_Assets__c',
                'TypeOfAccount' => 'What_type_of_Account_do_you_need__c',
                'MonthlyTurnover' => 'What_is_Your_Expected_Monthly_Turnover__c',
                'ExpertiseOnAmazon' => 'What_is_your_level_of_expertise__c',
                'Budget' => 'What_is_your_Budget__c',
                'WhatDoYouSell' => 'What_Do_You_Sell__c',
                'AdditionalInformation' => 'Additional_information__c'
            };
                        
            for (String key : fieldMap.keySet()) {
                if (mapOfLeadData.containsKey(key)) {
                    leadInsert.put(fieldMap.get(key), mapOfLeadData.get(key));
                }
            }
            
            if(mapOfLeadData.containsKey('WhichMarketplace')) {
                leadInsert.Which_Marketplace__c = mapOfLeadData.get('WhichMarketplace').replaceAll(',',';');
            }
            
            if(mapOfLeadData.containsKey('Categories')) {
                leadInsert.In_What_Categories_are_your_Products__c = mapOfLeadData.get('Categories').replaceAll(',',';');
            }

            leadInsert.Company = String.format('{0} {1}', new List<String>{mapOfLeadData.get('FirstName'), mapOfLeadData.get('LastName')});
            
            leadInsert.Agree_to_receive_educational_newsletters__c = mapOfLeadData.containsKey('AgreeToNewsletters') && mapOfLeadData.get('AgreeToNewsletters') == 'yes';
            leadInsert.LeadSource = 'Web';
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            leadInsert.setOptions(dmo);
            INSERT leadInsert;
        } catch(Exception exp) {
            System.debug(LoggingLevel.ERROR, 'Exception ' + exp.getMessage());
        }
    }
}