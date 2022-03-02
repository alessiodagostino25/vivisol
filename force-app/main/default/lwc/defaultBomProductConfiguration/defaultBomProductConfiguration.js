/*eslint-disable no-console*/
import { LightningElement, track, api, wire } from 'lwc';
import {refreshApex} from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import Heading from '@salesforce/label/c.CT_DefaultBOMConfiguration_Heading';
import Paragraph from '@salesforce/label/c.CT_DefaultBOMConfiguration_Paragraph';
import ProductConfigStepTableProductName from '@salesforce/label/c.CT_ProductSelection_TableProductName';
import ProductConfigStepTableProductCode from '@salesforce/label/c.CT_ProductSelection_TableProductCode';
import ProductConfigStepTableFamilyName from '@salesforce/label/c.CT_FamilySelection_TableName';
import ProductConfigStepTableManufacturer from '@salesforce/label/c.CT_ProductSelection_TableManufacturer';
import DeleteModalHeader from '@salesforce/label/c.CT_DefaultBOMDeleteModal_Delete';
import DeleteModalMessage1 from '@salesforce/label/c.CT_DefaultBOMDeleteModal_Message1';
import DeleteModalMessage2 from '@salesforce/label/c.CT_DefaultBOMDeleteModal_Message2';
import CloseModal from '@salesforce/label/c.CT_JobConfiguration_ModalCloseIcon';
import Cancel from '@salesforce/label/c.Btn_Cancel';
import Delete from '@salesforce/label/c.AT_JobTile_DeleteButton';
import SearchProducts from '@salesforce/label/c.createQuoteLineItem_SearchProducts';
import NoElements from '@salesforce/label/c.Generic_NoElements';

import getDefaultBOMs from '@salesforce/apex/DefaultBomProductConfigurationController.getDefaultBOMs';
import deleteDefaultBOM from '@salesforce/apex/DefaultBomProductConfigurationController.deleteDefaultBOM';

// These are the actions of the Datatable

const actions = [
    { label: 'Delete', name: 'delete' },
];

// These are the columns of the Datatable

const columns = [
    { label: ProductConfigStepTableProductName, fieldName: 'Product_Name_Translate'},
    { label: ProductConfigStepTableProductCode, fieldName: 'Product_Code'},
    { label: ProductConfigStepTableFamilyName, fieldName: 'Product_Family'},
    { label: ProductConfigStepTableManufacturer, fieldName: 'Manufacturer_part_number'},

    // Adding actions to the Datatable
    {
        type: 'action',
        typeAttributes: { rowActions: actions }
    }
];

export default class DefaultBomProductConfiguration extends LightningElement {

    labels = {
        Heading,
        Paragraph,
        DeleteModalHeader,
        DeleteModalMessage1,
        DeleteModalMessage2,
        CloseModal,
        Cancel,
        Delete,
        SearchProducts,
        NoElements
    };

    @api contractTreatmentJobId;
    @api contractTreatmentJobName;

    @track showDeleteModal = false;
    @track isTableEmpty = false;
    @track searchValue = '';
    @track defaultBOMs;

    selectedDefaultBOMId;
    selectedDefaultBOMName;

    columns = columns;

    /*@wire(getDefaultBOMs, {contractTreatmentJobId: '$contractTreatmentJobId', searchValue: '$searchValue'})
    populateTable(value) {
        this.defaultBOMs = value;
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

    connectedCallback() { //NEW
        getDefaultBOMs({
            contractTreatmentJobId: this.contractTreatmentJobId,
            searchValue: this.searchValue
        }).then((data) => {
            if(data) {
                console.log('Data.length getDefaultBOMs: ' + data.length);
                this.defaultBOMs = data;
                if(data.length === 0) {
                    this.isTableEmpty = true;
                }
                else {
                    this.isTableEmpty = false;
                }
            }
        })
    }

    renderedCallback() {
        console.log('ContractTreatmentJobId in ProductConfiguration: ' + this.contractTreatmentJobId);
        //refreshApex(this.defaultBOMs);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        this.selectedDefaultBOMId = event.detail.row.Id;
        this.selectedDefaultBOMName = event.detail.row.Product_Name_Translate;
        console.log('Selected Contact Id: ' + this.selectedDefaultBOMId);

        if(actionName === 'delete') {
            this.showDeleteModal = true;
        }
    }

    handleSearchChange(event) {
        this.searchValue = event.target.value;
        this.connectedCallback(); //NEW
    }

    handleCloseModal() {
        this.showDeleteModal = false;
    }

    handleDeleteDefaultBOM() {
        console.log('To delete: ' + this.selectedDefaultBOMId);
        deleteDefaultBOM({
            defaultBOMId: this.selectedDefaultBOMId
        })
        .then(() => 
            {
                // ToastEvent to display a toast to notify the success
                const evt = new ShowToastEvent({
                    title: "Default BOM Deleted",
                    message: "The Default BOM was successfully deleted",
                    variant: "success"
                });
                this.dispatchEvent(evt);
                
                this.showDeleteModal = false;
                //refreshApex(this.defaultBOMs);
                this.connectedCallback(); //NEW

        }).catch(error => {
            console.log('ERROR IN DELETING RECORD: ' + error);
        });
    }
}