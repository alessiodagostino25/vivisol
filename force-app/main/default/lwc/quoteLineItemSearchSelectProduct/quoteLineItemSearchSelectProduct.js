import { LightningElement, track, api, wire } from 'lwc';
import { updateRecord } from "lightning/uiRecordApi";
import getQuoteLineItemsMethod from '@salesforce/apex/QuoteLineItemController.getQuoteLineItems';
import getAllProductsMethod from '@salesforce/apex/QuoteLineItemController.getAllProducts';
import getPricebookEntryMethod from '@salesforce/apex/QuoteLineItemController.getPricebookEntry';
import createQuoteLineItemMethod from '@salesforce/apex/QuoteLineItemController.createQuoteLineItem';
import getQuoteLineItemByIdsMethod from '@salesforce/apex/QuoteLineItemController.getQuoteLineItemByIds';
import getSAPQuoteLineItemDTO from "@salesforce/apex/QuoteLineItemController.getSAPQuoteLineItemDTO";
import MAX_DISC_FIELD from "@salesforce/schema/Quote_Line_Item__c.Max_discount__c";
import ID_FIELD from "@salesforce/schema/Quote_Line_Item__c.Id";
import TOT_AM_SAP_EX_VAT_FIELD from "@salesforce/schema/Quote_Line_Item__c.Total_Amount_from_SAP_excluding_VAT__c";
import TOT_VAT_SAP_FIELD from "@salesforce/schema/Quote_Line_Item__c.Total_VAT_from_SAP__c";
import TOT_AM_SAP_IN_VAT_FIELD from "@salesforce/schema/Quote_Line_Item__c.Total_Amount_from_SAP_including_VAT__c";
import VAT_FIELD from "@salesforce/schema/Quote_Line_Item__c.VAT__c";
import TOT_PR_IN_VAT_FIELD from "@salesforce/schema/Quote_Line_Item__c.TotalPrice_Including_VAT__c";
import TOT_PR_EX_VAT_FIELD from "@salesforce/schema/Quote_Line_Item__c.TotalPrice_excluding_VAT__c";
import TOT_VAT_FIELD from "@salesforce/schema/Quote_Line_Item__c.Total_VAT__c";
import labelPleaseEnterMessage from '@salesforce/label/c.createQuoteLineItem_PleaseEnterMessage';
import labelSearchEnter from '@salesforce/label/c.createQuoteLineItem_SearchEnter';
import labelProductName from '@salesforce/label/c.createQuoteLineItem_ProductName';
import labelProductCode from '@salesforce/label/c.createQuoteLineItem_ProductCode';
import labelProductFamily from '@salesforce/label/c.createQuoteLineItem_ProductFamily';
import labelManufacturerpartnumber from '@salesforce/label/c.createQuoteLineItem_Manufacturerpartnumber';
import labelNoProductsFoundMsg from '@salesforce/label/c.createQuoteLineItem_NoProductsFoundMsg';
import labelNextButton from '@salesforce/label/c.createQuoteLineItem_NextButton';
import labelShowSelected from '@salesforce/label/c.createQuoteLineItem_ShowSelected';
import labelSearchProducts from '@salesforce/label/c.createQuoteLineItem_SearchProducts';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class QuoteLineItemSearchSelectProduct extends LightningElement {

    @api recordId;
    @api mode;
    @api listItems;
    @api quoteLineItemsCreated;
    @api recordsToAnalize;
    @api quoteStatus;

    @api reloadStep1 = false;

    @api page1 = false;
    @api page2;
    @api page3;

    @api searchData;
    @api totalProducts;
    @api selected = labelShowSelected + ' (0/0)';

    @track errorMsg = '';
    @api strSearchProductName;

    @track dto;
    @track quantityValue = 1 ;

    @track searchEnter = labelSearchEnter;
    @track currenRecordId;
    @track isLoading = false;
    @api isButtonDisabled;
    @api selectedProducts;

    @api pricebookEntry;
    productsRecord;

    label = {
        labelPleaseEnterMessage, labelSearchEnter, labelProductName, labelProductCode, labelProductFamily,
        labelManufacturerpartnumber, labelNextButton, labelSearchProducts
    };

    //Init function, launch two function for recover mode (edit or create) and search all product LIMIT 100
    connectedCallback() {
        getQuoteLineItemsMethod({ quoteId: this.recordId })
            .then(result => {
                this.listItems = result;
                if (result.length > 0) {
                    //this.quoteStatus = this.listItems[0].Quote_Name__r.Status__c;
                    this.mode = 'edit';
                    this.isButtonDisabled = false;
                } else {
                    this.mode = 'create';
                    this.isButtonDisabled = true;
                }
            })
            .catch(error => {
                window.console.log('error  ' + error);
                if (error) {
                    console.log('Error message: ' + error.body.message);
                }
            })

        //Call controller method, for recover all products (limit 100)
        getAllProductsMethod({ id: this.recordId, pricebookentryList: this.selectedProducts })
            .then(result => {
                this.searchData = result;
                this.totalProducts = 0;
                this.totalProducts = this.searchData.length;
                this.selected = labelShowSelected + ' (' + this.selectedProducts.length + '/' + this.totalProducts + ')';

            })
            .catch(error => {
                this.searchData = undefined;
                window.console.log('error  ' + error);
                if (error) {
                    console.log('Error message: ' + error.body.message);
                }
            })
    }

    //function captures the event of when you start writing characters
    keyCheck(event) {
        this.errorMsg = '';
        // if (event.which == 13){
        this.strSearchProductName = event.target.value;
        this.handleSearchProducts();
        //  }    
    }

    // Select the all rows
    allSelected(event) {
        this.selectedProducts = [];
        let selectedRows = this.template.querySelectorAll('lightning-input');
        this.checkedAll = event.target.checked;
        console.log('checkedAll? ' + this.checkedAll);
        if (this.checkedAll) {
            for (let i = 0; i < selectedRows.length; i++) {
                if (selectedRows[i].type === 'checkbox') {
                    selectedRows[i].checked = this.checkedAll;
                    let productIdValue = selectedRows[i].dataset.product2id;
                    if (productIdValue) {
                        let pricebook2IdValue = selectedRows[i].dataset.pricebook2id;
                        let idValue = selectedRows[i].dataset.id;
                        this.selectedProducts.push({
                            product2id: productIdValue,
                            pricebook2id: pricebook2IdValue,
                            id: idValue
                        });
                    }
                }
            }
        } else {
            for (let i = 0; i < selectedRows.length; i++) {
                if (selectedRows[i].type === 'checkbox') {
                    selectedRows[i].checked = this.checkedAll;

                }
            }
            this.selectedProducts = [];
        }
        this.selected = labelShowSelected + ' (' + this.selectedProducts.length + '/' + this.totalProducts + ')';
        console.log('Selected: ' + this.selected);
        if (this.selectedProducts.length > 0) {
            this.isButtonDisabled = false;
        } else {
            this.isButtonDisabled = true;
        }
        /* if (this.mode == 'edit') {
            this.isButtonDisabled = false;
        } else {
            this.isButtonDisabled = true;
        } */
    }

    //Event when select one product checkbox 
    handleChange(event) {
        this.areDetailsVisible = event.target.checked;
        if (this.areDetailsVisible) {
            let pricebook2idValue = event.target.dataset.pricebook2id;
            let productIdValue = event.target.dataset.product2id;
            let idValue = event.target.dataset.id;
            if (this.selectedProducts.length == 0) {
                this.selectedProducts = [];
            }
            this.selectedProducts.push({
                product2id: productIdValue,
                pricebook2id: pricebook2idValue,
                id: idValue
            });
        } else {
            for (var i = 0; i < this.selectedProducts.length; i++) {
                if (this.selectedProducts[i].product2id === event.target.dataset.product2id) {
                    this.selectedProducts.splice(i, 1);
                }
            }
        }
        this.selected = labelShowSelected + ' (' + this.selectedProducts.length + '/' + this.totalProducts + ')';
        if (this.selectedProducts.length > 0) {
            this.isButtonDisabled = false;
        } else {
            if (this.mode == 'edit') {
                this.isButtonDisabled = false;
            } else {
                this.isButtonDisabled = true;
            }
        }

    }

    //function is invoked when you start writing characters
    handleSearchProducts() {
        if (this.strSearchProductName != null && this.strSearchProductName != '') {
            this.currenRecordId = this.recordId;
            getPricebookEntryMethod({ id: this.currenRecordId, strProductName: this.strSearchProductName, pricebookentryList: this.selectedProducts })
                .then(result => {
                    if (result.length == 0) {
                        this.errorMsg = labelNoProductsFoundMsg + ' ' + this.strSearchProductName;
                    }
                    this.searchData = result;

                    this.totalProducts = 0;
                    this.totalProducts = this.searchData.length;
                    this.selected = labelShowSelected + ' (' + this.selectedProducts.length + '/' + this.totalProducts + ')';
                })
                .catch(error => {
                    this.searchData = undefined;
                    window.console.log('error  ' + error);
                    if (error) {
                        console.log('Error message: ' + error.body.message);
                    }
                })
        } else {
            getAllProductsMethod({ id: this.recordId, pricebookentryList: this.selectedProducts })
                .then(result => {
                    this.searchData = result;
                    this.totalProducts = 0;
                    this.totalProducts = this.searchData.length;
                    this.selected = labelShowSelected + ' (' + this.selectedProducts.length + '/' + this.totalProducts + ')';

                })
                .catch(error => {
                    this.searchData = undefined;
                    window.console.log('error  ' + error);
                    if (error) {
                        console.log('Error message: ' + error.body.message);
                    }
                })
        }
    }

    //Function Next button event
    nextStep(event) {
        this.isLoading = true;

        if (this.selectedProducts.length > 0) {
            this.mode = 'create';
        } else {
            this.mode = 'edit';
        }
        createQuoteLineItemMethod({ pricebookentryList: this.selectedProducts, quoteId: this.recordId })
            .then(result => {

                getQuoteLineItemByIdsMethod({ quoteLineItemsIds: result })
                    .then(result => {

                        this.quoteLineItemsCreated = result;
                        this.recordsToAnalize = [];
                        if (this.quoteLineItemsCreated != null && this.quoteLineItemsCreated.length > 0
                            && this.listItems != null && this.listItems.length > 0) {
                            this.recordsToAnalize = this.quoteLineItemsCreated.concat(this.listItems);
                        } else {
                            if (this.quoteLineItemsCreated != null && this.quoteLineItemsCreated.length > 0) {
                                this.recordsToAnalize = this.quoteLineItemsCreated;
                            } else if (this.listItems != null && this.listItems.length > 0) {
                                this.recordsToAnalize = this.listItems;
                            }
                        }
                        if (this.mode == 'create') {
                            this.callSap(this.quoteLineItemsCreated);
                        }
                        const quoteLineCreated = new CustomEvent("nextbuttonstep",
                            {
                                detail: this.recordsToAnalize
                            });
                        this.dispatchEvent(quoteLineCreated);

                        this.isLoading = false;
                    })
                    .catch(error => {
                        console.log('error  ' + error);
                        if (error) {
                            console.log('Error message: ' + error.body.message);
                        }

                        this.isLoading = false;
                    })
            })
            .catch(error => {
                console.log('error  ' + error);
                if (error) {
                    console.log('Error message: ' + error.body.message);
                }

                this.isLoading = false;
            })
    }

    callSap(recordsToAnalize) {
        for(let i = 0; i < recordsToAnalize.length; i++) {
            console.log('Id '+recordsToAnalize[i].id)
            const  recordToBeUpdated = recordsToAnalize[i].id;

            getSAPQuoteLineItemDTO({ 
                quotelineitemid: recordToBeUpdated
            }).then(result => {

                if(result != null) {
                    this.dto = JSON.parse(result);
                    this.dto.tax_value = Number(this.dto.tax_value) ;
                    this.dto.net_value = Number(this.dto.net_value) ;

                    if(this.dto.max_disc == null) {
                        this.dto.max_disc = 0;
                    }
                
                    const fields = {};
                    fields[ID_FIELD.fieldApiName] = recordsToAnalize[i].id;
                    fields[TOT_AM_SAP_EX_VAT_FIELD.fieldApiName] = this.dto.net_value;
                    fields[TOT_VAT_SAP_FIELD.fieldApiName] = this.dto.tax_value;
                    fields[MAX_DISC_FIELD.fieldApiName] = this.dto.max_disc;
                    fields[TOT_AM_SAP_IN_VAT_FIELD.fieldApiName] = this.dto.net_value + this.dto.tax_value;
                    fields[VAT_FIELD.fieldApiName] = (this.dto.tax_value / this.dto.net_value) * 100;
                    fields[TOT_PR_IN_VAT_FIELD.fieldApiName] = this.dto.net_value + this.dto.tax_value;
                    fields[TOT_PR_EX_VAT_FIELD.fieldApiName] = this.dto.net_value;
                    fields[TOT_VAT_FIELD.fieldApiName] = this.dto.tax_value;
                    const recordInput = { fields };
                    updateRecord(recordInput)
                    .then(() => {
                        console.log('record is updated in the select product component');
                    })
                    .catch(error => {
                        console.log("ERROR Update ITEMS" + error);
                    });
                }
            }).catch(error => {
                console.log("ERROR ITEMS" +JSON.stringify(error));
            });
        }
    }
}