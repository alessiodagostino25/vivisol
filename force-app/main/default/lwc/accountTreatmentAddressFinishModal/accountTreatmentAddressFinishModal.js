import { LightningElement, track, api } from 'lwc';

import Close from '@salesforce/label/c.CT_JobConfiguration_ModalCloseIcon';
import Cancel from '@salesforce/label/c.Btn_Cancel';
import Finish from '@salesforce/label/c.AT_FinishButton';
import Yes from '@salesforce/label/c.createQuoteLineItem_Yes';
import No from '@salesforce/label/c.createQuoteLineItem_No';
import NoAddressSelected from '@salesforce/label/c.ATA_NoAddressSelected';
import AddressSelected from '@salesforce/label/c.ATA_AddressSelected';
import NoPrescription from '@salesforce/label/c.ATA_NoPrescription';
import Heading from '@salesforce/label/c.ATA_NoAddressSelected_Heading';
import SelectDateSales from '@salesforce/label/c.ATA_SelectDateSales';
import getTodayDatetime from '@salesforce/apex/ATMainComponentController.getTodayDatetime';

export default class AccountTreatmentAddressFinishModal extends LightningElement {

    labels = {
        Close,
        Cancel,
        Finish,
        Yes,
        No,
        NoAddressSelected,
        AddressSelected,
        Heading,
        SelectDateSales,
        NoPrescription
    }

    todayDatetime;

    @api addressSelected;
    @api accountTreatmentRecordType;
    @api isPrescriptionFilled;

    @track startDateForSales;
    @track showSalesModal = false;

    closeModal() {
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }

    handleFinishClick() {
        console.log('Finish clicked');
        const noClick = new CustomEvent('noclick'); // MainComponent will have same behaviour
        this.dispatchEvent(noClick);
    }

    handleNoClick() {
        console.log('No clicked');
        const noClick = new CustomEvent('noclick');
        this.dispatchEvent(noClick);
    }

    handleYesClick() {
        console.log('Yes clicked');
        const yesClick = new CustomEvent('yesclick');
        this.dispatchEvent(yesClick);
    }

    connectedCallback() {
        getTodayDatetime().then(result => {
            this.todayDatetime = result;
            console.log('TODAY IN MODAL: ' + this.todayDatetime);
        });

        console.log('accountTreatmentRecordType in Modal: ' + this.accountTreatmentRecordType);
        if(this.accountTreatmentRecordType === 'AccountTreatment_Sales' || this.accountTreatmentRecordType === 'AccountTreatment_Maintenance' 
        || this.accountTreatmentRecordType === 'AccountTreatment_RentMaintenance') {
            this.showSalesModal = true;
        }
    }

    handleDateChange(event) {
        console.log('New date: ' + event.target.value);
        const dateChange = new CustomEvent('datechange', {
            detail: event.target.value
        });

        this.dispatchEvent(dateChange);
    }

}