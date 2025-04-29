import { LightningElement, api } from 'lwc';
import changeSubStage from '@salesforce/apex/AssetTakeoverController.changeSubStage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpp from '@salesforce/apex/AssetTakeoverController.getOpp';
import sendDatatoOpp from '@salesforce/apex/AssetTakeoverController.sendDatatoOpp';

export default class SubStageMercuryCC extends LightningElement {

    @api oppId;
    record = {};
    objMercuryCard = { Generated_new_CC_in_Mercury_Account__c: false, Credit_Card_Name__c: '', Credit_Card_Number__c: '', Expiry_Month__c: '', Expiry_Year__c:'', CVV__c: '', Address__c: '' }

    connectedCallback() {
        setTimeout(() => {
            getOpp({ recordId: this.oppId })
                .then(result => {
                    this.record = result;
                    console.log('this.record.Generated_new_CC_in_Mercury_Account__c', this.record.Generated_new_CC_in_Mercury_Account__c);
                })
                .catch(err => {
                    this.displayToastMessage("Error", err, "error");
                });
        }, 50)
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('lightning-input-field');
        inputFields.forEach(inputField => {
            if (!inputField.reportValidity()) {
                isValid = false;
            }
        });
        return isValid;
    }

    @api handleSave(SubStageToBeUpdate) {
        let isValid = this.isInputValid();
        if (isValid) {
            let inputFields = this.template.querySelectorAll('lightning-input-field');
            inputFields.forEach(inputField => {
                if (this.objMercuryCard.hasOwnProperty(inputField.fieldName)) {
                    this.objMercuryCard[inputField.fieldName] = inputField.value;
                }
            });
            sendDatatoOpp({
                recordId: this.oppId, fieldValue: JSON.stringify(this.objMercuryCard)
            })
                .then(result => {
                    this.displayToastMessage("Success", "All the details are filled successfully", "success");
                })
                .catch(err => {
                    this.displayToastMessage("Error", err, "error");
                });
            
            changeSubStage({ recordId: this.oppId, subStage: SubStageToBeUpdate, finalSave : false });
        } else {
            this.displayToastMessage("Error", 'Please fill required fields', "error");
        }
        let ev = new CustomEvent('isvalidornot', {
            detail: isValid
        });
        this.dispatchEvent(ev);
    }

    handleCheckBox(event) {
        if (event.target.value) {
            this.record = { ...this.record, Generated_new_CC_in_Mercury_Account__c: true };
        } else {
            this.record = { ...this.record, Generated_new_CC_in_Mercury_Account__c: false, Credit_Card_Name__c: '', Credit_Card_Number__c: '', Expiry_Month__c: '', Expiry_Year__c:'', CVV__c: '', Address__c: '' };
        }
    }

    displayToastMessage(title, message, type) {
        const event = new ShowToastEvent({ title: title, message: message, variant: type });
        this.dispatchEvent(event);
    }
}