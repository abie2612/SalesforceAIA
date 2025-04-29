import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import changeSubStage from '@salesforce/apex/OwnershipTransferController.changeSubStage';
import getOpp from '@salesforce/apex/OwnershipTransferController.getOpp';
import saveData from '@salesforce/apex/OwnershipTransferController.saveData';

export default class SubStageChargeMethod extends LightningElement {
    @api oppId;
    record = {};
    chargeMethodsNameShow = '';
    chargeMethodsNewNameShow = '';
    allFilesData = [];
    isLoading = true;
    existFile1 = false;
    existFile2 = false;

    connectedCallback() {
        setTimeout(() => {
            getOpp({ recordId: this.oppId })
                .then(result => {
                    this.record = result;
                    if (this.record && this.record.Charge_Methods_Page_File_Name__c) {
                        this.chargeMethodsNameShow = this.record.Charge_Methods_Page_File_Name__c;
                        this.existFile1 = true;
                    }
                    if (this.record && this.record.Charge_Methods_Page_New_File_Name__c) {
                        this.chargeMethodsNewNameShow = this.record.Charge_Methods_Page_New_File_Name__c;
                        this.existFile2 = true;
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
        if (isValid && this.existFile1) {
            if (this.record.Access_Manage_Charge_Methods_Page__c && !this.existFile2) {
                isValid = false;
            } else {
                isValid = true;
            }
        } else {
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
                this.isLoading = true;
                this.displayToastMessage("Info", "Your files are uploading this may take some time Please wait", "info");
                this.allFilesData.every((file, idx) => {
                    if (file != (null || undefined) && file.base64 != (null || undefined) && file.base64.length > 0 && file.filename.length > 0) {
                        saveData({
                            "fileBase64": file.base64,
                            "filename": (file.fileNumber && file.fileNumber === 'file1' ? "Charge Methods Page Old - " + file.filename : (file.fileNumber && file.fileNumber === 'file2' ? "Charge Methods Page New - " + file.filename : file.filename)),
                            "recordId": this.oppId,
                            "file": file.fileNumber,
                            "subStage": "ChargeMethod"
                        })
                            .then(result => {
                                if (idx === this.allFilesData.length - 1) {
                                    this.displayToastMessage("Success", "All the details are filled successfully", "success");
                                    let ev = new CustomEvent('isvalidornot', {
                                        detail: {
                                            curStep: SubStageToBeUpdate,
                                            validCheck: isValid,
                                        }
                                    });
                                    this.dispatchEvent(ev);
                                    this.isLoading = false;
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
        }
        this.dispatchEvent(ev);
    }

    handleAccessChargeMethods(event) {
        if (event.target.value) {
            this.record = { ...this.record, Access_Charge_Methods__c: true };
        } else {
            this.record = { ...this.record, Access_Charge_Methods__c: false, Current_Charge_Method_Name__c: '', Current_Charge_Method_Address__c: '', Current_Charge_Method_Last_3_Digits__c: '', Current_Charge_Method_Marketplaces__c: '', Access_Manage_Charge_Methods_Page__c: false, Add_New_Charge_Method__c: false, Charge_Methods_Page_File_Name__c: '', Charge_Methods_Page_New_File_Name__c: '' };
            this.chargeMethodsNameShow = '';
            this.chargeMethodsNewNameShow = '';
            this.existFile1 = false;
            this.existFile2 = false;
        }
    }

    handleSSChargeMethods(event) {
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
            this.chargeMethodsNameShow = file.name;
            this.existFile1 = true;
        };
        reader.readAsDataURL(file);
    }

    handleAccessManageCharge(event) {
        if (event.target.value) {
            this.record = { ...this.record, Access_Manage_Charge_Methods_Page__c: true };
        } else {
            this.record = { ...this.record, Access_Manage_Charge_Methods_Page__c: false, Add_New_Charge_Method__c: false, Charge_Methods_Page_New_File_Name__c: '' };
            this.chargeMethodsNewNameShow = '';
            this.existFile2 = false;
        }
    }

    handleSSChargeMethodsNew(event) {
        const file = event.target.files[0];
        const reader = new FileReader();
        reader.onload = () => {
            const base64 = reader.result.split(",")[1];
            let indexofFile2 = this.allFilesData.findIndex(x => x.fileNumber === 'file2');
            if (indexofFile2 !== -1) {
                this.allFilesData[indexofFile2] = {
                    filename: file.name,
                    base64: base64,
                    fileNumber: 'file2'
                };
            } else {
                this.allFilesData.push({
                    filename: file.name,
                    base64: base64,
                    fileNumber: 'file2'
                });
            }
            this.chargeMethodsNewNameShow = file.name;
            this.existFile2 = true;
        };
        reader.readAsDataURL(file);
    }

    displayToastMessage(title, message, type) {
        const event = new ShowToastEvent({ title: title, message: message, variant: type });
        this.dispatchEvent(event);
    }
}