import { LightningElement, api } from 'lwc';
import getSubStage from '@salesforce/apex/AssetTakeoverController.getSubStage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AssetTakeover extends LightningElement {
    @api recordId;
    isValid = false;
    currentStep = '';
    isLoading = true;
    previousDisabled = false;
    nextDisabled = false;

    steps = [
        { Name: 'VPS', value: 'VPS' },
        { Name: 'CallHippo Number', value: 'CallHippo Number' },
        { Name: 'Mercury Credit Card', value: 'Mercury Credit Card' },
        { Name: 'Email account on Amazon', value: 'Email account on Amazon' },
        { Name: 'Live Takeover', value: 'Live Takeover' },
    ];

    connectedCallback() {
        setTimeout(() => {
            getSubStage({ recordId: this.recordId })
                .then(result => {
                    this.currentStep = result;
                    this.checkDisabled();
                    this.isLoading = false;
                })
                .catch(err => {
                    this.errorToast(err.body.message);
                });
        }, 50)
    }

    @api checkDisabled() {
        this.previousDisabled = false;
        this.nextDisabled = false;
        if (this.currentStep === 'VPS') {
            this.previousDisabled = true;
        } else if (this.currentStep === 'Live Takeover') {
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
        this.template.querySelector('c-asset-takeover-steps').handlePrevious(event);
        let ev = new CustomEvent('isvalidornot', {
            detail: {
                curStep: this.currentStep,
                allSteps: this.steps
            }
        });
        this.dispatchEvent(ev);
    }

    @api handleSave(event) {
        setTimeout(() => {
            this.template.querySelector('c-asset-takeover-steps').handleSave(event);
        }, 50)
    }

    @api handleNext(event) {
        this.template.querySelector('c-asset-takeover-steps').handleNext(event);
        let ev = new CustomEvent('isvalidornot', {
            detail: {
                curStep: this.currentStep,
                allSteps: this.steps
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