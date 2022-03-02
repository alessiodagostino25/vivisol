import { LightningElement, track } from 'lwc';

export default class ModalProductFirstStep extends LightningElement {

    @track viewModalFirst = true;
    @track viewFamilySelection = false;
    @track viewProductSelection = false;
    @track viewPage3 = false;
    
    closeModal() {
        this.viewModalFirst = false;
        this.viewPage3 = true;
    }

    handleClickAddFamilies() {
        this.viewModalFirst = false;
        this.viewFamilySelection = true;
    }

    handleClickSkipProducts() {
        console.log('buttonclicked')
        this.viewModalFirst = false;
        this.viewProductSelection = true;
    }

}