import { LightningElement, api, wire } from 'lwc';
import getLeadStages from '@salesforce/apex/LeadStagePathController.getLeadStages';
import updateLeadStage from '@salesforce/apex/LeadStagePathController.updateLeadStage';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import LEAD_STAGE from "@salesforce/schema/Lead.Lead_Stage__c";
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LeadStagePath extends LightningElement {
    @api recordId;
    @api objectApiName;
    leadStages;
    currentStep;
    clickedStage;
    isLoading = false;
    buttonLabel = 'Mark Status as Complete';
    isDisabled = false;

    @wire(getRecord, {
        recordId: "$recordId",
        fields: [LEAD_STAGE],
    })
    handleLeadData({ error, data }) {
        if (data) {
            this.currentStep = getFieldValue(data, LEAD_STAGE);
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getLeadStages, { recordId: '$recordId' })
    wiredGetLeadStages({ error, data }) {
        if (data) {
            this.isLoading = true;
            this.leadStages = data.DependentStages;
            if(this.currentStep === undefined || this.currentStep === null){
                this.currentStep = this.leadStages[0];
            }
            if(this.currentStep === this.leadStages[this.leadStages.length - 1]){
                this.isDisabled = true;
            }
        }
        else if (error) {
            console.error(error);
        }
    }

    handleStepFocus(event) {
        const stepIndex = event.detail.index;
        this.clickedStage = this.leadStages[stepIndex];
        if (this.clickedStage !== this.currentStep) {
            this.buttonLabel = 'Mark as Current Stage'
        } else {
            this.buttonLabel = 'Mark Status as Complete'
        }
        if(this.clickedStage === this.leadStages[this.leadStages.length - 1] && this.currentStep === this.clickedStage){
            this.isDisabled = true;
        }else{
            this.isDisabled = false;
        }
    }

    handleStepChange(event) {
        let updatedStage = '';
        if(event.currentTarget.label === 'Mark as Current Stage'){
            updatedStage = this.clickedStage;
        } else if(event.currentTarget.label === 'Mark Status as Complete'){
            updatedStage = this.leadStages[this.leadStages.indexOf(this.currentStep)+1];
        }
        updateLeadStage({ updatedStage: updatedStage, recordId: this.recordId })
            .then(result => {
                this.currentStep = updatedStage;
                this.buttonLabel = 'Mark Status as Complete';
                if(this.currentStep === this.leadStages[this.leadStages.length - 1]){
                    this.isDisabled = true;
                } else{
                    this.isDisabled = false;
                }
                this.displayToastMessage('Success', 'Lead Stage updated successfully', 'success');
                this.dispatchEvent(new RefreshEvent());
            })
            .catch(err => {
                if(err.body.message.includes('Lead Stage cannot move backwards')){
                    this.displayToastMessage('Error', 'Lead Stage cannot move backwards after meeting has been completed.', 'error');
                } else{
                    this.displayToastMessage('Error', err.body.message, 'error');
                }
            });
    }

    displayToastMessage(title, message, type) {
        const event = new ShowToastEvent({ title: title, message: message, variant: type });
        this.dispatchEvent(event);
    }
}