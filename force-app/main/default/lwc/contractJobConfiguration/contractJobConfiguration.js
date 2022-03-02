/* *
* @author Arturo Forneris
*/

/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContractTreatmentJob from '@salesforce/apex/ContractTreatmentJobController.getContractTreatmentJob';
import cloneContractTreatmentJob from '@salesforce/apex/ContractTreatmentJobController.cloneContractTreatmentJob';
//import getCorporateTreatmentJob from '@salesforce/apex/CorporateTreatmentJobController.getCorporateTreatmentJob';
import getContractTreatmentJobClonable from '@salesforce/apex/ContractTreatmentJobController.getContractTreatmentJobClonable';
import getCorporateJobFromContractJob from '@salesforce/apex/ContractTreatmentJobController.getCorporateJobFromContractJob';
import checkIfJobAlreadyExist from '@salesforce/apex/ContractTreatmentJobController.checkIfJobAlreadyExist';
import apexSearch from '@salesforce/apex/LookupController.searchZJOBProductsForContractFramework';
import { refreshApex } from '@salesforce/apex';

import NewCTJ from '@salesforce/label/c.CT_JobConfiguration_ModalJobCreationTitle';
import CloneCTJ from '@salesforce/label/c.CT_JobConfiguration_ModalJobCloneTitle';
import CloneJobBtn from '@salesforce/label/c.CT_JobConfiguration_BtnCloneJob';
import AddJobBtn from '@salesforce/label/c.CT_JobConfiguration_BtnAddJob';
import NewJobBtn from '@salesforce/label/c.CT_JobConfiguration_BtnNewJob';
import Info from '@salesforce/label/c.SectionTitle_Info';
import NoElements from '@salesforce/label/c.Generic_NoElements';
import Back from '@salesforce/label/c.AT_BackButton';
import CTJCloning from '@salesforce/label/c.CT_JobCloning';
import Clone from '@salesforce/label/c.Generic_Clone';
import AssetManagement from '@salesforce/label/c.Generic_AssetManagement';

const columns = [
    { label: 'Contract Treatment Job Name', fieldName: 'Name', type: 'Text(80)', wrapText: true },
    { label: 'Contract Treatment', fieldName: 'contractTreatmentName', type: 'text', wrapText: true },
    { label: 'Frequency', fieldName: 'frequencyDecimal', type: 'number', cellAttributes: { alignment: "left" } },
    { label: 'Frequency Unit of measure', fieldName: 'Frequency_Unit_of_measure', type: 'Picklist', cellAttributes: { alignment: "left" } },
    { label: 'Work Order', fieldName: 'Work_Order', type: 'boolean' },
    { label: 'Task', fieldName: 'Task', type: 'boolean' },
    { label: 'Sheduling Rule', fieldName: 'Scheduling_Rule', type: 'Picklist', wrapText: true },
    { label: 'Work Type', fieldName: 'workTypeName', type: 'text' },
    { label: 'Case Type', fieldName: 'Case_Type', type: 'Picklist' },
];

export default class ContractJobConfiguration extends LightningElement {

    label = {
        NewCTJ,
        CloneCTJ,
        CloneJobBtn,
        AddJobBtn,
        NewJobBtn,
        Info,
        NoElements,
        Back,
        CTJCloning,
        Clone,
        AssetManagement
    };

    @api objectApiName = "Contract_Treatment_Job__c";
    @api currentStep;
    @api page2;
    @api page2a;
    @api page2b;
    @api showAssetButton;

    @track viewCreateJobModal;
    @track cloneJobModal;
    @track jobDetail;
    @track clonableContractTreatmentJobs = [];

    @track error;
    @track columns = columns;
    @track isLoading = false;
    @track isTableEmpty = false;
    @track searchTerm = '';
    @track allSelectedIds = [];
    @track isCloneJobButtonDisabled = false;
    @track showAssetSelectionModal = false;

    @api contractFrameworkId;
    @api contractTreatmentRecordId;
    @api corporateTreatmentId;
    @api contractTreatmentJobId;
    @api contractTreatmentName;
    @api contractTreatmentJobName;
    @api corporateTreatmentName;

    @api contractTreatmentJob;
    @track corporateTreatmentJob;
    @track contractTreatmentJobCode;
    @api checkIfJobAlreadyExistValue;
    @api frameworkIsActive;
    @api frameworkIsInactive;

    @api contractTreatmentJobIdToCopy;

    @track addAndCloneDisabled = true;
    @api loading = false;

    ready = false;
    isMultiEntry = false;
    errors = [];

    @api createdProducts;

    @wire(getContractTreatmentJob, { contractTreatmentRecordId: '$contractTreatmentRecordId' })
    contractTreatmentJob;

    /*@wire(getCorporateTreatmentJob, { corporateTreatmentId: '$corporateTreatmentId'})
    Corporate_Treatment_Job__c;*/

    @wire(getCorporateJobFromContractJob, { contractTreatmentJobId: '$contractTreatmentJobId' })
    getCorporateTreatmentJobId({ data, error }) {
        if (data) {
            this.corporateTreatmentJobId = data;
        }
    }

    @wire(getContractTreatmentJobClonable, { corporateTreatmentJob: '$corporateTreatmentJob', corporateTreatmentId: '$corporateTreatmentId', 
    contractTreatmentRecordId: '$contractTreatmentRecordId', searchTerm: '$searchTerm'})
    populateTable(value) {
        this.clonableContractTreatmentJobs = value;
        const { data, error } = value;
        if (data) {
            console.log('Data.length: ' + data.length);
            if (data.length === 0) {
                this.isTableEmpty = true;
            }
            else {
                this.isTableEmpty = false;
            }
        }
        else if (error) {
            console.log('ERROR: ' + error);
        }
    }

    @wire(checkIfJobAlreadyExist, { corporateTreatmentJob: '$corporateTreatmentJob', contractTreatmentJobCode: '$contractTreatmentJobCode', contractTreatmentRecordId: '$contractTreatmentRecordId' })
    checkIfJobAlreadyExistValue;

    handleClickCreateJob() {
        this.viewCreateJobModal = true;
    }

    handleClickCloneJob() {
        this.isLoading = true;
        refreshApex(this.contractTreatmentJob);
        refreshApex(this.checkIfJobAlreadyExistValue);
        console.log('checkIfJobAlreadyExistValue: ' + this.checkIfJobAlreadyExistValue.data);
        if (this.checkIfJobAlreadyExistValue.data === true) {
            this.handleError();
        } else {
            console.log('corporateTreatmentJob is: ' + this.corporateTreatmentJob);
            console.log('corporateTreatmentId is: ' + this.corporateTreatmentId);
            console.log('contractTreatmentRecordId is not: ' + this.contractTreatmentRecordId);
            console.log('clonable Contract Treatment Job list: ' + JSON.stringify(this.clonableContractTreatmentJobs));
            this.viewCreateJobModal = false;
            this.cloneJobModal = true;
        }
    }

    handleClickViewSLA(event) {
        const viewConfiguredSla = new CustomEvent("entrysla", {
            detail: event.detail,
        });
        console.log('Job Id to pass at SLA by the event is: ' + event.detail);
        this.dispatchEvent(viewConfiguredSla);
    }

    handlePassJobName(event) {
        this.contractTreatmentJobName = event.detail;
        console.log('ContractTreatmentJobName in contractJobConfiguration: ' + this.contractTreatmentJobName);
    }

    handleClickViewProduct(event) {
        console.log('CorporateTreatmentJobId che passo da contractJobConfiguration::::::::::::::::::::: ' + this.corporateTreatmentJobId);
        const viewConfiguredProduct = new CustomEvent("entryproduct", {
            detail: event.detail
        });
        this.contractTreatmentJobId = event.detail;
        this.dispatchEvent(viewConfiguredProduct);
        console.log('Job Id to pass at SLA by the event is: ' + this.contractTreatmentJobId);
    }

    handleFinishedProdConfig(event) {
        this.createdProducts = event.detail;
        console.log('Numero CreatedProducts in jobConfiguration::::::::::::::::::::: ' + this.createdProducts.length);
        const backToJobs = new CustomEvent("backtojobs", {
            detail: this.createdProducts
        });
        this.dispatchEvent(backToJobs);
    }

    handleExitConfig(event) {
        this.createdProducts = event.detail;
        const backToJobs = new CustomEvent("backtojobs", {
            detail: this.createdProducts
        });
        this.dispatchEvent(backToJobs);
    }

    handleSuccessModal(event) {
        const evt = new ShowToastEvent({
            title: "Contract Treatment Job created ",
            //message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        this.dispatchEvent(evt);
        this.contractTreatmentJobId = event.detail.id;
        console.log("Contract Treatment Job created: " + this.contractTreatmentJobId)
        //console.log('CorporateTreatmentJobId in jobConfiguration::::::::::::::::::::: ' + this.corporateTreatmentJobId);
        this.closeModal();
        this.jobDetail = true;
        refreshApex(this.contractTreatmentJob);
    }

    handleRowSelection(event) {
        if(this.isCloneJobButtonDisabled === true) {
            this.isCloneJobButtonDisabled = false
        }

        this.contractTreatmentJobToCopyArray = event.detail.selectedRows;
        if(this.contractTreatmentJobToCopyArray != null && this.contractTreatmentJobToCopyArray != undefined && this.contractTreatmentJobToCopyArray.length > 0) {
            this.contractTreatmentJobIdToCopy = this.contractTreatmentJobToCopyArray[0].Id;
            console.log('Contract Treatment Job selected is: ' + this.contractTreatmentJobIdToCopy);
        }
        else {
            this.isCloneJobButtonDisabled = true;
        }
    }

    handleCorporateTreatmentSelection(event) {
        this.corporateTreatmentJob = event.detail.value;
        this.corporateTreatmentJob = this.corporateTreatmentJob.toString();
        console.log('Corporate Treatment Job selected is: ' + this.corporateTreatmentJob);
        console.log('Contract Treatment Job Code selected is: ' + this.contractTreatmentJobCode);

        if(this.corporateTreatmentJob != null && this.corporateTreatmentJob != '' && this.contractTreatmentJobCode != null && this.contractTreatmentJobCode != '') {
            this.addAndCloneDisabled = false;
        }
        else {
            this.addAndCloneDisabled = true;
        }
    }

    handleContractTreatmentJobCodeSelection(event) {
        const selection = event.target.getSelection();
        if (selection != undefined && selection.length != 0) {
            console.log('Prodotto selezionato: ' + selection[0].title);

            this.contractTreatmentJobCode = selection[0].id;
            this.contractTreatmentJobCode = this.contractTreatmentJobCode.toString();

            console.log('Contract Treatment Job Code selected is: ' + this.contractTreatmentJobCode);
        }
        
        if(this.corporateTreatmentJob != null && this.corporateTreatmentJob != '' && this.contractTreatmentJobCode != null && this.contractTreatmentJobCode != '') {
            this.addAndCloneDisabled = false;
        }
        else {
            this.addAndCloneDisabled = true;
        }
    }

    handleSuccessCloneJob() {
        this.loading = true;
        console.log('spinner loading variable is: ' + this.loading);
        cloneContractTreatmentJob({
            contractTreatmentJobIdToCopy: this.contractTreatmentJobIdToCopy, corporateTreatmentJob: this.corporateTreatmentJob,
            contractTreatmentJobCode: this.contractTreatmentJobCode, contractTreatmentRecordId: this.contractTreatmentRecordId,
            contractFrameworkId: this.contractFrameworkId
        }).then((result) => {
            console.log('Contract Treatment Job to cloned is: ' + JSON.stringify(result));

            const evt = new ShowToastEvent({
                title: "Job successfully cloned",
                variant: "success"
            });
            this.dispatchEvent(evt);

            this.contractTreatmentJobId = result;
        }).catch(error => {
            console.log('Error: ' + error);

            const evt = new ShowToastEvent({
                title: "Job not successfully cloned",
                message: "An error occurred while trying to clone this Job",
                variant: "error"
            });
            this.dispatchEvent(evt);
        })
        this.closeModal();
        this.jobDetail = true;
        refreshApex(this.contractTreatmentJob);
        this.loading = false;
    }

    handleEventUpdateJob() {
        refreshApex(this.contractTreatmentJob);
        console.log('Data refreshed after update');
    }

    handleEventDeleteJob() {
        refreshApex(this.contractTreatmentJob);
        console.log('Data refreshed after delete');
    }

    handleError() {
        const evt = new ShowToastEvent({
            title: "Error ",
            message: "Is not possible select a product already selected, select another product ",
            variant: "error"
        });
        this.dispatchEvent(evt);
    }

    // Event propagation
    handleDefaultBOMConfiguration(event) {
        const enterDefaultBOMConfiguration = new CustomEvent('defaultbomconfiguration', {
            detail: event.detail
        });
        this.dispatchEvent(enterDefaultBOMConfiguration);
    }

    closeModal() {
        this.viewCreateJobModal = false;
        this.cloneJobModal = false;
        this.addAndCloneDisabled = true;
        this.searchTerm = '';
        this.isCloneJobButtonDisabled = true;
        this.corporateTreatmentJob = null;
        this.contractTreatmentJobCode = null;
    }

    connectedCallback() {
        console.log('ConnectedCallback...');
    }

    renderedCallback() {
        console.log('RenderedCallback...');

        if(this.isTableEmpty === true || this.contractTreatmentJobIdToCopy === undefined || this.contractTreatmentJobIdToCopy === null) {
            this.isCloneJobButtonDisabled = true;
        }

        refreshApex(this.contractTreatmentJob);
        refreshApex(this.checkIfJobAlreadyExistValue);
        console.log('ready: ' + this.ready);
        if (this.ready === false) {
            this.ready = true;
            console.log('path false');
            this.jobDetail = true;
        } else {
            console.log('path true');
        }

        console.log('------- contractFrameworkId: ' + this.contractFrameworkId);
        console.log('------- contractTreatmentRecordId: ' + this.contractTreatmentRecordId);
        console.log('------- contractTreatmentJob list: ' + JSON.stringify(this.contractTreatmentJob));
    }

    handleFormSubmitClick() {
        let lightningButtons = this.template.querySelectorAll('lightning-button');

        // Getting the submit button of the form, i.e. the second / third in the HTML template (depending on assetButton). Need to do this to trigger the onSubmit event handler

        if(this.showAssetButton === true) {
            lightningButtons[2].click();
        }
        else {
            lightningButtons[1].click();
        }
    }

    handleSearchChange(event) {
        console.log('Search term: ' + event.target.value);

        this.searchTerm = event.target.value;
    }

    handleProductCodeSearch(event) {
        const target = event.target;
        apexSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
            });
    }

    handleBackFromClone() {
        this.cloneJobModal = false;
        this.viewCreateJobModal = true;
        this.addAndCloneDisabled = true;
        this.searchTerm = '';
        this.isCloneJobButtonDisabled = true;
        this.corporateTreatmentJob = null;
        this.contractTreatmentJobCode = null;
    }

    handleSelectAssets() {
        console.log('handleSelectAssets...');
        this.showAssetSelectionModal = true;
    }

    handleCloseAssetModal() {
        this.showAssetSelectionModal = false;
    }

    checkForErrors() {
        this.errors = [];
        const selection = this.template.querySelector('c-lookup').getSelection();
        console.log('Selection length: ' + selection);

        // Enforcing required field
        if (selection.length === 0) {
            this.errors.push({ message: 'Please make a selection.' });
        }
    }

    handleSubmitCreationModal(event) {
        this.checkForErrors();
        event.preventDefault();
        if (this.errors.length > 0) {
            /* const evt = new ShowToastEvent({
                title: "Please fill the Location field",
                //message: "Record ID: " + event.detail.id,
                variant: "error"
            });
            this.dispatchEvent(evt); */
        }
        else {
            console.log('Selected Product Code Id: ' + this.contractTreatmentJobCode);
            const fields = event.detail.fields;
            fields.Contract_Treatment_Job_Code__c = this.contractTreatmentJobCode;

            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }

}