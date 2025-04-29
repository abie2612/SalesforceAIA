import { LightningElement,api } from 'lwc';
import getProduct from '@salesforce/apex/ProductListController.getFilterProducts';
import { loadStyle } from 'lightning/platformResourceLoader';
import myStaticStyles from '@salesforce/resourceUrl/productList'

export default class ChildProductListModal extends LightningElement {
    llcAssetTypeValue=false;
    selectedItem = 'reports_recent';
    updatedCount = 12;
    isShowModal = true;
    aiaAccountTypeValue = '';
    specialAccountTypeValue = '';
    feedbackValue = '';
    brandQueryTerm = '';
    categoryQueryTerm = '';
    asinQueryTerm = '';
    marketplaceValue = '';
    recentSalesValue = '';
    sales_12_MonthsQueryTerm = '';
    numberOfSalesValue = '';
    amazonAccountTypeValue = '';
    brandRegistryValue = '';
    hazmatValue = '';
    healthAssuranceScoreValue;
    nonAmazonPlatformValue = '';
    objSearchProducts = {};
    @api newSearchProducts;
    @api leadRecordId;
    key = '';
    productData = [];
    calledFromSearch = false;

    connectedCallback(){
        loadStyle(this, myStaticStyles);
        setTimeout(() => {
        this.objSearchProducts = {...(this.newSearchProducts)};
        if(this.objSearchProducts != null){
            if(this.objSearchProducts.LLC_Asset__c !== undefined){
                this.llcAssetTypeValue = this.objSearchProducts.LLC_Asset__c;
            }
            if(this.objSearchProducts.Account_Type__c !== undefined){
                this.aiaAccountTypeValue = this.objSearchProducts.Account_Type__c;
            }
            if(this.objSearchProducts.Special_Account_Type__c !== undefined){
                this.specialAccountTypeValue = this.objSearchProducts.Special_Account_Type__c;
            }
            if(this.objSearchProducts.Feedback__c !== undefined){
                this.feedbackValue = this.objSearchProducts.Feedback__c;
            }
            if(this.objSearchProducts.Brands_approved__c !== undefined){
                this.brandQueryTerm = this.objSearchProducts.Brands_approved__c;
            }
            if(this.objSearchProducts.Categories_Approved__c !== undefined){
                this.categoryQueryTerm = this.objSearchProducts.Categories_Approved__c;
            }
            if(this.objSearchProducts.ASINs_approved__c !== undefined){
                this.asinQueryTerm = this.objSearchProducts.ASINs_approved__c;
            }
            if(this.objSearchProducts.Marketplace__c !== undefined){
                this.marketplaceValue = this.objSearchProducts.Marketplace__c;
            }
            if(this.objSearchProducts.RecentSales !== undefined){
                this.recentSalesValue = this.objSearchProducts.RecentSales;
            }
            if(this.objSearchProducts.Overall_Units_Sold__c !== undefined){
                this.numberOfSalesValue = this.objSearchProducts.Overall_Units_Sold__c;
            }
            if(this.objSearchProducts.Amazon_Account_Type__c !== undefined){
                this.amazonAccountTypeValue = this.objSearchProducts.Amazon_Account_Type__c;
            }
            if(this.objSearchProducts.Brand_Registry__c !== undefined){
                this.brandRegistryValue = this.objSearchProducts.Brand_Registry__c;
            }
            if(this.objSearchProducts.Hazmat__c !== undefined){
                this.hazmatValue = this.objSearchProducts.Hazmat__c;
            }
            if(this.objSearchProducts.Health_Assurance_Score__c !== undefined){
                this.healthAssuranceScoreValue = this.objSearchProducts.Health_Assurance_Score__c;
            }
            if(this.objSearchProducts.Non_Amazon_Platform__c !== undefined){
                this.nonAmazonPlatformValue = this.objSearchProducts.Non_Amazon_Platform__c;
            }
        }
        }, 200);
    }

    hidingFilterModal() {  
        this.isShowModal = false;
        var detailNew = {};
        if(this.calledFromSearch){
            detailNew = {
                list: this.productData,
                checkModal: false,
                filteredProduct: this.objSearchProducts
            };
        } else{
            detailNew = {
                checkModal: false,
                filteredProduct: this.newSearchProducts
            };
        }
        
        const selectedEvent = new CustomEvent("progressvaluechange", {
            detail: detailNew,

          });
      
          this.dispatchEvent(selectedEvent);
    }

    //LLC Asset Filter
    get llcAssetOptions() {
        return [
            { label: 'True', value: true },
            { label: 'False', value: false },
        ];
    }
    get llcAssetSelectedValue() {
        return this.value.join(',');
    }
    handlellcAsset(event) {
        this.llcAssetTypeValue = event.target.checked;
        this.key = event.target.name;
        this.objSearchProducts[this.key] = this.llcAssetTypeValue;
        if(this.objSearchProducts[this.key] == '' ||this.objSearchProducts[this.key] == undefined || this.objSearchProducts[this.key] == null){
            delete this.objSearchProducts[this.key];
        }
    }

    //AIA Account Type Filter
    get aiaAccountTypeOptions() {
        return [
            { label: 'Standard', value: 'Standard' },
            { label: 'Special', value: 'Special' },
        ];
    }
    handleAIAAccountType(event) {
        if(event.detail?.value != null && event.target?.name !=null){
            this.aiaAccountTypeValue = event.detail.value;
            this.key = event.target.name;
            this.objSearchProducts[this.key] = this.aiaAccountTypeValue;
        }
        if(this.objSearchProducts[this.key] == '' ||this.objSearchProducts[this.key] == undefined || this.objSearchProducts[this.key] == null){
            delete this.objSearchProducts[this.key];
        }
    }

    //Special Account Type Filter
    get specialAccountTypeOptions() {
        return [
            { label: 'Daily', value: 'Daily' },
            { label: '1-Week', value: '1-Week' },
            { label: '2-Week', value: '2-Week' },
        ];
    }
    handleSpecialAccountType(event) {
        if(event.detail?.value != null && event.target?.name !=null){
            this.specialAccountTypeValue = event.detail.value;
            this.key = event.target.name;
            this.objSearchProducts[this.key] = this.specialAccountTypeValue;
        }
        if(this.objSearchProducts[this.key] == '' ||this.objSearchProducts[this.key] == undefined || this.objSearchProducts[this.key] == null){
            delete this.objSearchProducts[this.key];
        }
    }

    //Feedback filter
    get feedbackOptions() {
        return [
            { label :'None', value: ''},
            { label: '50+', value: '50+' },
            { label: '250+', value: '250+' },
            { label: '500+', value: '500+' },
            { label: '1000+', value: '1000+' },
            { label: '5000+', value: '5000+' },
            { label: '10000+', value: '10000+' },
        ];
    }
    handleFeedback(event) {
        if(event.detail?.value != null && event.target?.name !=null){
            this.feedbackValue = event.detail.value;
            this.key = event.target.name;
            this.objSearchProducts[this.key] = this.feedbackValue;
        }
        if(this.objSearchProducts[this.key] == '' ||this.objSearchProducts[this.key] == undefined || this.objSearchProducts[this.key] == null){
            delete this.objSearchProducts[this.key];
        }
    }

    //Brand Filter
    handleBrand(evt) {
        this.brandQueryTerm = evt.target.value;
        this.key = evt.target.name;
        this.objSearchProducts[this.key] = this.brandQueryTerm;
    }

    //Category Filter
    handleCategory(evt) {
        this.categoryQueryTerm = evt.target.value;
        this.key = evt.target.name;
        this.objSearchProducts[this.key] = this.categoryQueryTerm;
    }

    //ASIN Filter
    handleASIN(evt) {
        this.asinQueryTerm = evt.target.value;
        this.key = evt.target.name;
        this.objSearchProducts[this.key] = this.asinQueryTerm;
    }

    //Marketplace filter
    get marketOptions() {
        return [
            { label: 'US', value: 'US' },
            { label: 'UK', value: 'UK' },
            { label: 'EU', value: 'EU' }
        ];
    }
    handleMarketplace(event) {
        if(event.detail?.value != null && event.target?.name !=null){
            this.marketplaceValue = event.detail.value;
            this.key = event.target.name;
            this.objSearchProducts[this.key] = this.marketplaceValue;
        }
        if(this.objSearchProducts[this.key] == '' ||this.objSearchProducts[this.key] == undefined || this.objSearchProducts[this.key] == null){
            delete this.objSearchProducts[this.key];
        }
    }

    //Recent Sales filter
    get recentSalesOptions() {
        return [
            { label: '3 Months', value: '3 Months' },
            { label: '12 Months', value: '12 Months' },
        ];
    }
    handleRecentSales(event) {
        if(event.detail?.value != null && event.target?.name !=null){
            this.recentSalesValue = event.detail.value;
            this.key = event.target.name;
            this.objSearchProducts[this.key] = this.recentSalesValue;
        }
        if(this.objSearchProducts[this.key] == '' ||this.objSearchProducts[this.key] == undefined || this.objSearchProducts[this.key] == null){
            delete this.objSearchProducts[this.key];
        }
    }

    //Number of Sales filter
    get numberOfSalesOptions() {
        return [
            { label: 'None', value: ''},
            { label: '500+', value: '500+' },
            { label: '2500+', value: '2500+' },
            { label: '5000+', value: '5000+' },
            { label: '10000+', value: '10000+' },
            { label: '50000+', value: '50000+' },
            { label: '100000+', value: '100000+' },
        ];
    }
    handleNumberOfSales(event) {
        if(event.detail?.value != null && event.target?.name !=null){
            this.numberOfSalesValue = event.detail.value;
            this.key = event.target.name;
            this.objSearchProducts[this.key] = this.numberOfSalesValue;
        }
        if(this.objSearchProducts[this.key] == '' ||this.objSearchProducts[this.key] == undefined || this.objSearchProducts[this.key] == null){
            delete this.objSearchProducts[this.key];
        }
    }

    //Number of Amazon Account Type
    get amazonAccountTypeOptions() {
        return [
            { label: 'Seller', value: 'Seller' },
            { label: 'Vendor', value: 'Vendor' },
            { label: 'Merch/POD', value: 'Merch/POD' },
        ];
    }
    handleAmazonAccountType(event) {
        if(event.detail?.value != null && event.target?.name !=null){
            this.amazonAccountTypeValue = event.detail.value;
            this.key = event.target.name;
            this.objSearchProducts[this.key] = this.amazonAccountTypeValue;
        }
        if(this.objSearchProducts[this.key] == '' ||this.objSearchProducts[this.key] == undefined || this.objSearchProducts[this.key] == null){
            delete this.objSearchProducts[this.key];
        }
    }

    //Number of Brand Registry
    get brandRegistryOptions() {
        return [
            { label: 'No', value: 'No' },
            { label: 'Yes', value: 'Yes' },
        ];
    }
    handleBrandRegistry(event) {
        if(event.detail?.value != null && event.target?.name !=null){
            this.brandRegistryValue = event.detail.value;
            this.key = event.target.name;
            this.objSearchProducts[this.key] = this.brandRegistryValue;
        }
        if(this.objSearchProducts[this.key] == '' ||this.objSearchProducts[this.key] == undefined || this.objSearchProducts[this.key] == null){
            delete this.objSearchProducts[this.key];
        }
    }

    //Hazmat Registry
    get hazmatOptions() {
        return [
            { label: 'No', value: 'No' },
            { label: 'Yes', value: 'Yes' },
        ];
    }
    handleHazmat(event) {
        if(event.detail?.value != null && event.target?.name !=null){
            this.hazmatValue = event.detail.value;
            this.key = event.target.name;
            this.objSearchProducts[this.key] = this.hazmatValue;
        }
        if(this.objSearchProducts[this.key] == '' ||this.objSearchProducts[this.key] == undefined || this.objSearchProducts[this.key] == null){
            delete this.objSearchProducts[this.key];
        }
    }

    //Health Assurance Score Filter
    handleHealthAssuranceScore(event) {
        this.healthAssuranceScoreValue = event.target.value;
        this.key = event.target.name;
        this.objSearchProducts[this.key] = this.healthAssuranceScoreValue;
    }
    
    //Non Amazon Platform
    get nonAmazonPlatformOptions() {
        return [
            { label: 'Walmart', value: 'Walmart' },
            { label: 'Ebay', value: 'Ebay' },
            { label: 'Etsy', value: 'Etsy' },
            { label: 'TikTok', value: 'TikTok' },
            { label: 'Facebook', value: 'Facebook' },
            { label: 'LLC', value: 'LLC' }
        ];
    }
    handleNonAmazonPlatform(event) {
        if(event.detail?.value != null && event.target?.name !=null){
            this.nonAmazonPlatformValue = event.detail.value;
            this.key = event.target.name;
            this.objSearchProducts[this.key] = this.nonAmazonPlatformValue;
        }
        if(this.objSearchProducts[this.key] == '' ||this.objSearchProducts[this.key] == undefined || this.objSearchProducts[this.key] == null){
            delete this.objSearchProducts[this.key];
        }
    }


    //Filter Products on the basis of Filtering options
    async handleFilterProduct(){
        getProduct({ objSearchProducts: JSON.stringify(this.objSearchProducts), leadId: this.leadRecordId})
		.then(result => {
			this.productData = result;
            this.calledFromSearch = true;
			this.error = undefined;
            this.hidingFilterModal();
		})
		.catch(error => {
			this.error = error;
			this.productData = undefined;
		})
    }


    handleClearFilterProduct(){
    this.llcAssetTypeValue=false;
    this.aiaAccountTypeValue = '';
    this.specialAccountTypeValue = '';
    this.feedbackValue = '';
    this.brandQueryTerm = '';
    this.categoryQueryTerm = '';
    this.asinQueryTerm = '';
    this.marketplaceValue = '';
    this.recentSalesValue = '';
    this.sales_12_MonthsQueryTerm = '';
    this.numberOfSalesValue = '';
    this.amazonAccountTypeValue = '';
    this.brandRegistryValue = '';
    this.hazmatValue = '';
    this.healthAssuranceScoreValue;
    this.nonAmazonPlatformValue = '';
    this.objSearchProducts = {};
    }
}