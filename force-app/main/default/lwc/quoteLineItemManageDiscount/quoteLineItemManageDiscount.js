import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from "@salesforce/apex";
import DISCOUNT_TYPE_FIELD from '@salesforce/schema/Quote_Line_Item__c.DiscountType__c';

// Labels
import ManageDiscount from '@salesforce/label/c.QuoteLineItem_ManageDiscountButton';
import SaveButtonLabel from '@salesforce/label/c.AT_ProductSelection_SaveButton';
import ClearDiscount from '@salesforce/label/c.QuoteLineItem_ClearDiscountButton';
import Yes from '@salesforce/label/c.createQuoteLineItem_Yes';
import No from '@salesforce/label/c.createQuoteLineItem_No';
import ClearDiscountText from '@salesforce/label/c.QuoteLineItem_ClearDiscountText';

// Apex actions
import handleManualPriceDiscount from '@salesforce/apex/QLIManageDiscountController.handleManualPriceDiscount';
import handlePercentageDiscount from '@salesforce/apex/QLIManageDiscountController.handlePercentageDiscount';
import clearDiscount from '@salesforce/apex/QLIManageDiscountController.clearDiscount';

export default class QuoteLineItemManageDiscount extends LightningElement {
    labels = {
        ManageDiscount,
        SaveButtonLabel,
        ClearDiscount,
        Yes,
        No,
        ClearDiscountText
    };
    quoteLineItem;

    @track manualPriceSelected = false;
    @track discountPercentageSelected = false;
    @track selectedDiscountType;
    @track selectedTotalPriceExVAT;
    @track selectedPercentage;
    @track queriedDiscountType;
    @track showClearDiscountButton;
    @track isLoading = false;
    @track showClearDiscountModal = false;

    @api quoteLineItemId;
    @api quoteLineItemDiscountType;

    @wire(getRecord, {recordId: '$quoteLineItemId', fields: [DISCOUNT_TYPE_FIELD]})
    getQuoteLineItem(value) {
        this.quoteLineItem = value;
        const{data, error} = value;

        if(data) {
            this.queriedDiscountType = data.fields.DiscountType__c.value;

            if(this.queriedDiscountType != undefined && this.queriedDiscountType != null && this.queriedDiscountType != 'NULL') {
                this.showClearDiscountButton = true;
            }
        }
    }

    connectedCallback() {
        console.log('quoteLineItemManageDiscount connected...');
    }

    renderedCallback() {
        console.log('quoteLineItemId for ManageDiscount modal: ' + this.quoteLineItemId);
        console.log('quoteLineItemDiscountType for ManageDiscount modal: ' + this.queriedDiscountType);

        if(this.queriedDiscountType === 'MAN_PRICE' || this.queriedDiscountType === null) {
            if(this.selectedDiscountType === 'MAN_PRICE' || this.selectedDiscountType == undefined) {
                this.manualPriceSelected = true;
                this.discountPercentageSelected = false;
            }
        }
        else if(this.queriedDiscountType === 'PERC' || this.queriedDiscountType === null) {
            if(this.selectedDiscountType === 'PERC' || this.selectedDiscountType == undefined) {
                this.manualPriceSelected = false;
                this.discountPercentageSelected = true;
            }
        }
    }

    handleDiscountTypeChange(event) {
        let selectedValue = event.target.value;
        console.log('selectedValue: ' + selectedValue);

        if(selectedValue != undefined) {
            this.selectedDiscountType = selectedValue;

            if(selectedValue === 'MAN_PRICE') {
                this.manualPriceSelected = true;
                this.discountPercentageSelected = false;
            }
            else if(selectedValue === 'PERC') {
                this.manualPriceSelected = false;
                this.discountPercentageSelected = true;
            }
        }
    }

    handleTotalPriceExVATChange(event) {
        let inputValue = event.target.value;

        if(inputValue != undefined) {
            this.selectedTotalPriceExVAT = inputValue;
        }
        else {
            this.selectedTotalPriceExVAT = null;
        }
    }

    handlePercentageChange(event) {
        let inputValue = event.target.value;

        if(inputValue != undefined) {
            this.selectedPercentage = inputValue;
        }
        else {
            this.selectedPercentage = null;
        }
    }

    handleSaveClick() {
        // Using onSubmit event to get the selected values
        let buttons = this.template.querySelectorAll('lightning-button');
        buttons[0].click();

        console.log('----- Saving discount for QLI ' + this.quoteLineItemId);
        console.log('selectedTotalPriceExVAT: ' + this.selectedTotalPriceExVAT);
        console.log('selectedPercentage: ' + this.selectedPercentage);
        console.log('selectedDiscountType: ' + this.selectedDiscountType);

        this.isLoading = true;

        if(this.selectedDiscountType === 'MAN_PRICE') {
            handleManualPriceDiscount({
                quoteLineItemId: this.quoteLineItemId,
                discountType: this.selectedDiscountType,
                totalPriceExVAT: this.selectedTotalPriceExVAT
            }).then(() => {
                console.log('OK!');

                this.isLoading = false;
                refreshApex(this.quoteLineItem);

                const evt = new ShowToastEvent({
                    title: "Record updated",
                    variant: "success"
                });
                this.dispatchEvent(evt);

                this.closeModal();
            }).catch(error => {
                const evt = new ShowToastEvent({
                    title: error.body.message,
                    variant: "error"
                });
                this.dispatchEvent(evt);

                this.isLoading = false;
            });
        }
        else if(this.selectedDiscountType === 'PERC') {
            handlePercentageDiscount({
                quoteLineItemId: this.quoteLineItemId,
                discountType: this.selectedDiscountType,
                discountPercentage: this.selectedPercentage
            }).then(() => {
                console.log('OK!');

                this.isLoading = false;
                refreshApex(this.quoteLineItem);

                const evt = new ShowToastEvent({
                    title: "Record updated",
                    variant: "success"
                });
                this.dispatchEvent(evt);

                this.closeModal();
            }).catch(error => {
                const evt = new ShowToastEvent({
                    title: error.body.message,
                    variant: "error"
                });
                this.dispatchEvent(evt);

                this.isLoading = false;
            });
        }
    }

    handleClearDiscount() {
        this.showClearDiscountModal = true;
    }

    handleNoClick() {
        this.showClearDiscountModal = false;
    }

    handleYesClick() {
        this.isLoading = true;

        clearDiscount({
            quoteLineItemId: this.quoteLineItemId
        }).then(() => {
            refreshApex(this.quoteLineItem);

            this.isLoading = false;
            this.showClearDiscountModal = false;
            this.closeModal();

            const evt = new ShowToastEvent({
                title: "Discount cleared",
                variant: "success"
            });
            this.dispatchEvent(evt);
        }).catch(error => {
            console.log('ERROR');
            console.log(JSON.stringify(error));

            this.isLoading = false;
        });
    }

    closeModal() {
        let closeModalEvent = new CustomEvent('close');
        this.dispatchEvent(closeModalEvent);
    }

    handleSubmit(event) {
        event.preventDefault();

        let fields = event.detail.fields;
        this.selectedDiscountType = fields.DiscountType__c;
        this.selectedTotalPriceExVAT = fields.TotalPrice_excluding_VAT__c;
        this.selectedPercentage = fields.Discount__c;
    }
}