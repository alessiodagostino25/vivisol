import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';

// Apex actions
import getPricebookEntries from '@salesforce/apex/WOLICreationController.getPricebookEntries';
import getCTJId from '@salesforce/apex/WOLICreationController.getContractTreatmentJobId';
import createWOLIs from '@salesforce/apex/WOLICreationController.createWOLIs';
import assetSearch from '@salesforce/apex/LookupController.assetsFromPESearch';
import plantSearch from '@salesforce/apex/LookupController.searchPlants';
import storageLocationSearch from '@salesforce/apex/LookupController.searchStorageLocations';
import checkForAssetDisabling from '@salesforce/apex/WOLICreationController.checkForAssetDisabling';
import checkForLocationFieldsShowing from '@salesforce/apex/WOLICreationController.checkForLocationFieldsShowing';
import getRelatedCTJP from '@salesforce/apex/WOLICreationController.getRelatedCTJP';
import getWorkOrderDocumentType from '@salesforce/apex/WOLICreationController.getWorkOrderDocumentType';
import getSelectedProductType from '@salesforce/apex/WOLICreationController.getSelectedProductType';

// Labels
import NoElements from '@salesforce/label/c.Generic_NoElements';
import ProductConfigStepTableProductName from '@salesforce/label/c.CT_ProductSelection_TableProductName';
import ProductConfigStepTableProductCode from '@salesforce/label/c.CT_ProductSelection_TableProductCode';
import ProductConfigStepTableFamilyName from '@salesforce/label/c.CT_FamilySelection_TableName';
import ProductConfigStepTableManufacturer from '@salesforce/label/c.CT_ProductSelection_TableManufacturer';
import Back from '@salesforce/label/c.AT_BackButton';
import Next from '@salesforce/label/c.AT_NextButton';
import Selection from '@salesforce/label/c.WOLI_ProductSelection';
import NewWOLI from '@salesforce/label/c.WOLI_NewWOLI';
import ProvideInformation from '@salesforce/label/c.General_ProvideInformation';
import Save from '@salesforce/label/c.AT_ProductSelection_SaveButton';

// Eventually independent columns for mobile and desktop view

const desktopColumns = [
    { label: ProductConfigStepTableProductName, fieldName: 'Product_Name_Translate', type: 'text', wrapText: true},
    { label: ProductConfigStepTableProductCode, fieldName: 'Product_Code' },
    { label: ProductConfigStepTableFamilyName, fieldName: 'Product_Family', wrapText: true},
    { label: ProductConfigStepTableManufacturer, fieldName: 'Manufacturer_part_number'}
];

const mobileColumns = [
    { label: ProductConfigStepTableProductName, fieldName: 'Product_Name_Translate', type: 'text', wrapText: true},
    { label: ProductConfigStepTableProductCode, fieldName: 'Product_Code' },
    { label: ProductConfigStepTableFamilyName, fieldName: 'Product_Family', wrapText: true},
    { label: ProductConfigStepTableManufacturer, fieldName: 'Manufacturer_part_number'}
];

export default class WoliCreationModal extends LightningElement {
    desktopColumns = desktopColumns;
    mobileColumns = mobileColumns;
    labels = {
        NoElements,
        Back,
        Next,
        Selection,
        NewWOLI,
        ProvideInformation,
        Save
    }
    contractTreatmentJobId;
    errors = [];
    isMultiEntry = false;
    workOrderDocumentType;
    productType;

    @api recordId;

    @track showTableModal = true;
    @track searchValue = '';
    @track isTableEmpty = false;
    @track pricebookEntries;
    @track somethingSelected = false;
    @track hideNext = true;
    @track selectedPricebookEntryId;
    @track selectedMovementType;
    @track selectedBillable;
    @track selectedAssetId;
    @track selectedPlantId;
    @track selectedStorageLocationId;
    @track showQuantityModal = false;
    @track hideSave = false;
    @track selectedQuantity = 1;
    @track creationLoading = false;
    @track disableAssetSelection = false;
    @track showLocationFields = false;
    @track relatedCTJP;
    @track CTJPBillable;
    @track CTJPPlant = null;
    @track CTJPStorageLocation = null;
    @track isLoading = false;

    get isMobile() {
        if(FORM_FACTOR === 'Small') {
            return true;
        }
        else {
            return false;
        }
    }

    get isMovementTypeDisabled() {
        if(this.workOrderDocumentType === 'ZRET' || this.workOrderDocumentType === 'ZRNC' || this.productType === 'ZSER') {
            return true;
        }

        return false;
    }

    get movementTypeValue() {
        if(this.productType === 'ZSER') {
            return 'Delivery (+)';
        }

        if(this.workOrderDocumentType === 'ZRET' || this.workOrderDocumentType === 'ZRNC') {
            return 'Removal (-)';
        }

        return 'Delivery (+)';
    }
    
    connectedCallback() {
        console.log('recordId: ' + this.recordId);
        console.log('isMobile: ' + this.isMobile);
        console.log('FORM FACTOR: ' + FORM_FACTOR);

        getCTJId({
            workOrderId: this.recordId
        }).then((value) => {
            this.contractTreatmentJobId = value;
            console.log('CTJ Id: ' + this.contractTreatmentJobId);

            this.getData();
        });

        getWorkOrderDocumentType({
            workOrderId: this.recordId
        }).then(result => {
            this.workOrderDocumentType = result;
        }).catch(error => {
            console.log('ERROR');
            console.log(JSON.stringify(error));
        });
    }

    renderedCallback() {
        if(this.isTableEmpty === true || this.template.querySelector('lightning-datatable') === null) {
            this.hideNext = true;
            this.somethingSelected = false;
        }
        else {
            let selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows(); 
            console.log('selectedRows size: ' + selectedRows.length);

            if(selectedRows.length > 0 && this.hideNext === true) {
                this.hideNext = false;
                this.somethingSelected = true;
            }
            else if(selectedRows.length === 0 && this.hideNext === false) {
                this.hideNext = true;
                this.somethingSelected = false;
            }
        }
    }

    getData() {
        getPricebookEntries({
            contractTreatmentJobId: this.contractTreatmentJobId,
            searchValue: this.searchValue
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
        this.searchValue = event.target.value;
        this.getData();
    }

    handleRowSelection(event) {
        let selectedRows = event.detail.selectedRows;
        if(selectedRows.length > 0) {
            this.selectedPricebookEntryId = selectedRows[0].Id;
            console.log('selectedPricebookEntryId: ' + JSON.stringify(this.selectedPricebookEntryId));

            if(this.somethingSelected === false && this.selectedPricebookEntryId != null && this.selectedPricebookEntryId != undefined) {
                this.somethingSelected = true;
            }
            if(this.hideNext === true && this.selectedPricebookEntryId != null && this.selectedPricebookEntryId != undefined) {
                this.hideNext = false;
            }
        }
    }

    closeModal() {
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }

    handleBack() {
        this.closeModal();
    }

    handleNext() {
        this.isLoading = true;
        // Filling the Billable, Plant and StorageLocation fields from the related CTJP

        //this.getFieldsFromCTJP();

        getRelatedCTJP({
            pricebookEntryId: this.selectedPricebookEntryId,
            workOrderId: this.recordId
        }).then(result => {
            console.log('Related CTJP: ' + JSON.stringify(result));

            this.relatedCTJP = result;
            this.CTJPBillable = result.Billable__c;
            this.CTJPPlant = result.Plant__c;
            this.CTJPStorageLocation = result.Storage_Location__c;

            // Getting selected Product's type

            getSelectedProductType({
                pricebookEntryId: this.selectedPricebookEntryId
            }).then(result => {
                this.productType = result;

                // Checking for Location fields showing

                checkForLocationFieldsShowing({
                    pricebookEntryId: this.selectedPricebookEntryId
                }).then(result => {
                    this.showLocationFields = result;
                    console.log('showLocationFields: ' + this.showLocationFields);

                    // Checking for Asset field showing

                    checkForAssetDisabling({
                        pricebookEntryId: this.selectedPricebookEntryId
                    }).then(result => {
                        this.disableAssetSelection = result;
                        console.log('disableAssetSelection: ' + this.disableAssetSelection);

                        this.showTableModal = false;
                        this.showQuantityModal = true;
                        this.isLoading = false;
                    }).catch(error => {
                        console.log('ERROR retrieving Asset disabled value: ');
                        console.log(error);
                        this.isLoading = false;
                    });
                }).catch(error => {
                    console.log('ERROR retrieving Location showing value: ');
                    console.log(error);
                    this.isLoading = false;
                });
            }).catch(error => {
                console.log('ERROR');
                console.log(JSON.stringify(error));
                this.isLoading = false;
            });
        }).catch(error => {
            console.log('ERROR');
            console.log(error);
            this.isLoading = false;
        });
    }

    handleBackToTable() {
        this.showQuantityModal = false;
        this.somethingSelected = false;
        this.hideNext = true;
        this.showTableModal = true;
    }

    /* handleQuantityChange(event) {
        console.log(event.target);
        let insertedQuantity = event.target.value;

        if(insertedQuantity === null || insertedQuantity === undefined) {
            event.target.value = 0;
            this.selectedQuantity = 0;
            this.hideSave = true;
            console.log('selected quantity: ' + this.selectedQuantity);
        }
        else {
            this.selectedQuantity = event.target.value;
            console.log('selected quantity: ' + this.selectedQuantity);
        }
    } */

    handleSave() { 
        /* if(this.disableAssetSelection === false || this.showLocationFields === true) {               
            this.checkForErrors();
        } */

        if(this.errors.length === 0) {
            this.template.querySelector('lightning-button').click();

            console.log('Selected quantity on Save: ' + this.selectedQuantity);
            console.log('Selected movementType on Save: ' + this.selectedMovementType);
            console.log('Selected Billable on Save: ' + this.selectedBillable);
            console.log('Selected Asset on Save: ' + this.selectedAssetId);
            console.log('Selected Plant on Save: ' + this.selectedPlantId);
            console.log('Selected Storage Location on Save: ' + this.selectedStorageLocationId);
            console.log('Rest: ' + this.selectedQuantity % 1);

            if(
                this.selectedQuantity === null || 
                this.selectedQuantity === undefined || 
                this.selectedQuantity === '' || 
                this.selectedQuantity < 0 ||
                this.selectedQuantity == 0 ||
                (this.selectedQuantity % 1 > 0) ||
                (this.selectedQuantity % 1 != 0)
                ) {
                    const evt = new ShowToastEvent({
                        title: "Invalid quantity",
                        message: "Please select a valid quantity",
                        variant: "warning"
                    });
                    this.dispatchEvent(evt);
                }
            else if(this.selectedQuantity > 100) {
                const evt = new ShowToastEvent({
                    title: "Invalid quantity",
                    message: "The quantity selected is too high",
                    variant: "warning"
                });
                this.dispatchEvent(evt);
            }

            if(this.selectedAssetId != undefined && this.selectedAssetId != null && this.selectedQuantity > 1) {
                const evt = new ShowToastEvent({
                    title: "Invalid quantity",
                    message: "Please select 1 as quantity if an Asset is selected.",
                    variant: "warning"
                });
                this.dispatchEvent(evt);
            }

            else {
                console.log('CREAZIONE PER:');
                console.log('Quantità: ' + this.selectedQuantity);
                console.log('MovementType: ' + this.selectedMovementType);
                console.log('Asset: ' + this.selectedAssetId);
                console.log('Plant: ' + this.selectedPlantId);
                console.log('StorageLocation: ' + this.selectedStorageLocationId);
                console.log('PricebookEntryId: ' + this.selectedPricebookEntryId);

                this.creationLoading = true;

                createWOLIs({
                    pricebookEntryId: this.selectedPricebookEntryId,
                    workOrderId: this.recordId,
                    quantity: this.selectedQuantity,
                    assetId: this.selectedAssetId,
                    plantId: this.selectedPlantId,
                    storageLocationId: this.selectedStorageLocationId,
                    movementType: this.selectedMovementType,
                    billable: this.selectedBillable
                }).then(() => {
                    this.creationLoading = false;
                    this.closeModal();

                    const evt = new ShowToastEvent({
                        title: "Work Order Line Items successfully created",
                        //message: "",
                        variant: "success"
                    });
                    this.dispatchEvent(evt);
                })
                .catch(error => {
                    console.log('ERROR:');
                    console.log(JSON.stringify(error));

                    this.creationLoading = false;

                    if(error.body != null) {
                        let pageErrors = error.body.pageErrors;

                        if(pageErrors != null && pageErrors.length > 0) {
                            const evt = new ShowToastEvent({
                                title: "Error",
                                message: pageErrors[0].message,
                                variant: "error"
                            });
                            this.dispatchEvent(evt);
                        }
                        else {
                            this.showGenericError();
                        }
                    }
                    else {
                        this.showGenericError();
                    }
                })
            }
        }
    }

    handleSubmit(event) {
        console.log('Submitting form...');

        event.preventDefault();

        if(event.detail.fields.Quantity != undefined) {
            this.selectedQuantity = event.detail.fields.Quantity;
        }
        if(event.detail.fields.Movement_Type__c != undefined) {
            this.selectedMovementType = event.detail.fields.Movement_Type__c;
        }
        if(event.detail.fields.Billable__c != undefined) {
            this.selectedBillable = event.detail.fields.Billable__c;
        }
        if(event.detail.fields.Plant__c != undefined) {
            this.selectedPlantId = event.detail.fields.Plant__c;
        }
        if(event.detail.fields.StorageLocation__c != undefined) {
            this.selectedStorageLocationId = event.detail.fields.StorageLocation__c;
        }
    }

    checkForErrors() {
        this.errors = [];
        const selection = this.template.querySelector('c-lookup').getSelection();
        console.log('Selection length: ' + selection);

        // Enforcing required field
        /* if (selection.length === 0) {
            this.errors.push({ message: 'Please make a selection.' });
        } */
    }

    // Asset Lookup methods

    handleAssetSearch(event) {
        const target = event.target;
        assetSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
            });
    }

    handleAssetSelectionChange(event) {
        console.log('In selection change');
        const selection = event.target.getSelection();
        console.log('selection: ' + selection);
        if (selection != undefined && selection.length != 0) {
            console.log('Asset selezionato: ' + selection[0].title);
            this.selectedAssetId = selection[0].id;
            // TODO: do something with the lookup selection
        }
        else {
            this.selectedAssetId = undefined;
        }
    }

    // Plant Lookup methods

    /* handlePlantSearch(event) {
        const target = event.target;
        plantSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
            });
    } */

    /* handlePlantSelectionChange(event) {
        const selection = event.target.getSelection();
        if (selection != undefined && selection.length != 0) {
            console.log('Plant selezionata: ' + selection[0].title);
            this.selectedPlantId = selection[0].id;
            // TODO: do something with the lookup selection
        }
        else {
            this.selectedPlantId = undefined;
        }
    } */

    // Storage Location Lookup methods

    /* handleStorageLocationSearch(event) {
        const target = event.target;
        storageLocationSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
            });
    } */

    /* handleStorageLocationSelectionChange(event) {
        const selection = event.target.getSelection();
        if (selection != undefined && selection.length != 0) {
            console.log('Storage Location selezionata: ' + selection[0].title);
            this.selectedStorageLocationId = selection[0].id;
            // TODO: do something with the lookup selection
        }
        else {
            this.selectedStorageLocationId = undefined;
        }
    } */

    showGenericError() {
        const evt = new ShowToastEvent({
            title: "Error",
            message: "An error occurred while creating Work Order Line Items",
            variant: "error"
        });
        this.dispatchEvent(evt);
    }

    getFieldsFromCTJP() {
        getRelatedCTJP({
            pricebookEntryId: this.selectedPricebookEntryId,
            workOrderId: this.recordId
        }).then(result => {
            console.log('Related CTJP: ' + JSON.stringify(result));

            this.relatedCTJP = result;
            this.CTJPBillable = result.Billable__c;
            this.CTJPPlant = result.Plant__c;
            this.CTJPStorageLocation = result.Storage_Location__c;
        }).catch(error => {
            console.log('ERROR');
            console.log(error);
        });
    }
}