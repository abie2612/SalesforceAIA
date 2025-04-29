/*
* Author Name 			: Adam Chauhan
* Date        			: 6/09/2024       
* Desc.       			: Controller class of GeneratePdfRelatedToAssetVisualorcePage.
* Last Modified By	  	: Axel Bagra
* Last Modified Date  	: 25/11/2024
*/
public class GeneratePdfRelatedToAsset {
    
    public String creationDate 									{get; set;}
    public String specialAccountType 							{get; set;}
    public String accountType 									{get; set;}
    public String marketplace 									{get; set;}
    public String usCitizenOwner 								{get; set;}
    public String feedback 									    {get; set;}
    public String positiveFeedbackUSA 						    {get; set;}
    public String healthAssuranceScore 						    {get; set;}
    public String categoriesApproved 							{get; set;}
    public String brandsApproved 								{get; set;}
    public String salesHistoryYeartoDate 						{get; set;}
    public String salesHistoryAllTime 							{get; set;}
    public String overallUnitsSold 							    {get; set;}
    public String unitsSoldYeartoDate 						    {get; set;}
    public String salePrice 									{get; set;}
    public String amazonAssetNumber 							{get; set;}
    public List<String> splitCategoriesApproved 				{get; set;}
    public List<String> splitBrandsApproved 					{get; set;}
    public List<String> concatenateSplitCategoriesApproved 	    {get; set;}
    public List<String> concatenateSplitBrandsApproved 		    {get; set;}
    public String hazmatValue						 		    {get; set;}
    public String hazmatFlammable						 	    {get; set;}
    public String hazmatAerosole						 	    {get; set;}
    String recId;
    
    public GeneratePdfRelatedToAsset(ApexPages.StandardController controller) {
        System.debug(ApexPages.currentPage());
        recId = String.valueof(ApexPages.currentPage().getParameters().get('id'));
        if(String.isNotBlank(recId)) {
            List<Asset> assetList = [SELECT Id,Creation_Date__c,Account_Type__c,Special_Account_Type__c,US_Citizen_Owner__c,Feedback__c,Positive_Feedback_USA__c,Health_Assurance_Score__c,Categories_Approved__c,Brands_approved__c,format(Sales_History_Year_to_Date__c) saleHisYear2Date,format(Sales_History_All_Time__c) saleHistAllTime,Overall_Units_Sold__c,format(Sale_Price__c) selPrice,Amazon_Asset_Name__c,Units_Sold_Year_to_Date__c,Marketplace__c, Hazmat_Aerosol_Storage_Limit__c, Hazmat_Flammable_Storage_Limit__c, Hazmat__c FROM Asset WHERE Id =: recId];
            if(assetList != NULL && assetList.size()>0) {
                creationDate = (assetList[0].Creation_Date__c == NULL ? ' ':String.valueOf(assetList[0].Creation_Date__c.year()));
                specialAccountType = (assetList[0].Special_Account_Type__c == NULL ? ' ':(assetList[0].Special_Account_Type__c));
                accountType = (assetList[0].Account_Type__c == NULL ? ' ':(assetList[0].Account_Type__c));
                marketplace = (assetList[0].Marketplace__c == NULL ? ' ':(assetList[0].Marketplace__c));
                usCitizenOwner = (assetList[0].US_Citizen_Owner__c == NULL ? ' ':(assetList[0].US_Citizen_Owner__c));
                feedback = (assetList[0].Feedback__c == NULL ? ' ':''+(assetList[0].Feedback__c));
                positiveFeedbackUSA = (assetList[0].Positive_Feedback_USA__c == NULL ? ' ':String.valueOf(assetList[0].Positive_Feedback_USA__c));
                healthAssuranceScore = (assetList[0].Health_Assurance_Score__c == NULL ? ' ':String.valueOf(assetList[0].Health_Assurance_Score__c));
                categoriesApproved = (assetList[0].Categories_Approved__c == NULL ? ' ':(assetList[0].Categories_Approved__c));
                if(String.isNotBlank(categoriesApproved)) {
                    splitCategoriesApproved = categoriesApproved.split(',');
                }else{
                    splitCategoriesApproved = null;
                }
                if(splitCategoriesApproved != null){
                    concatenateSplitCategoriesApproved = splitWordGroupWise(splitCategoriesApproved, 'open categories');
                }
                brandsApproved = (assetList[0].Brands_approved__c == NULL ? ' ':(assetList[0].Brands_approved__c));
                if(String.isNotBlank(brandsApproved)) {
                    splitBrandsApproved = brandsApproved.split(',');
                }else{
                    splitBrandsApproved = null;
                }
                if(splitBrandsApproved != null){
                    concatenateSplitBrandsApproved = splitWordGroupWise(splitBrandsApproved, 'approved brands');
                }
                hazmatValue = (String.isNotBlank(assetList[0].Hazmat__c) ? (assetList[0].Hazmat__c) : ' ');
                if(String.isNotBlank(hazmatValue) && hazmatValue =='Yes'){
                    hazmatFlammable = (assetList[0].Hazmat_Flammable_Storage_Limit__c != null && assetList[0].Hazmat_Flammable_Storage_Limit__c > 0 ? ''+(assetList[0].Hazmat_Flammable_Storage_Limit__c) : ' ');
                    hazmatAerosole = (assetList[0].Hazmat_Aerosol_Storage_Limit__c != null && assetList[0].Hazmat_Aerosol_Storage_Limit__c > 0 ? ''+ (assetList[0].Hazmat_Aerosol_Storage_Limit__c) : ' ');
                } else{
                    hazmatValue = ' ';
                    hazmatFlammable = ' ';
                    hazmatAerosole = ' ';
                }
                salesHistoryYeartoDate = (String.isBlank(String.valueOf(assetList[0].get('saleHisYear2Date'))) ? ' ':String.valueOf(assetList[0].get('saleHisYear2Date')));
                salesHistoryAllTime = (String.isBlank(String.valueOf(assetList[0].get('saleHistAllTime'))) ? ' ':String.valueOf(assetList[0].get('saleHistAllTime')));
                overallUnitsSold = (assetList[0].Overall_Units_Sold__c == NULL ? ' ': String.valueOf(assetList[0].Overall_Units_Sold__c));
                unitsSoldYeartoDate = (assetList[0].Units_Sold_Year_to_Date__c == NULL ? ' ':String.valueOf(assetList[0].Units_Sold_Year_to_Date__c));
                salePrice = (assetList[0].get('selPrice') == NULL? ' ':String.valueOf(assetList[0].get('selPrice')));
                amazonAssetNumber = (assetList[0].Amazon_Asset_Name__c == NULL ? ' ':(assetList[0].Amazon_Asset_Name__c));
            }                    
        }
    }
    
    private static List<String> splitWordGroupWise(List<String> wordsList, String referenceStr){
        Map<Integer,String> strMap = new Map<Integer,String>();
        if(wordsList != null && wordsList.size()>0){
            Decimal wordLength = wordsList.size();
            Integer ceilingRows = Math.ceil(wordLength/7).intValue();
            Integer batchSize = Math.ceil(wordLength/ceilingRows).intValue();
            Integer row=1;
            String str = '';
            Integer limitVar = 0;
            Integer additionalValues = 0;
            if(wordsList.size()>49){
                limitVar = 48;
                additionalValues = wordsList.size() - 49;
            } else{
                limitVar = wordsList.size() - 1;
            }
            for (Integer i=0;i<=limitVar;i++){
                if(Math.Mod(i, batchSize) != (batchSize - 1)  && i != limitVar){
                    str = str + wordsList[i].trim() + ', ';
                    strMap.put(row,str);
                }else{
                    str = str + wordsList[i].trim();
                    strMap.put(row,str);
                    str = '';
                    row++;
                }
            }
            if(additionalValues>0){
                if(String.isNotBlank(referenceStr) && referenceStr.contains('categories')){
                    strMap.put(8,'and '+additionalValues+' more open categories!');
                } else if(String.isNotBlank(referenceStr) && referenceStr.contains('brands')){
                    strMap.put(8,'and '+additionalValues+' more approved brands!');
                }
            }
        }
        return strMap.values();
    }
    
    public PageReference savePdf() {
        List<Asset> assetList = [Select id, ownerId, Amazon_Asset_Name__c From Asset Where id =:recId];
        if(assetList != NULL && assetList.size()>0){
            PageReference pdfPage = Page.GeneratePdfRelatedToAssetVisualorcePage;
            if(String.isNotBlank(recId)){
                String pdfTitle= assetList[0].Amazon_Asset_Name__c+' - Telegram Announcement';
                pdfPage.getParameters().put('id', recId);
                List<ContentDocument> cdList = [SELECT Id, Title, ParentId FROM ContentDocument WHERE Title =: pdfTitle ORDER BY CreatedDate DESC];
                ContentVersion cv = new ContentVersion();
                cv.Title = pdfTitle;
                cv.PathOnClient = 'Asset.pdf';
                cv.VersionData = !Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('Test content');
                INSERT cv;
                
                Id cdId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id=: cv.Id LIMIT 1].ContentDocumentId;
                ContentDocumentLink objContentDocumentLink = new ContentDocumentLink();
                objContentDocumentLink.ContentDocumentId = cdId;
                objContentDocumentLink.ShareType = 'V';
                objContentDocumentLink.LinkedEntityId = recId;
                INSERT objContentDocumentLink;
                if(cdList != null && cdList.size()>0){
                    DELETE cdList;
                }
                return new PageReference('/'+recId);
            }
        } 
        return new PageReference('/'+recId);
    }
}