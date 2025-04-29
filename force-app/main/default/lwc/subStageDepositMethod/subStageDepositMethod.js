import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import changeSubStage from '@salesforce/apex/OwnershipTransferController.changeSubStage';
import getOpp from '@salesforce/apex/OwnershipTransferController.getOpp';
import saveData from '@salesforce/apex/OwnershipTransferController.saveData';
import getRelatedFilesByRecordId from '@salesforce/apex/OwnershipTransferController.getRelatedFilesByRecordId'

export default class SubStageDepositMethod extends LightningElement {
    @api oppId;
    record = {};
    manageDepositNameShow = '';
    manageNewDepositNameShow = '';
    allFilesData = [];
    isLoading = true;
    file3Exist = false;
    bankStatementFile = null;

    @wire(getRelatedFilesByRecordId, {recordId: '$oppId'})
    wiredResult({data, error}){ 
        if(data){ 
                Object.keys(data).forEach(item => {
                const fileName = data[item];
                const fileUrl = `/sfc/servlet.shepherd/document/download/${item}`;
                
                if (fileName.includes('Bank Statement')) {
                    this.bankStatementFile = { label: fileName, value: item, url: fileUrl };
                }
            });
        } else if (error) {
            console.error(JSON.stringify(error));
        }
    }

    connectedCallback() {
        setTimeout(() => {
            getOpp({ recordId: this.oppId })
                .then(result => {
                    this.record = result;
                    if(this.record && this.record.Manage_Deposit_Methods_Old__c){
                        this.manageDepositNameShow = this.record.Manage_Deposit_Methods_Old__c;
                    }
                    if(this.record && this.record.Manage_Deposit_Methods_New_File_Name__c){
                        this.manageNewDepositNameShow =  this.record.Manage_Deposit_Methods_New_File_Name__c;
                        this.file3Exist = true;
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
        if(this.record.Add_New_Deposit_Method__c && !this.file3Exist){
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
                            "filename": (file.fileNumber && file.fileNumber === 'file1' ? "Manage Deposit Methods - " + file.filename : (file.fileNumber && file.fileNumber === 'file3' ? 'Manage Deposit Methods New - ' + file.filename : '')),
                            "recordId": this.oppId,
                            "file": file.fileNumber,
                            "subStage": "DepositMethod"
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

    handleAccessDeposit(event) {
        if (event.target.value) {
            this.record = { ...this.record, Access_Deposit_Methods__c: true };
        } else {
            this.record = { ...this.record, Access_Deposit_Methods__c: false, Current_Deposit_Method_Name__c: '', Current_Deposit_Method_Address__c: '', Current_Deposit_Method_Last_3_Digits__c: '', Current_Deposit_Method_Marketplaces__c: '', Access_Manage_Deposit_Methods_Page__c: false, Add_New_Deposit_Method__c: false, Bank_Verification_Required__c: '', Previous_Bank_Accounts_Deleted__c: false, Access_Account_profile_information__c: false };
            this.manageDepositNameShow = '';
            this.manageNewDepositNameShow = '';
            this.file3Exist = false;
        }
    }

    screenshotManageDeposit(event) {
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
            this.manageDepositNameShow = file.name;
        };
        reader.readAsDataURL(file);
    }

    handleAddNewDeposit(event) {
        if (event.target.value) {
            this.record = { ...this.record, Add_New_Deposit_Method__c: true };
        } else {
            this.record = { ...this.record, Add_New_Deposit_Method__c: false, Bank_Verification_Required__c: '', Previous_Bank_Accounts_Deleted__c: false, Access_Account_profile_information__c: false };
            this.manageNewDepositNameShow = '';
            this.file3Exist = false;
        }
    }

    screenshotManageDepositNew(event) {
        const file = event.target.files[0];
        const reader = new FileReader();
        reader.onload = () => {
            const base64 = reader.result.split(",")[1];
            let indexofFile3 = this.allFilesData.findIndex(x => x.fileNumber === 'file3');
            if (indexofFile3 !== -1) {
                this.allFilesData[indexofFile3] = {
                    filename: file.name,
                    base64: base64,
                    fileNumber: 'file3'
                };
            } else {
                this.allFilesData.push({
                    filename: file.name,
                    base64: base64,
                    fileNumber: 'file3'
                });
            }
            this.manageNewDepositNameShow = file.name;
            this.file3Exist = true;
        };
        reader.readAsDataURL(file);
    }

    displayToastMessage(title, message, type) {
        const event = new ShowToastEvent({ title: title, message: message, variant: type });
        this.dispatchEvent(event);
    }
}