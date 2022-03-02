import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Labels
import labelError from '@salesforce/label/c.OrderCreateButton_ErrorMessage';
import labelMessage from '@salesforce/label/c.OrderCreateButton_Message';
import RedirectError from '@salesforce/label/c.Order_RedirectError';
import CreationError from '@salesforce/label/c.Order_CreationError';
import GenericError from '@salesforce/label/c.Generic_Error';

// Apex actions
import checkQuoteStatus from '@salesforce/apex/OrderQuoteController.checkQuoteStatus';
import createOrder from '@salesforce/apex/OrderQuoteController.createOrder';

export default class OrderQuote extends NavigationMixin(LightningElement) {

    @api objectApiName;
    @api recordId;

    @track currentObjectName;
    @track currentRecordId;
    @track message = labelMessage;
    @track isLoading = false;

    records = false;
    resultId = '';
    label = { labelError, labelMessage };

    createOrderAndRedirect() {
        this.currentRecordId = this.recordId;
        this.currentObjectName = this.objectApiName;
        this.isLoading = true;
        checkQuoteStatus({
            id: this.currentRecordId
        }).then(result => {
            this.records = result;
            if (this.records) {

                createOrder({
                    id: this.currentRecordId
                })
                    .then(result => {
                        this.resultId = result;
                        try {
                            this.navigateToRecordViewPage(this.resultId);
                        } catch (e) {
                            console.log('error ' + e);
                            this.isLoading = false;
                            this.message = RedirectError;
                        }
                    })
                    .catch(error => {
                        console.log('error' + error);
                        this.error = error;
                        this.isLoading = false;
                        this.message = CreationError;

                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: GenericError,
                                message: CreationError,
                                variant: 'error',
                            }),
                        );
            
                        this.closeQuickAction();
                    })
                    ;
            } else {
                this.message = labelError;
                this.isLoading = false;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: GenericError,
                        message: labelError,
                        variant: 'error',
                    }),
                );
    
                this.closeQuickAction();
            }
        }).catch(error => {
            console.log('error' + error);
            this.error = error;
            this.isLoading = false;
            this.message = CreationError;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: GenericError,
                    message: CreationError,
                    variant: 'error',
                }),
            );

            this.closeQuickAction();
        });
    }


    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }

    navigateToRecordViewPage(id) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                objectApiName: 'Order',
                actionName: 'view'
            }
        });
    }

}