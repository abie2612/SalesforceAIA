import { LightningElement, wire, track } from 'lwc';
import getProductData from '@salesforce/apex/ProductListController.getProductData';
import sendEmailMessage from '@salesforce/apex/ProductListController.sendEmail';
import checkProductLeadProposal from '@salesforce/apex/ProductListController.checkProductLeadProposal';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { subscribe, unsubscribe, onError, setDebugFlag } from 'lightning/empApi';
import LightningConfirm from 'lightning/confirm';
import { RefreshEvent } from "lightning/refresh";

export default class ProductList extends LightningElement {
    recordId;
    currentPageReference = null;
    urlStateParameters = null;
    hideSpinner = false;
    products;
    showProductDetails = false;
    selectedProduct;
    openFiterModal = false;
    retainFilteredProduct = { "Marketplace__c": ["US"] };
    @track productCountOptions = [];
    
    

    //pagination related variables
    showPaginationTool = true;
    @track itemsRow = 2;
    pageItems = [];
    itemsPerPage = 6;
    totalPages = 0;
    currentPage = 1;
    addProductTagStyle;
    allProducts = [];
    itemPerRow = 1;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.attributes.recordId;
        }
    }

    connectedCallback() {
        this.subscribeToPushTopic();
        this.fetchProductList();
    }

    fetchProductList(){
        getProductData({leadId: this.recordId})
            .then(result => {
                this.hideSpinner = true;
                this.products = result.PRODUCTS;
                this.allProducts = result.PRODUCTS;
                if(result.PRODUCTS.length === 0){
                    this.showPaginationTool = false;
                }
                this.addProductTagStyle = this.products.reduce((accumulator, item) => {
                    if (item.LLC_Asset__c) {
                        accumulator.push(item.Id);
                    }
                    return accumulator;
                }, []);               
                this.handleTotalPage();
            })
            .catch(error => {
                this.hideSpinner = true;
                console.log(error);
            });
    }

    subscribeToPushTopic() {
        const channelName = '/topic/LeadUpdateRefresh';
        setDebugFlag(true);
        subscribe(channelName, -1, response => {
            this.handleRefreshProducts(response);
        }).then(response => {
            this.subscription = response;
        }).catch(error => {
            this.hideSpinner = true;
        });

        // Error handling
        onError(error => {
            console.error('EMP API error: ', JSON.stringify(error));
        });
    }

    handleRefreshProducts(response) {
        // Refresh the products list or perform other actions
        this.fetchProductList();
        this.template.querySelector('c-child-product-list-modal').clearFilters();
    }

    disconnectedCallback() {
        // Unsubscribe from the PushTopic when the component is removed from the DOM
        unsubscribe(this.subscription, response => {
            console.log('Successfully unsubscribed from: ', response);
        }).catch(error => {
            console.error('Error in unsubscribing: ', JSON.stringify(error));
        });
    }

    createProduct() {
        this.hideSpinner = true;
    }

    handleProduct(event) {
        this.showProductDetails = true;
        this.selectedProduct = this.products.filter((prod) => {
            return prod.Id === event.target.value;
        })[0];
    }

    hideModalBox() {
        this.showProductDetails = false;
    }

    async sendEmail() {
        this.showProductDetails = false;
        try {
            const result = await checkProductLeadProposal({ productId: this.selectedProduct.Id, leadId: this.recordId });
            console.log(result);
            if (result.STATUS == 'confirm') {
                const confirmResult = await LightningConfirm.open({
                    label: result.MSG,
                });
                if (confirmResult == true) {
                    console.log('Prompt result: ', confirmResult);
                    this.sendEmailMsg(false);
                }
            } else if (result.STATUS == 'success') {
                this.sendEmailMsg(true);
            }
            this.error = undefined;
        } catch (error) {
            console.log(error);
        }
    }

    sendEmailMsg(createNewProductProposal) {
        console.log('createNewProductProposal: ' + createNewProductProposal);
        sendEmailMessage({ productId: this.selectedProduct.Id, leadId: this.recordId, createNewProductProposal: createNewProductProposal })
            .then(result => {
                if (result.STATUS) {
                    this.showToastMessage(result.MSG, result.STATUS);
                    this.dispatchEvent(new RefreshEvent());
                }
                this.error = undefined;
            })
            .catch(error => {
                console.log(error);
            });
    }

    showToastMessage(message, variant) {
        const evt = new ShowToastEvent({
            title: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    //modal due to filter button
    showingFilterModal() {
        this.openFiterModal = true;
    }

    //Hide marketplace if marketplace is U.S.
    get hideUSMarketplace() {
        if (this.selectedProduct.Marketplace__c == 'US' || this.selectedProduct.Marketplace__c == null || this.selectedProduct.Marketplace__c == undefined || this.selectedProduct.Marketplace__c == '') {
            return false;
        } else
            return true;
    }

    hanldeProgressValueChange(event) {
        if (event.detail.list && event.detail.list !== undefined && event.detail.list.length > 0) {
            this.hideSpinner = true;
            this.products = this.allProducts.filter(({ Id }) => (event.detail.list).some(x => x.Id == Id));
            this.showPaginationTool = true;

        } else if (event.detail.list && event.detail.list.length === 0) {
            this.products = [];
            this.showPaginationTool = false;
        }
        if (event.detail.filteredProduct && event.detail.filteredProduct !== undefined) {
            this.retainFilteredProduct = event.detail.filteredProduct;
        }
        this.openFiterModal = event.detail.checkModal;
        if(this.itemsRow === 0 && this.itemsPerPage === 0){
            this.itemsRow = 2;
            this.totalPages = 1;
            this.setItemsCorrScreen();
        }
        this.handleFirst();
        this.handleTotalPage();
    }

    //Dynamically change number of products on each page
    get isLastPage() {
        if (this.currentPage == this.totalPages) {
            let rowValue = [];
            for (let i = 1; i <= Math.ceil((this.pageItems.length) / (this.itemPerRow)); i++) {
                let obj = {};
                obj.label = i.toString();
                obj.value = i;
                rowValue.push(obj);
            }
            this.productCountOptions = rowValue;
            return true;
        } else {
            this.productCountOptions = [
                { label: '1', value: 1 },
                { label: '2', value: 2 },
                { label: '3', value: 3 },
                { label: '4', value: 4 },
            ]
            return false;
        }
    }

    get isFirstPage() {
        if (this.currentPage == 1) {
            return true;
        } else {
            return false;
        }
    }

    get getItemsRow() {
        if (this.currentPage == this.totalPages) {
            this.alignLastPageRowNumber();
        }
        return this.itemsRow;
    }

    handleProductCountOptionsChange(event) {
        this.itemsRow = Number(event.detail.value);
        this.handleTotalPage();
    }

    //Pagination related code
    handleTotalPage() {
        this.setItemsCorrScreen();

        if (((typeof this.itemsPerPage) === "number" && !isNaN(this.itemsPerPage))) {
            this.totalPages = Math.ceil(this.products.length / this.itemsPerPage);
            if(isNaN(this.totalPages)){
                this.totalPages = 0;
            }
            this.updatePageItems();
        }
    }

    updatePageItems() {
        //Jump to the last page if current page is greater than last page
        if (this.currentPage > this.totalPages) {
            this.currentPage = this.totalPages;
        }
        if (((typeof this.itemsPerPage) === "number" && !isNaN(this.itemsPerPage)) && ((typeof this.itemsPerPage) === "number" && !isNaN(this.itemsPerPage))) {
            var startingItem = (this.currentPage - 1) * this.itemsPerPage;
            var endingItem = startingItem + this.itemsPerPage;
            this.pageItems = this.products.slice(startingItem, endingItem);
            this.alignLastPageRowNumber();
        }

        if ((Array.isArray(this.addProductTagStyle) && this.addProductTagStyle.length > 0)) {
            setTimeout(() => {
                this.addProductTagStyle.forEach(prodId => {
                    let test = this.template.querySelector(`div[data-id="${prodId}"]`);
                    if (test && test.classList && !test.classList.contains('productBox')) {
                        test.classList.add('productBox');
                    }
                });
            }, 1000);
        }
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage = this.currentPage + 1;
            this.updatePageItems();
        }
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage = this.currentPage - 1;
            this.updatePageItems();
        }
    }

    handleFirst() {
        this.currentPage = 1;
        this.updatePageItems();
    }

    handleLast() {
        this.currentPage = this.totalPages;
        this.updatePageItems();
    }

    alignLastPageRowNumber() {
        if ((this.pageItems.length) % (this.itemPerRow) === 0) {
            this.itemsRow = (this.pageItems.length) / (this.itemPerRow);
        } else if ((this.pageItems.length) % (this.itemPerRow) !== 0) {
            this.itemsRow = Math.ceil((this.pageItems.length) / (this.itemPerRow));
        }
        const countCombo = this.template.querySelector('.countCombo');
        if (countCombo) {
            countCombo.value = this.itemsRow;
        }
    }

    setItemsCorrScreen(){
        let dskWidth = window.innerWidth;
        if (FORM_FACTOR === 'Large') {
            if (dskWidth >= 1700) {
                this.itemPerRow = 4;
                this.itemsPerPage = 4 * (this.itemsRow);
            }
            if (dskWidth < 1700) {
                this.itemPerRow = 3;
                this.itemsPerPage = 3 * (this.itemsRow);
            }
        }
    }
}