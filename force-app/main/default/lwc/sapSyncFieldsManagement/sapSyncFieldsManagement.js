import { LightningElement, api, track } from 'lwc';

// Labels
import Save from '@salesforce/label/c.AT_ProductSelection_SaveButton';

// Apex actions
import getProductRequestFromId from '@salesforce/apex/ProductRequestService.getProductRequestFromId';
import setProductRequestSyncStatus from '@salesforce/apex/ProductRequestService.setProductRequestSyncStatus';

// Other stuff
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SapSyncFieldsManagement extends LightningElement {
    labels = {
        Save
    };

    @api recordId;
    @api objectApiName;

    @track hideIsCreatedField;
    @track syncFieldIsCheckbox;
    @track showSyncField;
    @track selectedSyncValue;
    @track productRequestSyncValue;

    connectedCallback() {
        console.log('sapSyncFieldsManagement connected...');
        console.log('objectApiName: ' + this.objectApiName);
    }

    renderedCallback() {
        console.log('sapSyncFieldsManagement rendered...');
        console.log('objectApiName: ' + this.objectApiName);

        if(this.objectApiName === 'WorkOrder' || this.objectApiName === 'ProductRequest') {
            this.hideIsCreatedField = true;
        }
        else {
            this.hideIsCreatedField = false;
        }

        if(this.objectApiName === 'Address') {
            this.syncFieldIsCheckbox = true;
        }
        else {
            this.syncFieldIsCheckbox = false;
        }

        if(this.objectApiName === 'Measurement__c') {
            this.showSyncField = false;
        }
        else {
            this.showSyncField = true;
        }

        // Getting the Sync status if the record is a ProductRequest

        if(this.objectApiName === 'ProductRequest') {
            getProductRequestFromId({
                relatedId: this.recordId
            }).then((value => {
                this.productRequestSyncValue = value.IsSyncSAP__c;
            })).catch((error) => {
                const evt = new ShowToastEvent({
                    title: "An error occurred while retrieving this record's status",
                    variant: "error"
                });
                this.dispatchEvent(evt); 

                console.log('ERROR');
                console.log(error);
            })
        }

        console.log('hideIsCreatedField: ' + this.hideIsCreatedField);
        console.log('showSyncField: ' + this.showSyncField);
    }

    get showRecordEditForm() {
        if(this.objectApiName === 'ProductRequest') {
            return false;
        }
        else {
            return true;
        }
    }

    // Classic record edit form methods

    handleSuccess() {
        const evt = new ShowToastEvent({
            title: "Record updated",
            variant: "success"
        });
        this.dispatchEvent(evt); 
    }

    handleError(event) {
        const evt = new ShowToastEvent({
            title: "Error",
            message: "An error occurred while updating the record.",
            variant: "error"
        });
        this.dispatchEvent(evt); 

        console.log('ERROR:');
        console.log(JSON.stringify(event.detail));
    }

    handleSubmit() {
        console.log('Submitting...');
    }

    // Custom inputs methods

    get syncOptions() {
        return [
            { label: 'Sync', value: 'Sync' },
            { label: 'Not Sync', value: 'NotSync' }
        ];
    }

    handleSyncChange(event) {
        this.selectedSyncValue = event.detail.value;

        console.log('Selected Sync value: ' + this.selectedSyncValue);
    }

    handleCustomSaveClick() {
        console.log('HandleCustomSaveClick - selectedSyncValue: ' + this.selectedSyncValue);

        if(this.selectedSyncValue === undefined || this.selectedSyncValue === null) {
            this.selectedSyncValue = this.productRequestSyncValue;
        }

        setProductRequestSyncStatus({
            relatedId: this.recordId,
            syncStatus: this.selectedSyncValue
        }).then(() => {
            const evt = new ShowToastEvent({
                title: "Record updated",
                variant: "success"
            });
            this.dispatchEvent(evt); 
        }).catch((error) => {
            const evt = new ShowToastEvent({
                title: "Error",
                message: "An error occurred while updating the record.",
                variant: "error"
            });
            this.dispatchEvent(evt); 
    
            console.log('ERROR:');
            console.log(JSON.stringify(error));
        })
    }
}