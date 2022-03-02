/* eslint-disable no-console */

import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from "@salesforce/apex";

import getFields from '@salesforce/apex/accountTreatmentConfigurationController.getFields';
import mainTitle from '@salesforce/label/c.AT_AccountTreatmentConfiguration_MainTitle';

export default class AccountTreatmentConfiguration extends LightningElement {

    apifield = [];
    @track fields = [];
    @api therapy;
    @api recordid;
    @api selectedrecordtype;
    @wire(CurrentPageReference) pageRef;
    @api buttonsareactive;
    @track detectbutton1;
    @track view = 'view';
    @track result;
    @track data;
    @track isLoading = true;

    @api showAddressSelectionPage;

    label = {
        mainTitle,
    };

    renderedCallback() {
        console.log('renedered call back worked ')
        console.log(this.recordid);
        console.log('SHOWADDRESSSELECTIONPAGE IN CONFIGURATION: ' + this.showAddressSelectionPage);
        if (this.recordid != undefined && this.showAddressSelectionPage != undefined) {
            this.isLoading = false;
        }
    }

    buttons() {
        this.buttonsareactive = true;
        console.log('button method wokred')
    }


    detectchange() {
        console.log('the form is changed ')
        this.buttonsareactive = false;
        const detectchange = new CustomEvent('mydetectchange', {
            detail: this.buttonsareactive

        });
        this.dispatchEvent(detectchange);

        //this.timeoutId = setTimeout(this.doExpensiveThing.bind(this), 1000);
    }

    detectbutton() {
        this.detectbutton1 = this.template.querySelector("submit");
        console.log('button is detected' + this.detectbutton1);
    }

    formisininputmode() {

        console.log('form is in input mode');
    }

    @wire(getFields, { therapy: "$therapy", recordtype: "$selectedrecordtype" })
    fieldes(result) {
        this.result = result;
        this.data = result.data;
        if (this.data) {
            const values = this.data;

            for (let i = 0; i < this.data.length; i++) {
                this.apifield.push(values[i].FieldApiName__c);
            }
            console.log("value of 0:::" + this.apifield);
            this.fields = this.apifield;
            console.log('final values:::' + this.fields);

        }
    }
}