/* eslint-disable no-console */
import { LightningElement, api, wire, track } from 'lwc';
import getContractTreatmentJobSla from '@salesforce/apex/ContractTreatmentJobSlaController.getContractTreatmentJobSla';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';

import Info from '@salesforce/label/c.SectionTitle_Info';
import Offset from '@salesforce/label/c.SectionTitle_Offset';
import Time from '@salesforce/label/c.SectionTitle_Time';
import SlaDeleteing from '@salesforce/label/c.CT_JobConfiguration_ModalSlaDeleteTitle';
import SlaDeleteMsg from '@salesforce/label/c.CT_JobConfiguration_ModalSlaDeleteMsg';
import BtnDelete from '@salesforce/label/c.Btn_Delete';
import BtnUpdate from '@salesforce/label/c.Btn_Update';
import BtnCancel from '@salesforce/label/c.Btn_Cancel';
import SlaDetail from '@salesforce/label/c.CT_JobConfiguration_SlaDetail';
import ManageStatus from '@salesforce/label/c.CT_JobTile_ManageStatus';
import WODetails from '@salesforce/label/c.Generic_WODetails';
import TaskDetails from '@salesforce/label/c.Generic_TaskDetails';
import OffsetDetails from '@salesforce/label/c.Generic_OffsetDetails';
import WOOffsetDetails from '@salesforce/label/c.Generic_WOOffsetDetails';
import TaskOffsetDetails from '@salesforce/label/c.Generic_TaskOffsetDetails';

export default class ContractTreatmentSlaDetail extends LightningElement {

    objectApiName = "Contract_Treatment_Job_SLA__c";
    @api contractTreatmentSlaId;
    @api contractTreatmentJobId;
    @track contractTreatmentJobName
    @api contractTreatmentSlaName;
    @api slaDetail;
    @api activeSections = [];
    @api contractTreatmentSla;
    @api frameworkIsActive;
    @api frameworkIsInactive;
    frameworkIsDraft;
    showManageStatusModal = false;

    @api slaName;

    @api deleteModal;

    @wire(getContractTreatmentJobSla, { contractTreatmentJobId: '$contractTreatmentJobId' })
    contractTreatmentSla;

    label = {
        Info,
        Offset,
        Time,
        SlaDeleteing,
        SlaDeleteMsg,
        BtnDelete,
        BtnUpdate,
        BtnCancel,
        SlaDetail,
        ManageStatus,
        WODetails,
        TaskDetails,
        OffsetDetails,
        WOOffsetDetails,
        TaskOffsetDetails
    };

    handleSuccess() {
        const evt = new ShowToastEvent({
            title: "Contract Treatment Job SLA updated ",
            message: "Updated!",
            variant: "success"
        });
        this.dispatchEvent(evt);
        console.log("Contract Treatment Job SLA updated " + this.contractTreatmentSlaId)
    }

    handleError(event) {
        const evt = new ShowToastEvent({
            title: "Error",
            message: event.detail.detail,
            variant: "error"
        });
        this.dispatchEvent(evt);
        console.log("Contract Treatment Job SLA error " + event.detail.detail);
        console.log(event.detail);
    }

    handleDeleteSLA() {
        console.log('Contract Treatment SLA to delete: ' + this.contractTreatmentSlaId);
        deleteRecord(this.contractTreatmentSlaId).then(() => {
            this.slaDetail = false;
            const viewConfiguredSla = new CustomEvent("deletesla", {
                //detail: this.contractTreatmentJobId
            });
            this.dispatchEvent(viewConfiguredSla);
            this.closeDeleteModal();
        });
    }

    handleStatusSubmit() {
        const evt = new ShowToastEvent({
            title: "Contract Treatment Job SLA Status updated ",
            //message: "Record ID: " + this.contractTreatmentJobId,
            variant: "success"
        });
        this.dispatchEvent(evt);
        this.showManageStatusModal = false;
    }

    handleManageStatus() {
        this.showManageStatusModal = true;
    }

    openDeleteModal() {
        this.deleteModal = true;
    }

    closeDeleteModal() {
        this.deleteModal = false;
    }

    closeManageStatusModal() {
        this.showManageStatusModal = false;
    }

    renderedCallback() {
        console.log('SLA Name is: ' + JSON.stringify(this.contractTreatmentSla.Name));
        console.log('Job Id is: ' + this.contractTreatmentJobId);
        if (this.frameworkIsInactive === false) {
            this.frameworkIsDraft = !this.frameworkIsActive;
        }
        // Setting both conditions to true (even if framework is not Active) just not to show both the buttons
        if (this.frameworkIsInactive === true) {
            this.frameworkIsDraft = true;
        }
    }
}