public class UKAccountDeliveryPdfController{
    public String currentRecordId 			{get; set;}
    public String parameterValue 			{get; set;}
    public Opportunity opp					{get; set;}
    public String newFormat					{get; set;}
    
    public UKAccountDeliveryPdfController(ApexPages.StandardController controller) {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        List<Opportunity> oppList = [SELECT Id, Name, Email_Address_on_Email_Account__c, Email_Password__c, Store_Name__c, Amazon_Password__c, Merchant_Token__c, Amazon_QR_Code__c, Google_recovery_Phone_Number__c FROM Opportunity WHERE Id =: currentRecordId ];
        if(oppList!= null && oppList.size()>0){
            opp = oppList[0];
            resizeTextAreaContent(opp);
        }
        DateTime oppDate = Date.today();
        newFormat = oppDate.format('MM/dd/yyyy');
        parameterValue = ApexPages.CurrentPage().getparameters().get('nameParam');
    }
    
    public static void resizeTextAreaContent(Opportunity opp) {
        if (opp != NULL && opp.Amazon_QR_Code__c != NULL) {
            Integer pixelsWide = 150;
        	Integer pixelsHeight = 150;
            string newTag = '<img style="height: ' + pixelsHeight + 'px;width: ' + pixelsWide + 'px"';
            if (opp.Amazon_QR_Code__c.startsWith('<p><img style="width:')) {
                opp.Amazon_QR_Code__c = opp.Amazon_QR_Code__c.replaceFirst('<img style="width: [0-9]*px;"', newTag);
            } else {
                opp.Amazon_QR_Code__c = opp.Amazon_QR_Code__c.replace('<img', newTag);
            }          
        }
    }
}