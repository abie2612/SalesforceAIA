public class GenerateContractPdf {
    
    public GenerateContractPdf(ApexPages.StandardController controller) {
        
        recId = controller.getRecord().Id;
        List<Contract> agreements = [SELECT Id, ContractNumber, Effective_Date__c, Seller_Full_Name__c, Seller_Full_Address__c,Account_Name__c,Amazon_Store_Name__c, Amazon_Login_Email_Address__c, Purchase_Price1__c, Closing_Date__c, Seller_Name__c, Seller_Signature_Date__c, Buyer_Name__c, Buyer_Signature_Date__c FROM Contract WHERE Id =: recId];
        if(String.isNotBlank(recId)) {
            if(agreements != NULL && agreements.size()>0) {
                
                contract_number = agreements[0].ContractNumber;
                Effective_Date = agreements[0].Effective_Date__c;
                Seller_Full_Name = agreements[0].Seller_Full_Name__c;
                Seller_Full_Address = agreements[0].Seller_Full_Address__c;
                Account_Name = agreements[0].Account_Name__c;
                Amazon_Store_Name = agreements[0].Amazon_Store_Name__c;
                Amazon_Login_Email_Address = agreements[0].Amazon_Login_Email_Address__c;
                Purchase_Price = agreements[0].Purchase_Price1__c;
                Closing_Date = agreements[0].Closing_Date__c;
                Seller_Name = agreements[0].Seller_Name__c;
                //Seller_Signature = agreements[0].Seller_Signature__c;
                Seller_Signature_Date = agreements[0].Seller_Signature_Date__c;
                Buyer_Name = agreements[0].Buyer_Name__c;
                //Buyer_Signature = agreements[0].Buyer_Signature__c;
                Buyer_Signature_Date = agreements[0].Buyer_Signature_Date__c;
            }
            
            List<Contract_Content__c> contentList = [SELECT Id, Name, Content_Number__c, Content__c FROM Contract_Content__c ORDER BY Content_Number__c ASC];
            if(contentList != null && !contentList.isEmpty()){
                listItem = new List<String>();
                for(Contract_Content__c con : contentList){
                    if(con.Name == 'Main Content'){
                        Content = con.Content__c;
                        Content = Content.replaceAll('<li>', '<li style="padding: 7px 0 10px">');
                        Content = Content.replaceAll('Effective_Date__c', Effective_Date != null ? String.valueOf(Effective_Date) : '');
                        Content = Content.replaceAll('Seller_Full_Name__c', Seller_Full_Name != null ? String.valueOf(Seller_Full_Name) : '');
                        Content = Content.replaceAll('Seller_Full_Address__c', Seller_Full_Address != null ? String.valueOf(Seller_Full_Address) : '');
                        Content = Content.replaceAll('Account_Name__c', Account_Name != null ? String.valueOf(Account_Name) :'');
                        Content = Content.replaceAll('Amazon_Store_Name__c', Amazon_Store_Name != null ? String.valueOf(Amazon_Store_Name) : '');
                        Content = Content.replaceAll('Amazon_Login_Email_Address__c', Amazon_Login_Email_Address != null ? String.valueOf(Amazon_Login_Email_Address) : '');
                        Content = Content.replaceAll('Purchase_Price__c', Purchase_Price != null ? String.valueOf(Purchase_Price) : '');
                        Content = Content.replaceAll('Closing_Date__c', Closing_Date != null ? String.valueOf(Closing_Date) : '');
                        Content = Content.replaceAll('nextLine', '<br/><br/>');
                        Content = Content.replaceAll('CloseDate', '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
                        Content = Content.replaceAll('TheBusiness', '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
                        Content = Content.replaceAll('SellerName', '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
                    }
                }
            }
        }
    }
    
    public PageReference savePdf() {
        List<Contract> contractList = [Select id, ownerId From Contract Where id =:recId];
        if(contractList != NULL && contractList.size()>0){
            PageReference pdf = Page.ContractPdf;
            pdf.getParameters().put('Id', String.valueOf(recId));
            Attachment attach = new Attachment();       
            Blob body;
            try {
                body = pdf.getContent();
            } catch (VisualforceException e) {
                body = Blob.valueOf('Error : ' + e);
            }
            attach.Body = body;
            attach.Name = 'AIA Contract_'+contract_number+ '.pdf';
            attach.IsPrivate = false;
            attach.OwnerId = contractList[0].ownerId;
            attach.ParentId = recId;
            insert attach;
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; 
            cVersion.PathOnClient = attach.Name;
            cVersion.Origin = 'H';
            cVersion.Title = attach.Name;
            cVersion.VersionData = attach.Body;
            Insert cVersion;
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = recId;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            Insert cdl;
            return new PageReference('/'+recId);
        }
        return new PageReference('/'+recId);
    } 
    public Id recId                                 {get; set;}
    public String contract_number                   {get; set;}
    public Date Effective_Date                      {get; set;}
    public String Seller_Full_Name                  {get; set;}
    public String Seller_Full_Address               {get; set;}
    public String Account_Name                      {get; set;}
    public String Amazon_Store_Name                 {get; set;}
    public String Amazon_Login_Email_Address        {get; set;}
    public Decimal Purchase_Price                   {get; set;}
    public Date Closing_Date                        {get; set;}
    public String Seller_Name                       {get; set;}
    public String Seller_Signature                  {get; set;}
    public Date Seller_Signature_Date               {get; set;}
    public String Buyer_Name                        {get; set;}
    public String Buyer_Signature                   {get; set;}
    public Date Buyer_Signature_Date                {get; set;}
    public String Content                           {get; set;}
    public List<String> listItem                    {get; set;}
}