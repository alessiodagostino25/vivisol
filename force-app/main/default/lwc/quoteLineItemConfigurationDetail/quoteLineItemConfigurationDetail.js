import { LightningElement, api, track, wire } from "lwc";
import { deleteRecord, updateRecord } from "lightning/uiRecordApi";
import MAX_DISC_FIELD from "@salesforce/schema/Quote_Line_Item__c.Max_discount__c";
import ID_FIELD from "@salesforce/schema/Quote_Line_Item__c.Id";
import TOT_AM_SAP_EX_VAT_FIELD from "@salesforce/schema/Quote_Line_Item__c.Total_Amount_from_SAP_excluding_VAT__c";
import TOT_VAT_SAP_FIELD from "@salesforce/schema/Quote_Line_Item__c.Total_VAT_from_SAP__c";
import TOT_AM_SAP_IN_VAT_FIELD from "@salesforce/schema/Quote_Line_Item__c.Total_Amount_from_SAP_including_VAT__c";
import VAT_FIELD from "@salesforce/schema/Quote_Line_Item__c.VAT__c";
import TOT_PR_IN_VAT_FIELD from "@salesforce/schema/Quote_Line_Item__c.TotalPrice_Including_VAT__c";
import TOT_PR_EX_VAT_FIELD from "@salesforce/schema/Quote_Line_Item__c.TotalPrice_excluding_VAT__c";
import QUANTITY_FIELD from "@salesforce/schema/Quote_Line_Item__c.Quantity__c";
import TOT_VAT_FIELD from "@salesforce/schema/Quote_Line_Item__c.Total_VAT__c";
import PROD_OBJECT from "@salesforce/schema/Product2";
import deleteButton from '@salesforce/label/c.createQuoteLineItem_DeleteButton';
import sureToDelete from '@salesforce/label/c.createQuoteLineItem_SureDeleteProductMsg';
import yesButton from '@salesforce/label/c.createQuoteLineItem_Yes';
import cancelButton from '@salesforce/label/c.createQuoteLineItem_Cancel';
import getSAPQuoteLineItemDTO from "@salesforce/apex/QuoteLineItemController.getSAPQuoteLineItemDTO";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import details from '@salesforce/label/c.createQuoteLineItem_details';
import confirmation from '@salesforce/label/c.createQuoteLineItem_confirmation';
import ErrorMessage from '@salesforce/label/c.Generic_Error';
import SAPSyncErrorSomeRecords from '@salesforce/label/c.SAP_SyncErrorSomeRecords';
import deleteQuoteLineItem from '@salesforce/apex/QuoteLineItemController.deleteQuoteLineItem';
import getAllowCallout from '@salesforce/apex/QuoteLineItemController.getAllowCallout';

export default class QuoteLineItemConfigurationDetail extends LightningElement {
    @api page2 = false;
    @api title;
    @api productName;
    @api productCode;
    @api productMeasure;
    @api quoteLineItemId;
    @api productId;
    @api isDisableDelButton;
    @api quoteStatus;
    @api item;
    @api isRequired;

    @track unitMeasureLabel;
    @track dto;
    @track confirmToDelete = false;
    @track quantityValue;

    label = { deleteButton, sureToDelete, yesButton, cancelButton, details, confirmation };
    allowCallout;

    @wire(getObjectInfo, { objectApiName: PROD_OBJECT })
    productInfo({ data, error }) {
        if (data) {
            this.unitMeasureLabel = data.fields.Unit_of_measure__c.label;
        }
    }

    connectedCallback() {
        console.log('quoteLineItemConfigurationDetail connected...');
        console.log('QuoteLineItemId: ' + this.quoteLineItemId);

        this.title = this.productName + " - " + this.productCode;
        this.isDisableDelButton = this.quoteStatus == "Accepted";
        this.isRequired = true;

        if(this.quoteLineItemId != null && this.quoteLineItemId != undefined) {
            getAllowCallout({
                quoteLineItemId: this.quoteLineItemId
            }).then(result => {
                this.allowCallout = result;
                console.log('allowCallout: ' + this.allowCallout);

                if(this.allowCallout) {
                    this.webServiceCallOut();
                }
                else {
                    console.log('Callout not allowed for QLI ' + this.quoteLineItemId);
                }
            }).catch(error => {
                console.log('ERROR!');
                console.log(JSON.stringify(error));
            });
        }
    }

    handleFocusEvent(event) {
        this.quantityValue = event.target.value;
    }

    handleChangeQuantity(event) {
        if (this.quantityValue != event.target.value) {
            this.quantityValue = event.target.value;
            this.updateQuoteLineItem();

            console.log('quantity changed')
        }
    }

    @api webServiceCallOut() {
        console.log('Callout allowed for QLI ' + this.quoteLineItemId);
        getSAPQuoteLineItemDTO({
            quotelineitemid: this.quoteLineItemId
        }).then(result => {
            if (result != null) {
                this.dto = JSON.parse(result);
                console.log('Response: ' + JSON.stringify(this.dto));

                let resultList = this.dto.resultList;

                if (resultList != null && resultList != undefined && resultList.length > 0) {
                    let success = resultList[0].success;

                    if (success != undefined && success === false) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: ErrorMessage,
                                message: SAPSyncErrorSomeRecords,
                                variant: 'error'
                            })
                        );
                    }
                }
                else {
                    console.log('dto value' + JSON.stringify(this.dto));
                    console.log('net value ' + this.dto.net_value);
                    console.log('net value ' + this.dto.tax_value);
                    this.dto.tax_value = Number(this.dto.tax_value);
                    this.dto.net_value = Number(this.dto.net_value);
                    console.log('net value ' + this.dto.net_value);
                    console.log('net value ' + this.dto.tax_value);

                    if (this.dto.max_disc == null) {
                        this.dto.max_disc = 0;
                    }

                    const fields = {};
                    fields[ID_FIELD.fieldApiName] = this.quoteLineItemId;
                    fields[TOT_AM_SAP_EX_VAT_FIELD.fieldApiName] = this.dto.net_value;
                    fields[TOT_VAT_SAP_FIELD.fieldApiName] = this.dto.tax_value;
                    fields[MAX_DISC_FIELD.fieldApiName] = this.dto.max_disc;
                    fields[TOT_AM_SAP_IN_VAT_FIELD.fieldApiName] = this.dto.net_value + this.dto.tax_value;
                    fields[VAT_FIELD.fieldApiName] = (this.dto.tax_value / this.dto.net_value) * 100;
                    fields[TOT_PR_IN_VAT_FIELD.fieldApiName] = this.dto.net_value + this.dto.tax_value;
                    fields[TOT_PR_EX_VAT_FIELD.fieldApiName] = this.dto.net_value;
                    fields[TOT_VAT_FIELD.fieldApiName] = this.dto.tax_value;

                    const recordInput = { fields };

                    updateRecord(recordInput).then(() => {
                        console.log('updated in webservice');
                    }).catch(error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Error creating record",
                                message: error.body.message,
                                variant: "error"
                            })
                        );
                    });
                }
            }
            else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: ErrorMessage,
                        message: SAPSyncErrorSomeRecords,
                        variant: 'error'
                    })
                );

                console.log('SAP RESPONSE NULL');
            }
        }).catch(error => {
            console.log("ERROR ITEMS" + JSON.stringify(error));
        });
    }
    @api updateQuoteLineItem() {
        // Create the recordInput object
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.quoteLineItemId;
        fields[QUANTITY_FIELD.fieldApiName] = this.quantityValue;

        const recordInput = { fields };
        updateRecord(recordInput)
            // eslint-disable-next-line no-unused-vars
            .then(() => {
                console.log('record is updated')
                this.webServiceCallOut();

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
    }

    deleteConfirm() {
        this.confirmToDelete = true;
        this.isRequired = false;
    }

    closeDeleteModal() {
        this.confirmToDelete = false;
        this.isRequired = true;
    }

    deleteMethod(event) {
        deleteQuoteLineItem({
            quoteLineItemId: this.quoteLineItemId
        }).then(() => {
            const quoteLineCreated = new CustomEvent("deletequotelineitem",
                {
                    detail: this.quoteLineItemId
                });
            this.dispatchEvent(quoteLineCreated);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Quote Line Item deleted",
                    variant: "success"
                })
            );
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error deleting record",
                    message: error.body.message,
                    variant: "error"
                })
            );
        });

        this.confirmToDelete = false;
    }

    @api handleSubmit() {
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    @api checkRequiredField() {
        /*const allValid = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);*/
        // var element  = this.template.querySelector('lightning-input-field');
        //console.log('element value'+element);
        //var quantity = element.value;

        if (this.quantityValue === null) {
            element.reportValidity();
            const event = new ShowToastEvent({
                title: 'Quantity Required',
                message: 'Check your input and try again.',
                variant: 'error'
            });
            this.dispatchEvent(event);
        } else {
            return true;
        }
    }
}