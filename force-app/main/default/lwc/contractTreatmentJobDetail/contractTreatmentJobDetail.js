/* eslint-disable no-console */
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';

import propagateDeliveryChannel from '@salesforce/apex/ContractTreatmentJobDetailController.propagateDeliveryChannel';
import propagateFrequencyChange from '@salesforce/apex/ContractTreatmentJobDetailController.propagateFrequency';
import checkShowFrequencyButton from '@salesforce/apex/ContractTreatmentJobDetailController.getShowFrequencyButton';
import checkShowDeliveryButton from '@salesforce/apex/ContractTreatmentJobDetailController.getShowDeliveryButton';
import checkForSLAWarningMessage from '@salesforce/apex/ContractTreatmentJobDetailController.checkForSLAWarningMessage';

import Delete from '@salesforce/label/c.Btn_Delete';
import Cancel from '@salesforce/label/c.Btn_Cancel';
import Close from '@salesforce/label/c.CT_JobConfiguration_ModalCloseIcon';
import SlaConfig from '@salesforce/label/c.CT_JobConfiguration_BtnSlaConfig';
import ProductConfig from '@salesforce/label/c.CT_JobConfiguration_BtnProductConfig';
import UpdateJob from '@salesforce/label/c.CT_JobConfiguration_BtnUpdateJob';
import JobDeleteing from '@salesforce/label/c.CT_JobConfiguration_ModalJobDeleteTitle';
import JobDeleteMsg from '@salesforce/label/c.CT_JobConfiguration_ModalJobDeleteMsg';
import JobDetail from '@salesforce/label/c.CT_JobConfiguration_JobDetail';
import updateChildModalTitle from '@salesforce/label/c.CT_JobConfiguration_ModalPropagateTitle';
import updateChildModalBody from '@salesforce/label/c.CT_JobConfiguration_ModalPropagateBody';
import deliveryButton from '@salesforce/label/c.CT_JobConfiguration_ModalPropagateDeliveryButton';
import frequencyButton from '@salesforce/label/c.CT_JobConfiguration_ModalPropagateFrequencyButton';
import updateChildButton from '@salesforce/label/c.CT_JobConfiguration_UpdateChildsButton';
import ManageStatus from '@salesforce/label/c.CT_JobTile_ManageStatus';
import ConfigureDefaultBOM from '@salesforce/label/c.CT_ConfigureDefaultBOM';
import Details from '@salesforce/label/c.CTJ_Section_Details';
import Scheduling from '@salesforce/label/c.CTJ_Section_Scheduling';
import SADependency from '@salesforce/label/c.CTJ_Section_SADependency';
import ActivityDetails from '@salesforce/label/c.CTJ_Section_ActivityDetails';
import OtherDetails from '@salesforce/label/c.CTJ_Section_OtherDetails';
import Frequency from '@salesforce/label/c.CTJ_Section_Frequency';
import NoSLAWarning from '@salesforce/label/c.CTJ_NoSLA_Warning';

export default class ContractTreatmentJobDetail extends LightningElement {

    label = {
        Delete,
        Cancel,
        Close,
        SlaConfig,
        ProductConfig,
        UpdateJob,
        JobDeleteing,
        JobDeleteMsg,
        JobDetail,
        ManageStatus,
        ConfigureDefaultBOM,
        updateChildModalTitle,
        updateChildModalBody,
        deliveryButton,
        frequencyButton,
        updateChildButton,
        Details,
        Scheduling,
        SADependency,
        ActivityDetails,
        OtherDetails,
        Frequency,
        NoSLAWarning
    };
    frameworkIsDraft;
    showManageStatusModal = false;
    showUpdateChildModal = false;
    firstLoad = true;
    isDefaultBOM;
    initialDeliveryValue;
    initialFrequencyValue;
    initialFrequencyUoMValue;
    showDeliveryButton = false;
    showFrequencyButton = false;
    showUpdateChildButton = false;

    @api contractFrameworkId;
    @api contractTreatmentRecordId;
    @api contractTreatmentJobId;
    @api corporateTreatmentJobId;
    @api contractTreatmentName;
    @api corporateTreatmentName;
    @api contractTreatmentJob;
    @api contractTreatmentProductCode;
    @api jobDetail;
    @api page2a;
    @api page2b;
    @api deleteModal;
    @api frameworkIsActive;
    @api frameworkIsInactive;
    @api jobName;

    @track hideConfigureDefaultBOMButton = true;
    @track isLoading = true;
    @track showSLAWarningMessage;

    handleSuccess(event) {
        console.log(event);
        //var deliveryChannel = event.detail.fields.Delivery_Channel__c.value;
        this.checkButtonsVisibility();
        const evt = new ShowToastEvent({
            title: "Contract Treatment Job updated ",
            //message: "Record ID: " + this.contractTreatmentJobId,
            variant: "success"
        });
        this.dispatchEvent(evt);
        console.log("Contract Treatment Job updated " + this.contractTreatmentJobId)
        const viewConfiguredJob = new CustomEvent("updatejob", {
            //detail: this.contractTreatmentJobId
        });
        this.dispatchEvent(viewConfiguredJob);
        console.log('DefaultBOM: ' + event.detail.fields.Default_BOM__c.value);

        // Checking, if the CTJ is scheduled, if there is a SLA. If not, showing a warning message

        checkForSLAWarningMessage({
            contractTreatmentJobId: this.contractTreatmentJobId
        }).then(result => {
            this.showSLAWarningMessage = result;

            console.log('checkSLAWarning result: ' + result);
            console.log('Show SLA warning message: ' + this.showSLAWarningMessage);
        }).catch(error => {
            console.log('ERROR');
            console.log(JSON.stringify(error));
        });
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

    checkShowUpdateChildButtons() {
        if (this.showDeliveryButton == true || this.showFrequencyButton == true) {
            this.showUpdateChildButton = true;
        } else {
            this.showUpdateChildButton = false;
        }
    }

    handleOnLoad(event) {
        this.isLoading = false;

        var record = event.detail.records;
        var fields = record[this.contractTreatmentJobId].fields;
        this.isDefaultBOM = fields.Default_BOM__c.value;
        this.hideConfigureDefaultBOMButton = !this.isDefaultBOM;
        this.checkShowUpdateChildButtons();
    }

    handleClickDeliveryChannel() {
        propagateDeliveryChannel({ contractTreatmentJobId: this.contractTreatmentJobId })
            .then(result => {
                console.log('call done!');
                this.showUpdateChildModal = false;
                this.showDeliveryButton = false;
                this.checkShowUpdateChildButtons();
            })
            .catch(error => {
                this.showUpdateChildModal = false;
                this.checkShowUpdateChildButtons();
            });
        const evt = new ShowToastEvent({
            title: "Delivery Channel successfully propagated",
            variant: "success"
        });
        this.dispatchEvent(evt);
    }

    handleClickFrequency() {
        propagateFrequencyChange({ contractTreatmentJobId: this.contractTreatmentJobId })
            .then(result => {
                console.log('call done!');
                this.showUpdateChildModal = false;
                this.showFrequencyButton = false;
                this.checkShowUpdateChildButtons();
            })
            .catch(error => {
                this.showUpdateChildModal = false;
                this.checkShowUpdateChildButtons();
            });
        const evt = new ShowToastEvent({
            title: "Frequency successfully propagated",
            variant: "success"
        });
        this.dispatchEvent(evt);
    }

    handleClickShowChildModal() {
        this.showUpdateChildModal = true;
    }

    handleClickHideChildModal() {
        this.showUpdateChildModal = false;
    }

    handleStatusSubmit() {
        const evt = new ShowToastEvent({
            title: "Contract Treatment Job Status updated ",
            //message: "Record ID: " + this.contractTreatmentJobId,
            variant: "success"
        });
        this.dispatchEvent(evt);
        this.showManageStatusModal = false;
    }

    handleDeleteJob() {
        console.log('Contract Treatment Job to delete: ' + this.contractTreatmentJobId);
        deleteRecord(this.contractTreatmentJobId).then(() => {
            const evt = new ShowToastEvent({
                title: "Job successfully deleted",
                variant: "success"
            });
            this.dispatchEvent(evt);
        }).catch(error => {
            console.log('Error: ' + error);

            const evt = new ShowToastEvent({
                title: "Job not successfully deleted",
                message: "An error occurred while trying to delete this Job",
                variant: "error"
            });
            this.dispatchEvent(evt);
        })
        //refreshApex(this.contractTreatmentJob);
        this.jobDetail = false;
        const viewConfiguredJob = new CustomEvent("deletejob", {
            //detail: this.contractTreatmentJobId
        });
        this.dispatchEvent(viewConfiguredJob);
        this.deleteModal = false;
    }

    handleClickViewSLA() {
        const viewConfiguredSla = new CustomEvent("entrysla", {
            detail: this.contractTreatmentJobId
        });
        console.log('Job Id to pass at SLA by the event is: ' + this.contractTreatmentJobId);
        this.dispatchEvent(viewConfiguredSla);

        const passJobName = new CustomEvent("passjobname", {     //SHOULD CREATE JUST ONE EVENT WITH AN OBJECT WITH DIFFERENT PROPERTIES AS DETAIL (event.detail.Name for example)
            detail: this.jobName
        });
        this.dispatchEvent(passJobName);
    }

    handleClickViewProduct() {
        const viewProductConfiguration = new CustomEvent('viewproductconfig', {
            detail: this.contractTreatmentJobId
        });
        this.dispatchEvent(viewProductConfiguration);

        const passJobName = new CustomEvent("passjobname", {     //SHOULD CREATE JUST ONE EVENT WITH AN OBJECT WITH DIFFERENT PROPERTIES AS DETAIL (event.detail.Name for example)
            detail: this.jobName
        });
        this.dispatchEvent(passJobName);
    }

    handleConfigureDefaultBOM() {
        const enterDefaultBOMConfiguration = new CustomEvent('defaultbomconfiguration', {
            detail: this.contractTreatmentJobId
        });
        this.dispatchEvent(enterDefaultBOMConfiguration);
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
        console.log('JOB NAME: ' + this.jobName);
        console.log('CONTRACT TREATMENT ID IN JobDetail:::::::::: ' + this.contractTreatmentRecordId);
        console.log('FrameworkIsActive????? ' + this.frameworkIsActive);
        console.log('FRAMEWORK INACTIVE??????????????????????????????????????????????????????????????????? ' + this.frameworkIsInactive);
        if (this.frameworkIsInactive === false) {
            this.frameworkIsDraft = !this.frameworkIsActive;
        }
        // Setting both conditions to true (even if framework is not Active) just not to show both the buttons
        if (this.frameworkIsInactive === true) {
            this.frameworkIsDraft = true;
        }

        // Checking, if the CTJ is scheduled, if there is a SLA. If not, showing a warning message

        checkForSLAWarningMessage({
            contractTreatmentJobId: this.contractTreatmentJobId
        }).then(result => {
            this.showSLAWarningMessage = result;

            console.log('checkSLAWarning result: ' + result);
            console.log('Show SLA warning message: ' + this.showSLAWarningMessage);
        }).catch(error => {
            console.log('ERROR');
            console.log(JSON.stringify(error));
        });
    }

    connectedCallback(){
        this.checkButtonsVisibility();
    }

    checkButtonsVisibility(){
        checkShowDeliveryButton({ contractTreatmentJobId: this.contractTreatmentJobId })
        .then(result => {
            this.showDeliveryButton = result;
            this.checkShowUpdateChildButtons();
        })
        .catch(error => {
            this.showUpdateChildModal = false;
            this.checkShowUpdateChildButtons();
        });
        checkShowFrequencyButton({ contractTreatmentJobId: this.contractTreatmentJobId })
        .then(result => {
            this.showFrequencyButton = result;
            this.checkShowUpdateChildButtons();
        })
        .catch(error => {
            this.showUpdateChildModal = false;
            this.checkShowUpdateChildButtons();
        });
    }

}