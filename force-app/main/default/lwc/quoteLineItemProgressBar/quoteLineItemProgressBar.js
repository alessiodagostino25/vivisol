import { LightningElement, track, api } from 'lwc';
import labelProgressBarStep1 from '@salesforce/label/c.createQuoteLineItem_progressBarLabelStep1';
import labelProgressBarStep2 from '@salesforce/label/c.createQuoteLineItem_progressBarLabelStep2';
import labelProgressBarStep3 from '@salesforce/label/c.createQuoteLineItem_progressBarLabelStep3';

const steps = [
    { label: labelProgressBarStep1, value: 'step-1' },
    { label: labelProgressBarStep2, value: 'step-2' },
    { label: labelProgressBarStep3, value: 'step-3' },
];

export default class QuoteLineItemProgressBar extends LightningElement {
    
    @track steps = steps;
    @api steps = steps;

    @api currentStep;

    handleClick(event){
        console.log('Click progress Bar');
        
    }
    
}