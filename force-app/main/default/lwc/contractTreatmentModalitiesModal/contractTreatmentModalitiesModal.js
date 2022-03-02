import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Labels
import saveAndCloseLabel from '@salesforce/label/c.CT_TreatmentModalities_SaveAndClose';
import treatmentModalitiesLabel from '@salesforce/label/c.CT_TreatmentModalities_Button';
import rebateModalitiesLabel from '@salesforce/label/c.CT_RebateModalities_Button';
import newLabel from '@salesforce/label/c.CT_TreatmentModalities_NewButton';
import cancelLabel from '@salesforce/label/c.Btn_Cancel';
import saveLabel from '@salesforce/label/c.AT_ProductSelection_SaveButton';
import newSuccessTitle from '@salesforce/label/c.CT_TreatmentModalities_New_Success_Title';
import newSuccessMessage from '@salesforce/label/c.CT_TreatmentModalities_New_Success_Message';
import newErrorTitle from '@salesforce/label/c.CT_TreatmentModalities_New_Error_Title';
import newErrorMessage from '@salesforce/label/c.CT_TreatmentModalities_New_Error_Message';

// Apex actions
import getContractTreatmentModalities from '@salesforce/apex/CTModalitiesModalController.getContractTreatmentModalities';
import apexSearchZSRT from '@salesforce/apex/LookupController.searchZSRTProductsForContractFramework';
import apexSearchZSER from '@salesforce/apex/LookupController.searchZSERProductsForContractFramework';
import getModalitytRTIdFromName from '@salesforce/apex/CTModalitiesModalController.getModalitytRTIdFromName';

// Fields
import CT_TREATMENT_TYPE_FIELD from '@salesforce/schema/Contract_Treatment__c.Treatment_Type__c';
import CT_FRAMEWORK_STATUS_FIELD from '@salesforce/schema/Contract_Treatment__c.Contract_Framework__r.Status__c';

const fields = [CT_TREATMENT_TYPE_FIELD, CT_FRAMEWORK_STATUS_FIELD];

export default class ContractTreatmentModalitiesModal extends LightningElement {
    label = {
        saveAndCloseLabel,
        treatmentModalitiesLabel,
        newLabel,
        cancelLabel,
        saveLabel
    };
    contractTreatmentModalities = [];
    errors = [];
    isMultiEntry = false;
    selectedProductId;

    @api contractTreatmentId;
    @api contractFrameworkId;
    @api recordTypeId;
    @api recordTypeName;

    @track showNewModal = false;
    @track isLoading = false;
    @track newModalButtonsDisabled = false;

    @wire(getRecord, { recordId: '$contractTreatmentId', fields })
    contractTreatment;

    get CTTreatmentType() {
        if(this.contractTreatment != undefined && this.contractTreatment != null) {
            return getFieldValue(this.contractTreatment.data, CT_TREATMENT_TYPE_FIELD);
        }

        return null;
    }

    get CTFrameworkStatus() {
        if(this.contractTreatment != undefined && this.contractTreatment != null) {
            return getFieldValue(this.contractTreatment.data, CT_FRAMEWORK_STATUS_FIELD);
        }

        return null;
    }

    get isSubTreatmentRequired() {
        if(this.CTTreatmentType != null && this.CTTreatmentType != undefined) {
            return true;
        }

        return false;
    }

    get headingLabel() {
        if(this.recordTypeName == 'CTM_Treatment') {
            return treatmentModalitiesLabel;
        }
        else if(this.recordTypeName == 'CTM_Rebate') {
            return rebateModalitiesLabel;
        }
    }

    get showTreatmentForm() {
        if(this.recordTypeName == 'CTM_Treatment') {
            return true;
        }
        return false;
    }

    get showRebateForm() {
        if(this.recordTypeName == 'CTM_Rebate') {
            return true;
        }
        return false;
    }

    connectedCallback() {
        console.log('contractTreatmentModalitiesModal connected...');
        console.log('contractTreatmentId: ' + this.contractTreatmentId);
        console.log('recordTypeName: ' + this.recordTypeName);

        getModalitytRTIdFromName({
            developerName: this.recordTypeName
        }).then(result => {
            this.recordTypeId = result;
        }).catch(error => {
            console.log('ERROR');
            console.log(JSON.stringify(error));
        })

        this.refreshCTModalities();
    }

    refreshCTModalities() {
        getContractTreatmentModalities({
            contractTreatmentId: this.contractTreatmentId,
            recordTypeName: this.recordTypeName
        }).then(result => {
            this.contractTreatmentModalities = result;
            console.log('Modalities:');
            console.log(JSON.stringify(this.contractTreatmentModalities));
        }).catch(error => {
            console.log('ERROR');
            console.log(JSON.stringify(error));
        });
    }

    closeModal() {
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }

    handleSaveAndCloseClick() {
        this.closeModal();
    }

    toggleNewModal() {
        if(this.showNewModal == true) {
            this.showNewModal = false;
            this.refreshCTModalities();
        }
        else {
            this.showNewModal = true;
        }
    }

    handleNewModalitySave() {
        this.template.querySelector('lightning-button').click();
    }

    handleNewSubmit(event) {
        this.newModalButtonsDisabled = true;
        this.isLoading = true;
        this.checkForErrors();
        
        if(this.errors.length == 0) {
            console.log('Submitting form...');

            event.preventDefault();

            const fields = event.detail.fields;
            fields.Contract_Treatment__c = this.contractTreatmentId;

            if(this.recordTypeName == 'CTM_Treatment') {
                fields.Treatment__c = this.selectedProductId;
            }
            else if(this.recordTypeName == 'CTM_Rebate') {
                fields.Rebate__c = this.selectedProductId;
            }

            console.log('CTM.Treatment__c: ' + fields.Treatment__c);
            console.log('CTM.Rebate__c: ' + fields.Rebate__c);

            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
        else {
            event.preventDefault();
            this.isLoading = false;
            this.newModalButtonsDisabled = false;
        }
    }

    handleNewSuccess() {
        this.newModalButtonsDisabled = false;
        this.isLoading = false;
        this.toggleNewModal();

        const evt = new ShowToastEvent({
            title: newSuccessTitle,
            message: newSuccessMessage,
            variant: "success"
        });
        this.dispatchEvent(evt);
    }

    handleNewError(event) {
        this.newModalButtonsDisabled = false;
        this.isLoading = false;
        let title;
        let message;

        if(event.detail != undefined && event.detail.message != undefined && event.detail.message != null) {
            title = event.detail.message;

            if(event.detail.detail != undefined && event.detail.detail != null) {
                message = event.detail.detail;
            }
            else {
                message = newErrorMessage;
            }
        }
        else {
            title = newErrorTitle;
            message = newErrorMessage;
        }

        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: "error"
        });
        this.dispatchEvent(evt);

        console.log('ERROR');
        console.log(JSON.stringify(event));
    }

    handleProductSearch(event) {
        const target = event.target;

        if(this.recordTypeName == 'CTM_Treatment') {
            apexSearchZSRT(event.detail).then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
            });
        }
        else if(this.recordTypeName == 'CTM_Rebate') {
            apexSearchZSER(event.detail).then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
            });
        }
    }

    handleProductSelection(event) {
        const selection = event.target.getSelection();
        if (selection != undefined && selection.length != 0) {
            console.log('Prodotto selezionato: ' + selection[0].title);

            this.selectedProductId = selection[0].id;
        }
    }

    checkForErrors() {
        this.errors = [];
        const selection = this.template.querySelector('c-lookup').getSelection();
        console.log('Selection: ' + selection);

        // Enforcing required field
        if (selection.length === 0) {
            this.errors.push({ message: 'Please make a selection.' });
        }
    }
}