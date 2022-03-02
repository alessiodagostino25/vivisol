import { LightningElement, track, api } from 'lwc';

const steps = [
    { label: 'Contract Treatment Configuration', value: 'step-1' },
    { label: 'Contract Job Configuration', value: 'step-2' },
    { label: 'Product Limits', value: 'step-3' },
];

export default class ContractTreatmentProgressBar extends LightningElement {

    @track steps = steps;
    @api steps = steps;

    @api currentStep;
    
}