import { LightningElement,api,track, wire } from 'lwc';
import getATA from '@salesforce/apex/ATAPSelectionController.getATA';
import apexSearchContractPayer from '@salesforce/apex/LookupController.apexSearchContractPayer';

export default class AccountTreatmentAddressPayerModal extends LightningElement {

    @api accountTreatmentId;
    @api selectedAddressId;
    @track editMode = false;
    @track isLoading = false;
    @track defaultAddress;
    @track selectedContractpayer;
    @track selectedpayer;
    @track selectedbillto;
    errors = [];

    @wire(getATA, {accountTreatmentId: '$accountTreatmentId'})
    valueofata({ data }) 
    {
        if(data){
            this.defaultAddress = data ;
        }
    }

    closeModal() {
        const successEvent = new CustomEvent('save');
        this.dispatchEvent(successEvent);
    }

    handleSuccess() {
        this.isLoading = false;

        const evt = new ShowToastEvent({
            title: "Address Payer Configured",
            message: "Address Payer successfully configured",
            variant: "success"
        });
        this.dispatchEvent(evt);

        const successEvent = new CustomEvent('save');
        this.dispatchEvent(successEvent);
    }

    handleError(event) {
        this.isLoading = false;

        console.log('Error on Address Payer Configuration: ' + event.detail);
    }


    checkForErrors() {
        this.errors = [];
    /*     const selection = this.template.querySelector('c-lookup').getSelection();
        console.log('Selection length: ' + selection);

        // Enforcing required field
        if (selection.length === 0) {
            this.errors.push({ message: 'Please make a selection.' });
        } */
    }

    handleSearch(event) {
        const target = event.target;
        apexSearchContractPayer(event.detail)
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
          
            this.selectedContractpayer = selection[0].Id;
            this.selectedpayer = selection[0].Payer__c;
            this.selectedbillto = selection[0].Bill_To__c;
            // TODO: do something with the lookup selection
            // TODO: do something with the lookup selection
        }
    }

    handleSubmit(event) {
        this.isLoading = true;

        this.checkForErrors();
        event.preventDefault();
        if (this.errors.length > 0) {
        
        }
        else {
           
            const fields = event.detail.fields;
            fields.Contract_Payer__c = this.selectedContractpayer
            fields.Payer__c  = this.selectedpayer;
            fields.Bill_To__c  = this.selectedbillto;

                this.template.querySelector('lightning-record-edit-form').submit(fields);
        

        }
    }
}