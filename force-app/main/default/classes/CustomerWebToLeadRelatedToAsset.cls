@RestResource(urlMapping='/CustomerWebToLeadRelatedToAsset/*')
global class CustomerWebToLeadRelatedToAsset {
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
                'Email' => 'Email'
            };
                        
            for (String key : fieldMap.keySet()) {
                if (mapOfLeadData.containsKey(key)) {
                    leadInsert.put(fieldMap.get(key), mapOfLeadData.get(key));
                }
            }
			//leadInsert.Phone = mapOfLeadData.containsKey('TelephoneCode') ? mapOfLeadData.get('TelephoneCode') +' '  : '';
            leadInsert.Phone = mapOfLeadData.containsKey('TelephoneNumber') ? mapOfLeadData.get('TelephoneNumber') : '';
            leadInsert.Company = String.format('{0} {1}', new List<String>{mapOfLeadData.get('FirstName'), mapOfLeadData.get('LastName')});
            String assetNumber = mapOfLeadData.containsKey('AssetNumber') ? mapOfLeadData.get('AssetNumber') : null;
            if(String.isNotBlank(assetNumber)){
                List<Product2> prodList = [SELECT Id, Name FROM Product2 WHERE Amazon_Asset_Number__c =: assetNumber ORDER BY CreatedDate DESC LIMIT 1];
                if(!prodList.isEmpty()){
                    leadInsert.Selected_Product__c = prodList[0].Id;
                }
            }
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