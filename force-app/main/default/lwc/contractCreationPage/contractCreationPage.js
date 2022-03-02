/* *
* @author Arturo Forneris
*/

/* eslint-disable no-console */
import { LightningElement, api, wire, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

// Apex actions
import getCorporateTreatment from '@salesforce/apex/ContractTreatmentController.getCorporateTreatment';
import apexSearchZSRT from '@salesforce/apex/LookupController.searchZSRTProductsForContractFramework';
import apexSearchZSER from '@salesforce/apex/LookupController.searchZSERProductsForContractFramework';
import getBusinessLineOptionsBySO from '@salesforce/apex/ContractTreatmentController.getBusinessLineOptionsBySO';
import getTreatmentTypeOptionsBySOAndBL from '@salesforce/apex/ContractTreatmentController.getTreatmentTypeOptionsBySOAndBL';

// Labels
import Info from '@salesforce/label/c.SectionTitle_Info';
import Details from '@salesforce/label/c.SectionTitle_Details';
import CustomerInfo from '@salesforce/label/c.SectionTitle_CustomerInfo';
import Product from '@salesforce/label/c.SectionTitle_Product';
import Threshold from '@salesforce/label/c.SectionTitle_Threshold';
import Description from '@salesforce/label/c.SectionTitle_Description';
import Duration from '@salesforce/label/c.SectionTitle_Duration';
import Billing from '@salesforce/label/c.SectionTitle_Billing';
import InvoicePlan from '@salesforce/label/c.SectionTitle_InvoicePlan';
import TreatmentInfo from '@salesforce/label/c.SectionTitle_TreatmentInfo';
import Rebate from '@salesforce/label/c.SectionTitle_Rebate';
import DefaultFiscalNature from '@salesforce/label/c.SectionTitle_DefaultFiscalNatureSplitEvaluation';
import Billable from '@salesforce/label/c.SectionTitle_Billable';
import TreatmentModalitiesButtonLabel from '@salesforce/label/c.CT_TreatmentModalities_Button';
import RebatedModalitiesButtonLabel from '@salesforce/label/c.CT_RebateModalities_Button';

// Fields
import ELECTRICITY_REBATES_FIELD from '@salesforce/schema/Contract_Treatment__c.Electricity_Rebates__c';
import BUSINESS_LINE_FIELD from '@salesforce/schema/Contract_Treatment__c.Business_Line__c';
import TREATMENT_TYPE_FIELD from '@salesforce/schema/Contract_Treatment__c.Treatment_Type__c';

const fields = [ELECTRICITY_REBATES_FIELD, TREATMENT_TYPE_FIELD, BUSINESS_LINE_FIELD];

export default class ContractCreationPage extends LightningElement {

    label = {
        Info,
        Details,
        CustomerInfo,
        Product,
        Threshold,
        Description,
        Duration,
        Billing,
        InvoicePlan,
        TreatmentInfo,
        Rebate,
        DefaultFiscalNature,
        Billable,
        TreatmentModalitiesButtonLabel,
        RebatedModalitiesButtonLabel
    };

    @api objectApiName = "Contract_Treatment__c";
    @api currentStep = 'step-1';
    @api page1;
    @api contractFrameworkId;
    @api contractTreatmentRecordId;
    @api contractTreatmentName;
    @api corporateTreatmentId;
    @api recordTypeId;
    @api typeValue;
    @api frameworkIsActive;
    @api checkIfContractIsActiveValue;
    @api salesOrgCode;

    @track showStandardProductLookup = false;
    @track showCTTreatmentModalitiesModal = false;
    @track showCTRebateModalitiesModal = false;
    @track businessLineOptions;
    @track treatmentTypeOptions;
    @track treatmentTypeDisabled = true;
    @track selectedBusinessLine;
    @track selectedTreatmentType;

    @wire(getRecord, { recordId: '$contractTreatmentRecordId', fields })
    contractTreatment;

    isLoading = true;
    isMultiEntry = false;
    errors = [];
    selectedZSRTProductId;
    selectedZSERProductId;

    get showTreatmentModalitiesButton() {
        if(this.contractTreatmentRecordId != null && this.contractTreatmentRecordId != undefined) {
            return true;
        }

        return false;
    }

    get showRebateModalitiesButton() {
        if(this.contractTreatmentRecordId != null && this.contractTreatmentRecordId != undefined && this.contractTreatment != null && this.contractTreatment != undefined &&
        this.electricityRebates == 'Yes') {
            return true;
        }

        return false;
    }

    get detailsClass() {
        if(this.showTreatmentModalitiesButton == true) {
            return 'slds-float_left top30';
        }

        return 'slds-float_left';
    }

    get rebateClass() {
        if(this.showRebateModalitiesButton == true) {
            return 'slds-float_left top30';
        }

        return 'slds-float_left';
    }

    get electricityRebates() {
        if(this.contractTreatment != undefined && this.contractTreatment != null) {
            return getFieldValue(this.contractTreatment.data, ELECTRICITY_REBATES_FIELD);
        }

        return null;
    }
    
    @wire(getCorporateTreatment, {contractTreatmentRecordId: '$contractTreatmentRecordId'})
    getCorporateTreatmentId({data, error}) {
        if(data) {
            if(data.length > 0) {
                this.corporateTreatmentId = data;
            }
        }
    }

    renderedCallback() {
        console.log('--- salesOrgCode: ' + this.salesOrgCode);
        console.log('--- businessLineOptions: ' + this.businessLineOptions);

        if(this.contractTreatmentRecordId != undefined) {
            this.showStandardProductLookup = true;
        }

        if(this.salesOrgCode && !this.businessLineOptions) {
            console.log('Retrieving business line options for SalesOrg ' + this.salesOrgCode + '...');

            getBusinessLineOptionsBySO({
                salesOrgCode: this.salesOrgCode
            }).then(result => {
                console.log(JSON.stringify(result));
                this.businessLineOptions = result;

                let businessLineValue = getFieldValue(this.contractTreatment.data, BUSINESS_LINE_FIELD);
                let treatmentTypeValue = getFieldValue(this.contractTreatment.data, TREATMENT_TYPE_FIELD);

                if(businessLineValue != null) {
                    this.selectedBusinessLine = businessLineValue;

                    getTreatmentTypeOptionsBySOAndBL({
                        salesOrgCode: this.salesOrgCode,
                        businessLine: this.selectedBusinessLine
                    }).then(result => {
                        console.log(JSON.stringify(result));
                        this.treatmentTypeOptions = result;
                        this.treatmentTypeDisabled = false;

                        if(treatmentTypeValue != null) {
                            this.selectedTreatmentType = treatmentTypeValue;
                        }
                    }).catch(error => {
                        console.log('ERROR');
                        console.log(JSON.stringify(error));
                    });
                }
            }).catch(error => {
                console.log('ERROR');
                console.log(JSON.stringify(error));
            });
        }
    }

    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: "Contract Treatment saved",
            //message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        this.dispatchEvent(evt);
        
        console.log('CORPORATE TREATMENT PRIMA DI EVENTO IN CREAZIONE: ' + this.corporateTreatmentId);
        this.contractTreatmentRecordId = event.detail.id;
        console.log('Contract Framework Id: ' + this.contractFrameworkId);
        console.log('Contract Treatment Id: '+ this.contractTreatmentRecordId);
        console.log('CORPORATE TREATMENT AFTER SUCCESS: ' + this.corporateTreatmentId);
        const createdContractTreatment = new CustomEvent("created", {
        detail: this.contractTreatmentRecordId
        });
        this.dispatchEvent(createdContractTreatment);

        const contractCreated = new CustomEvent("contractcreated", {
            detail: this.corporateTreatmentId.toString() //ERRORE!!! IN EDIT E' UNDEFINED
            });
            this.dispatchEvent(contractCreated);
    }

    handleSubmit(event) {
        console.log('handleSubmit...');
        console.log('contractTreatmentRecordId: ' + this.contractTreatmentRecordId);

        if(this.contractTreatmentRecordId === undefined) {
            this.checkForErrors();
            event.preventDefault();
            if (this.errors.length > 0) {
                console.log('ERRORS');
                console.log(this.errors);
            }
            else {
                console.log('Selected ZSRT Product Id: ' + this.selectedZSRTProductId);
                console.log('Selected ZSER Product Id: ' + this.selectedZSERProductId);
                console.log('Selected BusinessLine: ' + this.selectedBusinessLine);
                console.log('Selected TreatmentType: ' + this.selectedTreatmentType);

                const fields = event.detail.fields;
                fields.Product__c = this.selectedZSRTProductId;
                fields.RebateProduct__c = this.selectedZSERProductId;
                
                if(this.selectedBusinessLine != null) {
                    fields.Business_Line__c = this.selectedBusinessLine;
                }

                /* if(this.selectedTreatmentType != null) {
                    fields.Treatment_Type__c = this.selectedTreatmentType;
                } */

                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
        }
        else {
            // this.checkForErrors();
            event.preventDefault();

            if (this.errors.length > 0) {
                console.log('ERRORS');
                console.log(this.errors);
            }
            else {
                console.log('Selected BusinessLine: ' + this.selectedBusinessLine);
                console.log('Selected TreatmentType: ' + this.selectedTreatmentType);

                const fields = event.detail.fields;
                
                if(this.selectedBusinessLine != null) {
                    fields.Business_Line__c = this.selectedBusinessLine;
                }

                if(this.selectedTreatmentType != null) {
                    fields.Treatment_Type__c = this.selectedTreatmentType;
                }

                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
        }
    }

    disconnectedCallback() {
        this.businessLineOptions = undefined;
    }

    handleError(event){
        const evt = new ShowToastEvent({
        title: "Error ",
        message: event.detail.detail,
        variant: "error"
        });
        this.dispatchEvent(evt);
    }

    onchangeType(event){
        
    }

    handleCorpTreatChange(event) {
        this.corporateTreatmentId = event.detail.value;
    }

    handleOnLoad() {
        this.isLoading = false;
    }

    handleZSRTProductSearch(event) {
        const target = event.target;
        apexSearchZSRT(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
            });
    }

    handleZSERProductSearch(event) {
        const target = event.target;
        apexSearchZSER(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
            });
    }

    handleZSRTProductSelection(event) {
        const selection = event.target.getSelection();
        if (selection != undefined && selection.length != 0) {
            console.log('Prodotto ZSRT selezionato: ' + selection[0].title);

            this.selectedZSRTProductId = selection[0].id;
        }
    }

    handleZSERProductSelection(event) {
        const selection = event.target.getSelection();
        if (selection != undefined && selection.length != 0) {
            console.log('Prodotto ZSER selezionato: ' + selection[0].title);

            this.selectedZSERProductId = selection[0].id;
        }
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

    toggleCTTreatmentModalitiesModal() {
        if(this.showCTTreatmentModalitiesModal == false) {
            this.showCTTreatmentModalitiesModal = true;
        }
        else {
            this.showCTTreatmentModalitiesModal = false;
        }
    }

    toggleCTRebateModalitiesModal() {
        if(this.showCTRebateModalitiesModal == false) {
            this.showCTRebateModalitiesModal = true;
        }
        else {
            this.showCTRebateModalitiesModal = false;
        }
    }

    handleBusinessLineChange(event) {
        this.selectedBusinessLine = event.target.value;
        console.log('selectedBusinessLine: ' + this.selectedBusinessLine);

        if(this.selectedBusinessLine != null && this.selectedBusinessLine != undefined && this.selectedBusinessLine != '') {
            getTreatmentTypeOptionsBySOAndBL({
                salesOrgCode: this.salesOrgCode,
                businessLine: this.selectedBusinessLine
            }).then(result => {
                console.log(JSON.stringify(result));
                this.treatmentTypeOptions = result;
                this.treatmentTypeDisabled = false;
            }).catch(error => {
                console.log('ERROR');
                console.log(JSON.stringify(error));
            });
        }
        else {
            this.treatmentTypeDisabled = true;
        }
    }

    handleTreatmentTypeChange(event) {
        this.selectedTreatmentType = event.target.value;
    }
}