import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import changeSubStage from '@salesforce/apex/OwnershipTransferController.changeSubStage';
import getOpp from '@salesforce/apex/OwnershipTransferController.getOpp';
import saveData from '@salesforce/apex/OwnershipTransferController.saveData';
import getRelatedFilesByRecordId from '@salesforce/apex/OwnershipTransferController.getRelatedFilesByRecordId'

export default class SubStageTaxAndLegal extends LightningElement {
    @api oppId;
    taxInfoNameShow = '';
    showBusinessAndConInfo = false;
    record = {};
    allFilesData = [];
    isLoading = true;
    einFile = null;
    idFile = null;

    @wire(getRelatedFilesByRecordId, {recordId: '$oppId'})
    wiredResult({data, error}){ 
        if(data){             
            Object.keys(data).forEach(item => {
                const fileName = data[item];
                const fileUrl = `/sfc/servlet.shepherd/document/download/${item}`;
                
                if (fileName.includes('EIN Document')) {
                    this.einFile = { label: fileName, value: item, url: fileUrl };
                } else if (fileName.includes('ID Document')) {
                    this.idFile = { label: fileName, value: item, url: fileUrl };
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
                    if (this.record && this.record.Legal_Entity_Contains__c && this.record.Legal_Entity_Contains__c === 'Business Information and Primary Contact Information') {
                        this.showBusinessAndConInfo = true;
                    }
                    if (this.record && this.record.Tax_Information_Screenshot_File_Name__c) {
                        this.taxInfoNameShow = this.record.Tax_Information_Screenshot_File_Name__c;
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
        if(!this.taxInfoNameShow || this.taxInfoNameShow.length === 0){
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
                            "filename": (file.fileNumber && file.fileNumber === 'file1' ? "Tax Information - " + file.filename :''),
                            "recordId": this.oppId,
                            "file": file.fileNumber,
                            "subStage": "TaxAndLegal"
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

    handleTaxInformation(event) {
        if (event.target.value) {
            this.record = { ...this.record, Change_Tax_Information__c: true };
        } else {
            this.record = { ...this.record, Change_Tax_Information__c: false, Legal_Entity_Contains__c: '', Primary_Contact_Verification__c: false, Business_Primary_Contact_Verification__c: false };
        }
    }

    handleLegalEntity(event) {
        if (event.target.value) {
            this.record = { ...this.record, Legal_Entity_Contains__c: event.target.value };
            if (event.target.value === 'Business Information and Primary Contact Information') {
                this.showBusinessAndConInfo = true;
            } else {
                this.showBusinessAndConInfo = false;
            }
        } else {
            this.showBusinessAndConInfo = false;
        }
    }

    handleChangeLegalEntity(event) {
        if (event.target.value) {
            this.record = { ...this.record, Change_Legal_Entity_Information__c: true };
        } else {
            this.record = { ...this.record, Change_Legal_Entity_Information__c: false };
        }
    }
    
    uploadTaxInfoSS(event) {
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
            this.taxInfoNameShow = file.name;
        };
        reader.readAsDataURL(file);
    }

    displayToastMessage(title, message, type) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: type
        });
        this.dispatchEvent(event);
    }
}