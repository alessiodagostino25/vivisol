import getPrescriptionRecordTypes from '@salesforce/apex/newPrescriptionComponentController.getPrescriptionRecordTypes';
import getSalesOrganizationId from '@salesforce/apex/newPrescriptionComponentController.getSalesOrganizationId';
import getAccountFields from '@salesforce/apex/newPrescriptionComponentController.getAccountFields';
import currentDateTime from '@salesforce/apex/newPrescriptionComponentController.currentDateTime';
import getTableContractPayer from '@salesforce/apex/newPrescriptionComponentController.getTableContractPayer';
import getBusinessLineOptions from '@salesforce/apex/newPrescriptionComponentController.getBusinessLineOptions';
import getTableContractTreatment from '@salesforce/apex/newPrescriptionComponentController.getTableContractTreatment';
import newPrescription from '@salesforce/apex/newPrescriptionComponentController.newPrescription';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

const columns = [
    { label: 'Approver', fieldName: 'Approver', hideDefaultActions: true },
    { label: 'Bill To', fieldName: 'BillTo', hideDefaultActions: true },
    { label: 'Payer', fieldName: 'Payer', hideDefaultActions: true },
    { label: 'Area', fieldName: 'Area', hideDefaultActions: true },
    { label: 'Business Line', fieldName: 'BusinessLine', hideDefaultActions: true }
];

const columnsTreatment = [
    { label: 'Contract Treatment Name', fieldName: 'ContractTreatmentName', hideDefaultActions: true },
    { label: 'Treatment Type', fieldName: 'TreatmentType', hideDefaultActions: true },
    { label: 'Corporate Treatment', fieldName: 'CorporateTreatment', hideDefaultActions: true },
    { label: 'Treatment Local', fieldName: 'TreatmentLocal', hideDefaultActions: true }
];

//S: SIDEA V4AT-182
export default class NewPrescriptionComponent extends NavigationMixin(LightningElement) {
    @track optionsRecordType; // options for recordType picklist - page1
    @track businessLineOptions;
    isRecordTypeSelected = false; // check if recordType is selected and show the rest of page - page1
    @track isLoading = true; // spinner loading
    @api recId;
    retrievedRecordId = false;
    @api isPage1 = false;
    @api isPage2 = false;
    @api salesOrganizationId;
    @api location;
    @api healthInsurance;
    @api dateNow;
    @api recordTypeSelected;
    @api businessLineSelected = '';
    @track contractFrameworkId;
    @api tableData = [];
    @api tableDataTreatment = [];
    @track selectedPayer;
    @track selectedTreatmentTypes = [];
    @track contractTreatment;
    @track contractTreatmentIds;
    @track contractPayer;
    @track healthInsuranceNotNull = false;
    @api isLoaded = false;
    columns = columns;
    columnsTreatment = columnsTreatment;
    @api prescriptionObj = {
        sobjectType: "Prescription__c"
    };

    connectedCallback() {
        this.isPage1 = true;
        console.log('Start retrieving record types...');
        this.getSalesOrgId();
        this.getReceiveDate();
        getPrescriptionRecordTypes().then(result => {
            this.optionsRecordType = result;
        })
        setTimeout(() => {
            this.getAccFields(this.recId);
        }, 1500);
    }

    getSalesOrgId() {
        getSalesOrganizationId().then(result => {
            if(result) {
                this.salesOrganizationId = result;
            } else {
                console.log('No salesOrganizationId found...');
            }
        })
    }

    getAccFields() {
        getAccountFields({accId: this.recId}).then(result => {
            console.log('result acc fields: ' + result);
            if(result) {
                let res = result.split(';');
                if(res.length == 2) {
                    this.location = res[0];
                    if(res[1] == null) {
                        this.healthInsuranceNotNull = false;
                    } else {
                        this.healthInsuranceNotNull = true;
                        this.healthInsurance = res[1];
                    }
                } else if (res.length == 1) {
                    this.location = res[0];
                }

            } else {
                console.log('Error retrieving account info...');
            }
        })
    }

    getReceiveDate() {
        currentDateTime().then(result => {
            if(result) {
                this.dateNow = result;
            }
        })
    }

    // handle change picklist recordtype
    handleChangeRecordType(event) {
        this.isRecordTypeSelected = true;
        this.recordTypeSelected = event.target.value;
    }

    // handle change picklist businessline
    async handleChangeBusinessLine(event) {
        debugger;
        this.businessLineSelected = event.target.value;
        await this.getContractPayer();
        await this.getContractTreatment();
    }

    handleError(event) {

    }

    handleSuccess(event) {

    }

    handleOnLoad(event) {
        console.log('CARICATO');
        this.isLoading = false;
    }

    nextPage(event) {
        event.stopPropagation();

        // This must also suppress default submit processing
        event.preventDefault();
        const fields = event.detail.fields;
        this.prescriptionObj['Patient__c'] = fields.Patient__c;
        this.prescriptionObj['Sales_Organization__c'] = fields.Sales_Organization__c;
        this.prescriptionObj['Address__c'] = fields.Address__c;
        this.prescriptionObj['Customer_B2B_and_B2C_Paying_Customer__c'] = fields.Customer_B2B_and_B2C_Paying_Customer__c;
        this.prescriptionObj['Prescriber__c'] = fields.Hospital__c;
        this.prescriptionObj['Hospital__c'] = fields.Hospital__c;
        this.prescriptionObj['Contract_Framework__c'] = fields.Contract_Framework__c;
        this.prescriptionObj['Prescription_Date__c'] = fields.Prescription_Date__c;
        this.prescriptionObj['Received_date__c'] = fields.Received_date__c;
        this.prescriptionObj['Consignment_Installation__c'] = fields.Consignment_Installation__c;
        this.prescriptionObj['Required_Information__c'] = fields.Required_Information__c;
        this.prescriptionObj['Responsible__c'] = fields.Responsible__c;
        this.prescriptionObj['Notes__c'] = fields.Notes__c;
        console.log(JSON.stringify(this.prescriptionObj));
        this.isPage1 = false;
        this.isPage2 = true;
        this.contractFrameworkId = this.prescriptionObj['Contract_Framework__c'];
        getBusinessLineOptions({CFId: this.contractFrameworkId}).then(result => {
            if(result) {
                this.businessLineOptions = result;
            }
        })
        this.getContractPayer();
        this.getContractTreatment();
    }

    async getContractPayer() {
        this.tableData = [];
        this.contractPayer = '';
        this.isLoading = true;
        console.log(this.contractFrameworkId + ' ' + this.businessLineSelected);
        getTableContractPayer({CFId: this.contractFrameworkId, businessLine: this.businessLineSelected}).then(result => {
            if(result) {
                this.contractPayer = result;
                result.forEach(res => {
                    var Approver;
                    var BillTo;
                    var Payer;
                    var Area;
                    var BusinessLine;
                    var Id;
                    var ApproverId;

                    Approver = res.Approver__r.Name != undefined ? res.Approver__r.Name : '';
                    BillTo = res.Bill_To__r.Name != undefined ? res.Bill_To__r.Name : '';
                    Payer = res.Payer__r.Name != undefined ? res.Payer__r.Name : '';
                    Area = res.Area__c != undefined ? res.Area__c : '';
                    BusinessLine = res.Business_Line__c != undefined ? res.Business_Line__c : '';
                    Id = res.Id != undefined ? res.Id : '';
                    ApproverId = res.Approver__c != undefined ? res.Approver__c : '';

                    this.tableData = [...this.tableData, {Approver: Approver, BillTo: BillTo, Payer: Payer, Area: Area, BusinessLine: BusinessLine, Id: Id, ApproverId: ApproverId}];
                });
            } else {
                console.log('error');
            }
            this.contractPayer = [];
            this.isLoading = false;
        })
    }

    handleRowSelection = event => {
        debugger;
        var selectedRows = event.detail.selectedRows;
        if(selectedRows) {
            this.contractPayer = selectedRows[0];
        }
    }

    handleRowSelectionTreatment(event) {
        this.contractTreatment = [];
        this.contractTreatmentIds = []
        var selectedRows=event.detail.selectedRows;
        selectedRows.forEach(row => {
            this.contractTreatment.push(row['TreatmentType']);
            this.contractTreatmentIds.push(row['Id']);
        });
    }

    async getContractTreatment() {
        let baseUrl = 'https://' + location.host;
        this.isLoading = true;
        this.tableDataTreatment = [];
        this.contractTreatment = [];
        getTableContractTreatment({CFId: this.contractFrameworkId, businessLine: this.businessLineSelected}).then(result => {
            if(result) {
                this.contractTreatment = result;
                this.contractTreatmentIds = result;
                result.forEach(res => {
                    var ContractTreatmentName;
                    var TreatmentType;
                    var CorporateTreatment;
                    var TreatmentLocal;
                    var Id;

                    ContractTreatmentName = res.Name != undefined ? res.Name : '';
                    TreatmentType = res.Treatment_Type__c != undefined ? res.Treatment_Type__c : '';
                    CorporateTreatment = res.Corporate_Treatment__r.Name != undefined ? res.Corporate_Treatment__r.Name : '';
                    TreatmentLocal = res.Product__r.Product_Name_Translate__c != undefined ? res.Product__r.Product_Name_Translate__c : '';
                    var linkName = baseUrl + '/' + res.Id;
                    Id = res.Id != undefined ? res.Id : '';

                    this.tableDataTreatment = [...this.tableDataTreatment, {ContractTreatmentName: ContractTreatmentName, TreatmentType: TreatmentType, CorporateTreatment: CorporateTreatment, TreatmentLocal: TreatmentLocal, Id: Id}];
                });
            } else {
                console.log('error');
            }
            this.contractTreatment = [];
            this.isLoading = false;
        })
    }

    handleFinalSave() {    
        console.log('isloading: ' + this.isLoading);    
        console.log('isloading: ' + this.isLoading);
        if(this.contractPayer["Approver"] != undefined && this.contractTreatment.length > 0) {
            this.isLoaded = !this.isLoaded;
            console.log(JSON.stringify(this.prescriptionObj) + ' | cp id: ' + this.contractPayer["Id"] + ' | ctids: ' + JSON.stringify(this.contractTreatmentIds) + ' | ' + JSON.stringify(this.contractTreatment) + ' | accId: ' + this.recId + ' | rec type: ' + this.recordTypeSelected + ' | cfId: ' + this.prescriptionObj["Contract_Framework__c"] + ' | approverId: ' + this.contractPayer["ApproverId"]);
            newPrescription({prescription: JSON.stringify(this.prescriptionObj), treatmentTypes: this.contractTreatment, approverId: this.contractPayer["ApproverId"], contractTreatmentsId: this.contractTreatmentIds, 
                             accId: this.recId, recordTypeName: this.recordTypeSelected, CFId: this.prescriptionObj["Contract_Framework__c"], businessLine: this.businessLineSelected, CPId: this.contractPayer["Id"]}).then(result => {
                if(result) {
                    this.showNotification('Success!', 'Your prescription and account treatments have been saved!', 'success');
                    this.goBackToPrescription();
                } else {
                    this.showNotification('Error!', 'Your prescription and account treatments have not been saved!', 'error');
                    this.isLoaded = false;
                }
            });
        } else if(this.contractPayer["Approver"] == undefined) {
            this.showNotification('Error!', 'Select one Contract Payer!', 'error');
            this.isLoaded = false;
        } else if(this.contractTreatment.length == 0) {
            this.showNotification('Error!', 'Select at least one Contract Treatment!', 'error');
            this.isLoaded = false;
        } else {
            this.showNotification('Error!', 'You have not selected any Contract Payer nor a Contract Treatment!', 'error');
            this.isLoaded = false;
        }
    }
    

    showNotification(title, msg, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: 'pester'
        });
        this.dispatchEvent(event);
    }

    goBackToPrescription() {
        const isSaveOK = true;
        const valueChangeEvent = new CustomEvent("savedprescription", {
          detail: { isSaveOK }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
    }

    goBackToEditForm() {
        this.isPage1 = true;
        this.isRecordTypeSelected = false;
    }
}
//S: SIDEA V4AT-182