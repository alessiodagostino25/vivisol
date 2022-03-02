/* eslint-disable no-console */
import { LightningElement, track, /*wire,*/ api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ModalHeader from '@salesforce/label/c.CT_ProductConfigurationModal_Header';
import InformationSection from '@salesforce/label/c.CT_ProductConfigurationModal_SectionInformation';
import SaveButton from '@salesforce/label/c.CT_ProductConfigurationModal_SaveButton';
import QuantityLabel from '@salesforce/label/c.CT_ProductConfigStep_TableQuantity';
import CustomerCodesLabel from '@salesforce/label/c.CTJP_Config_Customer_Codes_Section';
import LocationLabel from '@salesforce/label/c.CTJP_Config_Location_Section';

export default class ProductConfigModal extends LightningElement {
 
    label = {
        ModalHeader,
        InformationSection,
        SaveButton,
        QuantityLabel,
        CustomerCodesLabel,
        LocationLabel
    };

    @track value = '';
    @track activeSections;
    @track viewProductConfigModal = true;
    @api selectedProductId;
    @api productName;

    closeModal() {
        this.viewProductConfigModal = false;
        const successEvent = new CustomEvent('saveproduct', {
            detail: this.viewProductConfigModal
        });
        this.dispatchEvent(successEvent);
    }

    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: "Product Configured",
            variant: "success"
        });
        this.dispatchEvent(evt);
        this.viewProductConfigModal = false;
        const successEvent = new CustomEvent('saveproduct', {
            detail: this.viewProductConfigModal
        });
        this.dispatchEvent(successEvent);
    }

    handleError() {
        /*const evt = new ShowToastEvent({
            title: "Error on Product Configuration",
            //message: "Please review product fields",
            variant: "error"
        });
        this.dispatchEvent(evt);*/
        console.log('Error on Product Configuration');
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    renderedCallback() {
        console.log('ID SELEZIONATO: ' + this.selectedProductId);
    }

    handleSubmitClick() {
        this.template.querySelector('lightning-record-edit-form').submit();
    }
}