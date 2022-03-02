import { LightningElement, track, api} from 'lwc';

export default class ContractClosure extends LightningElement {

    @track viewProductLimits = false;
    @track viewPage6 = true;

    @api contractTreatmentRecordId;

    handleClickBack() {
        this.viewPage6 = false;
        this.viewProductLimits = true ;
        this.currentStep = 'step-3';
    }
}