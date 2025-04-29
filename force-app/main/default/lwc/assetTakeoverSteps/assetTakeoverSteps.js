import { LightningElement, api } from 'lwc';
export default class AssetTakeoverSteps extends LightningElement {

    @api currentStepName;
    @api steps;
    @api opportunityId;
    isValid = false;
    isVPS = false;
    isCallHippo = false;
    isMercuryCC = false;
    isEmailAccount = false;
    isLiveTakeover = false;
    hideDetails = false;
    record;

    connectedCallback() {
        this.checkCurrentStep();
    }

    checkCurrentStep() {
        this.isVPS = false;
        this.isCallHippo = false;
        this.isMercuryCC = false;
        this.isEmailAccount = false;
        this.isLiveTakeover = false;
        if (this.currentStepName === 'VPS') {
            this.isVPS = true;
        } else if (this.currentStepName === 'CallHippo Number') {
            this.isCallHippo = true;
        } else if (this.currentStepName === 'Mercury Credit Card') {
            this.isMercuryCC = true;
        } else if (this.currentStepName === 'Email account on Amazon') {
            this.isEmailAccount = true;
        } else if (this.currentStepName === 'Live Takeover') {
            this.isLiveTakeover = true;
        }
        let ev = new CustomEvent('changestep', {
            detail: this.currentStepName
        });
        this.dispatchEvent(ev);
    }

    @api handleNext(event) {
        const subStagecomponent = this.checkCurrentComponent();
        let found = this.steps.findIndex(({ Name }) => Name === this.currentStepName);
        found++;
        this.template.querySelector(this.subStagecomponent).handleSave(this.steps[found].Name);
        
        if(this.isValid){
            this.currentStepName = this.steps[found].Name;
            this.checkCurrentStep();
        }else{
            console.log('Please fill required fields');
        }
        
    }

    @api handleSave(event) {
        const subStagecomponent = this.checkCurrentComponent();
        setTimeout(() => {
            this.template.querySelector(this.subStagecomponent).handleSave(this.currentStepName);
        }, 50)
    }

    @api handlePrevious(event) {
        let found = this.steps.findIndex(({ Name }) => Name === this.currentStepName);
        found--;
        this.currentStepName = this.steps[found].Name;
        this.checkCurrentStep();
    }

    @api handlePathClick(event) {
        this.currentStepName = this.steps[event.detail.index].Name;
        this.checkCurrentStep();
    }

    isValidOrNot(event){
        this.isValid = event.detail;
        let ev = new CustomEvent('isvalidornot', {
            detail: this.isValid
        });
        this.dispatchEvent(ev);
    }

    handleCheckbox(event){
        this.hideDetails = event.detail;
    }

    handleGetRecord(event){
        this.record = event.detail;
    }

    checkCurrentComponent() {
        let subStagecomponent = '';
        if (this.isVPS) {
            this.subStagecomponent = "c-sub-stage-v-p-s";
        } else if (this.isCallHippo) {
            this.subStagecomponent = "c-sub-stage-call-hippo";
        } else if (this.isMercuryCC) {
            this.subStagecomponent = "c-sub-stage-mercury-c-c";
        } else if (this.isEmailAccount) {
            this.subStagecomponent = "c-sub-stage-email-account";
        } else if (this.isLiveTakeover) {
            this.subStagecomponent = "c-sub-stage-live-takeover";
        }
        return this.subStagecomponent;
    }
}