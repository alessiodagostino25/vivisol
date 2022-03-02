/* eslint-disable no-console */
import { LightningElement, track, wire, api } from 'lwc';
import getProductTypes from '@salesforce/apex/CorporateTreatmentJobProductController.getProductTypes';
import getCTJP from '@salesforce/apex/CorporateTreatmentJobProductController.getCTJP';
import deleteProduct from '@salesforce/apex/CorporateTreatmentJobProductController.deleteProduct';
import getTableAction from '@salesforce/apex/CorporateTreatmentJobProductController.getCTJPTableActions';
import propagateQuantity from '@salesforce/apex/CorporateTreatmentJobProductController.propagateCTJPQuantity';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ProductConfigStepHeading from '@salesforce/label/c.CT_ProductConfigStep_Heading';
import ProductConfigStepParagraph from '@salesforce/label/c.CT_ProductConfigStep_Paragraph';
import ProductConfigStepSearchPlaceholder from '@salesforce/label/c.CT_ProductConfigStep_SearchPlaceholder';
import ProductConfigStepTableProductName from '@salesforce/label/c.CT_ProductSelection_TableProductName';
import ProductConfigStepTableProductCode from '@salesforce/label/c.CT_ProductSelection_TableProductCode';
import ProductConfigStepTableFamilyName from '@salesforce/label/c.CT_FamilySelection_TableName';
import ProductConfigStepTableManufacturer from '@salesforce/label/c.CT_ProductSelection_TableManufacturer';
import ProductConfigStepTableProductType from '@salesforce/label/c.CT_ProductConfigStep_TableProductType';
import ProductConfigStepTableQuantity from '@salesforce/label/c.CT_ProductConfigStep_TableQuantity';
import ProductConfigStepTableMinQuantity from '@salesforce/label/c.CT_ProductConfigStep_TableMinQuantity';
import ProductConfigStepTableMaxQuantity from '@salesforce/label/c.CT_ProductConfigStep_TableMaxQuantity';
import ProductConfigStepTableUnitOfMeasure from '@salesforce/label/c.CT_ProductConfigStep_TableUnitOfMeasure';
import ProductConfigStepTableConfigured from '@salesforce/label/c.CT_ProductConfigStep_TableConfigured';
import PropagateQuantityButton from '@salesforce/label/c.CT_ProductConfigStep_PropagateQuantityButton';
import PropagateQuantityHeader from '@salesforce/label/c.CT_ProductConfigStep_PropagateQuantityHeader';
import PropagateQuantityDescription from '@salesforce/label/c.CT_ProductConfigStep_PropagateQuantityDescription';
import ManageStatus from '@salesforce/label/c.CT_JobTile_ManageStatus';
import Status from '@salesforce/label/c.CT_Status';
import Billable from '@salesforce/label/c.ContractTreatmentRelatedList_Billable';
import NoElements from '@salesforce/label/c.Generic_NoElements';

const actions = [
    { label: 'Configure', name: 'configure' },
    { label: 'Delete', name: 'delete' }
];

const columns = [
    { label: ProductConfigStepTableProductName, fieldName: 'Name', type: 'text' },
    { label: ProductConfigStepTableProductCode, fieldName: 'Product_Code' },
    { label: ProductConfigStepTableFamilyName, fieldName: 'family_name' },
    { label: ProductConfigStepTableManufacturer, fieldName: 'manufacturer_number' },
    { label: ProductConfigStepTableProductType, fieldName: 'product_type' },
    { label: ProductConfigStepTableQuantity, fieldName: 'quantity', type: 'number', cellAttributes: { alignment: "left" } },
    { label: ProductConfigStepTableMinQuantity, fieldName: 'min_quantity', type: 'number', cellAttributes: { alignment: "left" } },
    { label: ProductConfigStepTableMaxQuantity, fieldName: 'max_quantity', type: 'number', cellAttributes: { alignment: "left" } },
    { label: Status, fieldName: 'status' },
    { label: Billable, fieldName: 'billable', type: 'boolean'},
    { label: ProductConfigStepTableConfigured, fieldName: 'configured', type: 'boolean' },
    {
        type: 'action',
        typeAttributes: { rowActions: actions }
    }
];


export default class ProductConfigurationStep extends LightningElement {

    @track columns = columns;
    @api step;
    @track value;
    @api viewProductSelection;
    @api selectedFamilyIds;
    @api viewProductConfigurationStep;
    viewProductConfigModal = false;
    @track error;
    @track items;
    @api contractFrameworkRecordId;
    @api corporateTreatmentId;
    @api corporateTreatmentJob;
    @api contractTreatmentJobId;
    @api contractTreatmentJobName;
    @api currentStep = 'step-3';
    @track deleteModal = false;
    @track picklistValue = '';
    @track optionList;
    @track contractTreatmentJobProducts;
    @track searchValue = '';
    selection = '';
    selectedIds = [];
    @api familiesAndProducts;
    @api productsToShow = [];
    @api selectedProductId;
    @api productName;
    @api frameworkIsActive;
    @api frameworkIsInactive;
    showManageStatusModal = false;
    showPropagateQuantityModal = false;

    label = {
        ProductConfigStepHeading,
        ProductConfigStepParagraph,
        ProductConfigStepSearchPlaceholder,
        ProductConfigStepTableProductName,
        ProductConfigStepTableProductCode,
        ProductConfigStepTableFamilyName,
        ProductConfigStepTableManufacturer,
        ProductConfigStepTableProductType,
        ProductConfigStepTableQuantity,
        ProductConfigStepTableMinQuantity,
        ProductConfigStepTableUnitOfMeasure,
        ProductConfigStepTableConfigured,
        ManageStatus,
        Status,
        NoElements,
        PropagateQuantityButton,
        PropagateQuantityHeader,
        PropagateQuantityDescription
    };

    @wire(getCTJP, {/*productsToGet: '$familiesAndProducts', */contractTreatmentJob: '$contractTreatmentJobId', searchValue: '$searchValue' })
    populateTable(value) {
        this.productsToShow = value;
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


    @wire(getProductTypes)
    optionList;


    get options() {
        console.log('Options: ' + JSON.stringify(this.optionList.data));
        console.log('Contract framework arrivato da parent: ' + this.contractFrameworkRecordId);
        return this.optionList.data;
    }


    /*handleProductTypeChange(event) {
        if(event.target.value === this.picklistValue) {
            console.log('should reset');
            this.picklistValue = '';
        }
        this.picklistValue = event.target.value;
        console.log('picklistValue: ' + event.target.value);
    }*/

    handleSearchChange(event) {
        console.log('Search value: ' + event.target.value);
        {
            this.searchValue = event.target.value;
            console.log('searchkey ::::::::::::: ' + this.searchValue)
        }
        return refreshApex(this.result);
    }

    renderedCallback() {
        console.log('Job Id in Config Step: ' + this.contractTreatmentJobId);
        console.log('FamiliesAndProducts arrivati alla Config: ' + this.familiesAndProducts);
        refreshApex(this.productsToShow);
        console.log('NUMERO RECORD IN CONFIG: ' + this.productsToShow.length);
        console.log('Actions:::::::::::::::::::::::::::::::::::::::::::::::::: ' + actions);
        console.log('Framework is Active? ' + this.frameworkIsActive);
    }

    constructor() {
        super();
        this.columns = [
            // Other column data here
            { label: ProductConfigStepTableProductName, fieldName: 'Name', type: 'text', wrapText: true },
            { label: ProductConfigStepTableProductCode, fieldName: 'Product_Code' },
            { label: ProductConfigStepTableFamilyName, fieldName: 'family_name', wrapText: true },
            { label: ProductConfigStepTableManufacturer, fieldName: 'manufacturer_number' },
            { label: ProductConfigStepTableProductType, fieldName: 'product_type' },
            { label: ProductConfigStepTableQuantity, fieldName: 'quantity', type: 'number', cellAttributes: { alignment: "left" } },
            { label: ProductConfigStepTableMinQuantity, fieldName: 'min_quantity', type: 'number', cellAttributes: { alignment: "left" } },
            { label: ProductConfigStepTableMaxQuantity, fieldName: 'max_quantity', type: 'number', cellAttributes: { alignment: "left" } },
            //{ label: ProductConfigStepTableUnitOfMeasure, fieldName: 'quantity_UOM' },
            { label: Status, fieldName: 'status' },
            { label: Billable, fieldName: 'billable', type: 'boolean'},
            { label: ProductConfigStepTableConfigured, fieldName: 'configured', type: 'boolean' },
            { type: 'action', typeAttributes: { rowActions: this.getRowActions } },
        ]
    }

    getRowActions(row, doneCallback) {
        const actions = [];

        getTableAction({
            contractTreatmentJobProductId: row['productId']
        })
            .then(result => {
                doneCallback(result);
            })
            .catch(error => {
                doneCallback(actions);
            });
    }

    handleRowAction(event) {
        console.log('VIEW MODAL PRODUCT CONFIG: ' + this.viewProductConfigModal);
        const actionName = event.detail.action.name;
        this.selectedProductId = event.detail.row.productId;
        this.productName = event.detail.row.Name;
        console.log('Action: ' + actionName);
        console.log('Selected product Id: ' + this.selectedProductId);
        if (event.detail.action.name === 'configure') {
            console.log('YOU ARE IN CONFIGURE');
            this.viewProductConfigModal = true;
        }
        else if (event.detail.action.name === 'delete') {
            console.log('YOU ARE IN DELETE');
            this.deleteModal = true;
        }
        else if (event.detail.action.name === 'managestatus') {
            console.log('YOU ARE IN MANAGE STATUS');
            this.showManageStatusModal = true;
        }
        else if (event.detail.action.name === 'progateQuantity') {
            console.log('YOU ARE IN PROPAGATE QUANTITY');
            this.showPropagateQuantityModal = true;
        }
    }

    handleProductSave(event) {
        console.log('Event.detail: ' + event.detail);
        this.viewProductConfigModal = event.detail;
    }

    handleStatusSubmit() {
        const evt = new ShowToastEvent({
            title: "Product Status updated ",
            //message: "Record ID: " + this.contractTreatmentJobId,
            variant: "success"
        });
        this.dispatchEvent(evt);
        this.showManageStatusModal = false;
    }

    closeDeleteModal() {
        this.deleteModal = false;
    }

    closePropagateQuantityModal() {
        this.showPropagateQuantityModal = false;
    }

    closeManageStatusModal() {
        this.showManageStatusModal = false;
    }

    handlePropagateQuantity() {
        console.log('Id da riga: ' + this.selectedProductId);
        propagateQuantity({
            contractTreatmentJobProductId: this.selectedProductId
        }).then(() => {
            refreshApex(this.productsToShow);
            const evt = new ShowToastEvent({
                title: "Quantity Propagated",
                variant: "success"
            });
            this.dispatchEvent(evt);
            this.showPropagateQuantityModal = false;
        }).catch(error => {
            this.error = error;
            refreshApex(this.productsToShow);
            const evt = new ShowToastEvent({
                title: "Quantity Not Propagated",
                variant: "error"
            });
            this.dispatchEvent(evt);
            this.showPropagateQuantityModal = false;
        });
    }

    handleDeleteProduct() {
        console.log('Id da riga: ' + this.selectedProductId);
        deleteProduct({
            productId: this.selectedProductId
        }).then(() => {
            console.log('RECORD' + this.selectedProductId + 'ELIMINATO');
            refreshApex(this.productsToShow);
        }).catch(error => {
            this.error = error;
            console.log('ERROR IN DELETING RECORD: ' + this.error);
        });
        const evt = new ShowToastEvent({
            title: "Product Deleted",
            variant: "success"
        });
        this.dispatchEvent(evt);
        this.deleteModal = false;
    }

    @api
    passCreatedProducts() {  //CAN'T MANAGE TO PASS THIS, UNDEFINED
        console.log('Products being passed from ConfigStep to productConfiguration:::::: ' + this.productsToShow.length);
        return this.productsToShow;
    }

    handleStatusModal(event){
        this.showManageStatusModal = false;
        if (event.detail.isUpdated == true){
            const evt = new ShowToastEvent({
                title: "Status Updated",
                variant: "success"
            });
            this.dispatchEvent(evt);
        }
        if (event.detail.isSubstituted == true){
            const evt = new ShowToastEvent({
                title: "Product Substituted",
                variant: "success"
            });
            this.dispatchEvent(evt);
        }
    }


}