import { LightningElement, api } from 'lwc';
import getSubStage from '@salesforce/apex/OwnershipTransferController.getSubStage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ownershipCSS from '@salesforce/resourceUrl/OwnershipTransferCSS';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class OwnershipTransfer extends LightningElement {

    @api recordId;
    isValid = false;
    currentStep = '';
    isLoading = true;
    previousDisabled = false;
    nextDisabled = false;
    isHelpTickets = false;
    taxAndLegal = false;
    depositMethod = false;
    sellerProfile = false;
    chargeMethod = false;
    buyerProfile = false;
    amazonCreds = false;
    emailAccountCreds = false;

    steps = [
        { Name: 'Help Tickets', value: 'Help Tickets' },
        { Name: 'Tax and Legal Entity', value: 'Tax and Legal Entity' },
        { Name: 'Deposit Method', value: 'Deposit Method' },
        { Name: 'Seller Profile', value: 'Seller Profile' },
        { Name: 'Charge Method', value: 'Charge Method' },
        { Name: 'Buyer Profile', value: 'Buyer Profile' },
        { Name: 'Amazon Credential Check', value: 'Amazon Credential Check' },
        { Name: 'Email Account Credential Check', value: 'Email Account Credential Check' }
    ];

    connectedCallback() {
        loadStyle(this, ownershipCSS)
        .then(() => {
            setTimeout(() => {
                getSubStage({ recordId: this.recordId })
                    .then(result => {
                        this.currentStep = result;
                        this.checkDisabled();
                        this.isLoading = false;
                        this.checkCurrentStep();
                    })
                    .catch(err => {
                        this.errorToast(err.body.message);
                    });
            }, 50)
        });
        
    }

    scrollToTop(){
        const topDiv = this.template.querySelector(".main-container-div");
        if (topDiv) {
            topDiv.scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'start' });
        }
    }

    checkCurrentStep() {
        this.scrollToTop();
        this.isHelpTickets = false;
        this.taxAndLegal = false;
        this.depositMethod = false;
        this.sellerProfile = false;
        this.chargeMethod = false;
        this.buyerProfile = false;
        this.amazonCreds = false;
        this.emailAccountCreds = false;
        if (this.currentStep === 'Help Tickets') {
            this.isHelpTickets = true;
        } else if (this.currentStep === 'Tax and Legal Entity') {
            this.taxAndLegal = true;
        } else if (this.currentStep === 'Deposit Method') {
            this.depositMethod = true;
        } else if (this.currentStep === 'Seller Profile') {
            this.sellerProfile = true;
        } else if (this.currentStep === 'Charge Method') {
            this.chargeMethod = true;
        } else if (this.currentStep === 'Buyer Profile') {
            this.buyerProfile = true;
        } else if (this.currentStep === 'Amazon Credential Check') {
            this.amazonCreds = true;
        } else if (this.currentStep === 'Email Account Credential Check') {
            this.emailAccountCreds = true;
        }
        this.checkDisabled();
    }

    @api checkDisabled() {
        this.previousDisabled = false;
        this.nextDisabled = false;
        if (this.currentStep === 'Help Tickets') {
            this.previousDisabled = true;
        } else if (this.currentStep === 'Email Account Credential Check') {
            this.nextDisabled = true;
        }
        let ev = new CustomEvent('isvalidornot', {
            detail: {
                curStep: this.currentStep,
                allSteps: this.steps
            }
        });
        this.dispatchEvent(ev);
    }

    checkCurrentComponent() {
        let subStagecomponent = '';
        if (this.isHelpTickets) {
            subStagecomponent = "c-sub-stage-help-tickets";
        } else if (this.taxAndLegal) {
            subStagecomponent = "c-sub-stage-tax-and-legal";
        } else if (this.depositMethod) {
            subStagecomponent = "c-sub-stage-deposit-method";
        } else if (this.sellerProfile) {
            subStagecomponent = "c-sub-stage-seller-profile";
        } else if (this.chargeMethod) {
            subStagecomponent = "c-sub-stage-charge-method";
        } else if (this.buyerProfile) {
            subStagecomponent = "c-sub-stage-buyer-profile";
        } else if (this.amazonCreds) {
            subStagecomponent = "c-sub-stage-amazon-credentials";
        } else if (this.emailAccountCreds) {
            subStagecomponent = "c-sub-stage-email-account-credentials";
        }
        return subStagecomponent;
    }

    getCurrentStep(event) {
        this.currentStep = event.detail;
        this.checkDisabled();
        let ev = new CustomEvent('isvalidornot', {
            detail: {
                curStep: this.currentStep,
                allSteps: this.steps
            }
        });
        this.dispatchEvent(ev);
    }

    errorToast(msg) {
        const event = new ShowToastEvent({
            title: 'Error!',
            message: msg,
            variant: 'error'
        });
        this.dispatchEvent(event);
    }

    @api handlePrevious(event) {
        let found = this.steps.findIndex(({ Name }) => Name === this.currentStep);
        found--;
        this.currentStep = this.steps[found].Name;
        this.checkCurrentStep();
    }

    @api handleSave(event) {
        const subStagecomponent = this.checkCurrentComponent();
        setTimeout(() => {
            this.template.querySelector(subStagecomponent).handleSave(this.currentStep);
        }, 50)
    }

    @api handleNext(event) {
        const subStagecomponent = this.checkCurrentComponent();
        let found = this.steps.findIndex(({ Name }) => Name === this.currentStep);
        found++;
        this.template.querySelector(subStagecomponent).handleSave(this.steps[found].Name);
    }

    isValidOrNot(event){
        this.isValid = event.detail.validCheck;
        if (this.isValid) {
            this.currentStep = event.detail.curStep;
            this.checkCurrentStep();
        } else {
            console.log('Please fill required fields');
        }
        let ev = new CustomEvent('isvalidornot', {
            detail: {
                curStep: this.currentStep,
                allSteps: this.steps,
                validCheck: this.isValid,
            }
        });
        this.dispatchEvent(ev);
    }

    checkValidity(event) {
        this.isValid = event.detail;
        let ev = new CustomEvent('isvalidornot', {
            detail: {
                curStep: this.currentStep,
                allSteps: this.steps,
                validCheck: this.isValid,
            }
        });
        this.dispatchEvent(ev);
    }
}