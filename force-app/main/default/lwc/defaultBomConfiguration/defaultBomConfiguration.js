/*eslint-disable no-console*/
import { LightningElement, api, track, wire } from 'lwc';
import Back from '@salesforce/label/c.AT_BackButton';
import Next from '@salesforce/label/c.AT_NextButton';
import Finish from '@salesforce/label/c.AT_FinishButton';
import Save from '@salesforce/label/c.AT_ProductSelection_SaveButton';
import createDefaultBOM from '@salesforce/apex/DefaultBomConfigurationController.createDefaultBOM';
import getContractTreatmentJobName from '@salesforce/apex/DefaultBomConfigurationController.getContractTreatmentJobName';

const steps = [
    { label: 'Product Selection', value: 'step-1' },
    { label: 'Product Configuration', value: 'step-2' },
];

export default class DefaultBomConfiguration extends LightningElement {

    labels = {
        Back,
        Next,
        Finish,
        Save
    };

    @api contractTreatmentJobId;
    @api contractTreatmentJobName;

    @track currentStep = 'step-1';
    @track showProductSelection = true;
    @track showProductConfiguration = false;

    steps = steps;
    selectedPricebookEntries = [];

    renderedCallback() {
        console.log('contractTreatmentJobId in defaultBOMConfiguration: ' + this.contractTreatmentJobId);
    }

    connectedCallback() {
        console.log('Conncted call back DEFAULT BOM');
        getContractTreatmentJobName({
            contractTreatmentJobId: this.contractTreatmentJobId
        })
            .then((result) => {
                this.contractTreatmentJobName = result;
            })
            .catch((error) => {
                console.log('Error in retrieving Job name: ' + error);
            });
    }

    handleBack() {
        if (this.showProductSelection === true) {
            this.dispatchEvent(new CustomEvent('exitbomconfiguration'));
        }
        if (this.showProductConfiguration === true) {
            this.showProductConfiguration = false;
            this.showProductSelection = true;
        }
    }

    handleNext() {
        if (this.showProductSelection === true) {
            this.currentStep = 'step-2';

            let returnValue = this.template.querySelector('c-default-bom-product-selection').passSelectedIds();
            console.log('return value: id selected');
            console.log(returnValue);
            if (returnValue.length !== 0) {
                this.selectedPricebookEntries = returnValue;
                console.log('Selected PricebookEntries: ' + this.selectedPricebookEntries);
                console.log('contractTreatmentJobId: ' + this.selectedPricebookEntries);
                createDefaultBOM({
                    pricebookEntryIds: this.selectedPricebookEntries,
                    contractTreatmentJobId: this.contractTreatmentJobId
                })
                    .then(() => {
                        console.log('COMPLETED createDefaultBOM');
                        this.showProductSelection = false;
                        this.showProductConfiguration = true;
                    }).catch((error) => {
                        console.log(error);
                    });
            }
            else {
                this.selectedPricebookEntries = [];

                this.showProductSelection = false;
                this.showProductConfiguration = true;
            }
        }
    }

    handleSave() {
        this.dispatchEvent(new CustomEvent('exitbomconfiguration'));
    }
}