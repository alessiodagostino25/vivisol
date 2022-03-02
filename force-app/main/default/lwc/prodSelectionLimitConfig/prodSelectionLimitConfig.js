/* eslint-disable no-console */
import { LightningElement, track, wire, api} from 'lwc';
//import getContractProductLimitController from '@salesforce/apex/ContractProductLimitController.getContractProductLimitController';
//import getProducts from '@salesforce/apex/ProductLimitsController.getProducts';
import getInactiveLimits from '@salesforce/apex/ProductLimitsController.getInactiveLimits';
import { refreshApex } from '@salesforce/apex';
import ProductLimitsSelectionHeading from '@salesforce/label/c.CT_ProductLimitsSelection_Heading';
import ProductLimitsSelectionParagraph from '@salesforce/label/c.CT_ProductLimitsSelection_Paragraph';
import ProductLimitsSelectionTypePlaceholder from '@salesforce/label/c.CT_ProductSelection_TypePlaceholder';
import ProductLimitsSelectionSearchPlaceholder from '@salesforce/label/c.CT_ProductSelection_SearchPlaceholder';
import ProductLimitsSelectionTableLimitName from '@salesforce/label/c.CT_ProductLimitsSelection_TableLimitName';
import ProductLimitsSelectionTableProductCode from '@salesforce/label/c.CT_ProductSelection_TableProductCode';
import NoElements from '@salesforce/label/c.Generic_NoElements';

const columns = [
    { label: ProductLimitsSelectionTableLimitName, fieldName: 'Name', type: 'text'},     //TODO: EDIT FOR PRODUCTS
    //{ label: 'Product  Family Name ', fieldName: 'ProductName' },
    { label: ProductLimitsSelectionTableProductCode, fieldName: 'ProductCode'}
    //{ label: 'ID Prodotto', fieldName: 'productId'},
    //{ label: 'Status', fieldName: 'Status'},
];

export default class prodSelectionLimitConfig extends LightningElement {

    @api page3;
    @api contractTreatmentRecordId;
    @api allSelectedRows = [];
    @api allSelectedIds = [];
    @api viewProductSelection;
    @api contractTreatmentName;
    @track searchValue = '';
    @track picklistValue = '';
    @track columns = columns; //holds column info.
    @track error; //this holds errors
    @track products = [];
    @track isTableEmpty = false;
    selectedIds = [];

    label = {
        ProductLimitsSelectionHeading,
        ProductLimitsSelectionParagraph,
        ProductLimitsSelectionTypePlaceholder,
        ProductLimitsSelectionSearchPlaceholder,
        ProductLimitsSelectionTableLimitName,
        ProductLimitsSelectionTableProductCode,
        NoElements
    };

    @wire(getInactiveLimits, {contractTreatmentId: '$contractTreatmentRecordId', searchValue: '$searchValue', allSelectedIds: '$allSelectedIds', productType: '$picklistValue'})
    populateTable(value) {
        this.products = value;
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
    } //THESE ARE LIMITS NOW

    get options() {
        return [
            { label: 'Products', value: 'products'},
            { label: 'Services', value: 'services'}
        ];
    }

    renderedCallback() {
        console.log('Contract Treatment Id in SelectionLimit: ' + this.contractTreatmentRecordId);
        refreshApex(this.products);
        //this.refresh();
    }

    /*refresh() {
        return refreshApex(this.corporateTreatmentJobProducts);
    }*/

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    handleProductTypeChange(event) {
        this.allSelectedIds = [];
        if(this.selectedRows === undefined) {
            console.log('SELECTED ROWS ERA UNDEFINED');
            this.selectedRows = [];
        }
        console.log('SELECTED ROWSSSSSSSSSSSS: ' + this.selectedRows + 'NUMBER: ' + this.selectedRows.length);
        for(let i = 0; i < this.selectedRows.length; i++) {
            //let a = [];
            this.allSelectedIds.push(this.selectedRows[i].Product);
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
            this.allSelectedIds.push(this.selectedRows[i].Product);
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
        //return refreshApex(this.corporateTreatmentJobProducts);
    }

    @api
    passProductIds() {
        if(this.selectedRows === undefined) {
            return this.selectedIds;
        }
        for (let i = 0; i < this.selectedRows.length; i++){
            this.selectedIds.push(this.selectedRows[i].Product);
            console.log('Id che sto pushando in selectedIds: ' + this.selectedRows[i].Product);
        }
        console.log('ID PRODOTTI SELEZIONATI CHE STO PASSANDO AL PADRE: ' + this.selectedIds);
        return this.selectedIds;
    }
}