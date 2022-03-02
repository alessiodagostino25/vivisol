import { LightningElement, api, track } from 'lwc';

export default class ContractTreatmentConfiguration extends LightningElement {

    @api objectApiName = "Contract_Treatment__c";

    @api contractTreatmentRecordId;

    @track viewContractTreatment = true;
    @track viewPage3 = false;

    handleClickNext() {
        this.viewContractTreatment = false;
        this.viewPage3 = true;
        this.currentStep = 'step-2';
    }
}