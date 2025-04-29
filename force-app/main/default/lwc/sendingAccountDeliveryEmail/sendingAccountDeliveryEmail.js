import { LightningElement, api, track } from 'lwc';
//import { CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSendEmail from '@salesforce/apex/SendAccountDeliveryEmailController.checkDeliveryEmail';
import sendingEmail from '@salesforce/apex/SendAccountDeliveryEmailController.sendingEmail';
import LightningConfirm from 'lightning/confirm';
import SendDeliveryCustomCSS from '@salesforce/resourceUrl/SendDeliveryCustomCSS';
import { loadStyle } from "lightning/platformResourceLoader";
import { CloseActionScreenEvent } from 'lightning/actions';

export default class SendingAccountDeliveryEmail extends LightningElement {

    @api recordId;
    @track accounts;
    @track error;
    checkSendMail = false;
    isModalOpen = false;
    pdfUrl;

    connectedCallback() {
        Promise.all([
            loadStyle(this, SendDeliveryCustomCSS),
        ])
        .then(() => {
            console.log("All CSS are loaded. ");
        })
        .catch(error => {
            console.log("failed to load the style");
        });
        setTimeout(() => {            
            if (this.recordId != null && this.recordId != undefined && this.recordId != '') {
                this.pdfUrl = '/apex/SendAccountDeliveryPdf?Id=' + this.recordId;
                this.checkDeliveryEmail();
            }
        }, 200);

    }

    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent());
        this.isModalOpen = false;
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    checkDeliveryEmail() {
        const searchKey = this.recordId;
        getSendEmail({ oppRecordId: searchKey })
            .then(result => {
                this.accounts = result;
                if (result.STATUS && result.MSG == 'The Delivery PDF is still being created. Please Wait!') {
                    this.showToastMessage(result.MSG, result.STATUS);
                    this.dispatchEvent(new CloseActionScreenEvent());
                }else if (result.STATUS && result.MSG == 'Preview mail') {
                    this.isModalOpen = true;
                } else if (result.STATUS && (result.MSG).includes('This delivery has already been sent')) {
                    this.handlePromptClick(result.MSG);
                }
                else if (result.STATUS) {
                    this.showToastMessage(result.MSG, result.STATUS)
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.accounts = undefined;
            })
    }

    showToastMessage(message, variant) {
        const evt = new ShowToastEvent({
            title: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    async handlePromptClick(msg) {

        const result = await LightningConfirm.open({
            label: msg,
        });

        if (result == true) {
            this.isModalOpen = true;
            
        } else {
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    sendEmail() {
        this.isModalOpen = false;
        this.waitingMessage();
        sendingEmail({ opporIds: this.recordId })
            .then(result => {
                this.showToastMessage(result.MSG, result.STATUS);
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {

            })
    }

    waitingMessage() {
        const evt = new ShowToastEvent({
            title: 'Please wait while we are sending mail',
            variant: 'info',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}