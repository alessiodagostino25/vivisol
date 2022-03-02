/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-empty */
/* eslint-disable no-console */
import { LightningElement, track, wire, api } from "lwc";

import getJobs from "@salesforce/apex/accountTreatmentJobSelectionController.getJobs";
import { refreshApex } from "@salesforce/apex";
import NoElements from "@salesforce/label/c.Generic_NoElements";
import createAccountTreatmentJobs from "@salesforce/apex/accountTreatmentJobSelectionController.createAccountTreatmentJobs";
import AccountTreatmentJobSelection_JobTitle from "@salesforce/label/c.AccountTreatmentJobSelection_JobTitle";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAccountTreatmentName from "@salesforce/apex/accountTreatmentJobSelectionController.getAccountTreatmentName";

export default class AccountTreatmentJobSelection extends LightningElement {
    @track error;
    @track data;

    @api searchKey2 = "";
    @api selectedcontract;
    @api recordid;
    @api showAddressSelectionPage;
    @track predata = [];
    @track selectedRows = [];
    @track preselectedrowslistjobs = [];
    @track preselectedrowslistjobs1 = [];
    @track nameofaccounttreatment;
    @track atidname;

    label = { AccountTreatmentJobSelection_JobTitle, NoElements };

    @api selectedjobs = [];
    tempjobs = [];

    @track columns = [
        {
            label: "Contract Treatment Job Name",
            fieldName: "Name",
            type: "text",
        },
        {
            label: "Delivery Channel",
            fieldName: "Delivery_Channel__c",
        },
        {
            label: "Frequency",
            fieldName: "Frequency__c",
            type: "number",
        },
        {
            label: "Frequency Unit of Measure",
            fieldName: "Frequency_Unit_of_measure__c",
        },
    ];

    @wire(getAccountTreatmentName, { atid: "$recordid" })
    nameofat({ data }) {
        if (data) {
            console.log("data of name " + JSON.stringify(data));
            this.nameofaccounttreatment = data[0].Name;
            console.log("name of atid" + this.nameofaccounttreatment);
        }
    }

    renderedCallback() {
        return refreshApex(this.result);
    }

    getjobsselected(event) {
        this.selectedRows = event.detail.selectedRows;
        for (let i = 0; i < this.selectedRows.length; i++) {
            this.preselectedrowslistjobs.push(this.selectedRows[i].Id);
            console.log("json object" + JSON.stringify(this.selectedRows));
        }
    }

    @api createaccountjobs() {
        console.log("rows length before creation" + this.selectedRows.length);
        console.log("selected rows before creation" + this.selectedRows);
        if (this.selectedRows.length > 0) {
            for (let i = 0; i < this.selectedRows.length; i++) {
                this.tempjobs.push(this.selectedRows[i].Id);
                console.log("selectedJob Js::" + this.selectedjobs);
                console.log("acountid " + this.recordid);
            }
            this.selectedjobs = this.tempjobs;
            createAccountTreatmentJobs({
                accounttreatmentid: this.recordid,
                selectedjobs: this.selectedjobs,
            })
                .then({})
                .catch(error => {
                    // eslint-disable-next-line no-console
                    console.log(error);
                });
        } else if (this.selectedRows.length < 0) {
            const evt = new ShowToastEvent({
                message: "please select rows",
                variant: "error",
            });
            this.dispatchEvent(evt);
        }
    }

    @wire(getJobs, {
        searchKey2: "$searchKey2",
        selectedcontract: "$selectedcontract",
        accountTreatmentId: "$recordid",
    })
    jobs(result) {
        this.result = result;
        if (result.data) {
            this.data = result.data;

            this.predata = [];
            for (let i = 0; i < this.data.length; i++) {
                this.predata = [
                    ...this.predata,
                    {
                        Id: this.data[i].Id,
                        Name: this.data[i].Name,
                        Delivery_Channel__c: this.data[i].Delivery_Channel__c,
                        Product_Name_Translate__c: this.data[i]
                            .Product_Name_Translate__c,
                        Frequency__c: this.data[i].Frequency__c,
                        Frequency_Unit_of_measure__c: this.data[i]
                            .Frequency_Unit_of_measure__c,
                    },
                ];
            }
            console.log("Get job: data is rendered");
            console.log("data in jobs " + JSON.stringify(this.predata));
        } else if (result.error) {
            this.error = result.error;
        }
    }

    get finaldata() {
        console.log("data is sent to datatable");
        return this.predata;
    }

    get isTableEmpty() {
        if (this.predata.length === 0) {
            return true;
        } else {
            return false;
        }
    }

    @api refresh() {
        console.log("came to refreshingthejobs method");
        refreshApex(this.jobs);
    }

    handleKeyChange(event) {
        this.preselectedrowslistjobs = [];
        console.log("search pre select" + this.preselectedrowslistjobs);
        console.log("selected rows length" + this.selectedRows.length);

        for (let i = 0; i < this.selectedRows.length; i++) {
            this.preselectedrowslistjobs.push(this.selectedRows[i].Id);
            console.log("json object" + JSON.stringify(this.selectedRows));
        }

        this.searchKey2 = event.target.value;
        console.log(this.searchKey2);
        return refreshApex(this.result);
    }
}