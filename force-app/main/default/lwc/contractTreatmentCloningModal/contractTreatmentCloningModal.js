import { LightningElement, api, track, wire } from 'lwc';

// Apex methods
import startCloneProcess from '@salesforce/apex/ContractTreatmentController.cloneContractTreatment';
import apexSearch from '@salesforce/apex/LookupController.contractFrameworkSearch';
import assignPermSetNew from '@salesforce/apex/ContractTreatmentController.assignPermSetNew';
import removePermSet from '@salesforce/apex/ContractTreatmentController.removePermSet';

// Labels
import Info from '@salesforce/label/c.SectionTitle_Info';
import CloneButton from '@salesforce/label/c.Generic_Clone';
import Selection from '@salesforce/label/c.CF_ProductCodeSelection';
import SuccessTitle from '@salesforce/label/c.ContractTreatmentCloning_Success_Title';
import SuccessMessage from '@salesforce/label/c.ContractTreatmentCloning_Success_Message';

// Other stuff
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import CONTRACT_FRAMEWORK_FIELD from '@salesforce/schema/Contract_Treatment__c.Contract_Framework__c';

export default class ContractTreatmentCloningModal extends NavigationMixin(LightningElement) {
    labels = {
        Info,
        CloneButton,
        Selection
    }

    errors = [];
    isMultiEntry = false;

    @api recordId;

    @track isLoading = false;
    @track queryFields = [];
    @track selectedContractFrameworkId;
    @track currentContractFrameworkId;

    @wire(getRecord, { recordId: '$recordId', fields: '$queryFields'})
    getContractTreatment(value) {
        console.log('Wire...');
        const{data, error} = value;

        if(data) {
            let contractFrameworkField = data.fields.Contract_Framework__c.value;
            this.currentContractFrameworkId = contractFrameworkField;
            console.log('currentContractFrameworkId: ' + this.currentContractFrameworkId);
        }
        if(error) {
            console.log('ERROR!!!');
            console.log(error);
        }
    };

    connectedCallback() {
        console.log('Connected...');

        /* assignPermSetNew().then(() => {
            console.log('Contract_Creation permission set assigned!');
        })
        .catch(error => {
            console.log('ERROR ASSIGNING PERMISSION SET');
            console.log(JSON.stringify(error));
        }); */

        this.queryFields.push(CONTRACT_FRAMEWORK_FIELD);
    }

    renderedCallback() {
        console.log('contractTreatmentCloningModal recordId: ' + this.recordId);
    }

    disconnectedCallback() {
        removePermSet().then(() => {
            console.log('Contract_Creation permission set removed!');
        })
        .catch(error => {
            console.log('ERROR REMOVING PERMISSION SET');
            console.log(JSON.stringify(error));
        });
    }

    handleError() {
        // TODO
    }

    handleSuccess() {
        // TODO
    }

    handleCFSearch(event){
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
            console.log('CF selezionato: ' + selection[0].title);
            this.selectedContractFrameworkId = selection[0].id;
            // TODO: do something with the lookup selection
        }
    }

    handleSubmit(event) {
        this.checkForErrors();

        if(this.errors.length === 0) {

            this.isLoading = true;

            // Stopping the form from submitting...
            console.log('Handling submit...');
            event.preventDefault();

            // Getting the values from the input fields...
            const fields = event.detail.fields;
            console.log('Selected Framework: ' + this.selectedContractFrameworkId);
            console.log('Selected Name: ' + fields.Name);

            const contractFrameworkId = this.selectedContractFrameworkId;
            const name = fields.Name;

            // Calling the clone Apex method
            startCloneProcess({
                contractTreatmentId: this.recordId,
                contractFrameworkId: contractFrameworkId,
                name: name
            }).then(() => {
                this.isLoading = false;
                //console.log('Result: ' + result);

                const evt = new ShowToastEvent({
                    title: SuccessTitle,
                    message: SuccessMessage,
                    variant: "success"
                });
                this.dispatchEvent(evt);

                // Navigating to new CT record page
                /* this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result,
                        objectApiName: 'Contract_Treatment__c',
                        actionName: 'view'
                    },
                }); */

                // Sending event to parent Aura Component to close the quick action
                const closeEvent = new CustomEvent('close');
                this.dispatchEvent(closeEvent);
            }).catch(error => {
                this.isLoading = false;

                console.log('ERROR: ' + JSON.stringify(error));

                if(error.body.pageErrors != null && error.body.pageErrors != undefined && error.body.pageErrors.length > 0) {
                    if(error.body.pageErrors[0].statusCode === 'DUPLICATE_VALUE') {
                        const evt = new ShowToastEvent({
                            title: "Contract Treatment not successfully cloned",
                            message: "Another treatment with the same product exists on the target framework.",
                            variant: "error"
                        });

                        this.dispatchEvent(evt);
                    }
                    else {
                        if(error.body.pageErrors[0].message != null && error.body.pageErrors[0].message != undefined) {
                            const evt = new ShowToastEvent({
                                title: "Contract Treatment not successfully cloned",
                                message: error.body.pageErrors[0].message,
                                variant: "error"
                            });

                            this.dispatchEvent(evt);
                        }
                        else {
                            const evt = new ShowToastEvent({
                                title: "Contract Treatment not successfully cloned",
                                message: "An error occurred while trying to clone this Contract Treatment.",
                                variant: "error"
                            });

                            this.dispatchEvent(evt);
                        }
                    }
                }
            });
        }
    }

    // This handler only calls the click() of the real submit button of the REF: only way to trigger handleSubmit!
    handleCloneClick() {
        console.log('Clone clicked');
        this.template.querySelector('lightning-button').click(); 
    }

    closeModal() {
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
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