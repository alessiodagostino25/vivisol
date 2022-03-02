import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { deleteRecord } from 'lightning/uiRecordApi';
import { updateRecord, } from 'lightning/uiRecordApi';
//import { refreshApex } from '@salesforce/apex';

// Labels
import saveButton from '@salesforce/label/c.createQuoteLineItem_SaveButton';
import deleteButton from '@salesforce/label/c.createQuoteLineItem_DeleteButton';
import backButton from '@salesforce/label/c.createQuoteLineItem_BackButton';
import finishButton from '@salesforce/label/c.createQuoteLineItem_FinishButton';
import sureToDelete from '@salesforce/label/c.createQuoteLineItem_SureDeleteProductMsg';
import yesButton from '@salesforce/label/c.createQuoteLineItem_Yes';
import cancelButton from '@salesforce/label/c.createQuoteLineItem_Cancel';
import confirmation from '@salesforce/label/c.createQuoteLineItem_confirmation';
import details from '@salesforce/label/c.createQuoteLineItem_details';
import RetrievePrice from '@salesforce/label/c.Generic_RetrievePrice';
import SAPError from '@salesforce/label/c.SAP_SyncError';
import SAPPriceSynced from '@salesforce/label/c.SAP_PriceSynced';
import SuccessMessage from '@salesforce/label/c.Generic_Success';
import ErrorMessage from '@salesforce/label/c.Generic_Error';
import RecordUpdated from '@salesforce/label/c.Generic_RecordUpdated';
import ManageDiscount from '@salesforce/label/c.QuoteLineItem_ManageDiscountButton';

// Apex actions
//import apexSearch from '@salesforce/apex/LookupController.assetsearch';
import getQuoteLineItemByIdsMethod from '@salesforce/apex/QuoteLineItemController.getQuoteLineItemByIds';
import getSAPQuoteLineItemDTO from "@salesforce/apex/QuoteLineItemController.getSAPQuoteLineItemDTO";
import deleteQuoteLineItem from '@salesforce/apex/QuoteLineItemController.deleteQuoteLineItem';

// QLI fields
//import ASSET_FIELD from '@salesforce/schema/Quote_Line_Item__c.Asset__c';
import ID_FIELD from '@salesforce/schema/Quote_Line_Item__c.Id';
import MAX_DISC_FIELD from "@salesforce/schema/Quote_Line_Item__c.Max_discount__c";
import TOT_AM_SAP_EX_VAT_FIELD from "@salesforce/schema/Quote_Line_Item__c.Total_Amount_from_SAP_excluding_VAT__c";
import TOT_VAT_SAP_FIELD from "@salesforce/schema/Quote_Line_Item__c.Total_VAT_from_SAP__c";
import TOT_AM_SAP_IN_VAT_FIELD from "@salesforce/schema/Quote_Line_Item__c.Total_Amount_from_SAP_including_VAT__c";
import VAT_FIELD from "@salesforce/schema/Quote_Line_Item__c.VAT__c";
import TOT_PR_IN_VAT_FIELD from "@salesforce/schema/Quote_Line_Item__c.TotalPrice_Including_VAT__c";
import TOT_PR_EX_VAT_FIELD from "@salesforce/schema/Quote_Line_Item__c.TotalPrice_excluding_VAT__c";
import TOT_VAT_FIELD from "@salesforce/schema/Quote_Line_Item__c.Total_VAT__c";


export default class QuoteLineItemGetPriceEdit extends NavigationMixin(LightningElement) {
    @track label = { 
        saveButton, 
        deleteButton, 
        backButton, 
        finishButton, 
        sureToDelete, 
        yesButton, 
        cancelButton, 
        confirmation, 
        details, 
        RetrievePrice,
        ManageDiscount
    }; 
    @track searchData;
    @track recordToDelete;
    @track isButtonDisabled;
    @track confirmToDelete = false;
    @track productNameCode;
    @track productName;
    @track productCode;
    @track selection;
    @track showManageDiscountModal = false;
    @track manageDiscountRecordId;
    @track manageDiscountRecordDiscountType;
    
    @api page3 = false;
    @api page1;
    @api page2;
    @api reloadStep3 = false;
    @api recordId;
    @api quoteStatus;
    @api recordsToAnalize;
    @api isLoading = false;

    connectedCallback() {
        this.isButtonDisabled = this.quoteStatus == "Accepted";
    }

    renderedCallback() {
        if (this.page3 && this.reloadStep3) {
            this.reloadStep3 = false;
            this.isLoading = true;
            setTimeout(() => {
                this.isLoading = false;
            }, 2000);
        }
    }

    //function that is invoked when success an update
    handleSuccess(event) {

        const evt = new ShowToastEvent({
            title: RecordUpdated,
            variant: "success"
        });
        this.dispatchEvent(evt);

    }

    //function that is invoked when fail an update
    handleError(event) {
        const evt = new ShowToastEvent({
            title: ErrorMessage,
            variant: "error"
        });
        this.dispatchEvent(evt);
    }

    //function that is invoked to open delete's popup
    deleteConfirm(event) {
        this.productName = event.target.dataset.name;
        this.productCode = event.target.dataset.code;
        this.productNameCode = " " + this.productName + " - " + this.productCode + "?";
        this.recordToDelete = event.target.dataset.id;
        this.confirmToDelete = true;
    }

    // function that is invoked when  cancel a quote line item
    deleteMethod(event) {
        this.isLoading = true;
      /*   for (let i = 0; i < this.recordsToAnalize.length; i++) {

            if (this.recordsToAnalize[i].Id === this.recordToDelete) {
                this.recordsToAnalize.splice(i, 1);
            }
        } */
        deleteQuoteLineItem({quoteLineItemId: this.recordToDelete})
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Quote Line Item deleted",
                        variant: "success"
                    })
                );
                let remainItemId= [];
                for( var i = 0; i < this.recordsToAnalize.length; i++){
                    if(this.recordsToAnalize[i].Id != this.recordToDelete) {                    
                        remainItemId.push(this.recordsToAnalize[i].id);
                    }
                }
         
                if(remainItemId.length > 0) {
                    getQuoteLineItemByIdsMethod({
                        quoteLineItemsIds: remainItemId
                    })
                    .then(result => {
                        this.recordsToAnalize = result;
                        this.isLoading = false;
                        //refreshApex(this.recordsToAnalize);
                    })
                    .catch((error) => {
                        /* var message = 'Error received: code' + error.body.output.errors[0].errorCode + ', ' +
                            'message ' + error.body.output.errors[0].message; */
                            console.log('ERROR '+ error);
                    });
                }
                else {
                    //refreshApex(this.recordsToAnalize);
                    this.isLoading = false;
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.output.errors[0].message,
                        variant: 'error'
                    })
                );
            });
        this.confirmToDelete = false;

    }
    // function that is invoked when click cancel to close a cancel's modal
    closeDeleteModal() {
        this.confirmToDelete = false;
    }

    // function that is invoked when click back
    handleBack(event) {
        this.page3 = false;
        const exitpriceedit = new CustomEvent('exitpriceedit', {
            //detail: this.page3
            detail: this.recordsToAnalize
        });
        this.dispatchEvent(exitpriceedit);
    }

    // function that is invoked when click finish
    handleFinish(event) {
        this.navigateToRecordViewPage(this.recordId);

        var close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: close
        });

        // Fire the custom event
        this.dispatchEvent(closeclickedevt);
    }

    // function that is invoked to redirect
    navigateToRecordViewPage(id) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                objectApiName: 'Quote__c',
                actionName: 'view'
            }
        });

    }

    /* handleSubmit(event) {
       
        event.preventDefault();
        console.log('save button is pressed');
        if(this.errors.length > 0) {
            /* do error message
        }
        else {
            console.log('Selected asset Id: ' + this.selectedAssetId);
            console.log(' Id: ' + event.target.dataset.id);
            console.log('fields'+JSON.stringify(event.detail.fields));
            const fields = event.detail.fields;
            fields[ID_FIELD.fieldApiName] = event.target.dataset.id;
            
            fields[ASSET_FIELD.fieldApiName] = this.selectedAssetId;
           
    
            const recordInput = { fields };
    
            console.log('recordinput '+JSON.stringify(recordInput))
            console.log('record input with json '+recordInput)
    
            updateRecord(recordInput)
            // eslint-disable-next-line no-unused-vars
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: SuccessMessage,
                        message: RecordUpdated,
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.output.errors[0].message,
                        variant: 'error',
                    }),
                );
            });
        }
    } */

    /* handleSearch(event) {
        const target = event.target;
        apexSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
            });
    } */

    /* handleSelectionChange(event) {
        this.selection  = event.target.getSelection();
        if( this.selection  != '' && this.selection.length != 0){
        console.log('asset selection ' + JSON.stringify(this.selection));
        this.selectedAssetId = this.selection[0].id;
        }
        // TODO: do something with the lookup selection
    } */

    retrySync(event) {
        this.isLoading = true;
        let quoteLineItemId = event.target.dataset.id;

        console.log('SYNC ID: ' + event.target.dataset.id);

        getSAPQuoteLineItemDTO({
            quotelineitemid: quoteLineItemId
        }).then(result => {
            let sapResponse = JSON.parse(result);

            console.log('----- SAP RESPONSE: ' + JSON.stringify(sapResponse));

            if(sapResponse != null) {
                let resultList = sapResponse.resultList;

                if(resultList != null && resultList != undefined && resultList.length > 0) {
                    let success = sapResponse.resultList[0].success;

                    if(success != undefined && success === false) {
                        this.isLoading = false;
                        let errorMessage = sapResponse.resultList[1].log_event.errorList[0].error_Description;

                        console.log('----- SAP Error: ');
                        console.log(errorMessage);

                        if(errorMessage != null && errorMessage != undefined) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: ErrorMessage,
                                    message: errorMessage,
                                    variant: 'error'
                                })
                            );
                        }
                        else {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: ErrorMessage,
                                    message: SAPError,
                                    variant: 'error'
                                })
                            );
                        }
                    }
                }
                else {
                    let netAmount = Number(sapResponse.net_value);
                    let vatAmount = Number(sapResponse.tax_value);
                    let maxDiscount = 0;

                    if(sapResponse.max_disc != null) {
                        maxDiscount = Number(sapResponse.max_disc);
                    }

                    const fields = {};
                
                    fields[ID_FIELD.fieldApiName] = quoteLineItemId;
                    fields[TOT_AM_SAP_EX_VAT_FIELD.fieldApiName] = netAmount;
                    fields[TOT_VAT_SAP_FIELD.fieldApiName] = vatAmount;
                    fields[MAX_DISC_FIELD.fieldApiName] = maxDiscount;
                    fields[TOT_AM_SAP_IN_VAT_FIELD.fieldApiName] = netAmount + vatAmount;
                    fields[VAT_FIELD.fieldApiName] = (vatAmount / netAmount) * 100;
                    fields[TOT_PR_IN_VAT_FIELD.fieldApiName] = netAmount + vatAmount;
                    fields[TOT_PR_EX_VAT_FIELD.fieldApiName] = netAmount;
                    fields[TOT_VAT_FIELD.fieldApiName] = vatAmount;

                    const recordInput = { fields };

                    console.log('Record Input:');
                    console.log(recordInput);

                    updateRecord(recordInput).then(() => {
                        this.isLoading = false;

                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: SuccessMessage,
                                message: SAPPriceSynced,
                                variant: 'success'
                            })
                        );
                    }).catch(error => {
                        this.isLoading = false;

                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: ErrorMessage,
                                message: error.body.message,
                                variant: 'error'
                            })
                        );

                        console.log(JSON.stringify(error));
                    });
                }
            }
            else {
                this.isLoading = false;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: ErrorMessage,
                        message: SAPError,
                        variant: 'error'
                    })
                );

                console.log('SAP RESPONSE NULL');
            }
        }).catch(error => {
            this.isLoading = false;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: ErrorMessage,
                    message: SAPError,
                    variant: 'error'
                })
            );

            console.log(JSON.stringify(error));
        });
    }

    handleManageDiscountClick(event) {
        this.manageDiscountRecordId = event.target.dataset.id;
        this.manageDiscountRecordDiscountType = event.target.dataset.discounttype;
        
        this.showManageDiscountModal = true;
    }

    closeManageDiscountModal() {
        this.showManageDiscountModal = false;
    }
}