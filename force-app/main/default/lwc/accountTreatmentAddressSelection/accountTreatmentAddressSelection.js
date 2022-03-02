import { LightningElement, track, api, wire } from 'lwc';
import {refreshApex} from '@salesforce/apex';
import getATAs from '@salesforce/apex/ATASelectionController.getATAs';
import getATAPs from '@salesforce/apex/ATASelectionController.getATAPs';

import NoElements from '@salesforce/label/c.Generic_NoElements';
import Name from '@salesforce/label/c.Generic_Name';
import AddressType from '@salesforce/label/c.Generic_AddressType';
import Address from '@salesforce/label/c.Generic_Address';
import StartDate from '@salesforce/label/c.Generic_StartDate';
import EndDate from '@salesforce/label/c.Generic_EndDate';
import Default from '@salesforce/label/c.Generic_Default';
import New from '@salesforce/label/c.AccountTreatmentRelatedList_NewButton';
import PageTitle from '@salesforce/label/c.ATA_PageTitle';

const actions = [
    { label: 'Configure', name: 'configure' },
];
const actions1 = [
    { label: 'Configure', name: 'configure' },
];

const columns = [
    { label: Name, fieldName: 'locationName', type: 'text'},
    { label: AddressType, fieldName: 'addressType' },
    { label: Address, fieldName: 'address'},
    { label: StartDate, fieldName: 'startDate'},
    { label: EndDate, fieldName: 'endDate'},
    { label: Default, fieldName: 'isDefault', type: 'boolean'},
    {
        type: 'action',
        typeAttributes: { rowActions: actions }
    } 
];

const columns1 = [
    { label: Name, fieldName: 'Name', type: 'text'},
    { label: AddressType, fieldName: 'accountTreatment' },
    { label: Address, fieldName: 'accountTreatmentAddress'},
    { label: StartDate, fieldName: 'payer'},
    { label: EndDate, fieldName: 'billTo'},
    {
        type: 'action',
        typeAttributes: { rowActions: actions1 }
    } 
];

export default class AccountTreatmentAddressSelection extends LightningElement {
    columns = columns;
    columns1 = columns1;
    labels = {
        NoElements,
        New,
        PageTitle
    }

    @track isTableEmpty = false;
    @track isTableEmpty1 = false;
    @track ATAs = [];
    @track ATAPs = [] ;
    @track showModal = false;
    @track showModal1 = false;
    @track loading = false;
    @track loading1 = false ;

    //accountTreatmentId = 'a259E000000zlmNQAQ';
    @api accountTreatmentId;
    @api accountId;
    @api accountTreatmentName;
    @api isPrescriptionFilled;

    addressToConfigureId;

    @wire(getATAs, {accountTreatmentId: '$accountTreatmentId'})
    populateTable(value) {
        console.log('Populating table...');
        this.loading = true;

        this.ATAs = value;
        const { data, error } = value;
        if(data) {
            console.log('Data.length: ' + data.length);
            if(data.length === 0) {
                this.isTableEmpty = true;
            }
            else {
                this.isTableEmpty = false;
            }
        }
        else if(error) {
            console.log('ERROR: ' + error);
        }

        this.loading = false;
    }


    @wire(getATAPs, {accountTreatmentId: '$accountTreatmentId'})
    populatePayerTable(value) {
        console.log('Populating Payer table...');
        this.loading1 = true;

        this.ATAPs = value;
        const { data, error } = value;
        if(data) {
            console.log('Data.length: ' + data.length);
            if(data.length === 0) {
                this.isTableEmpty1 = true;
            }
            else {
                this.isTableEmpty1 = false;
            }
        }
        else if(error) {
            console.log('ERROR: ' + error);
        }

        this.loading1 = false;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        this.addressToConfigureId = event.detail.row.Id;
        console.log('Address to Configure Id: ' + this.addressToConfigureId);
        console.log('Action: ' + actionName);
        if(event.detail.action.name === 'configure') {
            console.log('YOU ARE IN CONFIGURE');
            this.showModal = true;
        }
    }

    connectedCallback() {
        refreshApex(this.ATAs);
    }

    renderedCallback() {
        refreshApex(this.ATAs);
    }

    handleNewClick() {
        this.addressToConfigureId = '';
        this.showModal = true;
    }
    handleNewClick1() {
        this.showModal1 = true;
    }

    handleModalSave(){
        this.showModal = false;
        this.showModal1 = false;
        refreshApex(this.ATAs);
        refreshApex(this.ATAPs);
    }

    @api
    returnSomethingSelected() {
        console.log('ATAs.length: ' + this.ATAs.data.length);
        if(this.ATAs.data.length === 0) {
            return false;
        }
        else {
            return true;
        }
    }
}