public class USAccountDeliveryPdfController{
    public String currentRecordId 		{get; set;}
    public String parameterValue 		{get; set;}
    public Opportunity opp				{get; set;}
    public String newFormat				{get; set;}
    
    public USAccountDeliveryPdfController(ApexPages.StandardController controller) {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        List<Opportunity> oppList = [select id,Name,Email_Address_on_Email_Account__c,Email_Password__c,Store_Name__c,Amazon_Password__c,Email_QR_code__c,Merchant_Token__c,Amazon_QR_Code__c from Opportunity where id =: currentRecordId LIMIT 1];
        if(oppList!= null && oppList.size()>0){
            opp = oppList[0];
        }
        resizeTextAreaContent(opp);
        DateTime oppDate = Date.today();
        newFormat = oppDate.format('MM/dd/yyyy');
        parameterValue = ApexPages.CurrentPage().getparameters().get('nameParam');
    }
    
    
    public static void resizeTextAreaContent(Opportunity opp) {
        Integer pixelsWide = 150;
        Integer pixelsHeight = 150;
        string newTag = '<img style="height: ' + pixelsHeight + 'px;width: ' + pixelsWide + 'px;"';
        if (opp != null && opp.Email_QR_code__c != null) {
            if (opp.Email_QR_code__c.startsWith('<p><img style="width:')) {
                opp.Email_QR_code__c = opp.Email_QR_code__c.replaceFirst('<img style="height: [0-9]*px;"', newTag);
            } else {
                opp.Email_QR_code__c = opp.Email_QR_code__c.replace('<img', newTag);
            }
        }
        
        if (opp.Amazon_QR_Code__c != null) {
            if (opp.Amazon_QR_Code__c.startsWith('<p><img style="height:')) {
                opp.Amazon_QR_Code__c = opp.Amazon_QR_Code__c.replaceFirst('<img style="height: [0-9]*px;"', newTag);
            } else {
                opp.Amazon_QR_Code__c = opp.Amazon_QR_Code__c.replace('<img', newTag);
            }
        }
    }
}