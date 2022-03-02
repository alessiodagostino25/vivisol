import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ASSET_FIELD from '@salesforce/schema/OrderItem.Asset__c';
import ID_FIELD from '@salesforce/schema/OrderItem.Id';
import QUANTITY_FIELD from '@salesforce/schema/OrderItem.Quantity';
import TOTAL_AMOUNT_FROM_SAP_EXCLUDING_VAT_FIELD from '@salesforce/schema/OrderItem.Total_Amount_from_SAP_excluding_VAT__c';
import TOTAL_AMOUNT_FROM_SAP_INCLUDING_VAT_FIELD from '@salesforce/schema/OrderItem.Total_Amount_from_SAP_including_VAT__c';
import TOTALVAT_FIELD from '@salesforce/schema/OrderItem.Total_VAT__c';
import TOTALPRICE_EXCLUDING_VAT_FIELD from '@salesforce/schema/OrderItem.TotalPrice_excluding_VAT__c';
import TOTALPRICE_INCLUDING_VAT_FIELD from '@salesforce/schema/OrderItem.TotalPrice_Including_VAT__c';
import TOTAL_VAT_FROM_SAP_FIELD from '@salesforce/schema/OrderItem.Total_VAT_from_SAP__c';
import MAXDISCOUNT_FIELD from '@salesforce/schema/OrderItem.Max_discount__c';
import VAT_FIELD from '@salesforce/schema/OrderItem.VAT__c';

// Apex actions

import getCardTitle from '@salesforce/apex/OrderItemCardController.getCardTitle';
import deleteOrderItem from '@salesforce/apex/OrderItemCardController.deleteOrderItem';
//import apexSearch from '@salesforce/apex/LookupController.assetsearch';
import sapCallout from '@salesforce/apex/customOrderProductPagecardController.customorderitemsapcallout';

// Labels

import Delete from '@salesforce/label/c.Btn_Delete';
import Cancel from '@salesforce/label/c.Btn_Cancel';
import Close from '@salesforce/label/c.CT_JobConfiguration_ModalCloseIcon';
import Save from '@salesforce/label/c.AT_ProductSelection_SaveButton';
import Details from '@salesforce/label/c.SectionTitle_Details';
import RetrievePrice from '@salesforce/label/c.Generic_RetrievePrice';
import SAPError from '@salesforce/label/c.SAP_SyncError';
import SAPPriceSynced from '@salesforce/label/c.SAP_PriceSynced';
import SuccessMessage from '@salesforce/label/c.Generic_Success';
import ErrorMessage from '@salesforce/label/c.Generic_Error';
import ManageDiscount from '@salesforce/label/c.QuoteLineItem_ManageDiscountButton';


export default class OrderItemCard extends LightningElement {

    labels = {
        Delete,
        Cancel,
        Close,
        Save,
        Details,
        RetrievePrice,
        ManageDiscount
    };

    //isMultiEntry = false;
    //errors = [];

    @api orderItemId;
    @api orderSent;
    //@api inputassetvalue;

    @track cardTitle;
    @track error;
    @track showDeleteModal = false;
    @track showManageDiscountModal = false;
    @track isLoading = false;
    @track isButtonDisabled = false;

    @wire(getRecord, { recordId: '$orderItem', fields: [QUANTITY_FIELD, ASSET_FIELD] })
    orderItem;

    get inputassetvalue() {
        console.log('----- input asset: ' + getFieldValue(this.orderItem.data, ASSET_FIELD));
        return getFieldValue(this.orderItem.data, ASSET_FIELD);
    }

    get orderItemQuantity() {
        return getFieldValue(this.orderItem.data, QUANTITY_FIELD);
    }

    connectedCallback() {
        getCardTitle({ orderItemId: this.orderItemId }).then(result => {
            this.cardTitle = result;
        })
            .catch(error => {
                this.error = error;
                console.log('Error while retrieving cardTitle: ' + this.error);
            });

        console.log('Order sent? ' + this.orderSent);
    }

    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: "Order Item Configured",
            //message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        this.dispatchEvent(evt);

        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    handleDeleteClick() {
        this.showDeleteModal = true;
    }

    handleCloseDeleteModal() {
        this.showDeleteModal = false;
    }

    handleDeleteOrderItem() {

        deleteOrderItem({
            orderItemId: this.orderItemId
        }).then(() => {
            console.log('RECORD ' + this.orderItemId + ' ELIMINATO');

            this.dispatchEvent(new CustomEvent('orderitemdeleted'))

            const evt = new ShowToastEvent({
                title: "Order Item Deleted",
                //message: "Record ID: " + this.selectedProductId,
                variant: "success"
            });
            this.dispatchEvent(evt);
        }).catch(error => {
            this.error = error;
            console.log('ERROR ' + this.error);
        });


        this.showDeleteModal = false;
    }
    
    /* handleSubmit(event) {

        event.preventDefault();

        console.log('Selected asset Id: ' + this.selectedAssetId);
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.orderItemId;
        fields[ASSET_FIELD.fieldApiName] = this.selectedAssetId;


        const recordInput = { fields };

        console.log('recordinput ' + JSON.stringify(recordInput))
        console.log('record input with json ' + recordInput)

        updateRecord(recordInput)
            // eslint-disable-next-line no-unused-vars
            .then(() => {
                console.log('record is updated')

            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error on data save',
                        message: error.message.body,
                        variant: 'error',
                    }),
                );

            });

        const fields1 = event.detail.fields;

        this.template.querySelector('lightning-record-edit-form').submit(fields1);
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
        const selection = event.target.getSelection();
        if(selection != '' && selection.length != 0){
        console.log('asset selection ' + JSON.stringify(selection));
        this.selectedAssetId = selection[0].id;
        }
        // TODO: do something with the lookup selection
    } */

    retrySync() {
        this.isLoading = true;

        sapCallout({
            orderitemid: this.orderItemId
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
                
                    fields[ID_FIELD.fieldApiName] = this.orderItemId;
                    fields[TOTAL_AMOUNT_FROM_SAP_EXCLUDING_VAT_FIELD.fieldApiName] = netAmount;
                    fields[TOTAL_AMOUNT_FROM_SAP_INCLUDING_VAT_FIELD.fieldApiName] = netAmount + vatAmount;
                    fields[TOTALVAT_FIELD.fieldApiName] = vatAmount;
                    fields[TOTALPRICE_EXCLUDING_VAT_FIELD.fieldApiName] = netAmount;
                    fields[TOTALPRICE_INCLUDING_VAT_FIELD.fieldApiName] = netAmount + vatAmount;
                    fields[TOTAL_VAT_FROM_SAP_FIELD.fieldApiName] = vatAmount;
                    fields[MAXDISCOUNT_FIELD.fieldApiName] = maxDiscount;
                    fields[VAT_FIELD.fieldApiName] = ((vatAmount) / (netAmount)) * 100;

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

    handleManageDiscountClick() {
        this.showManageDiscountModal = true;
    }

    closeManageDiscountModal() {
        this.showManageDiscountModal = false;
    }
}