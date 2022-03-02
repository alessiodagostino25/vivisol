import { LightningElement, api , track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Apex actions
import apexSearch from '@salesforce/apex/LookupController.contractTreatmentJobProductSearch';
import propagateSubstitute from '@salesforce/apex/CorporateTreatmentJobProductController.substituteCTJP';
import checkIsFamilyCTJP from '@salesforce/apex/CorporateTreatmentJobProductController.checkIsFamilyCTJP';
import checkForCTJPActivation from '@salesforce/apex/CorporateTreatmentJobProductController.checkForCTJPActivation';
import getCTJPFamily from '@salesforce/apex/CorporateTreatmentJobProductController.getCTJPFamily';

// Labels
import ManageStatus from '@salesforce/label/c.CT_JobTile_ManageStatus';
import AlreadyActiveProducts from '@salesforce/label/c.CJTP_AlreadyActiveProducts';
import AlreadyActiveFamily from '@salesforce/label/c.CJTP_AlreadyActiveFamily';
import UnableToActivateProduct from '@salesforce/label/c.Generic_UnableToActivateProduct';


export default class ProductConfigStatusModal extends LightningElement {

    label = {
        ManageStatus
    };
    newProductSelected;
    showManageStatusModal = false;
    showSubstituteButton = false;
    isMultiEntry = false;
    errors = [];
    CTJPFamily;
    
    @api selectedProductId;
    @api contractTreatmentJob;

    @track viewManageStatusModal = true;
    @track step1 = true;
    @track step2 = false;
    @track inputStatus;
    
    handleStatusSuccess() {
        console.log('Success!');
        this.showManageStatusModal = false;
        const successEvent = new CustomEvent('closestatusmodalevent', {
            detail:  {
                isUpdated: true,
                isSubstituted: false
            }
        });
        this.dispatchEvent(successEvent);
    }

    handleStatusSubmit(event) {
        if(this.inputStatus === 'Active') {
            event.preventDefault();

            getCTJPFamily({
                CTJPId: this.selectedProductId
            }).then((result) => {
                console.log('Product family: ' + result);
                this.CTJPFamily = result;

                checkForCTJPActivation({
                    CTJPId: this.selectedProductId
                }).then((result) => {
                    console.log('CHECK RESULT: ' + result);
    
                    if(result === true) {
                        // Submitting the form if the result is true
    
                        this.template.querySelector('lightning-record-edit-form').submit();
                    }
                    else {
                        // Not submitting the form if the result is false
            
                        if(this.CTJPFamily != undefined && this.CTJPFamily != null) {
                            const evt = new ShowToastEvent({
                                title: UnableToActivateProduct,
                                message: AlreadyActiveFamily,
                                variant: "error"
                            });
                            this.dispatchEvent(evt);
                        }
                        else {
                            const evt = new ShowToastEvent({
                                title: UnableToActivateProduct,
                                message: AlreadyActiveProducts,
                                variant: "error"
                            });
                            this.dispatchEvent(evt);
                        }
                    }
                });
            });
        }
    }

    handleLoadForm(event) {
        var record = event.detail.records;
        var fields = record[this.selectedProductId].fields;
        var initialStatus = fields.Status__c.value;
        console.log('initialStatus');
        console.log(initialStatus);
        if (initialStatus == 'Active'){
            this.checkIsFamily();
        } else {
            this.showSubstituteButton = false;
        }
    }

    handleSubstituteProductSubmit() {
        this.checkForErrors();
        if (this.errors.length > 0){
            console.log('Errore ---- missing field');
        } else {
            propagateSubstitute({
                oldContractTreatmentJobProduct: this.selectedProductId,
                newContractTreatmentJobProduct: this.newProductSelected
            }).then(() => {
                const successEvent = new CustomEvent('closestatusmodalevent', {
                    detail:  {
                        isUpdated: false,
                        isSubstituted: true
                    }
                });
                this.dispatchEvent(successEvent);
            }).catch(error => {
                const successEvent = new CustomEvent('closestatusmodalevent', {
                    detail:  {
                        isUpdated: false,
                        isSubstituted: false
                    }
                });
                this.dispatchEvent(successEvent);
            });

        }
    }

    checkIsFamily(){
        checkIsFamilyCTJP({
            contractTreatmentJobProduct: this.selectedProductId
        }).then(result => {
            if (result == true){
                this.showSubstituteButton = false;
            } else {
                this.showSubstituteButton = true;
            }
        })
        .catch(error => {
            this.showSubstituteButton = true;
        });
    }

    closeManageStatusModal() {
        const successEvent = new CustomEvent('closestatusmodalevent', {
            detail:  {
                isUpdated: false,
                isSubstituted: false
            }
        });
        this.dispatchEvent(successEvent);
        this.showManageStatusModal = false;
    }

    switchStepButton(){
        if (this.step1 == true){
            this.step1 = false;
            this.step2 = true;
        } else {
            this.step2 = false;
            this.step1 = true;   
        }
    }

    handleSearch(event) {
        const target = event.target;
        console.log('event.detail');
        console.log(event.detail.accountId);
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
        if(selection != undefined && selection.length != 0) {
            console.log('Location selezionata: ' + selection[0].title);
            this.newProductSelected = selection[0].id;
            this.errors = [];
            // TODO: do something with the lookup selection
        }
    }

    checkForErrors() {
        this.errors = [];
        const selection = this.template.querySelector('c-lookup').getSelection();
        console.log('Selection length: ' + selection);

        console.log(selection.length);

        // Enforcing required field
        if (selection.length === 0) {
            console.log('push errors');
            this.errors.push({ message: 'Please make a selection.' });
        }
    }

    handleInputChange(event) {
        this.inputStatus = event.detail.value;
        console.log('inputStatus: ' + this.inputStatus);
    }
}