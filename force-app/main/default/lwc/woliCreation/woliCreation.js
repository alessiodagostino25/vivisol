import { LightningElement, track, api, wire } from 'lwc';

export default class WoliCreation extends LightningElement {
    @api recordId;

    @track errors = [];
    @track showModal = false;

    handleSearch() {
        console.log('SEARCH');
    }

    handleSelectionChange() {
        console.log('SELECTION CHANGED');
    }

    handleClick() {
        this.showModal = true;
    }

    handleClose() {
        this.showModal = false;
    }
}