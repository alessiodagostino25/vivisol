/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deleteModalMainBody from '@salesforce/label/c.AT_AccountTreatmentProductConfiguration_DeleteModalMainBody';
import ManageStatus from '@salesforce/label/c.AccountTreatment_ManageStatus';
import statusUpdated from '@salesforce/label/c.AccountTreatmentJobProduct_StatusUpdated';
import ManageStatus_BodyTitle from '@salesforce/label/c.AccountTreatmentJobProduct_ManageStatus_BodyTitle';
import deleteButton from '@salesforce/label/c.AT_JobTile_DeleteButton';
import deleteSuccess from '@salesforce/label/c.AccountTreatmentJobProduct_DeleteSuccess';

import PropagateQuantityHeader from '@salesforce/label/c.AccountTreatmentJobProduct_PropagateQuantityHeader';
import PropagateQuantityDescription from '@salesforce/label/c.AccountTreatmentJobProduct_PropagateQuantityDescription';
import PropagateQuantityButton from '@salesforce/label/c.AccountTreatmentJobProduct_PropagateQuantityButton';

import checkShowQuantity from '@salesforce/apex/ATPConfigurationController.getShowQuantityButton';
import propagateQuantity from '@salesforce/apex/ATPConfigurationController.propagateQuantity';
import propagateDelete from '@salesforce/apex/ATPConfigurationController.propagateDeleteToWOLI';

export default class AccountTreatmentProductConfiguration extends LightningElement {


    @api product;
    @track openmodal = false;
    @track managestatusdisabled;
    @track showManageStatusModal;
    @api accounttreatmentstatus;
    @track deletechanged;

    showPropagateQuantityButton = true;
    showPropagateQuantityModal = false;

    label = {
        deleteModalMainBody,
        ManageStatus,
        ManageStatus_BodyTitle,
        deleteButton,
        PropagateQuantityHeader,
        PropagateQuantityDescription,
        PropagateQuantityButton,
        statusUpdated,
        deleteSuccess
    };

    renderedCallback() {
        this.deletechanged = '\xa0\xa0\xa0\xa0\xa0\xa0\xa0' + deleteButton + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';
        if (this.accounttreatmentstatus === true) {

            this.managestatusdisabled = false;
        } else {
            this.managestatusdisabled = true;
        }
    }

    handleUpdateSuccess(){
        this.checkButtonVisibility();
    }

    handledClickShowPropagateQuantity() {
        this.showPropagateQuantityModal = true;
    }

    closePropagateQuantityModal() {
        this.showPropagateQuantityModal = false;
    }

    handledClickPropagateQuantity() {
        console.log('Id da riga: ' + this.product.Id);
        propagateQuantity({
            accountTreatmentJobProductId: this.product.Id
        }).then(() => {
            const evt = new ShowToastEvent({
                title: "Quantity Propagated",
                variant: "success"
            });
            this.dispatchEvent(evt);
            this.showPropagateQuantityButton = false;
            this.showPropagateQuantityModal = false;
        }).catch(error => {
            this.error = error;
            const evt = new ShowToastEvent({
                title: "Quantity Not Propagated",
                variant: "error"
            });
            this.dispatchEvent(evt);
            this.showPropagateQuantityModal = false;
        });
    }

    handlePropagateDelete() {
        console.log('Id da riga: ' + this.product.Id);
        propagateDelete({
            accountTreatmentJobProductId: this.product.Id
        }).then(() => {
            this.showUpdateStatusSuccessModal();
            this.showManageStatusModal = false;
        }).catch(error => {
            this.error = error;
            const evt = new ShowToastEvent({
                title: "WOLI Not Updated",
                variant: "error"
            });
            this.dispatchEvent(evt);
            this.showManageStatusModal = false;
        });
    }

    connectedCallback(){
        this.checkButtonVisibility();
    }

    checkButtonVisibility(){
        console.log('Id da riga: ' + this.selectedProductId);
        checkShowQuantity({ accountTreatmentJobProductId: this.product.Id })
        .then(result => {
            this.showPropagateQuantityButton = result;
        })
        .catch(error => {
            this.showPropagateQuantityButton = false;
        });         
    }
    
    handledelete() {
        this.openmodal = true;
        console.log('button is pressed ')
    }

    handleManageStatus() {
        this.showManageStatusModal = true;
    }
    
    handleStatusSubmit(event) {
        const fields = event.detail.fields;
        const newStatus = fields.Status__c;
        if (newStatus == 'Inactive'){
            this.handlePropagateDelete();
        } else {
            this.showUpdateStatusSuccessModal();
            this.showManageStatusModal = false;
        }
    }

    showUpdateStatusSuccessModal(){
        const evt = new ShowToastEvent({
            title: this.label.statusUpdated,
            variant: "success"
        });
        this.dispatchEvent(evt);
    }

    handleStatusSuccess() {
        /*const evt = new ShowToastEvent({
            title: this.label.statusUpdated,
            variant: "success"
        });
        this.dispatchEvent(evt);
        this.showManageStatusModal = false;*/
    }

    closemanagestatus() {
        this.showManageStatusModal = false;
    }

    closedelete() {
        this.openmodal = false;
        console.log('close is pressed')
    }
  
    savedelete() {
        console.log('delete pressed in product')
        // eslint-disable-next-line no-alert
        deleteRecord(this.product.Id)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: this.label.deleteSuccess,
                        variant: 'success'
                    })
                );
                // Navigate to a record home page after
                // the record is deleted, such as to the
                // contact home page

                const deleterefreshproduct = new CustomEvent('deleterefreshproduct', {
                    detail: this.product.Id

                });
                this.dispatchEvent(deleterefreshproduct);
                console.log('deletee refresh')

            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        this.openmodal = false;
    }

}