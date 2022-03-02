import { LightningElement, track, api, wire } from 'lwc';

// Apex actions
import getAssets from '@salesforce/apex/CTJAssetSelectionController.getAssets';
import createContractAssets from '@salesforce/apex/CTJAssetSelectionController.createContractAssets';
import getContractAssetsForCT from '@salesforce/apex/CTJAssetSelectionController.getContractAssetsForCT';

// Labels
import AssetManagement from '@salesforce/label/c.Generic_AssetManagement';
import SaveAndNext from '@salesforce/label/c.CT_ProductConfig_Next';
import Save from '@salesforce/label/c.AT_ProductSelection_SaveButton';
import AssetSelectionParagraph from '@salesforce/label/c.CTJ_SelectAssetsParagraph';
import NoElements from '@salesforce/label/c.Generic_NoElements';
import Back from '@salesforce/label/c.CT_ProductConfig_Back';
import NewContractAssetButtonLabel from '@salesforce/label/c.ContractAsset_NewButton';

// Other stuff
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from "@salesforce/apex";

const columns = [
    { label: 'Product Serial Number', fieldName: 'serialNumber'},
    { label: 'Product Manufacturer Id', fieldName: 'manufacturerId' },
    { label: 'Product Name', fieldName: 'productName'},
    { label: 'Product Code', fieldName: 'productCode'},
    { label: 'Product Manufacturer Part Number', fieldName: 'manufacturerPartNumber'},
    { label: 'Product Family Name', fieldName: 'familyName'}
];

export default class ContractTreatmentJobAssetSelection extends LightningElement {
    columns = columns;
    labels = {
        AssetManagement,
        Save,
        SaveAndNext,
        AssetSelectionParagraph,
        NoElements,
        Back,
        NewContractAssetButtonLabel
    };
    queryLimit = 30;

    @track isTableEmpty;
    @track searchInput = '';
    @track selectedIds = [];
    @track allAssets;
    @track assetsRelatedToCT;
    @track noRelatedAssets;
    @track isLoading = false;
    @track showSelectionPage = false;
    @track showConfigurationPage = true;

    @api contractTreatmentId;
    @api frameworkIsActive;

    // All Assets to show for Selection (first page)

    @wire(getAssets, {contractTreatmentId: '$contractTreatmentId', searchInput: '$searchInput', selectedIds: '$selectedIds', queryLimit: '$queryLimit'})
    getAllAssets(value) {
        console.log('In getAssets...');

        this.allAssets = value;
        const{data, error} = value;

        console.log('----- value for getAllAssets: ' + JSON.stringify(value));

        if(data) {
            if(data.length === 0) {
                this.isTableEmpty = true;
            }
            else {
                this.isTableEmpty = false;
            }
        }
        if(error) {
            console.log('Error: ' + error);
        }
    }

    // Assets related to the selected CTJ to show for Configuration (second page)

    @wire(getContractAssetsForCT, {contractTreatmentId: '$contractTreatmentId'})
    getRelatedAssets(value) {
        console.log('In getRelatedAssets...');

        this.assetsRelatedToCT = value;
        const{data, error} = value;

        console.log('----- value for getRelatedAssets: ' + JSON.stringify(value));

        if(data) {
            if(data.length === 0) {
                this.noRelatedAssets = true;
            }
            else {
                this.noRelatedAssets = false;
            }
        }
    }

    connectedCallback() {
        refreshApex(this.allAssets);

        console.log('contractTreatmentJobAssetSelection connected...');
        console.log('contractTreatmentId in contractTreatmentJobAssetSelection: ' + this.contractTreatmentId);
    }

    refreshAll() {
        refreshApex(this.allAssets);
        refreshApex(this.assetsRelatedToCT);
    }

    handleNewClick() {
        refreshApex(this.allAssets);
        this.showConfigurationPage = false;
        this.showSelectionPage = true;
    }

    closeModal() {
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }

    handleSave() {
        if(this.template.querySelector('lightning-datatable') != undefined) {
            let selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows(); 
            let selectedAssetIds = [];

            for(let i = 0; i < selectedRows.length; i++) {
                selectedAssetIds.push(selectedRows[i].Id);
            }

            console.log('selectedAssetIds on Save: ' + selectedAssetIds);

            if(selectedAssetIds.length > 0) {
                this.isLoading = true;

                // Contract Assets creation

                createContractAssets({
                    assetIds: selectedAssetIds,
                    contractTreatmentId: this.contractTreatmentId
                }).then(() => {
                    const evt = new ShowToastEvent({
                        title: "Contract Assets successfully created",
                        variant: "success"
                    });
                    this.dispatchEvent(evt);

                    this.isLoading = false;

                    refreshApex(this.allAssets);
                    refreshApex(this.assetsRelatedToCT);

                    this.showSelectionPage = false;
                    this.showConfigurationPage = true;
                    this.selectedIds = [];
                    this.searchInput = '';
                }).catch((error) => {
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: "An error occurred while trying to create Contract Assets.",
                        variant: "error"
                    });
                    this.dispatchEvent(evt);

                    console.log('Error: ' + error);

                    this.isLoading = false;
                });
            }
        }
        
        refreshApex(this.assetsRelatedToCT);
        this.isLoading = false;
        this.selectedIds = [];
        this.searchInput = '';
        this.showSelectionPage = false;
        this.showConfigurationPage = true;
    }

    handleBack() {
        if(this.showSelectionPage === true && this.showConfigurationPage === false) {
            this.showConfigurationPage = true;
            this.showSelectionPage = false;
        }
        else if(this.showSelectionPage === false && this.showConfigurationPage === true) {
            this.closeModal();
        }
    }

    handleSearchChange(event) {
        this.selectedIds = [];
        if(this.template.querySelector('lightning-datatable') != undefined) {
            let selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows(); 
            console.log('selectedRows: ' + selectedRows);

            if(selectedRows != null && selectedRows != undefined) {
                for(let i = 0; i < selectedRows.length; i++) {
                    this.selectedIds.push(selectedRows[i].Id);
                }
                console.log('SelectedIds: ' + this.selectedIds);
            }
        }

        this.searchInput = event.target.value;
    }
}