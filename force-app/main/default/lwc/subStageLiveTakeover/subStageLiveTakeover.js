import { LightningElement, api } from 'lwc';
import changeSubStage from '@salesforce/apex/AssetTakeoverController.changeSubStage';
import getOpp from '@salesforce/apex/AssetTakeoverController.getOpp';
import getFieldHistory from '@salesforce/apex/AssetTakeoverController.getFieldHistory';
import uploadQRCodes from '@salesforce/apex/AssetTakeoverController.uploadQRCodes';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendDatatoOpp from '@salesforce/apex/AssetTakeoverController.sendDatatoOpp';
import staticImage from '@salesforce/resourceUrl/staticImageForStage';

export default class SubStageLiveTakeover extends LightningElement {
    @api oppId;
    @api existingEmail;
    @api existingRecord;
    emailAddress = '';
    emailPassword = '';
    record = {};
    oldEmailAddress = '';
    oldEmailPassword = '';
    oldEmailQRCode = '';
    oldAmazonPassword = '';
    oldAmazonQRCode = '';
    oldCallHippoNumber = '';
    showVendorScreenshare = false;
    showVPSScreen = false;
    buttonsUnderPaymentValue = '';
    balanceRadio = { 'no': true, 'yes': false };
    paymentRadio = { 'no': true, 'yes': false };
    showStatementBeginning = true;
    readOnlySpecialAccountType = false;
    existingEmailAccount = true;
    isLoading = true;

    objLiveTakeover = { Vendor_PC__c: false, Accessed_Email_Account__c: false, Email_Address_On_Live_Takeover__c: '', Former_Email_Recovery_Phone_Number__c: '', AIA_recovery_email_address_added__c: false, Recovery_phone_number_removed__c: false, Set_up_2SV_by_phone_and_created_QR_by_PC__c: false, Changed_Gmail_password__c: false, Temp_Gmail_Password__c: '', VPS1__c: false, Email_logged_into_on_new_VPS__c: false, Disconnected_other_devices_from_Gmail__c: false, Changed_Gmail_password_again_from_VPS__c: false, Email_Password__c: '', Email_Password_Takeover_2__c:'', Removed_temp_2SV_QR_and_Added_new_One__c: false, Email_QR_Code_Takeover_2__c:'', Vendor_PC_Screenshare1__c: false, Accessed_Amazon_Account__c: false, Removed_2SV_from_login_settings__c: false, Added_2SV_QR_code_Temp__c: false, Former_Amazon_Phone_Number__c:'', Removed_phone_number_from_2SV_settings__c: false, Changed_Login_Password__c: false, Amazon_Password__c: '', VPS2__c: false, Logged_into_the_Amazon_Account__c: false, Vendor_PC_Screenshare2__c: false, Statement_Beginning_Balance_Amount__c: '', Account_Type__c: '', Special_Account_Type__c: '', Date_of_Last_Sale__c: null, Added_a_listing_successfully__c: false, Checked_Account_Info_Page_no_alerts__c: false, Checked_Account_Health_Page_no_alerts__c: false, Checked_Performance_Notifications__c: false };

    connectedCallback() {
        this.getValues();
    }

    getValues() {
        setTimeout(() => {
            getOpp({ recordId: this.oppId })
                .then(result => {
                    this.record = result;
                    if (this.record.Email_QR_code__c && this.record.Email_QR_code__c !== null) {
                        if (this.record.Amazon_Password__c && this.record.Amazon_Password__c !== null) {
                            this.showVPSScreen = true;
                        }
                    }
                    if (this.record.Email_QR_Code_Takeover_2__c && this.record.Email_QR_Code_Takeover_2__c !== null) {
                        this.showVendorScreenshare = true;
                    }
                    if ((this.existingRecord && !this.existingRecord.Existing_Email_Address_Included__c) || (this.record && !this.record.Existing_Email_Address_Included__c) ) {
                        console.log('Test ', this.record.Existing_Email_Address_Included__c);
                        this.existingEmailAccount = false;
                        this.record.Vendor_PC__c = false;
                        this.showVendorScreenshare = true;
                        if (this.record.Amazon_Password__c && this.record.Amazon_Password__c !== null) {
                            this.showVPSScreen = true;
                        }
                        if(this.existingRecord){
                            this.record = { ...this.record, Temp_Gmail_Password__c: 'NA', Temp_Gmail_QR_code__c: '<p><img src=' + staticImage + '></img></p>', Email_Password__c: this.existingRecord.Email_Account_Password_Final__c, Email_Address_On_Live_Takeover__c: this.existingRecord.Email_Address_on_Email_Account__c, Email_QR_code__c: this.record.Email_Account_OTP_QR_code_Final_Email__c };
                        } else{
                            this.record = { ...this.record, Temp_Gmail_Password__c: 'NA', Temp_Gmail_QR_code__c: '<p><img src=' + staticImage + '></img></p>', Email_Password__c: this.record.Email_Account_Password_Final__c, Email_Address_On_Live_Takeover__c: this.record.Email_Address_on_Email_Account__c, Email_QR_code__c: this.record.Email_Account_OTP_QR_code_Final_Email__c };
                        }
                    }
                    if (this.record.Vendor_PC_Screenshare2__c) {
                        if (this.record.On_Payment_3_button_under_Fund_Available__c) {
                            this.paymentRadio = { 'no': false, 'yes': true };
                        }
                        if (this.record.On_Statement_beginning_balance_shows_0__c) {
                            this.balanceRadio = { 'no': false, 'yes': true };
                            this.showStatementBeginning = false;
                        }
                        else {
                            this.balanceRadio = { 'no': true, 'yes': false };
                            this.showStatementBeginning = true;
                        }
                        if (this.balanceRadio.no) {
                            this.showStatementBeginning = true;
                        }
                    }
                    this.onLoadingChangeAccountType();
                    this.isLoading = false;
                })
                .catch(err => {
                    console.log(JSON.stringify(err));
                    this.displayToastMessage("Error" + err, err, "error");
                    this.isLoading = false;
                });
            getFieldHistory({ recordId: this.oppId })
                .then(result => {
                    if (result.Email_Address_On_Live_Takeover__c) {
                        this.oldEmailAddress = result.Email_Address_On_Live_Takeover__c;
                    }
                    if (result.Email_Password__c) {
                        this.oldEmailPassword = result.Email_Password__c;
                    }
                    if (result.Amazon_Password__c) {
                        this.oldAmazonPassword = result.Amazon_Password__c;
                    }
                    if (result.CallHippo_phone_number__c) {
                        this.oldCallHippoNumber = result.CallHippo_phone_number__c;
                    }
                })
                .catch(err => {
                    this.displayToastMessage("Error", err, "error");
                });


        }, 1000)
    }

    onLoadingChangeAccountType() {
        if (this.record.Account_Type__c !== undefined && this.record.Account_Type__c === 'Standard') {
            this.record.Special_Account_Type__c = 'None';
            this.readOnlySpecialAccountType = true;
        } else {
            this.readOnlySpecialAccountType = false;
        }
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('lightning-input-field');
        inputFields.forEach(inputField => {
            if (!inputField.reportValidity()) {
                isValid = false;
            }
            if (inputField.fieldName === 'Statement_Beginning_Balance_Amount__c' && this.balanceRadio.no == true) {
                var test = 0;
                test = inputField.value;
                if (test == 0) {
                    isValid = false;
                }
            }
        });
        return isValid;
    }

    @api handleSave(SubStageToBeUpdate) {
        let isValid = this.isInputValid();
        let image1 = '';
        let image2 = '';
        let image3 = '';
        setTimeout(() => {
            if (isValid) {
                let inputFields = this.template.querySelectorAll('lightning-input-field');
                if (this.record.Vendor_PC__c) {
                    inputFields.forEach(inputField => {
                        if (inputField.fieldName === 'Temp_Gmail_QR_code__c') {
                            image1 = inputField.value;
                        }
                        if (inputField.fieldName === 'Email_QR_code__c') {
                            image2 = inputField.value;
                        }
                        if (inputField.fieldName === 'Temp_Amazon_2SV_QR_code__c') {
                            image3 = inputField.value;
                        }
                        if (this.objLiveTakeover.hasOwnProperty(inputField.fieldName)) {
                            this.objLiveTakeover[inputField.fieldName] = inputField.value;
                        }
                    });
                }else if(this.showVendorScreenshare){
                    inputFields.forEach(inputField => {
                        if (inputField.fieldName === 'Temp_Amazon_2SV_QR_code__c') {
                            image3 = inputField.value;
                        }
                        if (this.objLiveTakeover.hasOwnProperty(inputField.fieldName)) {
                            this.objLiveTakeover[inputField.fieldName] = inputField.value;
                        }
                    });
                }

                if(this.record.Amazon_Password__c && this.record.Amazon_Password__c.length > 0){
                    this.showVPSScreen = true;
                }

                if (this.record.Vendor_PC_Screenshare2__c) {
                    this.objLiveTakeover['On_Payment_3_button_under_Fund_Available__c'] = this.paymentRadio['yes'];
                    this.objLiveTakeover['On_Statement_beginning_balance_shows_0__c'] = this.balanceRadio['yes'];
                }

                if (!this.showStatementBeginning) {
                    this.objLiveTakeover.Statement_Beginning_Balance_Amount__c = 0;
                }

                sendDatatoOpp({
                    recordId: this.oppId, fieldValue: JSON.stringify(this.objLiveTakeover)
                })
                    .then(result => {
                        changeSubStage({ recordId: this.oppId, subStage: SubStageToBeUpdate, finalSave: true })
                            .then(result => {
                            })
                            .catch(err => {
                                this.displayToastMessage("Error", err, "error");
                            });
                    })
                    .catch(err => {
                        this.displayToastMessage("Error", err, "error");
                    });
                this.emailAddress = this.existingEmail ? this.template.querySelector('lightning-input-field[data-name="EmailAddress"]') ? this.template.querySelector('lightning-input-field[data-name="EmailAddress"]').value : '' : '';
                this.emailPassword = this.existingEmail ? this.template.querySelector('lightning-input-field[data-name="EmailPasswordFinal"]') ? this.template.querySelector('lightning-input-field[data-name="EmailPasswordFinal"]').value : '' : '';
                try {
                    uploadQRCodes({ email: this.emailAddress, password: this.emailPassword, existing: this.existingEmail, recordId: this.oppId, image1Data: image1, image2Data: image2, image3Data: image3 })
                        .then(result => {
                            this.displayToastMessage("Success", "All the details are filled successfully", "success");
                        })
                        .catch(err => {
                            this.displayToastMessage("Error", err, "error");
                        });
                }
                catch (error) {
                    reduceErrors(error).forEach(err => this.displayToastMessage("Error", err, "error"));
                }
                this.displayToastMessage("Success", "All the details are filled successfully", "success");
                this.closeModalAndRefresh(isValid);
            }
            else {
                if (this.template.querySelector('[data-id="nameCmp"]').value == 0) {
                    this.displayToastMessage("Error", 'Please check off "On statement beginning balance shows $0", OR Enter an amount larger than $0', "error");
                }
                if (this.template.querySelector('[data-id="nameCmp"]').value != 0) {
                    this.displayToastMessage("Error", 'Please fill required fields', "error");
                }
            }
        }, 50)
    }

    closeModalAndRefresh(isValid) {
        let ev = new CustomEvent('isvalidornot', {
            detail: isValid
        });
        this.dispatchEvent(ev);
    }

    handleVendorPC(event) {
        if (event.target.value) {
            this.record = { ...this.record, Vendor_PC__c: true };
            if(this.record.Amazon_Password__c && this.record.Amazon_Password__c.length > 0){
                this.showVPSScreen = true;
            }
        } else {
            this.record = { ...this.record, Vendor_PC__c: false, Accessed_Email_Account__c: false, Email_Address_On_Live_Takeover__c: '', Email_QR_code__c: '', AIA_recovery_email_address_added__c: false, Recovery_phone_number_removed__c: false, Set_up_2SV_by_phone_and_created_QR_by_PC__c: false, Temp_Gmail_QR_code__c: '', Changed_Gmail_password__c: false, Temp_Gmail_Password__c: '', VPS1__c: false, Disconnected_other_devices_from_Gmail__c: false, Email_logged_into_on_new_VPS__c: false, Changed_Gmail_password_again_from_VPS__c: false, Email_QR_Code_Takeover_2__c: '', Removed_temp_2SV_QR_and_Added_new_One__c: false, Email_Password__c: '', Email_QR_code__c: '', Temp_Amazon_2SV_QR_code__c: '', Vendor_PC_Screenshare1__c: false, Accessed_Amazon_Account__c: false, Removed_2SV_from_login_settings__c: false, Added_2SV_QR_code_Temp__c: false, Removed_phone_number_from_2SV_settings__c: false, Changed_Login_Password__c: false, Amazon_Password__c: '', VPS2__c: false, Logged_into_the_Amazon_Account__c: false, Vendor_PC_Screenshare2__c: false, Statement_Beginning_Balance_Amount__c: '', Account_Type__c: '', Special_Account_Type__c: '', Date_of_Last_Sale__c: null, Added_a_listing_successfully__c: false, Checked_Account_Info_Page_no_alerts__c: false, Checked_Account_Health_Page_no_alerts__c: false, Checked_Performance_Notifications__c: false };
            this.showVendorScreenshare = false;
            this.showVPSScreen = false;
        }
    }

    handleAccessedEmail(event) {
        if (event.target.value) {
            this.record = { ...this.record, Accessed_Email_Account__c: true, Email_Address_On_Live_Takeover__c: ''};
        } else {
            this.record = { ...this.record, Accessed_Email_Account__c: false, Email_Address_On_Live_Takeover__c: '' };
        }
    }

    handleVendorPCEmail(event) {
        this.record = { ...this.record, Email_Address_On_Live_Takeover__c: event.detail.value };
    }

    handleFormerEmail(event) {
        this.record = { ...this.record, Former_Email_Recovery_Phone_Number__c: event.detail.value };
    }

    handleTempQR(event) {
        if (event.target.value) {
            this.record = { ...this.record, Set_up_2SV_by_phone_and_created_QR_by_PC__c: true, Email_QR_code__c: '' };
        } else {
            this.record = { ...this.record, Set_up_2SV_by_phone_and_created_QR_by_PC__c: false, Email_QR_code__c: '' };
        }
    }

    firstGmailQRChange(event) {
        if (event.detail.value && event.detail.value.length > 0) {
            this.record = { ...this.record, Email_QR_code__c: event.detail.value };
        }

    }

    handlePasswordChange(event) {
        if (event.target.value) {
            this.record = { ...this.record, Changed_Gmail_password__c: true , Email_Password__c: ''};
        } else {
            this.record = { ...this.record, Changed_Gmail_password__c: false, Email_Password__c: '' };
        }
    }

    handleEmailPassword(event) {
        this.record = { ...this.record, Email_Password__c: event.detail.value };
    }

    handleVPSChange(event) {
        if (event.target.value) {
            this.record = { ...this.record, VPS1__c: true };
        } else {
            this.record = { ...this.record, VPS1__c: false, Disconnected_other_devices_from_Gmail__c: false, Email_logged_into_on_new_VPS__c: false, Changed_Gmail_password_again_from_VPS__c: false, Removed_temp_2SV_QR_and_Added_new_One__c: false, Email_Password__c: '', Email_QR_Code_Takeover_2__c: '', Temp_Amazon_2SV_QR_code__c: '', Vendor_PC_Screenshare1__c: false, Accessed_Amazon_Account__c: false, Removed_2SV_from_login_settings__c: false, Added_2SV_QR_code_Temp__c: false, Removed_phone_number_from_2SV_settings__c: false, Changed_Login_Password__c: false, Amazon_Password__c: '', VPS2__c: false, Logged_into_the_Amazon_Account__c: false, Vendor_PC_Screenshare2__c: false, Statement_Beginning_Balance_Amount__c: '', Account_Type__c: '', Special_Account_Type__c: '', Date_of_Last_Sale__c: null, Added_a_listing_successfully__c: false, Checked_Account_Info_Page_no_alerts__c: false, Checked_Account_Health_Page_no_alerts__c: false, Checked_Performance_Notifications__c: false };
            this.showVendorScreenshare = false;
            this.showVPSScreen = false;
            this.showStatementBeginning = false;
        }
    }

    handlePasswordChangeFinal(event) {
        if (event.target.value) {
            this.record = { ...this.record, Changed_Gmail_password_again_from_VPS__c: true };
        } else {
            this.record = { ...this.record, Changed_Gmail_password_again_from_VPS__c: false, Email_Password__c: '' };
        }
    }

    handleFinalQR(event) {
        if (event.target.value) {
            this.record = { ...this.record, Removed_temp_2SV_QR_and_Added_new_One__c: true };
            if (this.existingRecord && !this.existingRecord.Existing_Email_Address_Included__c && this.record.Email_QR_code__c.length > 0) {
                this.showVendorScreenshare = true;
            }
        } else {
            this.record = { ...this.record, Removed_temp_2SV_QR_and_Added_new_One__c: false, Email_QR_Code_Takeover_2__c: '', Temp_Amazon_2SV_QR_code__c: '', Vendor_PC_Screenshare1__c: false, Accessed_Amazon_Account__c: false, Removed_2SV_from_login_settings__c: false, Added_2SV_QR_code_Temp__c: false, Removed_phone_number_from_2SV_settings__c: false, Changed_Login_Password__c: false, Amazon_Password__c: '', VPS2__c: false, Logged_into_the_Amazon_Account__c: false, Vendor_PC_Screenshare2__c: false, Statement_Beginning_Balance_Amount__c: '', Account_Type__c: '', Special_Account_Type__c: '', Date_of_Last_Sale__c: null, Added_a_listing_successfully__c: false, Checked_Account_Info_Page_no_alerts__c: false, Checked_Account_Health_Page_no_alerts__c: false, Checked_Performance_Notifications__c: false };
            this.showVendorScreenshare = false;
            this.showVPSScreen = false;
        }
    }

    finalGmailQRChange(event) {
        if (event.detail.value && event.detail.value.length > 0) {
            this.showVendorScreenshare = true;
        } else {
            this.showVendorScreenshare = false;
            this.showVPSScreen = false;
            this.record = { ...this.record, Vendor_PC_Screenshare1__c: false, Accessed_Amazon_Account__c: false, Removed_2SV_from_login_settings__c: false, Added_2SV_QR_code_Temp__c: false, Removed_phone_number_from_2SV_settings__c: false, Changed_Login_Password__c: false, Amazon_Password__c: '', Temp_Amazon_2SV_QR_code__c: '', VPS2__c: false, Logged_into_the_Amazon_Account__c: false, Vendor_PC_Screenshare2__c: false, Statement_Beginning_Balance_Amount__c: '', Account_Type__c: '', Special_Account_Type__c: '', Date_of_Last_Sale__c: null, Added_a_listing_successfully__c: false, Checked_Account_Info_Page_no_alerts__c: false, Checked_Account_Health_Page_no_alerts__c: false, Checked_Performance_Notifications__c: false };
        }
        this.record = { ...this.record, Email_QR_Code_Takeover_2__c: event.detail.value };
    }

    handleVendorScreenshare(event) {
        if (event.target.value) {
            this.record = { ...this.record, Vendor_PC_Screenshare1__c: true};
        } else {
            this.record = { ...this.record, Vendor_PC_Screenshare1__c: false, Accessed_Amazon_Account__c: false, Removed_2SV_from_login_settings__c: false, Added_2SV_QR_code_Temp__c: false, Temp_Amazon_2SV_QR_code__c: '', Removed_phone_number_from_2SV_settings__c: false, Changed_Login_Password__c: false, Amazon_Password__c: '', VPS2__c: false, Logged_into_the_Amazon_Account__c: false, Vendor_PC_Screenshare2__c: false, Statement_Beginning_Balance_Amount__c: '', Account_Type__c: '', Special_Account_Type__c: '', Date_of_Last_Sale__c: null, Added_a_listing_successfully__c: false, Checked_Account_Info_Page_no_alerts__c: false, Checked_Account_Health_Page_no_alerts__c: false, Checked_Performance_Notifications__c: false };
            this.showVPSScreen = false;
        }
    }

    handleTempAmznQR(event) {
        if (event.target.value) {
            this.record = { ...this.record, Added_2SV_QR_code_Temp__c: true };
        } else {
            this.record = { ...this.record, Added_2SV_QR_code_Temp__c: false, Temp_Amazon_2SV_QR_code__c: '' };
        }
    }

    tempAmazonQRChange(event) {
        this.record = { ...this.record, Temp_Amazon_2SV_QR_code__c: event.detail.value };
    }

    handleFormerAmazon(event) {
        this.record = { ...this.record, Former_Amazon_Phone_Number__c: event.detail.value };
    }

    handleChangeAmznPass(event) {
        if (event.target.value) {
            this.record = { ...this.record, Changed_Login_Password__c: true };
        } else {
            this.record = { ...this.record, Changed_Login_Password__c: false, Amazon_Password__c: '', VPS2__c: false, Logged_into_the_Amazon_Account__c: false, Vendor_PC_Screenshare2__c: false, Statement_Beginning_Balance_Amount__c: '', Account_Type__c: '', Special_Account_Type__c: '', Date_of_Last_Sale__c: null, Added_a_listing_successfully__c: false, Checked_Account_Info_Page_no_alerts__c: false, Checked_Account_Health_Page_no_alerts__c: false, Checked_Performance_Notifications__c: false };
            this.showVPSScreen = false;
        }
    }

    handleFinalAmznPass(event) {
        if (event.detail.value && event.detail.value.length > 0) {
            this.showVPSScreen = true;
        } else {
            this.showVPSScreen = false;
            this.record = { ...this.record, VPS2__c: false, Logged_into_the_Amazon_Account__c: false, Vendor_PC_Screenshare2__c: false, Statement_Beginning_Balance_Amount__c: '', Account_Type__c: '', Special_Account_Type__c: '', Date_of_Last_Sale__c: null, Added_a_listing_successfully__c: false, Checked_Account_Info_Page_no_alerts__c: false, Checked_Account_Health_Page_no_alerts__c: false, Checked_Performance_Notifications__c: false };
        }
        this.record = { ...this.record, Amazon_Password__c: event.detail.value };
    }

    handleVPS2Change(event) {
        if (event.target.value) {
            this.record = { ...this.record, VPS2__c: true, };
        } else {
            this.record = { ...this.record, VPS2__c: false, Logged_into_the_Amazon_Account__c: false, Vendor_PC_Screenshare2__c: false, Statement_Beginning_Balance_Amount__c: '', Account_Type__c: '', Special_Account_Type__c: '', Date_of_Last_Sale__c: null, Added_a_listing_successfully__c: false, Checked_Account_Info_Page_no_alerts__c: false, Checked_Account_Health_Page_no_alerts__c: false, Checked_Performance_Notifications__c: false };
        }
    }

    handleLoggedIn(event) {
        if (event.target.value) {
            this.record = { ...this.record, Logged_into_the_Amazon_Account__c: true, };
        } else {
            this.record = { ...this.record, Logged_into_the_Amazon_Account__c: false, Vendor_PC_Screenshare2__c: false, Statement_Beginning_Balance_Amount__c: '', Account_Type__c: '', Special_Account_Type__c: '', Date_of_Last_Sale__c: null, Added_a_listing_successfully__c: false, Checked_Account_Info_Page_no_alerts__c: false, Checked_Account_Health_Page_no_alerts__c: false, Checked_Performance_Notifications__c: false };
        }
    }

    handleVendorPC2(event) {
        if (event.target.value) {
            this.record = { ...this.record, Vendor_PC_Screenshare2__c: true };
            if (this.balanceRadio.no) {
                this.showStatementBeginning = true;
            }
        } else {
            this.record = { ...this.record, Vendor_PC_Screenshare2__c: false, Statement_Beginning_Balance_Amount__c: '', Account_Type__c: '', Special_Account_Type__c: '', Date_of_Last_Sale__c: null, Added_a_listing_successfully__c: false, Checked_Account_Info_Page_no_alerts__c: false, Checked_Account_Health_Page_no_alerts__c: false, Checked_Performance_Notifications__c: false };
            this.balanceRadio = { 'no': true, 'yes': false };
            this.paymentRadio = { 'no': true, 'yes': false };
        }
    }

    get getPaymentRadioOptions() {
        return [
            { label: 'Yes', value: 'paymentYes', checked: this.paymentRadio.yes },
            { label: 'No', value: 'paymentNo', checked: this.paymentRadio.no },
        ];
    }

    get getBalanceRadioOptions() {
        return [
            { label: 'Yes', value: 'balanceYes', checked: this.balanceRadio.yes },
            { label: 'No', value: 'balanceNo', checked: this.balanceRadio.no },
        ];
    }

    changeAccountType() {
        if (this.template.querySelector('[data-id="accType"]').value == 'Standard') {
            this.template.querySelector('[data-id="specialAccType"]').value = 'None';
            this.readOnlySpecialAccountType = true;
        } else {
            this.readOnlySpecialAccountType = false;
        }
    }

    changeRadioOptions(event) {
        switch (event.target.value) {
            case 'paymentYes':
                this.paymentRadio = { 'yes': true, 'no': false };
                break;
            case 'paymentNo':
                this.paymentRadio = { 'yes': false, 'no': true };
                break;
            case 'balanceYes':
                this.balanceRadio = { 'yes': true, 'no': false };
                this.showStatementBeginning = false;
                break;
            case 'balanceNo':
                this.balanceRadio = { 'yes': false, 'no': true };
                this.showStatementBeginning = true;
                break;
            default:
                break;
        }
    }

    displayToastMessage(title, message, type) {
        const event = new ShowToastEvent({ title: title, message: message, variant: type });
        this.dispatchEvent(event);
    }
}