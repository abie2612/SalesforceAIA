import { LightningElement, api } from 'lwc';
import getStageName from '@salesforce/apex/OpportunityStageController.getStageName';
import { CloseActionScreenEvent } from "lightning/actions";
import { NavigationMixin } from "lightning/navigation";
import LightningConfirm from 'lightning/confirm';

export default class OpportunityStage extends NavigationMixin(LightningElement) {
    @api recordId
    @api objectApiName

    record;
    recordIdValue;
    assetTakeOverDisabled = false;
    assetIntegrationDisabled = false;
    assetTakeoverCheck = false;
    assetIntegrationCheck = false;
    previousDisabled = false;
    nextDisabled = false;
    subStage;
    isShowModal = true;
    checkButton = false;
    doNotClose = true;
    isSaveButton = false;
    isSaveAndCloseButton = false;
    assetIntegrationNext = false;
    vendorOpportunity = false;
    customerOpportunity = false;
    ownershipChecked = false;

    connectedCallback() {
        setTimeout(() => {
            getStageName({ recordId: this.recordId })
                .then(result => {
                    this.record = result;
                    this.vendorOpportunity = this.record.RecordType.Name === 'Vendor' ? true : false;
                    this.customerOpportunity = this.record.RecordType.Name === 'Customer' ? true : false;
                    this.buttonActionCheck(this.record.StageName, this.vendorOpportunity, this.customerOpportunity);
                    this.isValidOrNot();
                })
                .catch(err => {
                    //this.displayToastMessage("Error", err, "error");
                });
        }, 50)
    }

    showModalBox() {
        this.assetTakeoverCheck = true;
    }

    async hideModalBox() {
        if (this.isSaveButton == false) {
            const result = await LightningConfirm.open({
                label: 'ALERT',
                theme: 'warning',
                message: 'Are you sure you want to close without saving the data?'
            });
            if (result) {
                this.assetTakeoverCheck = false;
                this.assetIntegrationCheck = false;
                setTimeout(() => {
                    window.location.reload();
                }, 1000)
                this.dispatchEvent(new CloseActionScreenEvent());
            }
        } else {
            this.assetTakeoverCheck = false;
            this.assetIntegrationCheck = false;
            setTimeout(() => {
                window.location.reload();
            }, 1500)
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    buttonActionCheck(stage, venOpportunity, cusOpportunity) {
        if (venOpportunity) {
            if (stage == 'Asset Takeover') {
                this.assetTakeOverDisabled = false
                this.assetIntegrationDisabled = true
            } else if (stage == 'Asset Integration') {
                this.assetTakeOverDisabled = true
                this.assetIntegrationDisabled = false
            } else {
                this.assetTakeOverDisabled = true
                this.assetIntegrationDisabled = true
            }
        } else if (cusOpportunity) {
            if(stage === 'Ownership Transfer'){
                this.ownershipTransferDisabled = false
            }
            else{
                this.ownershipTransferDisabled = true
            }
        }
            
    }

    handleAssetTakeOver() {
        this.assetTakeoverCheck = true;
    }

    handleAssetIntegration() {
        this.assetIntegrationCheck = true;
    }

    handleOwnershipTransfer(){
        this.ownershipChecked = true;
    }

    handlePrevious(event) {
        if (this.assetTakeoverCheck) {
            this.template.querySelector('c-asset-takeover').handlePrevious(event);
        } else if (this.assetIntegrationCheck) {
            this.assetIntegrationNext = false;
            this.template.querySelector('c-asset-integration').handlePrevious();
        }  else if(this.ownershipChecked){
            this.template.querySelector('c-ownership-transfer').handlePrevious(event);
        }
    }

    handleSave(event) {
        this.doNotClose = true;
        this.isSaveButton = true;
        if (this.assetTakeoverCheck) {
            this.template.querySelector('c-asset-takeover').handleSave(event);
        } else if (this.assetIntegrationCheck) {
            this.assetIntegrationNext = false;
            this.template.querySelector('c-asset-integration').handleSave(this.isSaveButton);
        } else if(this.ownershipChecked){
            this.template.querySelector('c-ownership-transfer').handleSave(event);
        }

    }

    handleSaveAndClose(event) {
        this.isSaveAndCloseButton = true;
        if (this.assetTakeoverCheck) {
            this.template.querySelector('c-asset-takeover').handleSave(event);
        } else if (this.assetIntegrationCheck) {
            this.assetIntegrationNext = false;
            this.template.querySelector('c-asset-integration').handleSave(this.isSaveButton);
        }  else if(this.ownershipChecked){
            this.template.querySelector('c-ownership-transfer').handleSave(event);
        }

    }

    handleNext(event) {
        this.doNotClose = false;
        if (this.assetTakeoverCheck) {
            this.template.querySelector('c-asset-takeover').handleNext(event);
        } else if (this.assetIntegrationCheck) {
            this.template.querySelector('c-asset-integration').handleNext(event);
            this.assetIntegrationNext = true;
        } else if(this.ownershipChecked){
            this.template.querySelector('c-ownership-transfer').handleNext(event);
        }
    }

    savedAssetIntegration(event) {
        let saveCheck = event.detail.isSaveButton;
        if (saveCheck) {
            this.isSaveButton = true;
        }
    }

    isValidOrNot(event) {
        let steps = event.detail.allSteps;
        let currentStep = event.detail.curStep;
        let saveCheck = event.detail.validCheck;
        if (!saveCheck) {
            this.isSaveButton = false;
        }
        if (currentStep == steps[0].value) {
            this.previousDisabled = true;
            this.nextDisabled = false;
        } else if (currentStep == steps[steps.length - 1].value) {
            this.previousDisabled = false;
            this.nextDisabled = true;
            if (event.detail.validCheck && this.doNotClose && !this.assetIntegrationNext) {
                setTimeout(() => {
                    window.location.reload();
                }, 1000)
                this.dispatchEvent(new CloseActionScreenEvent());
            }
        } else {
            this.previousDisabled = false;
            this.nextDisabled = false;
        }
        if (this.isSaveAndCloseButton) {
            if (event.detail.validCheck && this.doNotClose) {
                setTimeout(() => {
                    window.location.reload();
                }, 1000)
                this.dispatchEvent(new CloseActionScreenEvent());
            }
        }
        setTimeout(() => {
            this.doNotClose = true;
            this.isSaveAndCloseButton = false;
        }, 1200);
    }
}