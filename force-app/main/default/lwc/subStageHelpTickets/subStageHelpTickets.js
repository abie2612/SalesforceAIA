import { LightningElement, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import changeSubStage from '@salesforce/apex/OwnershipTransferController.changeSubStage';
import getOpp from '@salesforce/apex/OwnershipTransferController.getOpp';

export default class SubStageHelpTickets extends LightningElement {
    @api oppId;
    record = {};

    connectedCallback() {
        setTimeout(() => {
            getOpp({ recordId: this.oppId })
                .then(result => {
                    this.record = result;
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
            this.template.querySelector('lightning-record-edit-form').submit();
            changeSubStage({ recordId: this.oppId, subStage: SubStageToBeUpdate, finalSave : false });
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

    handleAccessedAmazon(event) {
        if (event.target.value) {
            this.record = { ...this.record, Accessed_Amazon_Account__c: true};
        } else {
            this.record = { ...this.record, Accessed_Amazon_Account__c: false, Open_Help_ticket_1__c: false, Received_Amazon_s_response__c: false, Reply_to_Help_ticket_1__c: false, Open_Help_ticket_2__c:false};
        }
    }

    handleOpenTicketHelp(event) {
        if (event.target.value) {
            this.record = { ...this.record, Open_Help_ticket_1__c: true};
        } else {
            this.record = { ...this.record, Open_Help_ticket_1__c: false, Received_Amazon_s_response__c: false, Reply_to_Help_ticket_1__c: false, Open_Help_ticket_2__c:false};
        }
    }

    handleReceivedAmazon(event) {
        if (event.target.value) {
            this.record = { ...this.record, Received_Amazon_s_response__c: true};
        } else {
            this.record = { ...this.record, Received_Amazon_s_response__c: false, Reply_to_Help_ticket_1__c: false, Open_Help_ticket_2__c:false};
        }
    }

    handleReplyToHelp1(event) {
        if (event.target.value) {
            this.record = { ...this.record, Reply_to_Help_ticket_1__c: true};
        } else {
            this.record = { ...this.record, Reply_to_Help_ticket_1__c: false, Open_Help_ticket_2__c:false};
        }
    }

    displayToastMessage(title, message, type) {
        const event = new ShowToastEvent({ title: title, message: message, variant: type });
        this.dispatchEvent(event);
    }

}