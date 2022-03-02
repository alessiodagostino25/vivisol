import { LightningElement, api } from 'lwc';
import {FlowAttributeChangeEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';

// Apex actions
import getSObject from '@salesforce/apex/FlowRefreshController.getSObject';

export default class FlowRefresh extends LightningElement {
    @api recordId;
    record;

    connectedCallback() {
        console.log('flowRefresh connected...');
        console.log('RecordId: ' + this.recordId);

        if(this.recordId != null && this.recordId != undefined) {
            this.getRecord();
        }
    }

    getRecord() {
        getSObject({
            recordId: this.recordId
        }).then(result => {
            if(result == null || result.length == 0) {
                console.log('Still no record... Retrying...');
                clearTimeout(this.timeoutId); // no-op if invalid id
                this.timeoutId = setTimeout(this.getRecord.bind(this), 2000);
                //this.getRecord();
            }
            else {
                console.log('Record retrieved!');
                this.record = result;
                this.goNext();
            }
        }).catch(error => {
            console.log('ERROR');
            console.log(JSON.stringify(error));
        })
    }

    goNext() {
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);
    }
}