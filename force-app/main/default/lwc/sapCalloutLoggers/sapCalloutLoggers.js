import { LightningElement, track, api } from 'lwc';

// Apex actions
import getCalloutLoggers from '@salesforce/apex/SAPCalloutLoggersController.getCalloutLoggers';

// Labels
import NoElements from '@salesforce/label/c.Generic_NoElements';

// Other stuff
import { NavigationMixin } from 'lightning/navigation';

const TYPE_ACTIONS = [
    { label: 'All', checked: true, name: 'EW'},
    { label: 'Errors', name: 'E'},
    { label: 'Warnings', name: 'W'}
];

const actions = [
    { label: 'View', name: 'view' },
];

const columns = [
    { label: 'Error', fieldName: 'errorMessage', type: 'text', cellAttributes: { alignment: "left" }, wrapText: true},
    { label: 'Creation Date', fieldName: 'createdDate', type: 'date', typeAttributes:{
        year: "numeric",
        month: "long",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit"
    }},
    { label: 'Type', fieldName: 'errorType', type: 'text', cellAttributes: { alignment: "left" }, actions: TYPE_ACTIONS},
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];

export default class SapCalloutLoggers extends NavigationMixin(LightningElement) {
    columns = columns;
    labels = {
        NoElements
    }

    @api recordId;
    @api objectApiName;

    @track isTableEmpty = false;
    @track calloutLoggers;
    @track selectedErrorType = 'EW';
    @track isLoading = false;

    connectedCallback() {
        console.log('connectedCallback...');

        this.loadCalloutLoggers();
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('row: ' + row.Id);

        if(actionName === 'view') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: row.Id,
                    objectApiName: 'Callout_Logger__c',
                    actionName: 'view'
                }
            });
        }
    }

    loadCalloutLoggers() {
        this.isLoading = true;

        getCalloutLoggers({
            recordId: this.recordId,
            objectApiName: this.objectApiName,
            errorType: this.selectedErrorType
        }).then(result => {
            this.calloutLoggers = result;
            console.log('calloutLoggers: ' + JSON.stringify(this.calloutLoggers));

            if(this.calloutLoggers != undefined && this.calloutLoggers != null && this.calloutLoggers.length > 0) {
                this.isTableEmpty = false;
            }
            else {
                this.isTableEmpty = true;
            }

            this.isLoading = false;
        }).catch(error => {
            console.log('ERROR');
            console.log(error);

            this.isLoading = false;
        });
    }

    handleRefresh() {
        this.loadCalloutLoggers();
    }

    handleHeaderAction(event) {
        const actionName = event.detail.action.name;
        const colDef = event.detail.columnDefinition;
        const cols = this.columns;
        
        console.log('actionName: ' + actionName);
        
        if(actionName == 'EW' || actionName == 'E' || actionName == 'W') {
            this.selectedErrorType = actionName;
            this.loadCalloutLoggers();

            cols.find(col => col.label === colDef.label).actions.forEach(action => action.checked = action.name === actionName);
            this.columns = [...cols];
        }
    }
}