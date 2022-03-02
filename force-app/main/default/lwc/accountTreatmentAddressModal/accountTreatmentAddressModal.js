import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import apexSearch from '@salesforce/apex/LookupController.search';
import getLocationName from '@salesforce/apex/LocationDAO.getLocationNameFromId';

import Close from '@salesforce/label/c.CT_JobConfiguration_ModalCloseIcon';
import AddressConfiguration from '@salesforce/label/c.Generic_AddressConfiguration';

export default class AccountTreatmentAddressModal extends LightningElement {

    labels = {
        Close,
        AddressConfiguration
    }

    // Custom lookup component parameters

    isMultiEntry = false;
    errors = [];

    @api accountTreatmentId;
    @api accountId;
    @api selectedAddressId;

    @track editMode = false;
    @track selectedLocationId;
    @track isLoading = false;

    renderedCallback() {
        console.log('AccountTreatmentId in Modal: ' + this.accountTreatmentId);
        console.log('AccountId in Modal: ' + this.accountId);
        console.log('EditMode: ' + this.editMode);
        console.log('Selected AddressId: ' + this.selectedAddressId);

        if (this.selectedAddressId !== '') {
            this.editMode = true;
        }
    }

    closeModal() {
        const successEvent = new CustomEvent('save');
        this.dispatchEvent(successEvent);
    }

    handleSuccess() {
        this.isLoading = false;

        const evt = new ShowToastEvent({
            title: "Address Configured",
            message: "Address successfully configured",
            variant: "success"
        });
        this.dispatchEvent(evt);

        const successEvent = new CustomEvent('save');
        this.dispatchEvent(successEvent);
    }

    handleError(event) {
        this.isLoading = false;

        console.log('Error on Address Configuration: ' + event.detail);
    }

    handleSubmit(event) {
        this.isLoading = true;

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
            console.log('Selected Location Id: ' + this.selectedLocationId);
            const fields = event.detail.fields;
            fields.Location__c = this.selectedLocationId;

            // Filling ATA Name with the name of the Location

            getLocationName({
                locationId: this.selectedLocationId
            }).then((result) => {
                console.log('Result: ' + result);
                fields.Name = result;
                console.log('Name: ' + fields.Name);

                this.template.querySelector('lightning-record-edit-form').submit(fields);
            });

        }
    }

    handleSearch(event) {
        const target = event.target;
        apexSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
            });
    }

    handleSelectionChange(event) {
        const selection = event.target.getSelection();
        if (selection != undefined && selection.length != 0) {
            console.log('Location selezionata: ' + selection[0].title);
            this.selectedLocationId = selection[0].id;
            // TODO: do something with the lookup selection
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
}