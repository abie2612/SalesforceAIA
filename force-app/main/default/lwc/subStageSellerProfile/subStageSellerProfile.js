import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import changeSubStage from '@salesforce/apex/OwnershipTransferController.changeSubStage';
import getOpp from '@salesforce/apex/OwnershipTransferController.getOpp';
import saveData from '@salesforce/apex/OwnershipTransferController.saveData';

export default class SubStageSellerProfile extends LightningElement {
    @api oppId;
    record = {};
    addressVerifyNameShow = '';
    allFilesData = [];
    isLoading = true;

    connectedCallback() {
        setTimeout(() => {
            getOpp({ recordId: this.oppId })
                .then(result => {
                    this.record = result;
                    if(this.record && this.record.Address_Verification_File_Name__c){
                        this.addressVerifyNameShow = this.record.Address_Verification_File_Name__c;
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
                            "filename": (file.fileNumber && file.fileNumber === 'file1' ? "Address Verification - " + file.filename : ''),
                            "recordId": this.oppId,
                            "file": file.fileNumber,
                            "subStage": "SellerProfile"
                        })
                            .then(result => {
                                console.log(file.fileNumber, ' Uploaded');
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

    handleAccessAccountProfile(event) {
        if (event.target.value) {
            this.record = { ...this.record, Access_Account_profile_information__c: true };
        } else {
            this.record = { ...this.record, Access_Account_profile_information__c: false, Change_Store_Name_Link_Marketplaces__c: false, Rename_Store_in_Global_Accounts__c: false, Change_Notifications_Email__c: false, Updated_Address_for_Returns__c: false, Updated_Address_of_Auto_Removals__c: false, Delete_all_Your_Info_and_Policies__c: false, Delete_all_FBM_Listings__c: false, Added_product__c: false, Changed_Business_Address__c: false, Address_Verification_Required__c:false };
            this.addressVerifyNameShow = '';
        }
    }

    handleUpdatedAddress(event) {
        if (event.target.value) {
            this.record = { ...this.record, Updated_Address_for_Returns__c: true };
        } else {
            this.record = { ...this.record, Updated_Address_for_Returns__c: false};
        }
    }
    
    handleAddressVerification(event) {
        if (event.target.value) {
            this.record = { ...this.record, Address_Verification_Required__c: true };
        } else {
            this.record = { ...this.record, Address_Verification_Required__c: false};
            this.addressVerifyNameShow = '';
        }
    }

    handleSSAddressVerify(event) {
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
            this.addressVerifyNameShow = file.name;
        };
        reader.readAsDataURL(file);
    }

    displayToastMessage(title, message, type) {
        const event = new ShowToastEvent({ title: title, message: message, variant: type });
        this.dispatchEvent(event);
    }
}