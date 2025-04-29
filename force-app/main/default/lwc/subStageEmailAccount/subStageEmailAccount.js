import { LightningElement, api } from 'lwc';
import changeSubStage from '@salesforce/apex/AssetTakeoverController.changeSubStage';
import getOpp from '@salesforce/apex/AssetTakeoverController.getOTP';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SubStageEmailAccount extends LightningElement {

    @api oppId;
    hideDetails = true;
    recordValue = {};
    isLoading = true;
    record = { Existing_Email_Address_Included__c: false, Email_Address_on_Email_Account__c: '', Email_Account_Password_Final__c: '', Email_Account_OTP_QR_code_Final_Email__c: '' };

    connectedCallback() {
        this.getChechboxValue();
        this.isLoading =false;
    }

    getChechboxValue() {
        setTimeout(() => {
            if (this.template.querySelector('lightning-input-field[data-name="existingCheckbox"]').value) {
                this.hideDetails = true;
            } else {
                this.hideDetails = false;
            }
            getOpp({ recordId: this.oppId })
                .then(result => {
                    this.recordValue = result;
                }).catch(error => {

                })
        }, 800)
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
            this.isLoading = true;
            this.template.querySelector('lightning-record-edit-form').submit();
            setTimeout(() => {
                getOpp({ recordId: this.oppId })
                .then(result => {
                    this.recordValue = result;
                    console.log(this.recordValue.Email_Account_OTP_QR_code_Final_Email__c);
                    this.isLoading = false;
                }).catch(error => {
                    this.isLoading = false;
                })
            }, 500);
            
            try {
                this.displayToastMessage("Success", "All the details are filled successfully", "success");
                changeSubStage({ recordId: this.oppId, subStage: SubStageToBeUpdate, finalSave: false });
            }
            catch (error) {
                reduceErrors(error).forEach(err => this.displayToastMessage("Error", err, "error"));
            }
        } else {
            this.displayToastMessage("Error", 'Please fill required fields', "error");
        }
        let inputFields = this.template.querySelectorAll('lightning-input-field');
        inputFields.forEach(inputField => {
            this.record[inputField.fieldName] = inputField.value;
        });

        let ev3 = new CustomEvent('getrecord', {
            detail: this.record
        });
        this.dispatchEvent(ev3);

        let ev = new CustomEvent('isvalidornot', {
            detail: isValid
        });
        this.dispatchEvent(ev);
        let ev2 = new CustomEvent('getcheckbox', {
            detail: this.hideDetails
        });
        this.dispatchEvent(ev2);
    }

    handleOTP(event){
        this.recordValue = {...this.recordValue, Email_Account_OTP_QR_code_Final_Email__c : event.detail.value};
    }

    handleCheckBox(event) {
        let value = event.target.value;
        if (value === true) {
            this.hideDetails = true;
        } else {
            this.hideDetails = false;
        }
    }

    displayToastMessage(title, message, type) {
        const event = new ShowToastEvent({ title: title, message: message, variant: type });
        this.dispatchEvent(event);
    }
}