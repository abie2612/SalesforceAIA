import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import changeSubStage from '@salesforce/apex/OwnershipTransferController.changeSubStage';
import getOpp from '@salesforce/apex/OwnershipTransferController.getOpp';

export default class SubStageAmazonCredentials extends LightningElement {
    @api oppId;
    record = {};
    isLoading = true;

    connectedCallback() {
        setTimeout(() => {
            getOpp({ recordId: this.oppId })
                .then(result => {
                    this.record = result;
                    this.isLoading = false;
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
            this.isLoading = true;
            this.template.querySelector('lightning-record-edit-form').submit();
            changeSubStage({ recordId: this.oppId, subStage: SubStageToBeUpdate, finalSave: false });
            this.isLoading = false;
            this.displayToastMessage("Success", "All the details are filled successfully", "success");
        } else {
            this.displayToastMessage("Error", 'Please fill required fields', "error");
        }

        let ev = new CustomEvent('isvalidornot', {
            detail: {
                curStep: SubStageToBeUpdate,
                validCheck: isValid,
            }
        });
        this.dispatchEvent(ev);
    }

    handleAccessSellerAccount(event) {
        if (event.target.value) {
            this.record = { ...this.record, Access_Seller_Account__c: true };
        } else {
            this.record = { ...this.record, Access_Seller_Account__c: false, Check_for_New_Addresses_only__c: false, Check_for_New_Credit_Card_only__c: false, Logout_and_in_of_Amazon_to_check_PW_QR__c: false};
        }
    }

    displayToastMessage(title, message, type) {
        const event = new ShowToastEvent({ title: title, message: message, variant: type });
        this.dispatchEvent(event);
    }
}