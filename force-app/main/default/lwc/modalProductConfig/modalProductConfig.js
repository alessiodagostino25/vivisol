import { LightningElement, track } from 'lwc';

export default class ModalProductConfig extends LightningElement {

    @track viewModal;
    @track viewPage5;
    @track viewModal2;

    viewModal = true;
    viewPage5 = false;
    viewModal2 = false;
    
    closeModal() {
        this.viewModal = false;
        this.viewPage5 = true;
    }

    handleSkipClick() {
        this.viewModal = false;
        this.viewModal2 = true;
    }
}