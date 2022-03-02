import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Labels
import manageStatusLabel from '@salesforce/label/c.AccountTreatment_ManageStatus';
import deleteLabel from '@salesforce/label/c.AccountTreatment_DeleteButton';
import deleteHeadingLabel from '@salesforce/label/c.CT_TreatmentModalities_Delete_Heading';
import deleteMessageLabel from '@salesforce/label/c.CT_TreatmentModalities_Delete_Message';
import cancelLabel from '@salesforce/label/c.Btn_Cancel';
import successTitleLabel from '@salesforce/label/c.CT_TreatmentModalities_New_Success_Title';
import errorTitleLabel from '@salesforce/label/c.CT_TreatmentModalities_New_Error_Title';
import recordDeletedMessageLabel from '@salesforce/label/c.Generic_RecordDeleted';
import recordUpdatedMessageLabel from '@salesforce/label/c.Generic_RecordUpdated';
import saveLabel from '@salesforce/label/c.AT_ProductSelection_SaveButton';

// Apex actions
import deleteCTModality from '@salesforce/apex/CTModalitiesModalController.deleteCTModality';

// Fields
import TREATMENT_FIELD from '@salesforce/schema/Contract_Treatment_Modality__c.Treatment__r.Product_Name_Translate__c';
import SUB_TREATMENT_FIELD from '@salesforce/schema/Contract_Treatment_Modality__c.Sub_Treatment__c';
import NAME_FIELD from '@salesforce/schema/Contract_Treatment_Modality__c.Name';

const fields = [TREATMENT_FIELD, SUB_TREATMENT_FIELD, NAME_FIELD];

export default class ContractTreatmentModalityCard extends LightningElement {
    label = {
        manageStatusLabel,
        deleteLabel,
        deleteHeadingLabel,
        deleteMessageLabel,
        cancelLabel,
        saveLabel
    };

    @api contractTreatmentModalityId;
    @api frameworkStatus;
    @api recordTypeName;

    @track showDeleteModal = false;
    @track showManageStatusModal = false;
    @track isLoadingDelete = false;

    @wire(getRecord, { recordId: '$contractTreatmentModalityId', fields })
    contractTreatmentModality;

    get isManageStatusDisabled() {
        if(this.frameworkStatus != 'Active') {
            return true;
        }
        return false;
    }

    get isDeleteDisabled() {
        if(this.frameworkStatus != 'Draft') {
            return true;
        }
        return false;
    }

    get modalityTreatmentName() {
        if(this.contractTreatmentModality != undefined && this.contractTreatmentModality != null) {
            return getFieldValue(this.contractTreatmentModality.data, TREATMENT_FIELD);
        }

        return null;
    }

    get modalitySubTreatment() {
        if(this.contractTreatmentModality != undefined && this.contractTreatmentModality != null) {
            return getFieldValue(this.contractTreatmentModality.data, SUB_TREATMENT_FIELD);
        }

        return null;
    }

    get name() {
        if(this.contractTreatmentModality != undefined && this.contractTreatmentModality != null) {
            return getFieldValue(this.contractTreatmentModality.data, NAME_FIELD);
        }

        return null;
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
        console.log('contractTreatmentModalityCard connected...');
        console.log('contractTreatmentModalityId: ' + this.contractTreatmentModalityId);
        console.log('recordTypeName: ' + this.recordTypeName);
    }

    renderedCallback() {
        console.log('contractTreatmentModalityCard renderedCallback...');
        console.log('Contract Framework Status: ' + this.frameworkStatus);
    }

    toggleManageStatusModal() {
        if(this.showManageStatusModal == false) {
            this.showManageStatusModal = true;
        }
        else {
            this.showManageStatusModal = false;
        }
    }

    toggleDeleteModal() {
        if(this.showDeleteModal == false) {
            this.showDeleteModal = true;
        }
        else {
            this.showDeleteModal = false;
        }
    }

    deleteCTModality() {
        this.isLoadingDelete = true;

        deleteCTModality({
            CTModalityId: this.contractTreatmentModalityId
        }).then(() => {
            const evt = new ShowToastEvent({
                title: successTitleLabel,
                message: recordDeletedMessageLabel,
                variant: "success"
            });
            this.dispatchEvent(evt);

            this.isLoadingDelete = false;
            this.showDeleteModal = false;
            
            const deleteEvent = new CustomEvent('delete');
            this.dispatchEvent(deleteEvent);
        }).catch(error => {
            console.log('ERROR');
            console.log(JSON.stringify(error));

            this.isLoadingDelete = true;

            const evt = new ShowToastEvent({
                title: errorTitleLabel,
                message: error.body.message,
                variant: "error"
            });
            this.dispatchEvent(evt);
        });
    }

    handleManageStatusSuccess() {
        const evt = new ShowToastEvent({
            title: successTitleLabel,
            message: recordUpdatedMessageLabel,
            variant: "success"
        });
        this.dispatchEvent(evt);

        this.toggleManageStatusModal();
    }

    handleManageStatusError(event) {
        let title;
        let message;

        if(event.detail != undefined && event.detail.message != undefined && event.detail.message != null) {
            title = event.detail.message;

            if(event.detail.detail != undefined && event.detail.detail != null) {
                message = event.detail.detail;
            }
            else {
                message = '';
            }
        }
        else {
            title = errorTitleLabel;
            message = '';
        }

        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: "error"
        });
        this.dispatchEvent(evt);
    }

    handleFormSuccess() {
        const updateEvent = new CustomEvent('update');
        this.dispatchEvent(updateEvent);

        const evt = new ShowToastEvent({
            title: successTitleLabel,
            message: recordUpdatedMessageLabel,
            variant: "success"
        });
        this.dispatchEvent(evt);
    }
}