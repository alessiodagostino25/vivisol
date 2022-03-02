import { LightningElement, api, track, wire } from 'lwc';

import box from '@salesforce/label/c.CustomOrderProductEdit_Box';
import Description from '@salesforce/label/c.CustomOrderProductEdit_Description';
import QuantityValidation from '@salesforce/label/c.CustomOrderProductEdit_QuantityValidation';
import unitofmeasure from '@salesforce/label/c.CustomOrderProductEdit_unitofmeasure';
import Name from '@salesforce/label/c.CustomOrderProductEdit_Name';
import Quantity from '@salesforce/label/c.CustomOrderProductEdit_Quantity';
import deleteButton from '@salesforce/label/c.AT_JobTile_DeleteButton';
import deleteModalMainTitle from '@salesforce/label/c.AT_JobTile_DeleteModal_Title';
import deleteModalMainBody from '@salesforce/label/c.OrderItem_DeleteModalMainBody';
import QUANTITY_FIELD from '@salesforce/schema/OrderItem.Quantity';
import ID_FIELD from '@salesforce/schema/OrderItem.Id';
import BOX_FIELD from '@salesforce/schema/OrderItem.Box__c';
import DESCRIPTION_FIELD from '@salesforce/schema/OrderItem.Description';
import Total_Amount_from_SAP_excluding_VAT__c_FIELD from '@salesforce/schema/OrderItem.Total_Amount_from_SAP_excluding_VAT__c';
import Total_Amount_from_SAP_including_VAT__c_FIELD from '@salesforce/schema/OrderItem.Total_Amount_from_SAP_including_VAT__c';
import TOTALVAT_FIELD from '@salesforce/schema/OrderItem.Total_VAT__c';
import VAT_FIELD from '@salesforce/schema/OrderItem.VAT__c';
import TotalPrice_excluding_VAT__c_FIELD from '@salesforce/schema/OrderItem.TotalPrice_excluding_VAT__c';
import TotalPrice_Including_VAT__c_FIELD from '@salesforce/schema/OrderItem.TotalPrice_Including_VAT__c';
import Total_VAT_from_SAP__c_FIELD from '@salesforce/schema/OrderItem.Total_VAT_from_SAP__c';
import MAXDISCOUNT_FIELD from '@salesforce/schema/OrderItem.Max_discount__c';
import deleteOrderItem from '@salesforce/apex/OrderItemCardController.deleteOrderItem';
import Details from '@salesforce/label/c.SectionTitle_Details';
import SAPSyncErrorSomeRecords from '@salesforce/label/c.SAP_SyncErrorSomeRecords';
import ErrorMessage from '@salesforce/label/c.Generic_Error';
import getOrderItem from '@salesforce/apex/OrderItemCardController.getOrderItem';
import getAllowCallout from '@salesforce/apex/OrderItemCardController.getAllowCallout';

import { updateRecord, } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import customorderitemsapcallout from '@salesforce/apex/customOrderProductPagecardController.customorderitemsapcallout';

export default class CustomOrderProductPageCard extends LightningElement {

    label = {
        unitofmeasure,
        box,
        Description,
        Name,
        Quantity,
        deleteButton,
        deleteModalMainTitle,
        deleteModalMainBody,
        QuantityValidation,
        Details

    };
    allowCallout;

    @track openmodal = false;
    @track webservicecalloutresponse = [];
    @track NetAmount = 0;
    @track vatAmount = 0;
    @track maxdiscount = 0;
    @track orderItem;
    @track unitOfMeasure;
    @track orderitemid;
    @track one = 0;

    @api name;
    @api quantity;
    @api productcode = 'ce45345';
    @api productunitofmeasure = 'pep';
    @api box;
    @api description;
    @api itemId;
    @api orderSent;

    connectedCallback() {
        console.log('customOrderProductPageCard connected...');

        const str = this.itemId;
        if (str.length > 22) {
            this.orderitemid = str.slice(0, -5);
        } 
        else {
            this.orderitemid = str;
        }

        getOrderItem({orderItemId: this.orderitemid}).then(result => {
            this.orderItem = result;
            this.unitOfMeasure = this.orderItem.Product2.Unit_of_measure__c;

            console.log('unitOfMeasure: ' + this.unitOfMeasure);
            console.log('OrderItem: ' + JSON.stringify(this.orderItem));

            if(this.orderitemid != null && this.orderitemid != undefined) {
                getAllowCallout({
                    orderItemId: this.orderitemid
                }).then(result => {
                    this.allowCallout = result;
                    console.log('allowCallout: ' + this.allowCallout);

                    if(this.allowCallout) {
                        this.webcallout();
                    }
                    else {
                        console.log('Callout not allowed for OrderItem ' + this.orderitemid + ' (not null values, would overwrite)');
                    }
                }).catch(error => {
                    console.log('ERROR!');
                    console.log(JSON.stringify(error));
                });
            }
        }).catch(error => {
            console.log(JSON.stringify(error));
        });

        /* if(this.orderitemid != null && this.orderitemid != undefined) {
            getAllowCallout({
                orderItemId: this.orderitemid
            }).then(result => {
                this.allowCallout = result;
                console.log('allowCallout: ' + this.allowCallout);

                this.webcallout();
            }).catch(error => {
                console.log('ERROR!');
                console.log(JSON.stringify(error));
            });
        } */
    }

    renderedCallback() {
        /* getOrderItem({orderItemId: this.orderitemid}).then(result => {
            this.orderItem = result;
            this.unitOfMeasure = this.orderItem.Product2.Unit_of_measure__c;

            console.log('unitOfMeasure: ' + this.unitOfMeasure);
            console.log('OrderItem: ' + JSON.stringify(this.orderItem));
        }).catch(error => {
            console.log(JSON.stringify(error));
        }); */

        /* if (this.one < 1) {

            this.webcallout();
            this.one = 2;
        } */

    }
    handleCloseDeleteModal() {
        this.openmodal = false;
    }


    @api updateorderitem() {

        console.log('reached the method')
        const str = this.itemId;

        if (str.length > 22) {
            this.orderitemid = str.slice(0, -5);
        } else {
            this.orderitemid = str;
        }
        // Create the recordInput object
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.orderitemid;
        fields[QUANTITY_FIELD.fieldApiName] = this.quantity;
        fields[DESCRIPTION_FIELD.fieldApiName] = this.description;
        fields[BOX_FIELD.fieldApiName] = this.box;

        const recordInput = { fields };

        console.log('recordinput ' + JSON.stringify(recordInput))
        console.log('record input with json ' + recordInput)

        updateRecord(recordInput)
            // eslint-disable-next-line no-unused-vars
            .then(() => {
                console.log('record is updated')

                this.webcallout();

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

    changeinquantity(event) {

        console.log('event value ' + event.target.value);
        if (event.target.value !== '0' && event.target.value !== '') {
            this.quantity = event.target.value;
            console.log('quantity value ' + this.quantity)

            this.updateorderitem();
            clearTimeout(this.timeoutId);
            this.timeoutId = setTimeout(this.doExpensiveThing.bind(this), 10000);
            console.log('change in quantity');

        }

    }

    changeinbox(event) {
        this.box = event.target.value;
        console.log('box value ' + this.box)
        this.updateorderitem();
    }
    changeindescription(event) {
        this.description = event.target.value;
        console.log('description value ' + this.description)
        this.updateorderitem();

    }


    presseddelete() {

        this.openmodal = true;
        console.log('button is pressed ')
    }

    closedelete() {
        this.openmodal = false;
        console.log('close is pressed')
    }

    deletetheorderitem() {
        deleteOrderItem({
            orderItemId: this.orderitemid
        }).then(() => {
            console.log('RECORD ' + this.orderitemid + ' ELIMINATO');

            this.dispatchEvent(new CustomEvent('orderitemdeleted'))

            const evt = new ShowToastEvent({
                title: "Order Item Deleted",
                //message: "Record ID: " + this.selectedProductId,
                variant: "success"
            });
            this.dispatchEvent(evt);
        }).catch(error => {
            this.error = error;
            console.log('ERROR IN DELETING RECORD: ' + this.error);
        });

        this.openmodal = false;

    }

    @api changesfromthesap() {

        clearTimeout(this.timeoutId);
        this.timeoutId = setTimeout(this.doExpensiveThing.bind(this), 2000);

        console.log('reached the changesfromthesap method')
        const str = this.itemId;
        if (str.length > 22) {
            this.orderitemid = str.slice(0, -5);
        } else {
            this.orderitemid = str;
        }
        // Create the recordInput object
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.orderitemid;
        fields[Total_Amount_from_SAP_excluding_VAT__c_FIELD.fieldApiName] = this.NetAmount;
        fields[Total_Amount_from_SAP_including_VAT__c_FIELD.fieldApiName] = this.NetAmount + this.vatAmount;
        fields[TOTALVAT_FIELD.fieldApiName] = this.vatAmount;
        fields[TotalPrice_excluding_VAT__c_FIELD.fieldApiName] = this.NetAmount;
        fields[TotalPrice_Including_VAT__c_FIELD.fieldApiName] = this.NetAmount + this.vatAmount;
        fields[Total_VAT_from_SAP__c_FIELD.fieldApiName] = this.vatAmount;
        fields[MAXDISCOUNT_FIELD.fieldApiName] = this.maxdiscount;
        fields[VAT_FIELD.fieldApiName] = ((this.vatAmount) / (this.NetAmount)) * 100;

        console.log('vat value ' + ((this.vatAmount) / (this.NetAmount)) * 100)



        const recordInput = { fields };

        updateRecord(recordInput)
            // eslint-disable-next-line no-unused-vars
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record Is Updated',
                    variant: 'sucess',
                }),
            );
            console.log('success in changesfromsap method')

        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error on data save',
                    message: error.message.body,
                    variant: 'error',
                }),
            );
            console.log('error in changesfromsap method' + error)
        });

    }

    @api webcallout() {
        console.log('reached webcallout')
        console.log('Callout allowed for OrderItem ' + this.orderitemid);
        
        customorderitemsapcallout({ 
            orderitemid: this.orderitemid}
        ).then(result => {
            if (result != null) {
                this.webservicecalloutresponse = JSON.parse(result);
                let resultList = this.webservicecalloutresponse.resultList;

                console.log('----- SAP Response:');
                console.log(JSON.stringify(this.webservicecalloutresponse));

                if(resultList != null && resultList != undefined && resultList.length > 0) {
                    let success = resultList[0].success;

                    if(success != undefined && success === false) {
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
                    this.NetAmount = Number(this.webservicecalloutresponse.net_value);
                    this.vatAmount = Number(this.webservicecalloutresponse.tax_value);
                    if (this.webservicecalloutresponse.max_disc == null) {
                        this.maxdiscount = 0;
                    } else {
                        this.maxdiscount = this.webservicecalloutresponse.max_disc;
                    }

                    this.changesfromthesap();

                    console.log('webserviceoiut' + JSON.stringify(this.webservicecalloutresponse))
                    console.log('net ammount' + this.NetAmount);
                    console.log('vat ammount' + this.vatAmount);
                    console.log('max discount ammount' + this.maxdiscount);
                }
            }
        })
        .catch(error => {
            this.error = error;
            console.log(this.error)
        });
    }


    doExpensiveThing() { }

}