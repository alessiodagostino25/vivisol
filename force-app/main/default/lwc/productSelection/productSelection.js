/*eslint-disable no-console*/
import { LightningElement, track, wire, api } from 'lwc';
import getCorporateTreatmentJobProduct from '@salesforce/apex/CorporateTreatmentJobProductController.getCorporateTreatmentJobProduct';
import getProductTypes from '@salesforce/apex/CorporateTreatmentJobFamilyController.getProductTypes';
import { refreshApex } from '@salesforce/apex';
import ProductSelectionHeading from '@salesforce/label/c.CT_ProductSelection_Heading';
import ProductSelectionParagraph from '@salesforce/label/c.CT_ProductSelection_Paragraph';
import ProductSelectionTypePlaceholder from '@salesforce/label/c.CT_ProductSelection_TypePlaceholder';
import ProductSelectionSearchPlaceholder from '@salesforce/label/c.CT_ProductSelection_SearchPlaceholder';
import ProductSelectionTableProductName from '@salesforce/label/c.CT_ProductSelection_TableProductName';
import ProductSelectionTableProductCode from '@salesforce/label/c.CT_ProductSelection_TableProductCode';
import ProductSelectionTableFamilyName from '@salesforce/label/c.CT_FamilySelection_TableName';
import ProductSelectionTableFamilyCode from '@salesforce/label/c.CT_FamilySelection_TableCode';
import ProductSelectionTableManufacturer from '@salesforce/label/c.CT_ProductSelection_TableManufacturer';
import NoElements from '@salesforce/label/c.Generic_NoElements';

const columns = [
    { label: ProductSelectionTableProductName, fieldName: 'Name', type: 'text'},     //TODO: EDIT FOR PRODUCTS
    { label: ProductSelectionTableProductCode, fieldName: 'Product_Code' },
    //{ label: 'ID Prodotto', fieldName: 'productId'},
    { label: ProductSelectionTableFamilyName, fieldName: 'family_name'},
    { label: ProductSelectionTableFamilyCode, fieldName: 'family_code'},
    { label: ProductSelectionTableManufacturer, fieldName: 'manufacturer_number'}
];

/*const steps = [
    { label: 'Family Selection', value: 'step-1' },
    { label: 'Product Selection', value: 'step-2' },
    { label: 'Configuration', value: 'step-3' },
];*/

export default class FamilySelection extends LightningElement {

    @track columns = columns;
    @api step;
    @track value;
    //@track viewPage3 = false;
    //@api viewFamilySelection; 
    @api viewProductSelection;
    @api selectedFamilyIds = [];
    //@track options;
    @track error;
    @track items;
    @api contractFrameworkRecordId; 
    @api corporateTreatmentId; 
    @api corporateTreatmentJob;
    @api contractTreatmentJobName;
    @api currentStep = 'step-2';
    @api contractTreatmentJobId;
    @track picklistValue = '';
    @track optionList;
    @track corporateTreatmentJobProducts;
    @track searchValue = '';
    @track isTableEmpty = false;
    @api allSelectedRows = [];
    @api allSelectedIds = [];
    selection = '';
    selectedIds = [];

    label = {
        ProductSelectionHeading,
        ProductSelectionParagraph,
        ProductSelectionTypePlaceholder,
        ProductSelectionSearchPlaceholder,
        ProductSelectionTableProductName,
        ProductSelectionTableProductCode,
        ProductSelectionTableFamilyName,
        ProductSelectionTableFamilyCode,
        ProductSelectionTableManufacturer,
        NoElements
    };

    @wire(getCorporateTreatmentJobProduct, {corporateTreatment: '$corporateTreatmentId', corporateTreatmentJob: '$corporateTreatmentJob', 
    contractFramework: '$contractFrameworkRecordId', picklistValue: '$picklistValue', searchValue: '$searchValue', 
    /*viewProductSelection: '$viewProductSelection',*/ selectedFamilyStrings: '$selectedFamilyIds', allSelectedIds: '$allSelectedIds', contractTreatmentJobId: '$contractTreatmentJobId'})
    populateTable(value) {
        this.corporateTreatmentJobProducts = value;
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

    /*closeModal() {
        this.viewFamilySelection = false;
        this.viewPage3 = true;
    }*/


    handleProductTypeChange(event) {
        this.allSelectedIds = [];
        if(this.selectedRows === undefined) {
            console.log('SELECTED ROWS ERA UNDEFINED');
            this.selectedRows = [];
        }
        console.log('SELECTED ROWSSSSSSSSSSSS: ' + this.selectedRows + 'NUMBER: ' + this.selectedRows.length);
        for(let i = 0; i < this.selectedRows.length; i++) {
            //let a = [];
            this.allSelectedIds.push(this.selectedRows[i].productId);
        }
        console.log('All selected ids: ' + this.allSelectedIds);

        if(event.target.value === this.picklistValue) {
            console.log('should reset');
            this.picklistValue = '';
        }
        this.picklistValue = event.target.value;
        console.log('picklistValue: ' + event.target.value);
    }

    handleSearchChange(event) {
        this.allSelectedIds = [];
        if(this.selectedRows === undefined) {
            console.log('SELECTED ROWS ERA UNDEFINED');
            this.selectedRows = [];
        }
        console.log('SELECTED ROWSSSSSSSSSSSS: ' + this.selectedRows + 'NUMBER: ' + this.selectedRows.length);
        for(let i = 0; i < this.selectedRows.length; i++) {
            //let a = [];
            this.allSelectedIds.push(this.selectedRows[i].productId);
        }
        console.log('All selected ids: ' + this.allSelectedIds);

        console.log('Search value: ' + event.target.value);
        {
            this.searchValue = event.target.value;
            console.log('searchkey ::::::::::::: '+this.searchValue)
        }
        /*for (let i = 0; i < this.selectedRows.length; i++){ //TO KEEP SELECTION
            this.allSelectedRows.push(this.selectedRows[i]);
        }
        console.log('ALL SELECTED ROWS: ' + this.allSelectedRows);*/
        return refreshApex(this.corporateTreatmentJobProducts);
    }

    renderedCallback() {
        console.log('ContractFramework in ProductSelection: ' + this.contractFrameworkRecordId);
        console.log('CorporateTreatmentId in ProductSelection: ' + this.corporateTreatmentId);
        console.log('CorporateTreatmentJob in ProductSelection: ' + this.corporateTreatmentJob);
        console.log('ContractTreatmentJobId in ProductSelection: ' + this.contractTreatmentJobId);
        this.refresh();
    }

    refresh() {
        return refreshApex(this.corporateTreatmentJobProducts);
    }

    /*@api
    refresh() {
        refreshApex(this.corporateTreatmentJobProducts);
    }*/

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
        // Display that fieldName of the selected rows  
        /*let partialSelection = [];
        partialSelection.push(selectedRows);*/
        //console.log('selected row id'+this.selectedRows1)
    }

    @api
    passProductIds() {
        if(this.selectedRows === undefined) {
            return this.selectedIds;
        }
        for (let i = 0; i < this.selectedRows.length; i++){
            this.selectedIds.push(this.selectedRows[i].productId);
            console.log('Id che sto pushando in selectedIds: ' + this.selectedRows[i].productId);
        }
        console.log('ID PRODOTTI SELEZIONATI CHE STO PASSANDO AL PADRE: ' + this.selectedIds);
        return this.selectedIds;
    }
}