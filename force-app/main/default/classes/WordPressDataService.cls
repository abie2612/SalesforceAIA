/*
* Author Name : Adam Chauhan
* Date        : 21/10/2024  
* Description : Data Service class for Wordpress
*/

public class WordPressDataService {
    public static String prepareWordPressJson(Asset asset){
        if(asset != null){
            String jsonBody = getWordPressJSONBody(asset);
            return jsonBody;
        }
        return null;
    }
    
    //Preparing json 
    private static String getWordPressJSONBody(Asset asset){
        String allMarketPlaces = '';
        if(String.isNotBlank(asset.Marketplace__c)){
            if(String.isNotBlank(asset.Additional_Marketplaces__c) && (asset.Additional_Marketplaces__c).contains(asset.Marketplace__c)){
                allMarketPlaces = asset.Additional_Marketplaces__c;
            }else if(String.isNotBlank(asset.Additional_Marketplaces__c)){
                allMarketPlaces = asset.Marketplace__c + ';' +asset.Additional_Marketplaces__c;
            }else{
                allMarketPlaces = asset.Marketplace__c;
            }
        }else if(String.isBlank(asset.Marketplace__c) && String.isNotBlank(asset.Additional_Marketplaces__c)){
            allMarketPlaces = asset.Additional_Marketplaces__c;
        }
        String specialAccType = String.isNotBlank(asset.Special_Account_Type__c) ? (asset.Special_Account_Type__c == 'Daily'? 'DAILY PAYOUT! No Reserve':(asset.Special_Account_Type__c == '1-Week'?'WEEKLY PAYOUT! No Reserve': (asset.Special_Account_Type__c == '2-Week'?'TWO WEEK PAYOUT! No Reserve': ''))) : '';
        ConnectApi.OrganizationSettings  orgSettings = ConnectApi.Organization.getSettings();
        String body = '{"title": "' + asset.Amazon_Asset_Name__c + '", "content": "' + asset.Amazon_Asset_Name__c + '", "status": "publish", "type":"accounts","show_in_rest":true, "acf": {"established":"' + (asset.Creation_Date__c != null ? ''+ (asset.Creation_Date__c).YEAR() : '') + '","store_feedback":"' + (asset.Feedback__c!=null ? ''+asset.Feedback__c: '') + '", "stars":"' + (asset.Stars_Store_Feedback__c!=null ? ''+asset.Stars_Store_Feedback__c:'4') + '" , "price":"' + (asset.Sale_Price__c != null ? ''+asset.Sale_Price__c : '') + '" ,"sales_history_to_date":"' +(asset.get('saleHistoryAllTime') != null ? ''+asset.get('saleHistoryAllTime') : '') + '" , "sales_history_month":"' + (asset.get('saleHistoryYearToDate') != null ? ''+asset.get('saleHistoryYearToDate') : '') + '" , "brand_name":"' + (asset.Brands_approved__c != null ? ''+asset.Brands_approved__c:'') + '", "category_name":"' + (asset.Categories_Approved__c != null ? ''+asset.Categories_Approved__c:'') + '" , "currency":"'  + orgSettings.UserSettings.currencySymbol + '" , "is_sold":'  + asset.Delivered__c + ' ,"m_place":"'  + allMarketPlaces + '" , "payout":"' + specialAccType + '"  , "number_of_units_sold_to_date":"' + (asset.Overall_Units_Sold__c != null ? ''+asset.Overall_Units_Sold__c:'') + '"}}';
        return body;
    }
}