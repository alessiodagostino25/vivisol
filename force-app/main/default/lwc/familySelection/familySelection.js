/*eslint-disable no-console*/
import { LightningElement, track, wire, api } from 'lwc';
import getCorporateTreatmentJobFamily from '@salesforce/apex/CorporateTreatmentJobFamilyController.getCorporateTreatmentJobFamily';
import getProductTypes from '@salesforce/apex/CorporateTreatmentJobFamilyController.getProductTypes';
import { refreshApex } from '@salesforce/apex';
import FamilySelectionHeadingLabel from '@salesforce/label/c.CT_FamilySelection_Heading';
import FamilySelectionParagraphLabel from '@salesforce/label/c.CT_FamilySelection_Paragraph'; //TODO: USE CUSTOM LABELS FOR EVERYTHING
import FamilySelectionTypePlaceholder from '@salesforce/label/c.CT_FamilySelection_TypePlaceholder';
import FamilySelectionSearchPlaceholder from '@salesforce/label/c.CT_FamilySelection_SearchPlaceholder';
import FamilySelectionTableName from '@salesforce/label/c.CT_FamilySelection_TableName';
import FamilySelectionTableCode from '@salesforce/label/c.CT_FamilySelection_TableCode';
import NoElements from '@salesforce/label/c.Generic_NoElements';

const columns = [
    { label: FamilySelectionTableName, fieldName: 'Name', type: 'text' },
    { label: FamilySelectionTableCode, fieldName: 'Product_Code' },
];

export default class FamilySelection extends LightningElement {

    @track columns = columns;
    @api currentStep = 'step-1';
    @track value;
    @track error;
    @track items;
    @api contractFrameworkRecordId = '';
    @api corporateTreatmentId = '';
    @api corporateTreatmentJob = '';
    @api contractTreatmentJobId = '';
    @api contractTreatmentJobName;
    @track picklistValue = '';
    @track optionList;
    @track searchValue = '';
    @track corporateTreatmentJobProducts = [];
    @track isTableEmpty = false;
    selectedIds = [];
    selectedRows = [];
    @api preSelectedRows = [];
    @api allSelectedRows = [];
    @api allSelectedIds = [];
    table;
    rows;

    label = {
        FamilySelectionHeadingLabel,
        FamilySelectionParagraphLabel,
        FamilySelectionTypePlaceholder,
        FamilySelectionSearchPlaceholder,
        FamilySelectionTableName,
        FamilySelectionTableCode,
        NoElements
    };

    @wire(getCorporateTreatmentJobFamily, {
        corporateTreatment: '$corporateTreatmentId', corporateTreatmentJob: '$corporateTreatmentJob',
        contractFramework: '$contractFrameworkRecordId', picklistValue: '$picklistValue', searchValue: '$searchValue', allSelectedIds: '$allSelectedIds',
        contractTreatmentJobId: '$contractTreatmentJobId'
    })

    populateTable(value) {
        this.corporateTreatmentJobProducts = value;
        const { data, error } = value;
        if (data) {
            console.log('Data.length: ' + data.length);
            if (data.length === 0) {
                this.isTableEmpty = true;
            }
            else {
                this.isTableEmpty = false;
            }
        }
        else if (error) {
            console.log('ERROR: ' + error);
        }
    }

    renderedCallback() {

        console.log('FAMILY:::::::::::::::::::: Contract framework: ' + this.contractFrameworkRecordId);
        console.log('CorporateTreatmentId: ' + this.corporateTreatmentId);
        console.log('CorporateTreatmentJob: ' + this.corporateTreatmentJob);
        console.log('PRESELECTED ROWS: ' + this.preSelectedRows);
        console.log('CONTRACT TREATMENT JOB IN FAMILYSELECTION:::::::::::::::::::: ' + this.contractTreatmentJobId);
        this.refresh();
    }

    refresh() {
        return refreshApex(this.corporateTreatmentJobProducts);
    }

    @wire(getProductTypes)
    optionList;
    /*getOptions({error, data}) {
        if(data) {
            console.log('Data: ' + JSON.stringify(data));
            this.optionList = JSON.stringify(data);
            console.log('Picklist options: ' + this.options);
        }
        else if(error) {
        this.error = error;
        console.log(this.error);
        }
    }*/

    get options() {
        console.log('Options: ' + JSON.stringify(this.optionList.data));
        console.log('Contract framework arrivato da parent: ' + this.contractFrameworkRecordId);
        return this.optionList.data;
    }

    closeModal() {
        this.viewFamilySelection = false;
        this.viewPage3 = true;
    }


    handleProductTypeChange(event) {
        this.allSelectedIds = [];
        if (this.selectedRows === undefined) {
            console.log('SELECTED ROWS ERA UNDEFINED');
            this.selectedRows = [];
        }
        console.log('SELECTED ROWSSSSSSSSSSSS: ' + this.selectedRows + 'NUMBER: ' + this.selectedRows.length);
        for (let i = 0; i < this.selectedRows.length; i++) {
            //let a = [];
            console.log('INDEX: ' + this.selectedRows.indexOf(this.selectedRows[i]));
            this.allSelectedIds.push(this.selectedRows[i].id);
        }
        console.log('All selected ids: ' + this.allSelectedIds);
        if (event.target.value === this.picklistValue) {
            console.log('should reset');
            this.picklistValue = '';
        }
        this.picklistValue = event.target.value;
        console.log('picklistValue: ' + event.target.value);
    }

    handleSearchChange(event) {
        /*if(this.selectedRows !== undefined) {
            for (let i = 0; i < this.selectedRows.length; i++){
                if(!this.allSelectedIds.includes(this.selectedRows[i].productId)) {
                    this.allSelectedIds.push(this.selectedRows[i].productId);
                }
                console.log('All selected IDS: ' + this.allSelectedIds);
            }
        }*/
        console.log('ALL SELECTED IDS BEFORE PUSH: ' + this.allSelectedIds);
        this.allSelectedIds = [];
        if (this.selectedRows === undefined) {
            console.log('SELECTED ROWS ERA UNDEFINED');
            this.selectedRows = [];
        }
        console.log('SELECTED ROWSSSSSSSSSSSS: ' + this.selectedRows + 'NUMBER: ' + this.selectedRows.length);
        for (let i = 0; i < this.selectedRows.length; i++) {
            //let a = [];
            this.allSelectedIds.push(this.selectedRows[i].id);
        }
        console.log('All selected ids: ' + this.allSelectedIds);

        console.log('Search value: ' + event.target.value);
        {
            if (this.searchValue !== undefined) {
                this.searchValue = event.target.value;
            }
            console.log('searchkey ::::::::::::: ' + this.searchValue)
        }
        refreshApex(this.corporateTreatmentJobProducts);
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
        console.log('SELECTED ROW::::::::::::::::::::::::: ' + this.selectedRows);
    }

    @api
    passProductIds() {
        /*if(this.selectedRows === undefined) {
            return this.selectedIds;
        }*/
        if (this.selectedRows !== undefined) {
            for (let i = 0; i < this.selectedRows.length; i++) {
                this.selectedIds.push(this.selectedRows[i].productId);
            }
        }
        console.log('ID FAMIGLIE SELEZIONATE CHE STO PASSANDO AL PADRE: ' + this.selectedIds);
        return this.selectedIds;
    }
}