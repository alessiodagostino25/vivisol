/* eslint-disable no-console */
import { LightningElement, track, /*wire,*/ api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ProductLimitModal extends LightningElement {

    steps = [
        { label: 'Family Selection', value: 'step-1' },
        { label: 'Product Selection', value: 'step-2' },
        { label: 'Configuration', value: 'step-3' },
    ];

    @track value = '';
    @track activeSections;
    //@track viewPage3 = false;
    //@track viewProductSelection = false;
    @track viewProductConfigModal = true;
    @api selectedLimitId;
    @track viewProductLimitModal = true;
    @api limitName;

    closeModal() {
        this.viewProductLimitModal = false;
        const successEvent = new CustomEvent('savelimit', {
            detail: this.viewProductLimitModal
        });
        this.dispatchEvent(successEvent);
    }

    /*handleNextClick() {
        this.viewProductConfigModal = false;
    }*/

    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: "Product Limit Configured",
            //message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        this.dispatchEvent(evt);
        this.viewProductLimitModal = false;
        const successEvent = new CustomEvent('savelimit', {
            detail: this.viewProductLimitModal
        });
        this.dispatchEvent(successEvent);
        /*this.contractTreatmentRecordId = event.detail.id;
        
        const createdContractTreatment = new CustomEvent("created", {
            detail: this.contractTreatmentRecordId
          });
          this.dispatchEvent(createdContractTreatment);*/
    }

    handleError() {
        /*const evt = new ShowToastEvent({
            title: "Error on Limits Configuration",
            //message: "Please review limits fields",
            variant: "error"
        });
        this.dispatchEvent(evt);*/
        console.log('Error on limits configuration');
    }

    get invoiceSplittingOptions() {
        return [
            { label: '--None--', value: '' },
            { label: 'Option 1', value: 'option1' },
            { label: 'Option 2', value: 'option2' },
        ];
    }

    get quantityUnitOptions() {
        return [
            { label: '--None--', value: '' },
            { label: 'Option 1', value: 'option1' },
            { label: 'Option 2', value: 'option2' },
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    renderedCallback() {
        console.log('ID SELEZIONATO: ' + this.selectedLimitId);
    }

    handleSubmitClick() {
        this.template.querySelector('lightning-record-edit-form').submit();
    }
}