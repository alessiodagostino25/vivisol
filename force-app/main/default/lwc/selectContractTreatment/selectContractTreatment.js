/* eslint-disable no-empty */
/* eslint-disable no-undef */

/* eslint-disable no-console */
import { LightningElement, track, wire, api } from "lwc";
import getContracts from "@salesforce/apex/selectContractTreatmentController.getContracts";
import getPrescriptions from "@salesforce/apex/selectContractTreatmentController.getPrescriptions";
import getRecordTypeLabel from "@salesforce/apex/selectContractTreatmentController.getRecordTypeLabel";
import getAccountName from "@salesforce/apex/selectContractTreatmentController.getAccountName";
import getRecordType from "@salesforce/apex/selectContractTreatmentController.getRecordType";
import getBusinessLineOptionsBySO from '@salesforce/apex/selectContractTreatmentController.getBusinessLineOptionsBySO';
import getTreatmentTypeOptionsBySOAndBL from '@salesforce/apex/selectContractTreatmentController.getTreatmentTypeOptionsBySOAndBL';
import getselectedCTThreshold from "@salesforce/apex/selectContractTreatmentController.getselectedCTThreshold";
import { refreshApex } from "@salesforce/apex";
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Account_Treatment__c.Name';
import CUSTOMER_PURCHASE_DATE_FIELD from '@salesforce/schema/Account_Treatment__c.Customer_Purchase_Date__c';
import CUSTOMER_TREATMENT_ALIAS_FIELD from '@salesforce/schema/Account_Treatment__c.Customer_Treatment_Alias__c';
import CUSTOMER_PURCHASE_ORDER_NUMBER_FIELD from '@salesforce/schema/Account_Treatment__c.Customer_Purchase_Order_Number__c';
import CUSTOMER_REQUEST_CODE_FIELD from '@salesforce/schema/Account_Treatment__c.Customer_Request_Code__c';
import ACCOUNT_FIELD from '@salesforce/schema/Account_Treatment__c.Account__c';
import TREATMENT_TYPE_FIELD from '@salesforce/schema/Account_Treatment__c.Treatment_Type__c';
import ACCOUNT_TREATMENT_OBJECT from '@salesforce/schema/Account_Treatment__c';
import BILLABLE_FIELD from '@salesforce/schema/Account_Treatment__c.Billable__c';
import RECORD_TYPE_FIELD from '@salesforce/schema/Account_Treatment__c.RecordTypeId';
import CONTRACT_TREATMENT_FIELD from '@salesforce/schema/Account_Treatment__c.Contract_Treatment__c';
import PRESCRIPTION_FIELD from '@salesforce/schema/Account_Treatment__c.Prescription__c';
import BUSINESS_LINE_FIELD from '@salesforce/schema/Account_Treatment__c.Business_Line__c';
import THRESHOLD_DAY_FIELD from '@salesforce/schema/Account_Treatment__c.Threshold_day__c';
import THRESHOLD_HOUR_FIELD from '@salesforce/schema/Account_Treatment__c.Threshold_hour__c';
import THRESHOLD_AHI_FIELD from '@salesforce/schema/Account_Treatment__c.Threshold_AHI__c'
import SelectContract from '@salesforce/label/c.AT_SelectContractTreatment_SelectContract';
import typeOfTreatment from '@salesforce/label/c.AT_SelectContractTreatment_SelectTypeOfTreatment';
import selectPrescription from '@salesforce/label/c.AT_SelectContractTreatment_SelectPrescription';
import selectTherapy from '@salesforce/label/c.AT_SelectContractTreatment_SelectTherapy';
import selectBusinessline from '@salesforce/label/c.AT_SelectContractTreatment_SelectBusinessline';

export default class SelectContractTreatment extends LightningElement {
    @track error;
    @track data;
    @api selectedrecordtype = '';
    @api recordId;
    @wire(CurrentPageReference) pageRef;
    @api searchKey = "";
    @track items = [];
    @track rt = [];
    @track value = '';
    @track accountname;
    @track result1;
    @track selectedprescription;
    @track contractSelection;
    @track accountfromprescription;
    @track accounttreatmentId;
    @track finalvalidation = false;
    @track therapyvalues;
    @track businesslines;
    @track therapyisselected = false;
    @track orderdate;
    @track validateContractselection = false;
    @track Validaterecordtype = false;
    @track validateBusinessline = false;
    @track validateTypeoftreatment = false;
    @track contractname;
    @track ordernumber;
    @track customeralias;
    @track atselectedrecordtype;
    @track requestcode;
    @track thresholdday;
    @track thresholdahi;
    @track thresholdhour;
    @api accountId;
    @api SelectedRecordLabel = "";
    @api selectedtherapy = "";
    @track businesslinevalue = "";
    @track billable;
    selectedRows = [];
    @track preselectedrowslist = [];
    @track therapyvaluesoptions;
    @track selectedrecordid;

    @track therapyRecordTypeId;

    @track columns = [
        {
            label: "Contract Treatment Name",
            fieldName: "Name",
            type: "text"
        },
        {
            label: "Customer Name",
            fieldName: "Customer_Name",
            type: "Text"
        },
        {
            label: "Customer Purchase Date",
            fieldName: "customerPurchaseOrderDate",
            type: "Date"
        },
        {
            label: "Customer Treatment Alias",
            fieldName: "customerTreatmentAlias",
            type: "Text"
        },
        {
            label: "Customer Purchase Order Number",
            fieldName: "customerPurchaseOrderNumber",
            type: "Text"
        },
        {
            label: "Customer Request Code",
            fieldName: "customerRequestCode",
            type: "Text"
        },
        {
            label: "Uzovi Code",
            fieldName: "Uzovi_code",
            type: "Text"
        },

    ];

    label = {
        SelectContract,
        typeOfTreatment,
        selectPrescription,
        selectTherapy,
        selectBusinessline

    };


 /*    @wire(getPicklistValues, { recordTypeId: '$therapyRecordTypeId', fieldApiName: TREATMENT_TYPE_FIELD })
    setPicklistOptions({ data }) {
        if (data) {
            this.therapyvalues = data;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$therapyRecordTypeId', fieldApiName: BUSINESS_LINE_FIELD })
    setPicklistbusinessOptions({ data }) {
        console.log('setPicklistbusinessOptions' + JSON.stringify(this.data))
        if (data) {

            this.businesslines = data.values;
        }
    } */

    @wire(getPrescriptions, { accountId: '$accountId' })
    precs({ error, data }) {
        if (data) {
            for (let i = 0; i < data.length; i++) {
                console.log('id=' + data[i].Id);
                console.log('patient=' + data[i].Patient__c);

                this.items = [...this.items, { value: data[i].Id, label: data[i].Principal_Information__c, patient: data[i].Patient__c }];
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;

        }
    }

    @wire(getselectedCTThreshold, { contractSelection: '$contractSelection' })
    thresholdvales({ error, data }) {
        if (data) {

            console.log('data of threshold values' + JSON.stringify(data))
            this.thresholdhour = data[0].Threshold_hour__c;
            console.log('threshold hour' + this.thresholdhour)
            this.thresholdday = data[0].Threshold_day__c;
            console.log('threshold day' + this.thresholdday)
            this.thresholdahi = data[0].Threshold_AHI__c;
            this.billable = data[0].Billable__c;
        }

    }

    @wire(getRecordType)
    recordtype({ error, data }) {
        if (data) {
            for (let i = 0; i < data.length; i++) {
                console.log('record type id=' + data[i].Id);
                console.log('record type name =' + data[i].Name);
                if (data[i].Name === 'Therapy') {
                    this.therapyRecordTypeId = data[i].Id;
                }
                //giacomo --- RT id: data[i].Id, label: data[i].Name 
                this.rt = [...this.rt, { value: data[i].Id, label: data[i].Name }];
            }
            for (let j = 0; j < this.rt.length; j++) {
                console.log('RT value= ' + this.rt[j].value);
                console.log('RT label= ' + this.rt[j].label);
            }

            this.error = undefined;

        } else if (error) {
            this.error = error;

        }
    }

    @wire(getAccountName, { accountId: '$accountId' })
    accname(result1) {
        if (result1.data) {
            this.result1 = result1.data;
            console.log('data from accountname: ' + JSON.stringify(this.result1))
            this.accountname = this.result1[0].Name;
            console.log('account name ' + this.accountname)
        }
    }


    get recordOptions() {
        console.log(this.rt);
        return this.rt;
    }


    @wire(getContracts, { searchKey: "$searchKey", preselectedrowslist: '$preselectedrowslist', therapy:'$selectedtherapy',recordType:'$selectedrecordtype',
    business :'$businesslinevalue'})
    getAcc(result) {
        this.result = result;
        if (result.data) {
            this.data = result.data;
            console.log('data of get contracts: ' + JSON.stringify(this.data))
        } else if (result.error) {
            this.error = result.error;
        }
    }


    //getter property from statusOptions which return the items array
    get statusOptions() {
        console.log(this.items);
        return this.items;
    }


    handleKeyChange(event) {
        this.preselectedrowslist = [];
        console.log("search pre select" + this.preselectedrowslist);

        console.log("selected rows length" + this.selectedRows.length);
        for (let i = 0; i < this.selectedRows.length; i++) {
            this.preselectedrowslist.push(this.selectedRows[i].Id);
            console.log("json object" + JSON.stringify(this.selectedRows));
        }

        console.log("preselected list in search " + this.preselectedrowslist);
        this.searchKey = event.target.value;
        console.log("searc key value" + this.searchKey);

        console.log(this.searchKey);
        return refreshApex(this.result);
    }

    handleContractSelection(event) {
        this.selectedRows = event.detail.selectedRows;
        // Display that fieldName of the selected rows
        console.log(this.selectedRows[0].Id);
        this.contractSelection = this.selectedRows[0].Id;
        this.contractname = this.selectedRows[0].Name;
        this.orderdate = this.selectedRows[0].customerPurchaseOrderDate;
        this.requestcode = this.selectedRows[0].customerRequestCode;
        this.customeralias = this.selectedRows[0].customerTreatmentAlias;
        this.ordernumber = this.selectedRows[0].customerPurchaseOrderNumber;
        this.validateContractselection = true;

        console.log('orderdate');
        console.log(this.orderdate);
    }


    getSelectedName(event) {
        this.selectedrecordid = event.detail.value;
        console.log('JSON Evnt detail' + JSON.stringify(event.detail));
        console.log(event.detail);

        this.SelectedRecordLabel = this.selectedrecordid;
        // Display that fieldName of the selected rows
        console.log('selectedrecordtype: ' + this.selectedrecordid);

        console.log('final value of the selected: ' + this.selectedrecordtype);

        if (this.selectedrecordid === this.therapyRecordTypeId) {
            this.therapyisselected = true;
            getBusinessLineOptionsBySO().then(result => {
                console.log('business line options'+JSON.stringify(result));
                this.businesslines = result;
                
            }).catch(error => {
                console.log('ERROR');
                console.log(JSON.stringify(error)); 
            });
            
        } else {
            this.therapyisselected = false;
        }
        this.Validaterecordtype = true;
    }


    @wire(getRecordTypeLabel, { SelectedRecordLabel: "$SelectedRecordLabel" })
    getLabels({ error, data }) {

        console.log(this.SelectedRecordLabel)
        console.log(JSON.stringify(data));
        if (data) {

            this.selectedrecordtype = data[0].DeveloperName;
            this.atselectedrecordtype = data[0].Id;
            console.log('final developer name' + this.selectedrecordtype)
            console.log('checking selected recordtype ' + this.atselectedrecordtype)

        } else if (error) {

        }
    }




    /*   @wire(getRecordTypeLabel, { RecordTypeLabel: "$RecordTypeLabel" })
      label([error, data]) {
          if (data) {
              this.recordtype = data[0].developerName;
              console.log('recieved data from labe:::' + this.recordtype);
  
          }
          // eslint-disable-next-line no-empty
          else if (error) {
  
          }
      } */

    getselectedbusinessline(event) {
         this.businesslinevalue = event.detail.value;
       /* console.log('businesslinvalue' + this.businesslinevalue)
        let key = this.therapyvalues.controllerValues[event.target.value];
        this.therapyvaluesoptions = this.therapyvalues.values.filter(opt => opt.validFor.includes(key));
        this.validateBusinessline = true; */

        getTreatmentTypeOptionsBySOAndBL({
            businessLine: this.businesslinevalue
        }).then(result => {
            console.log(JSON.stringify(result));
            this.therapyvaluesoptions = result;
            this.validateBusinessline = true;
        }).catch(error => {
            console.log('ERROR');
            console.log(JSON.stringify(error));
        });
    }



    getselectedtherapy(event) {
        this.selectedtherapy = event.detail.value;

        console.log('selectedtherapy:::' + this.selectedtherapy);
        this.validateTypeoftreatment = true;
    }



    handleprescriptionselect(event) {
        this.selectedprescription = event.detail.value;
        console.log(this.selectedprescription)
        this.accountfromprescription = event.detail.label;
        console.log('patient' + this.accountfromprescription)
    }


    connectedCallback() {
        // initialize component
        //let testURL = window.location.href;
        //let newURL = new URL(testURL).searchParams;
        //this.accountId = newURL.get('c__accountRecordId');
        console.log('SELECT CONTRACT TREATMENT ACCOUNT accountId ===> ' + this.accountId);
    }




    @api handleValidationofAt() {
        if (this.Validaterecordtype === false) {

            const handlevalidationrt = new ShowToastEvent({
                title: 'error',
                message: 'please select the record type',
                variant: 'error',
            });
            this.dispatchEvent(handlevalidationrt);
        }

        else if (this.validateContractselection === false) {

            const handlevalidationcs = new ShowToastEvent({
                title: 'error',
                message: 'please select the contract',
                variant: 'error',
            });
            this.dispatchEvent(handlevalidationcs);
        }


        if (this.therapyisselected === true) {

            if (this.validateBusinessline === false) {


                const handlevalidationBL = new ShowToastEvent({
                    title: 'error',
                    message: 'please select the Business Line',
                    variant: 'error',
                });
                this.dispatchEvent(handlevalidationBL);
            }
            if (this.validateTypeoftreatment === false) {
                const handlevalidationToT = new ShowToastEvent({
                    title: 'error',
                    message: 'please select the Type of Treatment',
                    variant: 'error',
                });
                this.dispatchEvent(handlevalidationToT);
            }
        }


        if (this.Validaterecordtype === true && this.validateContractselection === true) {

            if (this.therapyisselected === true) {

                if (this.validateBusinessline && this.validateTypeoftreatment) {
                    this.finalvalidation = true;
                }
            } else {
                this.finalvalidation = true;

            }
        }

        console.log('finalvalidation in selecttretamtn ' + this.finalvalidation)
        return this.finalvalidation;
    }


    @api createAccountTreatment() {
        const fields = {};
        fields[BUSINESS_LINE_FIELD.fieldApiName] = this.businesslinevalue;
        fields[TREATMENT_TYPE_FIELD.fieldApiName] = this.selectedtherapy;
        fields[NAME_FIELD.fieldApiName] = this.accountname + ' - ' + this.contractname;
        fields[RECORD_TYPE_FIELD.fieldApiName] = this.selectedrecordid;
        fields[CONTRACT_TREATMENT_FIELD.fieldApiName] = this.contractSelection;
        fields[PRESCRIPTION_FIELD.fieldApiName] = this.selectedprescription;
        fields[CUSTOMER_PURCHASE_DATE_FIELD.fieldApiName] = this.orderdate;
        fields[CUSTOMER_PURCHASE_ORDER_NUMBER_FIELD.fieldApiName] = this.ordernumber;
        fields[CUSTOMER_TREATMENT_ALIAS_FIELD.fieldApiName] = this.customeralias;
        fields[CUSTOMER_REQUEST_CODE_FIELD.fieldApiName] = this.requestcode;
        fields[THRESHOLD_DAY_FIELD.fieldApiName] = this.thresholdday;
        fields[THRESHOLD_HOUR_FIELD.fieldApiName] = this.thresholdhour;
        fields[ACCOUNT_FIELD.fieldApiName] = this.accountId;
        fields[THRESHOLD_AHI_FIELD.fieldApiName] = this.thresholdahi;
        fields[BILLABLE_FIELD.fieldApiName] = this.billable;

        const recordInput = {
            apiName: ACCOUNT_TREATMENT_OBJECT.objectApiName,
            fields
        };

        if (fields[NAME_FIELD.fieldApiName].length > 80) {
            let nameToCut = fields[NAME_FIELD.fieldApiName];
            fields[NAME_FIELD.fieldApiName] = nameToCut.substring(0, 79) + '.';
        }

        createRecord(recordInput)
            .then(accounttreatment => {
                console.log('accounttreatment details' + JSON.stringify(accounttreatment));
                this.accounttreatmentId = accounttreatment.id;
                console.log('acoount treatment  id created is ' + this.accounttreatmentId)
                const event = new CustomEvent('newrecord', {
                    detail: {
                        data: accounttreatment
                    },
                });
                this.dispatchEvent(event);
                console.log('event fired');
                const sucessaccounttreatment = new ShowToastEvent({
                    title: 'Success',
                    //message: event.detail.Id,
                    variant: 'success',
                });
                this.dispatchEvent(sucessaccounttreatment);
                const selectEvent = new CustomEvent('mycustomevent', {
                    detail: this.accounttreatmentId

                });
                this.dispatchEvent(selectEvent);
                console.log('selected event is fired')
                const selectEventone = new CustomEvent('mycustomeventone', {
                    detail: this.selectedrecordtype

                });
                this.dispatchEvent(selectEventone);
                console.log('selected recordtype is fired' + this.selectedrecordtype)
                const selectEventtwo = new CustomEvent('mycustomeventtwo', {
                    detail: this.selectedtherapy

                });
                this.dispatchEvent(selectEventtwo);
                console.log('selected therapytype is fired' + this.selectedtherapy)
                const selectEventthree = new CustomEvent('mycustomeventthree', {
                    detail: this.contractSelection

                });
                this.dispatchEvent(selectEventthree);
                console.log('selected contractID is fired' + this.contractSelection)

            })
            .catch(error => {
                console.log('error' + JSON.stringify(error, null, 2));

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.message,
                        variant: 'error',
                    }),
                );
            });

    }

}