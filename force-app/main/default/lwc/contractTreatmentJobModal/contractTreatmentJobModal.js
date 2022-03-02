/* eslint-disable no-alert */
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ContractTreatmentJobModal extends LightningElement {

    @api currentStep;
    @api objectApiName = "Contract_Treatment_Job__c";
    @api contractFrameworkRecordId;
    @api contractTreatmentRecordId;
    @api contractTreatmentJobRecordId;
    @api contractTreatmentJobRecordIdList = [];

    @track contractTreatmentJob;

    @track contractTreatmentJobModal = true;
    @track viewPage3;

    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: "Contract Treatment Job created",
            //message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        this.dispatchEvent(evt);
        this.contractTreatmentJobRecordId = event.detail.id;
        this.contractTreatmentJobRecordIdList.add(this.contractTreatmentJobRecordId);
        this.closeModal();
    }

    closeModal() {
        this.contractTreatmentJobModal = false
        this.viewPage3 = true
        this.currentStep = 'step-2';
    } 

    saveMethod() {
        alert('save method invoked');
        this.closeModal();
    }
}