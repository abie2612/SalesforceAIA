import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import changeSubStage from '@salesforce/apex/OwnershipTransferController.changeSubStage';
import getOpp from '@salesforce/apex/OwnershipTransferController.getOpp';
import saveData from '@salesforce/apex/OwnershipTransferController.saveData';

export default class SubStageBuyerProfile extends LightningElement {
    @api oppId;
    record = {};
    isLoading = true;
    existingAddressNameShow = '';
    allFilesData = [];

    connectedCallback() {
        setTimeout(() => {
            getOpp({ recordId: this.oppId })
                .then(result => {
                    this.record = result;
                    if(this.record && this.record.All_Existing_Addresses_File_Name__c){
                        this.existingAddressNameShow = this.record.All_Existing_Addresses_File_Name__c;
                    }
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
        console.log(this.record.Access_Buyer_Account__c, this.existingAddressNameShow);
        if(this.record.Access_Buyer_Account__c && (!this.existingAddressNameShow || this.existingAddressNameShow.length === 0)){
            isValid = false;
        }
        return isValid;
    }

    @api handleSave(SubStageToBeUpdate) {
        let isValid = this.isInputValid();
        if (isValid) {
            this.template.querySelector('lightning-record-edit-form').submit();
            changeSubStage({ recordId: this.oppId, subStage: SubStageToBeUpdate, finalSave: false });
            if (this.allFilesData.length > 0) {
                this.displayToastMessage("Info", "Your files are uploading this may take some time Please wait", "info");
                this.isLoading = true;
                this.allFilesData.every((file, idx) => {
                    if (file != (null || undefined) && file.base64 != (null || undefined) && file.base64.length > 0 && file.filename.length > 0) {
                        saveData({
                            "fileBase64": file.base64,
                            "filename": (file.fileNumber && file.fileNumber === 'file1' ? "All Existing Addresses - " + file.filename : ''),
                            "recordId": this.oppId,
                            "file": file.fileNumber,
                            "subStage": "BuyerProfile"
                        })
                            .then(result => {
                                if (idx === this.allFilesData.length - 1) {
                                    this.displayToastMessage("Success", "All the details are filled successfully", "success");
                                    this.isLoading = false;
                                    let ev = new CustomEvent('isvalidornot', {
                                        detail: {
                                            curStep: SubStageToBeUpdate,
                                            validCheck: isValid,
                                        }

                                    });
                                    this.dispatchEvent(ev);
                                }
                            })
                            .catch(error => {
                                console.log(file.fileNumber, ' : ', error);
                                this.isLoading = false;
                                this.displayToastMessage("Error", `Error occurred while uploading ${file.fileName}`, "error");
                                return false;
                            });
                    }
                    return true;
                })
            } else {
                this.displayToastMessage("Success", "All the details are filled successfully", "success");
                let ev = new CustomEvent('isvalidornot', {
                    detail: {
                        curStep: SubStageToBeUpdate,
                        validCheck: isValid,
                    }
                });
                this.dispatchEvent(ev);
            }
        } else {
            this.displayToastMessage("Error", 'Please fill required fields', "error");
            let ev = new CustomEvent('isvalidornot', {
                detail: {
                    curStep: SubStageToBeUpdate,
                    validCheck: isValid,
                }
            });
            this.dispatchEvent(ev);
        }
    }

    handleAccessBuyerAccount(event) {
        if (event.target.value) {
            this.record = { ...this.record, Access_Buyer_Account__c: true };
        } else {
            this.record = { ...this.record, Access_Buyer_Account__c: false, Close_Business_Account__c: false, Change_Login_Name__c: false, Change_Account_Profile_Name__c: false, Remove_Other_Profiles__c: false, Deleted_all_other_Deposit_Methods__c: false, Deleted_All_other_Charge_Methods__c: false, Deleted_All_other_Addresses__c: false };
        }
    }

    screenshotExistingAddress(event) {
        const file = event.target.files[0];
        const reader = new FileReader();
        reader.onload = () => {
            const base64 = reader.result.split(",")[1];
            let indexofFile1 = this.allFilesData.findIndex(x => x.fileNumber === 'file1');
            if (indexofFile1 !== -1) {
                this.allFilesData[indexofFile1] = {
                    filename: file.name,
                    base64: base64,
                    fileNumber: 'file1'
                };
            } else {
                this.allFilesData.push({
                    filename: file.name,
                    base64: base64,
                    fileNumber: 'file1'
                });
            }
            this.existingAddressNameShow = file.name;
        };
        reader.readAsDataURL(file);
    }

    displayToastMessage(title, message, type) {
        const event = new ShowToastEvent({ title: title, message: message, variant: type });
        this.dispatchEvent(event);
    }
}