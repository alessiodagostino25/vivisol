/*eslint-disable no-console*/
import { LightningElement, track, api, wire } from 'lwc';
import getPricebookEntries from '@salesforce/apex/DefaultBomProductSelectionController.getPricebookEntries';
import {refreshApex} from '@salesforce/apex';

import ProductConfigStepTableProductName from '@salesforce/label/c.CT_ProductSelection_TableProductName';
import ProductConfigStepTableProductCode from '@salesforce/label/c.CT_ProductSelection_TableProductCode';
import ProductConfigStepTableFamilyName from '@salesforce/label/c.CT_FamilySelection_TableName';
import ProductConfigStepTableManufacturer from '@salesforce/label/c.CT_ProductSelection_TableManufacturer';
import DefaultBOMSelectionHeading from '@salesforce/label/c.CT_DefaultBOMSelection_Heading';
import DefaultBOMSelectionParagraph from '@salesforce/label/c.CT_DefaultBOMSelection_Paragraph';
import NoElements from '@salesforce/label/c.Generic_NoElements';

const columns = [
    { label: ProductConfigStepTableProductName, fieldName: 'Product_Name_Translate', type: 'text'},
    { label: ProductConfigStepTableProductCode, fieldName: 'Product_Code' },
    { label: ProductConfigStepTableFamilyName, fieldName: 'Product_Family'},
    { label: ProductConfigStepTableManufacturer, fieldName: 'Manufacturer_part_number'}
];

export default class DefaultBomProductSelection extends LightningElement {
    columns = columns;
    labels = {
        ProductConfigStepTableProductName,
        ProductConfigStepTableProductCode,
        ProductConfigStepTableFamilyName,
        ProductConfigStepTableManufacturer,
        DefaultBOMSelectionHeading,
        DefaultBOMSelectionParagraph,
        NoElements
    }

    @track searchValue = '';
    @track isTableEmpty = false;
    @track pricebookEntries;
    
    @api contractTreatmentJobId;
    @api contractTreatmentJobName;
    @api selectedIds = [];
    
    selectedRows = [];

    /*@wire(getPricebookEntries, {contractTreatmentJobId: '$contractTreatmentJobId', searchValue: '$searchValue', selectedIds: '$selectedIds'})
    populateTable(value) {
        this.pricebookEntries = value;
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
    }*/

    renderedCallback() {
        //refreshApex(this.pricebookEntries);
    }

    connectedCallback() { //NEW
        console.log('DEFAULT BOM PRODUCT SELECTION Executing connected callback');
        console.log('this.contractTreatmentJobId: ' + this.contractTreatmentJobId);
        console.log('this.searchValue: ' + this.searchValue);
        console.log('this.selectedIds: ' + this.selectedIds);
        getPricebookEntries({
            contractTreatmentJobId: this.contractTreatmentJobId,
            searchValue: this.searchValue,
            selectedIds: this.selectedIds
        }).then((data) => {
            if(data) {
                console.log('Data.length product selection: ' + data.length);
                console.log(data);
                this.pricebookEntries = data;
                if(data.length === 0) {
                    this.isTableEmpty = true;
                }
                else {
                    this.isTableEmpty = false;
                }
            }
        });
    }

    handleSearchChange(event) {
        for(let i = 0; i < this.selectedRows.length; i++) {
            //Adding the selected row's Account Id to the list of selected Ids

            if(!this.selectedIds.includes(this.selectedRows[i].Id)) {
                this.selectedIds.push(this.selectedRows[i].Id);
            }
        }

        this.searchValue = event.target.value;
        console.log('Selected ids: ' + this.selectedIds);
        this.connectedCallback(); //NEW
    }
    
    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    @api
    passSelectedIds() {
        //Also have to do this here. If not, if the search bar is never used, selectedIds is empty 

        for(let i = 0; i < this.selectedRows.length; i++) {
            //Adding the selected row's Account Id to the list of selected Ids

            if(!this.selectedIds.includes(this.selectedRows[i].Id)) {
                this.selectedIds.push(this.selectedRows[i].Id);
            }
        }
        
        return this.selectedIds;
    }
}