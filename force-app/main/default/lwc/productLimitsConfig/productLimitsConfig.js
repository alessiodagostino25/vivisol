/* eslint-disable no-console */
import { LightningElement, track, wire, api} from 'lwc';
//import getContractProductLimitController from '@salesforce/apex/ContractProductLimitController.getContractProductLimitController';
//import getProducts from '@salesforce/apex/ProductLimitsController.getProducts';
import getLimits from '@salesforce/apex/ProductLimitsController.getLimits';
import deleteLimit from '@salesforce/apex/ProductLimitsController.deleteLimit';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ProductLimitsConfigHeading from '@salesforce/label/c.CT_ProductLimitsConfig_Heading';
import ProductLimitsConfigParagraph from '@salesforce/label/c.CT_ProductLimitsConfig_Paragraph';
import ProductLimitsConfigTypePlaceholder from '@salesforce/label/c.CT_ProductSelection_TypePlaceholder';
import ProductLimitsConfigSearchPlaceholder from '@salesforce/label/c.CT_ProductSelection_SearchPlaceholder';
import ProductLimitsConfigTableLimitName from '@salesforce/label/c.CT_ProductLimitsSelection_TableLimitName';
import ProductLimitsConfigTableLimitCode from '@salesforce/label/c.CT_ProductLimitsSelection_TableLimitName';
import NoElements from '@salesforce/label/c.Generic_NoElements';

const actions = [
    { label: 'Configure', name: 'configure' },
    { label: 'Delete', name: 'delete' },
];

const columns = [
    { label: ProductLimitsConfigTableLimitName, fieldName: 'Name', cellAttributes: { alignment:"left" }},     //TODO: EDIT FOR PRODUCTS
    //{ label: 'Product Name', fieldName: 'ProductName' },
    { label: ProductLimitsConfigTableLimitCode, fieldName: 'ProductCode',cellAttributes: { alignment:"left" }},
    { label: 'Frequency', fieldName: 'Frequency', type: 'number', cellAttributes: { alignment:"left" }},   //Other fields
    { label: 'Frequency Unit of Measure', fieldName: 'FrequencyUnitMeasure', cellAttributes: { alignment:"left" }},
    { label: 'Maximum Quantity', fieldName: 'MaxQuantity', type: 'number', cellAttributes: { alignment:"left" }},
    { label: 'Minimum Quantity', fieldName: 'MinQuantity', type: 'number', cellAttributes: { alignment:"left" }},
    { label: 'Quantity Unit of Measure', fieldName: 'QuantityUnitMeasure', cellAttributes: { alignment:"left" }},
    //{ label: 'ID Prodotto', fieldName: 'productId'},
    //{ label: 'Status', fieldName: 'Status'},
    { label: 'Configured', fieldName: 'Configured', type: 'boolean', cellAttributes: { alignment:"left" }},
    {
        type: 'action',
        typeAttributes: { rowActions: actions }
    }  //LOOK DOCUM. AT "Working with Inline Editing" FOR EVENTS TO UPDATE
];

export default class productLimitsConfig extends LightningElement {

    @api page3;
    @api productName;
    @api selectedLimitId;
    @api contractTreatmentName;
    @api contractTreatmentRecordId;
    @api allSelectedRows = [];
    @api allSelectedIds = [];
    @api viewLimitsConfiguration;
    @api selectedProducts = [];
    @track searchValue = '';
    @track picklistValue = '';
    @track deleteModal = false;
    @track limits = [];
    @track isTableEmpty = false;
    @track columns = columns; //holds column info.
    @track error; //this holds errors
    toRefresh;
    viewProductLimitModal = false;
    error;


    label = {
        ProductLimitsConfigHeading,
        ProductLimitsConfigParagraph,
        ProductLimitsConfigTypePlaceholder,
        ProductLimitsConfigSearchPlaceholder,
        ProductLimitsConfigTableLimitName,
        ProductLimitsConfigTableLimitCode,
        NoElements
    };

    renderedCallback() {
        console.log('selected products arrivati a limitsConfig: ' + this.selectedProducts.length);
        refreshApex(this.limits);
    }

    @wire(getLimits, {productIds: '$selectedProducts', contractTreatmentId: '$contractTreatmentRecordId', productType: '$picklistValue', searchValue: '$searchValue'})  //EDIT FOR FILTERS
    populateTable(value) {
        this.limits = value;
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
    /*getNewLimits({data, error}) {
        if(data) {
            this.toRefresh = data;
            let currentData = [];

            data.forEach((row) => {
                let rowData = {};
                
                rowData.Id = row.Id;
                console.log('row.Id: ' + row.Id);
                rowData.ProductName = row.Product__r.Name;
                rowData.LimitName = row.Name;
                rowData.Product = row.Product__c;
                rowData.Frequency = row.Frequency__c;
                rowData.FrequencyUnitOfMeasure = row.Frequency_Unit_of_measure__c;
                rowData.MaxQuantity = row.Max_Quantity__c;
                rowData.MinQuantity = row.Min_Quantity__c;
                rowData.QuantityUnitOfMeasure = row.Quantity_Unit_of_measure__c;
                rowData.Status = row.Status__c;
                
                currentData.push(rowData);
            });
            this.limits = currentData;
        }
        else if(error) {
            console.log('ERROR IN GETTING NEW LIMITS: ' + error);
        }
    }*/

    get options() {
        return [
            { label: 'Products', value: 'products'},
            { label: 'Services', value: 'services'}
        ];
    }

    /*renderedCallback() {
        this.refresh();
    }

    refresh() {
        return refreshApex(this.corporateTreatmentJobProducts);
    }*/
    handleRowAction(event) {
        console.log('VIEW MODAL: ' + this.viewProductLimitModal);
        const actionName = event.detail.action.name;
        this.selectedLimitId = event.detail.row.Id;
        console.log('Selected Limit Id: ' + this.selectedLimitId);
        this.productName = event.detail.row.ProductName;
        console.log('Action: ' + actionName);
        console.log('Selected product Id: ' + this.selectedProductId);
        if(event.detail.action.name === 'configure') {
            console.log('YOU ARE IN CONFIGURE');
            this.viewProductLimitModal = true;
        }
        else if(event.detail.action.name === 'delete') {
            console.log('YOU ARE IN DELETE');
            this.deleteModal = true;
        }
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    handleProductTypeChange(event) {
        /*this.allSelectedIds = [];
        if(this.selectedRows === undefined) {
            console.log('SELECTED ROWS ERA UNDEFINED');
            this.selectedRows = [];
        }
        console.log('SELECTED ROWSSSSSSSSSSSS: ' + this.selectedRows + 'NUMBER: ' + this.selectedRows.length);
        for(let i = 0; i < this.selectedRows.length; i++) {
            //let a = [];
            this.allSelectedIds.push(this.selectedRows[i].Id);
        }
        console.log('All selected ids: ' + this.allSelectedIds);

        if(event.target.value === this.picklistValue) {
            console.log('should reset');
            this.picklistValue = '';
        }*/
        this.picklistValue = event.target.value;
        console.log('picklistValue: ' + event.target.value);
    }

    handleSearchChange(event) {
        /*this.allSelectedIds = [];
        if(this.selectedRows === undefined) {
            console.log('SELECTED ROWS ERA UNDEFINED');
            this.selectedRows = [];
        }
        console.log('SELECTED ROWSSSSSSSSSSSS: ' + this.selectedRows + 'NUMBER: ' + this.selectedRows.length);
        for(let i = 0; i < this.selectedRows.length; i++) {
            //let a = [];
            this.allSelectedIds.push(this.selectedRows[i].Id);
        }
        console.log('All selected ids: ' + this.allSelectedIds);
*/
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

    handleLimitSave(event) {
        console.log('Event.detail: ' + event.detail);
        this.viewProductLimitModal = event.detail;
    }

    handleDeleteLimit() {
        console.log('Id da riga: ' + this.selectedProductId);
        deleteLimit({
            limitId: this.selectedLimitId
        }).then(() => 
            {
                console.log('RECORD' + this.selectedLimitId + 'ELIMINATO');
                refreshApex(this.limits);
            }).catch(error => {
                this.error = error;
                console.log('ERROR IN DELETING RECORD: ' + this.error);
            });
        const evt = new ShowToastEvent({
            title: "Product Limit Deleted",
            //message: "Record ID: " + this.selectedLimitId,
            variant: "success"
        });
        this.dispatchEvent(evt);
        this.deleteModal = false;
    }

    closeDeleteModal() {
        this.deleteModal = false;
    }

    @api
    passProductIds() {
        if(this.selectedRows === undefined) {
            return this.selectedIds;
        }
        for (let i = 0; i < this.selectedRows.length; i++){
            this.selectedIds.push(this.selectedRows[i].Id);
            console.log('Id che sto pushando in selectedIds: ' + this.selectedRows[i].Id);
        }
        console.log('ID PRODOTTI SELEZIONATI CHE STO PASSANDO AL PADRE: ' + this.selectedIds);
        return this.selectedIds;
    }
}