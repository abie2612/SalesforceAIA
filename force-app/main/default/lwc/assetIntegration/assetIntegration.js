import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadScreenShot from '@salesforce/apex/AssetIntegrationController.uploadScreenShot';
import getOpp from '@salesforce/apex/AssetIntegrationController.getOpp';
import getFieldHistory from '@salesforce/apex/AssetTakeoverController.getFieldHistory';
import sendingSubStage from '@salesforce/apex/AssetIntegrationController.sendingSubStage';
import sendDatatoOpp from '@salesforce/apex/AssetIntegrationController.sendDatatoOpp';
import accountType from '@salesforce/apex/AssetIntegrationController.accountTypeMethod';
import saveData from '@salesforce/apex/AssetIntegrationController.saveData';

export default class AssetIntegration extends LightningElement {

  steps = [{
    label: 'Asset Integration',
    value: 'step-1'
  },
  {
    label: 'Account Type Analysis',
    value: 'step-2'
  }
  ];

  objAssertIntegration = { VPS3__c: false, Accessed_Amazon_Account_1__c: false, Put_account_into_vacation_mode__c: false, Added_2SV_QR_code_Final__c: false, Changed_phone_number_in_login_settings__c: false, Added_AIA_as_a_user_in_Amazon_Account__c: false, Remove_existing_users_from_permissions__c: false, Disabled_Third_party_developer_and_apps__c: false, Changed_charge_method_to_Mercury_cc__c: false, Took_Screenshot_of_updated_charge_method__c: false, Changed_All_Notification_Email_addresses__c: false, Changed_Contact_Info_email_phone__c: false, Paused_all_active_ad_campaigns__c: false, Comment__c: '', Noted_performance_notifications__c: false, Took_screenshot_of_Acc_Health_Dashboard__c: false, Existing_account_health_violations__c: false, Accessed_Buyer_Account__c: false, Removed_all_subscriptions__c: false, Returned_to_Seller_Account__c: false, Asset_purchased_with_Pesticide_approval__c: false, AIA_has_opened_Pesticide_category__c: false }

  @api recordId;
  @api objectApiName;

  record = {};
  fileData = {};
  fileData1 = {};
  fileData2 = {};
  fileData3 = {};
  txn1FileData = {};
  txn2FileData = {};
  salesFileData = {};
  allFilesData = [];
  txn1NameShow = '';
  txn2NameShow = '';
  salesReportNameShow = '';
  currentStep = 'step-1';
  isStepOne = true
  isStepTwo = false
  nextDisabled = false
  previousDisabled = false
  screenShotBoolean = false;
  earliestAccountStatementDateBoolean = false;
  checkImages = false
  checkSubStage = true
  checkEarliestAccStatementDate = false
  checkSecondStage = false
  checkNext = false
  isLoading = true;
  imageUploadCheck = false;
  checkSaveandNext = false;
  imageLink1Check = false;
  imageLink2Check = false;
  imageLink3Check = false;
  imageLink4Check = false;
  amznQrFileNameShow = '';
  chargeFileNameShow = '';
  accFileNameShow = '';
  existingViolationFileNameShow = '';
  oldCallHippoNumber = '';
  //showAccountPayment = false;
  nextClicked = false;
  latestOrdersFileData = {};
  latestOrderFileName = '';

  connectedCallback() {
    this.setPreviousButton();
    this.getRecords(false);
    if (!this.imageLink4Check) {
      this.isLoading = false;
    }
  }

  getRecords(manual) {
    setTimeout(() => {
      getOpp({
        recordId: this.recordId
      })
        .then(result => {
          this.record = result;
          this.imageUpdateApextoLWC(this.record.Amazon_QR_Code__c, this.record.Charge_Methods_screenshot__c, this.record.Account_Health_Dashboard_Screenshot__c, this.record.Comment__c)
          if (this.record.Amazon_QR_Code__c) {
            if (this.record.AmznQRFileNameFinal__c != null) {
              this.amznQrFileNameShow = this.record.AmznQRFileNameFinal__c;
            }
          }
          if (this.record.Charge_Methods_screenshot__c) {
            if (this.record.ChargeFileName__c != null) {
              this.chargeFileNameShow = this.record.ChargeFileName__c;
            }
          }
          if (this.record.Account_Health_Dashboard_Screenshot__c) {
            if (this.record.AccFileName__c != null) {
              this.accFileNameShow = this.record.AccFileName__c;
            }
          }
          if (this.record.CommentFileName__c != null && !this.imageLink4Check) {
            this.existingViolationFileNameShow = this.record.CommentFileName__c;
          }
          if (this.record.Txn_1_year_file_name__c) {
            this.txn1NameShow = this.record.Txn_1_year_file_name__c;
          }
          if (this.record.Txn_2_year_file_name__c) {
            this.txn2NameShow = this.record.Txn_2_year_file_name__c;
          }
          if (this.record.Sales_report_file_name__c) {
            this.salesReportNameShow = this.record.Sales_report_file_name__c;
          }
          if (this.record.Latest_Orders_File_Name__c) {
            this.latestOrderFileName = this.record.Latest_Orders_File_Name__c;
          }
          if (!manual) {
            this.setSubStage(this.record.Sub_Stage__c);
          }
        })
        .catch(err => {
          this.displayToastMessage("Error", err, "error");

        });
      getFieldHistory({ recordId: this.recordId })
        .then(result => {
          if (result.CallHippo_phone_number__c) {
            this.oldCallHippoNumber = result.CallHippo_phone_number__c;
          }
        })
        .catch(err => {
          this.displayToastMessage("Error", err, "error");
        });
    }, 50)
  }

  doNotDisplayToast = false;
  @api handleSave(saveButton) {
    let image1 = '';
    let found = this.steps.findIndex(({
      value
    }) => value === this.currentStep);
    let stage = this.steps[found].label;
    let step = this.steps[found].value;
    if (step == this.steps[this.steps.length - 1].value) {
      this.checkSecondStage = true;
    }

    let isValid = this.isInputValid();
    if (isValid) {
      if ((step === this.steps[0].value) || ((step === this.steps[1].value) && this.checkSaveandNext)) {
        let inputFields = this.template.querySelectorAll('lightning-input-field');
        inputFields.forEach(inputField => {
          if (inputField.fieldName === 'Amazon_QR_Code__c') {
            image1 = inputField.value;
          }
          if (this.objAssertIntegration.hasOwnProperty(inputField.fieldName)) {
            this.objAssertIntegration[inputField.fieldName] = inputField.value;
          }
        });
        this.sendFieldRecordtoApex(this.objAssertIntegration, saveButton, this.checkSaveandNext);
        this.checkSaveandNext = false;
      } else {
        this.template.querySelector('lightning-record-edit-form').submit();
        if (this.allFilesData.length > 0) {
          this.doNotDisplayToast = true;
          this.displayToastMessage("Info", "Your files are uploading this may take some time Please wait", "info")
          this.isLoading = true;
          this.allFilesData.every((file, idx) => {
            if (file != (null || undefined) && file.base64 != (null || undefined) && file.base64.length > 0 && file.filename.length > 0) {
              saveData({
                "fileBase64": file.base64,
                "filename": (file.fileNumber && file.fileNumber === 'file1' ? "Transaction Summary 1 Year - " + file.filename : (file.fileNumber && file.fileNumber === 'file2' ? "Transaction Summary 2 Year - " + file.filename : (file.fileNumber && file.fileNumber === 'file3' ? 'Sales report - ' + file.filename : (file.fileNumber && file.fileNumber === 'file4' ? 'Latest Orders - ' + file.filename : '')))),
                "recordId": this.recordId,
                "file": file.fileNumber
              })
                .then(result => {
                  if (idx === this.allFilesData.length - 1) {
                    this.doNotDisplayToast = false;
                    this.isLoading = false;
                    this.updateAccountType();
                    this.displayToastMessage("Success", "Records are saved successfully", "success");
                    setTimeout(() => {
                      let ev = new CustomEvent('isvalidornot', {
                        detail: {
                          curStep: this.currentStep,
                          allSteps: this.steps,
                          validCheck: isValid,
                        }
                      });
                      this.dispatchEvent(ev);
                    }, 500);
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
              curStep: this.currentStep,
              allSteps: this.steps,
              validCheck: isValid,
            }
          });
          this.dispatchEvent(ev);
        }
        this.updateAccountType();
        this.displayToastMessage("Success", "Records are saved successfully", "success");
      }

      if ((this.imageLink1Check || this.imageLink2Check || this.imageLink3Check || this.imageLink4Check) && (this.isStepOne || this.nextClicked)) {
        this.uploadFile(image1);
      }
      if (this.imageUploadCheck || !this.record.VPS3__c) {
        this.displayToastMessage("Success", "Records are saved successfully", "success")
      }
      if (this.checkSubStage) {
        this.assignSubStage(stage);
      }
    } else {
      this.displayToastMessage("Error", "Fill the required fields", "error")
    }
    this.nextClicked = false;
    if (((step === this.steps[0].value) || ((step === this.steps[1].value) && this.checkSaveandNext)) && !this.imageLink4Check) {
      let ev = new CustomEvent('isvalidornot', {
        detail: {
          curStep: this.currentStep,
          allSteps: this.steps,
          validCheck: isValid,
        }
      });
      this.dispatchEvent(ev);
    }
  }

  imageUpdateApextoLWC(amazonQRcodefinalImageURL, chargeMethodScreenshotImageURL, accountHealthDashboardScreenshotImageURL, commentImageURL) {
    if (chargeMethodScreenshotImageURL != undefined) {
      this.screenShotBoolean = true;
    }
    if (this.record.Changed_phone_number_in_login_settings__c == false) {
      this.record = {
        ...this.record,
        Changed_phone_number_in_login_settings__c: false,
        Added_AIA_as_a_user_in_Amazon_Account__c: false,
        Remove_existing_users_from_permissions__c: false,
        Disabled_Third_party_developer_and_apps__c: false,
        Changed_charge_method_to_Mercury_cc__c: false,
        Took_Screenshot_of_updated_charge_method__c: false,
        Changed_All_Notification_Email_addresses__c: false,
        Changed_Contact_Info_email_phone__c: false,
        Paused_all_active_ad_campaigns__c: false,
        Noted_performance_notifications__c: false,
        Took_screenshot_of_Acc_Health_Dashboard__c: false,
        Existing_account_health_violations__c: false,
        Accessed_Buyer_Account__c: false,
        Removed_all_subscriptions__c: false,
        Returned_to_Seller_Account__c: false,
        Asset_purchased_with_Pesticide_approval__c: false,
        AIA_has_opened_Pesticide_category__c: false
      };
      this.fileData2 = {};
      this.fileData3 = {};
      this.checkSecondStage = false;
      this.imageUploadCheck = false;
    }
    if ((amazonQRcodefinalImageURL != undefined && chargeMethodScreenshotImageURL != undefined && this.record.Paused_all_active_ad_campaigns__c == false)) {
      this.imageUploadCheck = true;
      this.checkSecondStage = true;
    } else if ((amazonQRcodefinalImageURL != undefined && chargeMethodScreenshotImageURL != undefined && accountHealthDashboardScreenshotImageURL != undefined) && (this.record.Paused_all_active_ad_campaigns__c == true)) {
      this.imageUploadCheck = true;
      this.checkSecondStage = true;
    }
  }

  setSubStage(subStage) {
    let found = 0
    if (subStage != null && subStage != undefined && subStage.length != 0) {
      this.steps.forEach(step => {

        if (step.label == subStage) {
          this.currentStep = step.value
          if (this.currentStep == this.steps[found].value) {
            let ev = new CustomEvent('isvalidornot', {
              detail: {
                curStep: this.currentStep,
                allSteps: this.steps
              }
            });
            this.dispatchEvent(ev);

            if (found > 0) {
              this.setNextButton()
              this.isStepTwo = true;
              this.isStepOne = false;
              if (this.record.Earliest_account_statement_date__c != null && this.record.Earliest_account_statement_date__c != undefined && this.record.Earliest_account_statement_date__c.length != 0) {
                this.checkEarliestAccStatementDate = true;
              }
              this.pdf1 = true;
              this.pdf2 = true;
              this.xls = true;
            } else if (found == 0) {
              this.setPreviousButton()
              this.isStepTwo = false;
              this.isStepOne = true;
              if (this.record.Earliest_account_statement_date__c != null && this.record.Earliest_account_statement_date__c != undefined && this.record.Earliest_account_statement_date__c.length != 0) {
                this.checkEarliestAccStatementDate = true;
              }
            }
          }
        }
        found++
      });
    }
  }

  pdf1 = false;
  pdf2 = false;
  xls = false;

  txn1YearUpload(event) {
    const file = event.target.files[0];
    const reader = new FileReader();
    if (file.name.substring(file.name.lastIndexOf('.') + 1) === 'pdf') {
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
        this.txn1NameShow = file.name;
      };
      reader.readAsDataURL(file);
      this.pdf1 = true;
    } else {
      this.displayToastMessage("Error", "Please upload pdf file only", "error")
    }

  }

  txn2YearUpload(event) {
    const file = event.target.files[0];
    const reader = new FileReader();

    if (file.name.substring(file.name.lastIndexOf('.') + 1) === 'pdf') {
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
        this.txn2NameShow = file.name;
      };
      reader.readAsDataURL(file);
      this.pdf2 = true;
    } else {
      this.displayToastMessage("Error", "Please upload pdf file only", "error")
    }

  }

  salesReportUpload(event) {
    const file = event.target.files[0];
    const reader = new FileReader();

    if (file.name.substring(file.name.lastIndexOf('.') + 1) === 'xls' || file.name.substring(file.name.lastIndexOf('.') + 1) === 'xlsx') {
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
        this.salesReportNameShow = file.name;
      };
      reader.readAsDataURL(file);
      this.xls = true;
    } else {
      this.displayToastMessage("Error", "Please upload xls file only", "error")
    }

  }

  latestOrdersFile(event) {
    const file = event.target.files[0];
    const reader = new FileReader();
    reader.onload = () => {
      const base64 = reader.result.split(",")[1];
      let indexofFile4 = this.allFilesData.findIndex(x => x.fileNumber === 'file4');
      if (indexofFile4 !== -1) {
        this.allFilesData[indexofFile4] = {
          filename: file.name,
          base64: base64,
          fileNumber: 'file4'
        };
      } else {
        this.allFilesData.push({
          filename: file.name,
          base64: base64,
          fileNumber: 'file4'
        });
      }
      this.latestOrderFileName = file.name;
    };
    reader.readAsDataURL(file);
  }

  handleVPSCheck(event) {
    if (event.target.value) {
      this.record = {
        ...this.record,
        VPS3__c: true
      };
    } else {
      this.record = {
        ...this.record,
        VPS3__c: false,
        Accessed_Amazon_Account_1__c: false,
        Put_account_into_vacation_mode__c: false,
        Added_2SV_QR_code_Final__c: false,
        Amazon_QR_Code__c: '',
        Changed_phone_number_in_login_settings__c: false,
        Added_AIA_as_a_user_in_Amazon_Account__c: false,
        Remove_existing_users_from_permissions__c: false,
        Disabled_Third_party_developer_and_apps__c: false,
        Changed_charge_method_to_Mercury_cc__c: false,
        Took_Screenshot_of_updated_charge_method__c: false,
        Changed_All_Notification_Email_addresses__c: false,
        Changed_Contact_Info_email_phone__c: false,
        Paused_all_active_ad_campaigns__c: false,
        Noted_performance_notifications__c: false,
        Took_screenshot_of_Acc_Health_Dashboard__c: false,
        Existing_account_health_violations__c: false,
        Accessed_Buyer_Account__c: false,
        Removed_all_subscriptions__c: false,
        Returned_to_Seller_Account__c: false,
        Asset_purchased_with_Pesticide_approval__c: false,
        AIA_has_opened_Pesticide_category__c: false
      };
      this.fileData = {};
      this.amznQrFileNameShow = '';
      this.fileData1 = {};
      this.chargeFileNameShow = '';
      this.fileData2 = {};
      this.accFileNameShow = '';
      this.fileData3 = {};
      this.existingViolationFileNameShow = '';
      this.imageLink1Check = true;
      this.imageLink2Check = true;
      this.imageLink3Check = true;
      this.imageLink4Check = true;
      this.screenShotBoolean = false;
      this.checkSecondStage = false;
      this.imageUploadCheck = false;
    }
  }

  handleAddedQRCodeFinal(event) {
    if (event.target.value) {
      this.record = {
        ...this.record,
        Added_2SV_QR_code_Final__c: true
      };
      this.fileData = {};
      this.amznQrFileNameShow = '';
    } else {
      this.record = {
        ...this.record,
        Added_2SV_QR_code_Final__c: false, Amazon_QR_Code__c: ''
      };
      this.fileData = {};
      this.amznQrFileNameShow = '';
      this.checkSecondStage = false;
      this.imageUploadCheck = false;
    }
  }

  finalAmazonQRChange(event) {
    this.record = { ...this.record, Amazon_QR_Code__c: event.detail.value };
    this.imageLink1Check = true;
  }

  handleScreenShotofAccountHealthDashboard(event) {
    if (event.target.value) {
      this.record = {
        ...this.record,
        Took_screenshot_of_Acc_Health_Dashboard__c: true
      };
    } else {
      this.record = {
        ...this.record,
        Took_screenshot_of_Acc_Health_Dashboard__c: false,
        Account_Health_Dashboard_Screenshot__c: ''
      };
      this.fileData3 = {};
      this.existingViolationFileNameShow = '';
      this.imageLink4Check = true;
      this.checkSecondStage = false;
      this.imageUploadCheck = false;
    }
  }

  handleExistingAccountHealth(event) {
    if (event.target.value) {
      this.record = {
        ...this.record,
        Existing_account_health_violations__c: true
      };
    } else {
      this.record = {
        ...this.record,
        Existing_account_health_violations__c: false,
        Comment__c: ''
      };
    }
  }

  handleAmazonQRCode(event) {
    const file = event.target.files[0];
    const reader = new FileReader();
    reader.onload = () => {
      const base64 = reader.result.split(",")[1];
      this.fileData = {
        amznqrfilename: file.name,
        firstBase64: base64
      };
      this.amznQrFileNameShow = file.name;
    };
    reader.readAsDataURL(file);
    this.record.Amazon_QR_Code__c = 'Show';
    this.imageUploadCheck = false;
    this.checkSecondStage = true;
    this.imageLink1Check = true;
  }


  handlePhoneNumberLogin(event) {
    if (event.target.value) {
      this.record = {
        ...this.record,
        Changed_phone_number_in_login_settings__c: true
      };
    } else {
      this.record = {
        ...this.record,
        Changed_phone_number_in_login_settings__c: false,
        Added_AIA_as_a_user_in_Amazon_Account__c: false,
        Remove_existing_users_from_permissions__c: false,
        Disabled_Third_party_developer_and_apps__c: false,
        Changed_charge_method_to_Mercury_cc__c: false,
        Took_Screenshot_of_updated_charge_method__c: false,
        Changed_All_Notification_Email_addresses__c: false,
        Changed_Contact_Info_email_phone__c: false,
        Paused_all_active_ad_campaigns__c: false,
        Noted_performance_notifications__c: false,
        Took_screenshot_of_Acc_Health_Dashboard__c: false,
        Existing_account_health_violations__c: false,
        Accessed_Buyer_Account__c: false,
        Removed_all_subscriptions__c: false,
        Returned_to_Seller_Account__c: false,
        Asset_purchased_with_Pesticide_approval__c: false,
        AIA_has_opened_Pesticide_category__c: false
      };
      this.fileData1 = {};
      this.chargeFileNameShow = '';
      this.fileData2 = {};
      this.accFileNameShow = '';
      this.fileData3 = {};
      this.existingViolationFileNameShow = '';
      this.imageLink2Check = true;
      this.imageLink3Check = true;
      this.imageLink4Check = true;
      this.screenShotBoolean = false;
      this.checkSecondStage = false;
      this.imageUploadCheck = false;
    }
  }

  handleScreenShotUpdation(event) {
    if (event.target.value) {
      this.record = {
        ...this.record,
        Took_Screenshot_of_updated_charge_method__c: true
      };
    } else {
      this.record = {
        ...this.record,
        Took_Screenshot_of_updated_charge_method__c: false,
        Changed_All_Notification_Email_addresses__c: false,
        Changed_Contact_Info_email_phone__c: false,
        Paused_all_active_ad_campaigns__c: false,
        Noted_performance_notifications__c: false,
        Took_screenshot_of_Acc_Health_Dashboard__c: false,
        Existing_account_health_violations__c: false,
        Accessed_Buyer_Account__c: false,
        Removed_all_subscriptions__c: false,
        Returned_to_Seller_Account__c: false,
        Asset_purchased_with_Pesticide_approval__c: false,
        AIA_has_opened_Pesticide_category__c: false,
        Charge_Methods_screenshot__c: ''
      };
      this.fileData1 = {};
      this.chargeFileNameShow = '';
      this.fileData2 = {};
      this.accFileNameShow = '';
      this.fileData3 = {};
      this.existingViolationFileNameShow = '';
      this.imageLink2Check = true;
      this.imageLink3Check = true;
      this.imageLink4Check = true;
      this.screenShotBoolean = false;
      this.checkSecondStage = false;
      this.imageUploadCheck = false;
    }
  }

  openfileUpload1(event) {
    const file = event.target.files[0];
    const reader = new FileReader();
    this.screenShotBoolean = true;
    reader.onload = () => {
      const base64 = reader.result.split(",")[1];
      this.fileData1 = {
        chargefilename: file.name,
        secondBase64: base64
      };
      this.chargeFileNameShow = file.name;
    };
    this.record.Charge_Methods_screenshot__c = 'Show';
    reader.readAsDataURL(file);
    this.imageUploadCheck = false;
    this.checkSecondStage = true;
    this.imageLink2Check = true;
  }
  handlePausedActiveAdCampaigns(event) {
    if (event.target.value) {
      this.record = {
        ...this.record,
        Paused_all_active_ad_campaigns__c: true
      };
      this.checkSecondStage = false;
    } else {
      this.record = {
        ...this.record,
        Paused_all_active_ad_campaigns__c: false,
        Noted_performance_notifications__c: false,
        Took_screenshot_of_Acc_Health_Dashboard__c: false,
        Existing_account_health_violations__c: false,
        Accessed_Buyer_Account__c: false,
        Removed_all_subscriptions__c: false,
        Returned_to_Seller_Account__c: false,
        Asset_purchased_with_Pesticide_approval__c: false,
        AIA_has_opened_Pesticide_category__c: false
      };
      this.fileData2 = {};
      this.accFileNameShow = '';
      this.imageLink3Check = true;
      this.checkSecondStage = true;
      this.imageUploadCheck = false;
    }
  }

  accountHealthDashboardScreenShot(event) {
    const file = event.target.files[0];
    const reader = new FileReader();
    reader.onload = () => {
      const base64 = reader.result.split(",")[1];
      this.fileData2 = {
        accfilename: file.name,
        thirdBase64: base64
      };
      this.accFileNameShow = file.name;
    };
    reader.readAsDataURL(file);
    this.record.Account_Health_Dashboard_Screenshot__c = 'Show';
    this.imageUploadCheck = false;
    this.checkSecondStage = true;
    this.imageLink3Check = true;
  }


  handleUploadExistingViolation(event) {
    const file = event.target.files[0];
    const reader = new FileReader();
    reader.onload = () => {
      const base64 = reader.result.split(",")[1];
      this.fileData3 = {
        existingViolationFileName: file.name,
        fourthBase64: base64
      };
      this.existingViolationFileNameShow = file.name;
    };
    reader.readAsDataURL(file);
    this.imageUploadCheck = false;
    this.imageLink4Check = true;
  }

  async uploadFile(image1) {
    try {
      const firstBase64 = image1;
      const {
        secondBase64,
        chargefilename
      } = this.fileData1;
      const {
        thirdBase64,
        accfilename
      } = this.fileData2;
      const {
        fourthBase64,
        existingViolationFileName
      } = this.fileData3;
      this.isLoading = true;
      this.displayToastMessage("Info", "Don't refresh the page until loader is running", "info")
      await uploadScreenShot({
        firstBase64: firstBase64,
        secondBase64: secondBase64,
        thirdBase64: thirdBase64,
        fourthBase64: fourthBase64,
        recordId: this.recordId,
        imageLink1Check: this.imageLink1Check,
        imageLink2Check: this.imageLink2Check,
        imageLink3Check: this.imageLink3Check,
        imageLink4Check: this.imageLink4Check,
        filename1: this.amznQrFileNameShow,
        filename2: this.chargeFileNameShow,
        filename3: this.accFileNameShow,
        filename4: this.existingViolationFileNameShow,
        pausedAllActiveAdCampaigns: this.record.Paused_all_active_ad_campaigns__c
      })
        .then(result => {
          if (this.imageLink4Check) {
            saveData({
              "fileBase64": this.fileData3.fourthBase64,
              "filename": "Existing Violation - " + this.existingViolationFileNameShow,
              "recordId": this.recordId,
              "file": ""
            })
              .then(result => {
                this.isLoading = false;
                this.imageLink4Check = false;
                let ev = new CustomEvent('isvalidornot', {
                  detail: {
                    curStep: this.currentStep,
                    allSteps: this.steps,
                    validCheck: true,
                  }
                });
                this.dispatchEvent(ev);
                this.displayToastMessage("Success", "Records are saved successfully", "success");
              })
              .catch(error => {
                console.log('Error in Health Violation File Upload', error);
                this.isLoading = false;
                this.displayToastMessage("Error", "Error occurred while uploading existing violation(s) File", "error")
              });
          } else {
            this.displayToastMessage("Success", "Records are saved successfully", "success");
            this.isLoading = false;
          }
        })
        .catch(err => {
          this.displayToastMessage("Error", 'Size of images are larger', "error");
          this.currentStep = this.steps[0].value;
          let ev = new CustomEvent('isvalidornot', {
            detail: {
              curStep: this.currentStep,
              allSteps: this.steps
            }
          });
          this.dispatchEvent(ev);
          this.isStepTwo = false;
          this.isStepOne = true;
          this.isLoading = false;
        });

    } catch (error) {
      reduceErrors(error).forEach(err => this.displayToastMessage("Error", err, "error"));
    }
  }

  displayToastMessage(title, message, type) {
    if ((title === 'Success' && this.doNotDisplayToast === false) || title === 'Error' || title === 'Info') {
      const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: type
      });
      this.dispatchEvent(event);
    }
  }

  handleAssetPesticideApproval(event) {
    if (event.target.value) {
      this.record = {
        ...this.record,
        Asset_purchased_with_Pesticide_approval__c: true
      };
    } else {
      this.record = {
        ...this.record,
        Asset_purchased_with_Pesticide_approval__c: false
      };
    }
    this.record.Asset_purchased_with_Pesticide_approval__c = event.target.value;
  }

  // handleStatement(event) {
  //   if (event.target.value) {
  //     this.record = { ...this.record, On_Statement_beginning_balance_shows_0__c: true }
  //     this.showAccountPayment = true;
  //   } else {
  //     this.record = { ...this.record, On_Statement_beginning_balance_shows_0__c: false }
  //     if (this.record.On_Payment_3_button_under_Fund_Available__c === false) {
  //       this.record = { ...this.record, Account_payment_schedule__c: '' }
  //       this.showAccountPayment = false;
  //     }
  //   }
  // }

  // handlePaymentButton(event) {
  //   if (event.target.value) {
  //     this.record = { ...this.record, On_Payment_3_button_under_Fund_Available__c: true }
  //     this.showAccountPayment = true;
  //   } else {
  //     this.record = { ...this.record, On_Payment_3_button_under_Fund_Available__c: false }
  //     if (this.record.On_Statement_beginning_balance_shows_0__c === false) {
  //       this.record = { ...this.record, Account_payment_schedule__c: '' }
  //       this.showAccountPayment = false;
  //     }
  //   }
  // }

  handleEarliestAccStatementDate(event) {
    if (event.target.value) {
      this.checkEarliestAccStatementDate = true
      this.record = {
        ...this.record,
        Earliest_account_statement_date__c: event.target.value
      };
    } else {
      this.checkEarliestAccStatementDate = false
      this.record = {
        ...this.record,
        Earliest_account_statement_date__c: '',
        Add_ASINs_to_check_brands_or_categories__c: false,
        Check_for_HAZMAT_storage__c: false,
        Retrieved_sales_history_data__c: false,
        Sales_History_Year_to_Date__c: '',
        Sales_History_2_Years_to_Date__c: '',
        Sales_History_All_Time__c: '',
        Units_Sold_Year_to_Date__c: '',
        Unit_Sold_2_Years_to_Date__c: '',
        Overall_Units_Sold__c: '',
        IPI__c: '',
        Fulfillment__c: '',
        Recent_Sales_Within_3_months__c: '',
        Prime_Memebership_Expiration__c: '',
        Brand_Registry__c: '',
        Gift_card_balance__c: '',
        INFORM_Verifications_passed__c: '',
        INFORM_Verification_passed_date__c: '',
        Tax_Info_complete__c: '',
        Listings_Status__c: '',
        Health_Assurance_Score__c: '',
        Positive_Feedback_USA__c: '', Amazon_Login_Email_Address__c: '', Bank_Account_Number_last_three_digits__c: '', Legal_Entity_Address__c: '', Bank_Account_name__c: '', Legal_Entity_Name__c: '', Bank_Account_Address__c: '', Legal_Entity_Owner_Status__c: '', Bank_Account_Marketplaces__c: '', Legal_Entity_Street__c: '', Card_Name__c: '', Legal_Entity_City__c: '', Credit_Card_last_four_digits__c: '', Legal_Entity_Country__c: '', Credit_Card_Street__c: '', Legal_Entity_State_Province__c: '', Credit_Card_City__c: '', Legal_Entity_Zip_Postal_Code__c: '', Credit_Card_State_Province__c: '', Contact_person_first_name__c: '', Credit_Card_Zip_Postal_Code__c: '', Contact_person_middle_name_opt__c: '', Credit_Card_Country__c: '', Contact_person_last_name__c: '', Credit_Card_Address__c: '', Phone_Number__c: '', Creation_Date__c: '', Marketplace__c: '', Additional_Marketplaces__c: '', US_Citizen_Owner__c: '', Amazon_Account_Type__c: '', Subscription_Plan__c: '', Account_Type__c: '', Owner_Status__c: '', Merchant_Token__c: '', Special_Account_Type__c: '', Date_of_Last_Sale__c: ''
      };
      this.txn1NameShow = '';
      this.txn2NameShow = '';
      this.salesReportNameShow = '';
      this.txn1FileData = {};
      this.txn2FileData = {};
      this.salesFileData = {};
      this.latestOrdersFileData = {};
      this.latestOrderFileName = '';
    }
  }

  @api handleNext() {

    this.nextClicked = true;

    let isValid = this.isInputValid();
    if (isValid == false) {
      this.displayToastMessage("Error", "Fill the required fields", "error")
    }
    let found = this.steps.findIndex(({
      value
    }) => value === this.currentStep);
    found++;
    let stage = this.steps[found].label;
    if (isValid) {
      this.pdf1 = true;
      this.pdf2 = true;
      this.xls = true;
      if (this.currentStep == this.steps[0].value) {
        this.setNextButton()
        this.assignSubStage(stage)
        this.checkSubStage = false
        if (this.record.Earliest_account_statement_date__c != null && this.record.Earliest_account_statement_date__c != undefined && this.record.Earliest_account_statement_date__c.length != 0) {
          this.checkEarliestAccStatementDate = true;
        } else {
          this.checkEarliestAccStatementDate = false;
          this.txn1NameShow = '';
          this.txn2NameShow = '';
          this.salesReportNameShow = '';
        }
      }
      this.currentStep = this.steps[found].value;
      let ev = new CustomEvent('isvalidornot', {
        detail: {
          curStep: this.currentStep,
          allSteps: this.steps
        }
      });
      this.dispatchEvent(ev);
      this.isStepTwo = true;
      this.isStepOne = false;
      this.checkSaveandNext = true;
      this.handleSave();
    }
  }

  assignSubStage(firstStage) {
    sendingSubStage({
      firstStage: firstStage,
      recordId: this.recordId
    })
      .then(result => {
      })
      .catch(err => {
        this.displayToastMessage("Error", err, "error");
      });
  }

  setNextButton() {
    this.nextDisabled = true;
    this.previousDisabled = false;
  }

  @api handlePrevious(event) {
    this.pdf1 = false;
    this.pdf2 = false;
    this.xls = false;
    let found = this.steps.length - 1;
    this.checkSubStage = true;

    if (this.currentStep == this.steps[found].value) {
      this.setPreviousButton();
    }
    found--
    this.currentStep = this.steps[found].value;
    this.isStepTwo = false;
    this.isStepOne = true;

    setTimeout(() => {
      getOpp({
        recordId: this.recordId
      })
        .then(result => {
          this.record = result;
          this.isLoading = false;
          this.imageUpdateApextoLWC(this.record.Amazon_QR_Code__c, this.record.Charge_Methods_screenshot__c, this.record.Account_Health_Dashboard_Screenshot__c, this.record.Comment__c)
        })
        .catch(err => {
          this.displayToastMessage("Error", err, "error");

        });
    }, 50)

    let ev = new CustomEvent('isvalidornot', {
      detail: {
        curStep: this.currentStep,
        allSteps: this.steps
      }
    });
    this.dispatchEvent(ev);
  }

  setPreviousButton() {
    this.previousDisabled = true;
    this.nextDisabled = false;
  }

  isInputValid() {
    let isValid = true;
    let inputFields = this.template.querySelectorAll('lightning-input-field');
    inputFields.forEach(inputField => {
      if (!inputField.reportValidity()) {
        isValid = false;
      }
    });

    if (this.checkSecondStage == false || this.isStepOne) {
      if (this.record.Took_Screenshot_of_updated_charge_method__c) {
        if ((Object.keys(this.fileData1).length === 0 && this.fileData1.constructor === Object) && (this.record.Charge_Methods_screenshot__c === undefined || this.record.Charge_Methods_screenshot__c.length === 0)) {
          this.checkImages = true;
          isValid = false;
        }
      }
      if (this.record.Paused_all_active_ad_campaigns__c) {
        if ((Object.keys(this.fileData2).length === 0 && this.fileData2.constructor === Object) && (this.record.Account_Health_Dashboard_Screenshot__c === undefined || this.record.Account_Health_Dashboard_Screenshot__c.length === 0)) {
          this.checkImages = true;
          isValid = false;
        }
      }
    } else if (this.nextClicked === false && (this.pdf1 === true || this.pdf2 === true || this.xls === true)) {
      if ((Object.keys(this.txn1FileData).length === 0 && this.txn1FileData.constructor === Object) && this.txn1NameShow.length === 0) {
        isValid = false;
      }
      if ((Object.keys(this.txn2FileData).length === 0 && this.txn2FileData.constructor === Object) && this.txn2NameShow.length === 0) {
        isValid = false;
      }
      if ((Object.keys(this.salesFileData).length === 0 && this.salesFileData.constructor === Object) && this.salesReportNameShow.length === 0) {
        isValid = false;
      }
    }

    return isValid;
  }

  sendFieldRecordtoApex(booleanFieldValue, saveButton, saveAndNextChecked) {
    sendDatatoOpp({
      recordId: this.recordId, booleanFieldValue: JSON.stringify(booleanFieldValue)
    })
      .then(result => {
        if (this.record.VPS3__c) {
          this.getRecords(true);
        }
        if (!saveAndNextChecked) {
          this.currentStep = this.steps[0].value;
          let ev = new CustomEvent('savevalue', {
            detail: {
              isSaveButton: saveButton
            }
          });
          this.dispatchEvent(ev);
        }

      })
      .catch(err => {
        this.displayToastMessage("Error", err, "error");
      });
  }

  updateAccountType() {
    accountType({
      recordId: this.recordId, assetIntegrate: true
    })
      .then(result => {

      })
      .catch(err => {
        this.displayToastMessage("Error", err, "error");
      });
  }
}