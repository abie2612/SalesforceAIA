public class UtilityController {
    
    public static boolean firstRun = true;
    // Sending email when getting exception
    public static void sendEmailNotification(Exception__c excp) {
        Boolean isSend = Boolean.valueOf(SYSTEM.LABEL.IsExceptionNotification);
        if(isSend) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            // Assign the addresses for the To lists to the mail object.
            mail.setToAddresses(String.valueOf(SYSTEM.LABEL.ExceptionEmailAddress).split(','));
            
            // Specify the name used as the display name.
            mail.setSenderDisplayName('AIA Developer Support');
            
            // Specify the subject line for your email address.
            mail.setSubject('Exception : ' + excp.Name + ' Exception Type' + excp.Type__c);
            
            // Specify the text content of the email.
            mail.setPlainTextBody('Exception Message : ' + excp.Exception_Message__c);
            
            // Send the email you have created.
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
    }
    
    // Get Exception Data
    public static Exception__c getExceptionData(Exception exp, String type) {
        Exception__c e = new Exception__c();
        e.Exception_Message__c = 'Message - ' + exp.getMessage() + ' Line Number - ' + exp.getLineNumber() + ' Stack Trace String ' + exp.getStackTraceString();
        e.Type__c = type;
        return e;
    }
    
    // Get Exception Data
    public static Exception__c getExceptionData(Exception exp, String type, String apexClassName) {
        Exception__c e = new Exception__c();
        e.Exception_Message__c = 'Message - ' + exp.getMessage() + ' Line Number - ' + exp.getLineNumber() + ' Stack Trace String ' + exp.getStackTraceString();
        e.Type__c = type;
        e.Controller_Method_Name__c = apexClassName;
        return e;
    }
    
    public static void opportunityToAssetMapping(List<Id> oppIds, String queryString, Map<String, String> customSettingMap){
        UtilityController.firstRun = false;
        List<Asset> assetList = new List<Asset>();
        String fullQuery = 'SELECT Id, '+queryString+', (SELECT Id FROM Amazon_Assets__r ORDER BY CreatedDate DESC LIMIT 1) FROM Opportunity WHERE Id IN: oppIds';
        for(Opportunity opp : Database.query(fullQuery)){
            if(!opp.Amazon_Assets__r.isEmpty()){
                Asset asset = new Asset();
                asset.Id = opp.Amazon_Assets__r[0].Id;
                for (String oppField : customSettingMap.keySet()) {
                    asset.put(customSettingMap.get(oppField), opp.get(oppField));
                } 
                assetList.add(asset);
            }
        }
        if(!assetList.isEmpty()){
            UPDATE assetList;
        }
    }
    
    public static void assetToOpportunityMapping(List<Id> assIds, String queryString, Map<String, String> customSettingMap){
        UtilityController.firstRun = false;
        List<Opportunity> opportunityList = new List<Opportunity>();
        String fullQuery = 'SELECT Id, Opportunity__r.Id, '+queryString+' FROM Asset WHERE Id IN: assIds';
        for(Asset ast : Database.query(fullQuery)){
            Opportunity oppor = new Opportunity();
            oppor.Id = ast.Opportunity__r.Id;
            for (String astField : customSettingMap.keySet()) {
                oppor.put(customSettingMap.get(astField), ast.get(astField));
            } 
            opportunityList.add(oppor);
        }
        
        if(!opportunityList.isEmpty()){
            UPDATE opportunityList;
        } 
    }
}