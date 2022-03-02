import { LightningElement, track, api } from 'lwc';

const steps = [
    { label: 'Family Selection', value: 'step-1' },
    { label: 'Product Selection', value: 'step-2' },
    { label: 'Configuration', value: 'step-3' },
    { label: 'Review Configured Products', value: 'step-4' },
];

export default class ContractTreatmentProgressBar extends LightningElement {

    @track steps = steps;
    @api steps = steps;

    @api currentStep;
    
}