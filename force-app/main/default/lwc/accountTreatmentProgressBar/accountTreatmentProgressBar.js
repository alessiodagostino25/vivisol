import { LightningElement, track, api } from 'lwc';

import ContractTreatmentSelection from '@salesforce/label/c.AT_ProgressBar_ContractTreatmentSelection';
import AccountTreatmentConfiguration from '@salesforce/label/c.AT_ProgressBar_AccountTreatmentConfiguration';
import JobSelection from '@salesforce/label/c.AT_ProgressBar_JobSelection';
import JobConfiguration from '@salesforce/label/c.AT_ProgressBar_JobConfiguration';
import AddressConfiguration from '@salesforce/label/c.AT_ProgressBar_AddressConfiguration';

const steps = [
    { label: ContractTreatmentSelection, value: 'step-1' },
    { label: AccountTreatmentConfiguration, value: 'step-2' },
    { label: JobSelection, value: 'step-3' },
    { label: JobConfiguration, value: 'step-4' }
];

name = {
    AddressConfiguration,
};
 


export default class AccountTreatmentProgressBar extends LightningElement {

    @api steps = steps;
    @api currentStep;
    @api showAddressSelectionPage;

}