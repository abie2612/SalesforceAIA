public class SendAccountDeliveryEmailController {
    public Static String opporIds;
    public Static List<Opportunity> opportunity;
    @AuraEnabled
    public static Map<String, Object> checkDeliveryEmail(String oppRecordId){
        try{
            if(String.isNotBlank(oppRecordId)){
                opportunity = [SELECT Id, Name, Delivery_PDF_Generated__c, Sent_Delivery_Email__c, Email_Sent_Date__c, Opportunity_Number_Text__c, Marketplace__c, Asset_Number__c, StageName FROM Opportunity WHERE Id =: oppRecordId LIMIT 1];
               	if(opportunity.isEmpty()){
                    return errorMap('Opportunity does not exists');
                }
                if(opportunity[0].StageName != 'Delivery'){
                    return errorMap('Please select delivery stage for sending email');
                }
                if(String.isBlank(opportunity[0].Marketplace__c) || !(opportunity[0].Marketplace__c == 'US' || opportunity[0].Marketplace__c == 'UK')){
                    return errorMap('Delivery PDF is Not Available');
                }
                if(opportunity[0].Delivery_PDF_Generated__c){
                    return warningMap('The Delivery PDF is still being created. Please Wait!');
                }else{
                    if(!opportunity[0].Sent_Delivery_Email__c){
                        return warningMap('Preview mail');
                    } else if(!opportunity.isEmpty()  && opportunity[0].Sent_Delivery_Email__c && opportunity[0].Email_Sent_Date__c !=null){
                        String previousMailDate = String.valueOf(opportunity[0].Email_Sent_Date__c.date());
                        String previousMailTime = String.valueOf(opportunity[0].Email_Sent_Date__c.time()).substring(0, 5);
                        return warningMap('This delivery has already been sent on '+previousMailDate+' at '+previousMailTime+'! Are you sure you would like to send this again?');
                    }
                }
            }
            return errorMap('Opportunity Record Id Not available');
        } catch (Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'ProductListController');
            if(e != NULL) Database.insert(e);
            System.debug('Error : ' + exp.getMessage());
            return errorMap(exp.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, Object> sendingEmail(String opporIds){
        try{
            if(String.isNotBlank(opporIds)){
                String assetNumber;
                String primaryContactMail;
                List<Opportunity> opportunity = [SELECT Id, Name, Sent_Delivery_Email__c, Opportunity_Number_Text__c, Marketplace__c, Asset_Number__c, Selected_Product__r.Amazon_Asset__r.Account_Type__c FROM Opportunity WHERE Id =: opporIds LIMIT 1];
                if(String.isNotBlank(opportunity[0].Asset_Number__c)){
                    assetNumber = opportunity[0].Asset_Number__c;
                } else {
                    return errorMap('Asset Number is not available');
                }
                
                Set<Id> conDocumentIds = new Set<Id>();
                
                String pdfName = opportunity[0].Opportunity_Number_Text__c +'- '+opportunity[0].Marketplace__c+' Account Delivery Pdf';
                for(ContentDocumentLink conDocumentLink : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: opporIds]){
                    conDocumentIds.add(conDocumentLink.ContentDocumentId);
                }
                
                if(conDocumentIds.isEmpty()){
                    return errorMap('Delivery PDF is Not Available');
                }
                
                List<ContentVersion> contentVersion = [SELECT Id, Title, VersionData FROM ContentVersion WHERE ContentDocumentId IN: conDocumentIds AND Title =: pdfName];
                if(contentVersion.isEmpty()){
                    return errorMap('Delivery PDF is Not Available');
                }
                
                List<OpportunityContactRole> oppContactRole = [SELECT Id, Contact.Email, OpportunityId, ContactId, IsPrimary FROM OpportunityContactRole WHERE IsPrimary = TRUE AND OpportunityId =: opporIds LIMIT 1];
                if(!oppContactRole.isEmpty()){
                    primaryContactMail = oppContactRole[0].Contact.Email;
                } else {
                    return errorMap('Primary contact role not available');
                }
                return sendMail(contentVersion, primaryContactMail,opportunity,assetNumber);
            }
            return errorMap('Opportunity Record Id Not available');
        } catch (Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'ProductListController');
            if(e != NULL) Database.insert(e);
            System.debug('Error : ' + exp.getMessage());
            return errorMap(exp.getMessage());
        }
    }
    
    //Construct and send email
    private static Map<String, Object> sendMail(List<ContentVersion> contentVersion, String primaryContactMail, List<Opportunity> opportunity, String assetNumber){
        //Create the email attachment
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setBody(contentVersion[0].VersionData);
        attachment.setFileName(contentVersion[0].Title + '.pdf');
        attachment.setContentType('application/pdf');
        attachment.setInline(false);
        
        // Set the message template
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<EmailTemplate> templates = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Account_Delivery_Email_Template'];
        String body= ''; 
        if (!templates.isEmpty()) {
            email.setToAddresses(new String[] { primaryContactMail });
            if(!opportunity.isEmpty() && String.isNotBlank(opportunity[0].Name)){
                body = (templates[0].HtmlValue).replace('{!Opportunity.Name}',opportunity[0].Name );
            }
            if(String.isNotBlank(assetNumber)){
                body = body.replace('REF# [Asset Number]',assetNumber);
            }
            email.setTemplateId(templates[0].Id);
            email.setSubject(templates[0].Subject);
            email.setHtmlBody(body);
        }
        // Attach the file to the email
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        emailList.add(email);

        //Email to yehudit as asset has been delivered.
        if(!opportunity.isEmpty() && opportunity[0].Id != null){
            String emailSubject = assetNumber + ' has been delivered in ' + opportunity[0].Opportunity_Number_Text__c;
            String htmlBody = assetNumber + ' has been delivered in <a href='+URL.getOrgDomainURL().toExternalForm() + '/' + opportunity[0].Id +'>'+ opportunity[0].Opportunity_Number_Text__c +'</a>.';
            Messaging.SingleEmailMessage emailForAllAccounts = new Messaging.SingleEmailMessage();
            emailForAllAccounts.setSubject(emailSubject);
            emailForAllAccounts.setToAddresses(new String[] { System.Label.Yehudit_Email });
            emailForAllAccounts.setHtmlBody(htmlBody);
            emailList.add(emailForAllAccounts);
        }
            
        if(!opportunity.isEmpty() && opportunity[0].Selected_Product__c != null && opportunity[0].Selected_Product__r.Amazon_Asset__c != null){
            if(opportunity[0].Selected_Product__r.Amazon_Asset__r.Account_Type__c == 'Special'){
                List<CustomNotificationType> cnType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Send_Asset_Sold_Notification' LIMIT 1];
                String userId = System.Label.User_Id_of_Lisa;
                if(!cnType.isEmpty()){
                    Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();
                    customNotificationObj.setBody('Please check details by clicking here.');
                    customNotificationObj.setTitle(assetNumber + ' has been delivered.');
                    customNotificationObj.setNotificationTypeId(cnType[0].id);
                    customNotificationObj.setSenderId(userId);
                    customNotificationObj.setTargetId(opportunity[0].Selected_Product__r.Amazon_Asset__c);
                    customNotificationObj.send(new Set<String> {userId});
                }
            } else if(opportunity[0].Selected_Product__r.Amazon_Asset__r.Account_Type__c == 'Standard'){
                List<CustomNotificationType> cnType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Send_Asset_Sold_Notification' LIMIT 1];
                String userId = System.Label.User_Id_of_Abraham;
                List<User> userList = [SELECT Id, Email FROM User WHERE Id =: userId];
                if(!userList.isEmpty()){
                    if(!cnType.isEmpty()){
                        Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();
                        customNotificationObj.setBody('Please check details by clicking here.');
                        customNotificationObj.setTitle(assetNumber + ' has been delivered.');
                        customNotificationObj.setNotificationTypeId(cnType[0].id);
                        customNotificationObj.setSenderId(userList[0].Id);
                        customNotificationObj.setTargetId(opportunity[0].Selected_Product__r.Amazon_Asset__c);
                        customNotificationObj.send(new Set<String> {userList[0].Id});
                    }
                    String emailSubjectAndBody = assetNumber + ' has been delivered';
                    Messaging.SingleEmailMessage emailForAllAccounts = new Messaging.SingleEmailMessage();
                    emailForAllAccounts.setSubject(emailSubjectAndBody);
                    emailForAllAccounts.setToAddresses(new String[] { userList[0].Email });
                    emailForAllAccounts.setHtmlBody(emailSubjectAndBody);
                    emailList.add(emailForAllAccounts);
                }
                
            }
        }

        // Send both emails in a single call
        Messaging.sendEmail(emailList);
        
        opportunity[0].Sent_Delivery_Email__c = True;
        opportunity[0].Email_Sent_Date__c = System.now();
        if(!opportunity.isEmpty()){
            UPDATE opportunity;
        }
        return successMap('Email Sent Successfully');
    }
    
    //Generate a error response map
    private static Map<String, Object> errorMap(String msg){
        Map<String, Object> result = new Map<String, Object>();
        result.put('STATUS', 'error');
        result.put('MSG', msg);
        return result;
    }
    
    //Generate a success response map
    private static Map<String, Object> successMap(String msg){
        Map<String, Object> result = new Map<String, Object>();
        result.put('STATUS', 'success');
        result.put('MSG', msg);
        return result;
    }
    
    //Generate a warning response map
    private static Map<String, Object> warningMap(String msg){
        Map<String, Object> result = new Map<String, Object>();
        result.put('STATUS', 'warning');
        result.put('MSG', msg);
        return result;
    }
}