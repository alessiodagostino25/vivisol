import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Apex actions
import getLayout from '@salesforce/apex/LayoutService.getLayout';

export default class LayoutForm extends LightningElement {
    @api objectApiName;
    @api recordId;

    @track layoutSections = [];
    //@track sectionExpanded = true;

    connectedCallback() {
        console.log('layoutForm connected...');
        console.log('objectApiName: ' + this.objectApiName);
        console.log('recordId: ' + this.recordId);

        getLayout({
            recordId: this.recordId
        }).then(result => {
            console.log('RESULT:');
            console.log(JSON.stringify(result));
            if(result != null) {
                for(let i = 0; i < result.layoutSections.length; i++) {
                    this.layoutSections.push(result.layoutSections[i]);
                }
            }

            console.log('layoutSections: ' + this.layoutSections);
        }).catch(error => {
            console.log('ERROR');
            console.log(JSON.stringify(error));
        });
    }

    handleSuccess() {
        const evt = new ShowToastEvent({
            title: "Success",
            //message: "Address successfully configured",
            variant: "success"
        });
        this.dispatchEvent(evt);

        // Event to aura component to close modal

        const successEvent = new CustomEvent('success');
        this.dispatchEvent(successEvent);
    }

    handleError() {
        const evt = new ShowToastEvent({
            title: "Error",
            //message: "Address successfully configured",
            variant: "error"
        });
        this.dispatchEvent(evt);
    }

    /* handleSectionClick() {
        this.sectionExpanded = !this.sectionExpanded;
    } */
}