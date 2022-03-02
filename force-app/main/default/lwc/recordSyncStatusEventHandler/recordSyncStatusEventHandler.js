import { LightningElement, api } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';

export default class RecordSyncStatusEventHandler extends LightningElement {
    @api recordId;

    statusChangeChannelName = '/event/Status_Change_Event__e';
    startingCalloutChannelName = '/event/Starting_Callout_Event__e';
    subscription = {};

    get recordIdStringified() {
        return '"' + this.recordId + '"';
    }

    // Callback invoked whenever a new event message is received

    statusChangeMessageCallback = ((response) => {
        console.log('New message received: ', JSON.stringify(response));
        console.log('RecordId__c in Event: ' + JSON.stringify(response.data.payload.RecordId__c));
        console.log('RecordIdStringified: ' + this.recordIdStringified); // HERE RECORDID IS THE ID OF THE PREVIOUS RECORD I'VE VISITED! Probably bugged, event on main cmp

        //if(JSON.stringify(response.data.payload.RecordId__c) === this.recordIdStringified) {
            console.log('Dispatching refresh event...');

            const refreshEvent = new CustomEvent('messagereceived');
            this.dispatchEvent(refreshEvent);
        //}
    });

    startingCalloutMessageCallback = ((response) => {
        console.log('New message received: ', JSON.stringify(response));
        console.log('RecordId__c in Event: ' + JSON.stringify(response.data.payload.RecordId__c));
        console.log('RecordId in startingCalloutMessageCallback: ' + this.recordId);
        console.log('RecordIdStringified: ' + this.recordIdStringified);

        //if(JSON.stringify(response.data.payload.RecordId__c) === this.recordIdStringified) {
            console.log('Dispatching starting callout event...');

            const startingCalloutEvent = new CustomEvent('startingcallout');
            this.dispatchEvent(startingCalloutEvent);
        //}
    });

    /* connectedCallback() {
        // Register error listener 

        this.registerErrorListener();
        console.log('ConnectedCallback, RecordId: ' + this.recordId);
        console.log('ConnectedCallback, RecordIdStringified: ' + this.recordIdStringified);

        // Invoke subscribe method of empApi. Pass reference to messageCallback

        subscribe(this.statusChangeChannelName, -1, this.statusChangeMessageCallback)/* .then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            //this.subscription = response;
        });

        subscribe(this.startingCalloutChannelName, -1, this.startingCalloutMessageCallback)/* .then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            //this.subscription = response;
        });
    } */

    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }
}