import { LightningElement, api } from 'lwc';
import changeSubStage from '@salesforce/apex/AssetTakeoverController.changeSubStage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SubStageCallHippo extends LightningElement {
    @api oppId;

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
            this.template.querySelector('lightning-record-edit-form').submit();
            this.displayToastMessage("Success", "All the details are filled successfully", "success");
            changeSubStage({ recordId: this.oppId, subStage: SubStageToBeUpdate, finalSave : false });
        } else{
            this.displayToastMessage("Error", 'Please fill required fields', "error");
        }
        let ev = new CustomEvent('isvalidornot', {
            detail: isValid
        });
        this.dispatchEvent(ev);
    }

    displayToastMessage(title, message, type) {
        const event = new ShowToastEvent({ title: title, message: message, variant: type });
        this.dispatchEvent(event);
    }
}