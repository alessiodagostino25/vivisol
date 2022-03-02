/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-console */
import { LightningElement, wire, api, track } from 'lwc';
import getContractTreatmentJobSla from '@salesforce/apex/ContractTreatmentJobSlaController.getContractTreatmentJobSla';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import SlaTitle from '@salesforce/label/c.CT_JobConfiguration_SlaConfigTitle';
import NewSla from '@salesforce/label/c.CT_JobConfiguration_BtnNewSla';
import AddSla from '@salesforce/label/c.CT_JobConfiguration_BtnAddSla';
import WODetails from '@salesforce/label/c.Generic_WODetails';
import TaskDetails from '@salesforce/label/c.Generic_TaskDetails';
import OffsetDetails from '@salesforce/label/c.Generic_OffsetDetails';
import Info from '@salesforce/label/c.SectionTitle_Info';
import WOOffsetDetails from '@salesforce/label/c.Generic_WOOffsetDetails';
import TaskOffsetDetails from '@salesforce/label/c.Generic_TaskOffsetDetails';

export default class SlaConfiguration extends LightningElement {

    @api currentStep;

    @api page2a;
    @track viewCreateSlaModal;
    @api slaDetail;

    @api contractTreatmentRecordId;
    @api contractTreatmentJobId;
    @api contractTreatmentSlaId;
    //@api contractTreatmentSla;
    @api contractTreatmentSlaName;
    @api contractTreatmentJobName;
    @api frameworkIsActive;
    @api frameworkIsInactive;

    label = {
        SlaTitle,
        NewSla,
        AddSla,
        Info,
        WODetails,
        TaskDetails,
        OffsetDetails,
        WOOffsetDetails,
        TaskOffsetDetails
    };

    @wire(getContractTreatmentJobSla, { contractTreatmentJobId: '$contractTreatmentJobId'})
    contractTreatmentSla;

    handleSuccessModal(event){
        const evt = new ShowToastEvent({
            title: "Contract Treatment Job SLA created ",
            //message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        this.dispatchEvent(evt);
        this.contractTreatmentSlaId = event.detail.id;
        console.log("Contract Treatment Job SLA created ID: " + this.contractTreatmentSlaId)
        console.log("Contract Treatment Job SLA created NAME: " + this.contractTreatmentSlaName)
        this.closeModal();
        this.slaDetail = true;
        refreshApex(this.contractTreatmentSla);
    }

    handleEventDeleteSla(){
        refreshApex(this.contractTreatmentSla);
        console.log('Refresh Contract Treatment SLA');
    }

    handleClickCreateSLA() {
        this.viewCreateSlaModal = true;
    }

    closeModal() {
        this.viewCreateSlaModal = false;
    }

    handleSubmitClick() {
        this.template.querySelector('lightning-record-edit-form').submit();
    }
}