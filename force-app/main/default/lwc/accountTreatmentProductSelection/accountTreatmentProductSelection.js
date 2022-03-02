/* eslint-disable no-console */
import { LightningElement, track, wire, api } from "lwc";
import getProducts from "@salesforce/apex/TreatmentProductSelectionController.getProducts";
import getAsset from "@salesforce/apex/TreatmentProductSelectionController.getAsset";
import createAccountProduct from "@salesforce/apex/TreatmentProductSelectionController.createAccountProduct";
import createAccountAsset from "@salesforce/apex/TreatmentProductSelectionController.createAccountAsset";
import getSelectedProducts from '@salesforce/apex/ProductListController.getSelectedProducts';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from "@salesforce/apex";

import selectAssetsButton from '@salesforce/label/c.AT_JobTile_SelectAssetsButton';
import selectProductsButton from '@salesforce/label/c.AT_JobTile_SelectProductsButton';
import nextButton from '@salesforce/label/c.AT_ProductSelection_NextButton';
import saveButton from '@salesforce/label/c.AT_ProductSelection_SaveButton';
import progressBarProductSelection from '@salesforce/label/c.AT_ProductSelection_ProgressBarProductSelection';
import progressBarProductConfiguration from '@salesforce/label/c.AT_ProductSelection_ProgressBarProductConfiguration';
import tableProductName from '@salesforce/label/c.AT_ProductSelectionTable_ProductName';
import tableProductCode from '@salesforce/label/c.AT_ProductSelectionTable_ProductCode';
import tableProductManufacturer from '@salesforce/label/c.AT_ProductSelectionTable_ProductManufacturer';
import tableProductFamily from '@salesforce/label/c.AT_ProductSelectionTable_ProductFamily';
import NoElements from '@salesforce/label/c.Generic_NoElements';
import ManufacturerId from '@salesforce/label/c.Generic_ProductManufacturerId';
import ProductSerialNumber from '@salesforce/label/c.Generic_ProductSerialNumber'

export default class AccountTreatmentProductSelection extends LightningElement {

    label = {
        selectProductsButton,
        nextButton,
        saveButton,
        progressBarProductConfiguration,
        progressBarProductSelection,
        tableProductName,
        tableProductCode,
        tableProductManufacturer,
        tableProductFamily,
        selectAssetsButton,
        NoElements //TODO: use the labels
    };

    @track tableIsEmpty = false;
    @track data;
    @track error;
    @track data1;
    @track isdisablednext = false;
    @track isdisabledback = true;
    @track component1 = true;
    @track component2 = false;
    @api searchKey = "";
    @track nextisdisplayed = true;
    @track saveisdisplayed = false;
    @api selectedrecordtype;
    @track predata = [];
    @track predata1 = [];
    @api preselectedrowslist = [];
    @api preselectedrowslistasset = [];
    @api selectedjobid;
    selectedRows = [];
    selectedRows2 = [];
    @track selectedproducts;
    @track selectedasset;
    @api preselectedrowslist1 = [];
    @api preselectedrowslist2 = [];
    @track preselectedproductsineditmode = [];
    @track result;
    @track result1;
    @api jobid;
    @api jobname;
    @track viewasset;
    @track viewproduct;
    @track viewassetbutton;
    @api accounttreatmentstatus;
    tempproducts = [];
    @api tempasset = [];
    @api my_ids = [];
    @track productnametranslate;
    @track productcode;
    @track productmanufacturer;
    @track productfamilytranslate;
    @track columns = [
        {
            label: this.label.tableProductName,
            fieldName: "productNameTranslate",
            type: "text"
        },
        {
            label: this.label.tableProductCode,
            fieldName: "productCode",
            type: "text"
        },
        {
            label: this.label.tableProductManufacturer,
            fieldName: "manufacturerPartNumber",
            type: "text"
        },
        {
            label: this.label.tableProductFamily,
            fieldName: "productFamily",
            type: "text"
        }
    ];
    @track columns1 = [
        {
            label: ProductSerialNumber,
            fieldName: "serialNumber",
            type: "text"
        },
        {
            label: ManufacturerId,
            fieldName: "manufacturerId",
            type: "text"
        },
        {
            label: this.label.tableProductName,
            fieldName: "productNameTranslate",
            type: "text"
        },
        {
            label: this.label.tableProductCode,
            fieldName: "productCode",
            type: "text"
        },
        {
            label: this.label.tableProductManufacturer,
            fieldName: "manufacturerPartNumber",
            type: "text"
        },
        {
            label: this.label.tableProductFamily,
            fieldName: "productFamilyNameTranslate",
            type: "text"
        }
    ];


    /*  @wire(getSelectedProducts, { selectedjobid2: '$selectedjobid2' })
     productsinedit({ data }) {
   
       if (data) {
         for (let i = 0; i < data.length; i++) {
           this.preselectedproductsineditmode.push(data[i].Product__c);
         }
       }
     } */


    getjobselected(event1) {
        this.selectedRows = event1.detail.selectedRows;
        console.log("selected row product" + JSON.stringify(this.selectedRows));
        for (let i = 0; i < this.selectedRows.length; i++) {
            this.preselectedrowslist.push(this.selectedRows[i].Id);
            console.log("json object" + JSON.stringify(this.selectedRows));
        }

    }

    renderedCallback() {
        let searchBarInput = this.template.querySelector('lightning-input');

        if(searchBarInput) {
            searchBarInput.focus();
        }

        if (this.selectedrecordtype === "AccountTreatment_Therapy" || this.selectedrecordtype === "AccountTreatment_Sales") {
            this.viewassetbutton = false;
        } else if (this.selectedrecordtype === "AccountTreatment_RentMaintenance" || this.selectedrecordtype === "AccountTreatment_Maintenance") {
            this.viewassetbutton = true;
        }
        this.refresh();
        console.log('rendered call back')
        return refreshApex(this.result);
    }

    refresh() {
        return refreshApex(this.result1);
    }

    handleKeyChange(event) {
        this.preselectedrowslist = [];
        console.log("search pre select" + this.preselectedrowslist);

        console.log("selected rows length" + this.selectedRows.length);
        for (let i = 0; i < this.selectedRows.length; i++) {
            this.preselectedrowslist.push(this.selectedRows[i].id);
            console.log("json object" + JSON.stringify(this.selectedRows));
        }

        console.log("preselected list in search " + this.preselectedrowslist);
        this.searchKey = event.target.value;
        console.log("searc key value" + this.searchKey);

        refreshApex(this.products);
    }

    /* handleKeyChangeasset(event) {
        this.preselectedrowslistasset = [];
        console.log("search pre select" + this.preselectedrowslist);

        console.log("selected rows length" + this.selectedRows.length);
        for (let i = 0; i < this.selectedRows.length; i++) {
            this.preselectedrowslistasset.push(this.selectedRows[i].Id);
            console.log("json object" + JSON.stringify(this.selectedRows));
        }

        console.log("preselected list in search " + this.preselectedrowslist);
        this.searchKey = event.target.value;
        console.log("searc key value" + this.searchKey);

        refreshApex(this.asset);
    } */

    @wire(getProducts, {
        searchKey: "$searchKey",
        selectedjobid: "$selectedjobid",
        selectedrecordtype: "$selectedrecordtype",
        preselectedrowslist: "$preselectedrowslist"
    })
    products(result) {
        this.result = result;
        if (result.data) {
            this.data = this.result.data;
            console.log('data in wire producst' + JSON.stringify(this.data));

            this.predata = result.data;
            //this.predata = [];
            /* for (let i = 0; i < this.data.length; i++) {
                this.predata = [
                    ...this.predata,
                    {
                        Id: this.data[i].Id,
                        Product_Family__c: this.data[i].Product_Family__r.Product_Name_Translate__c,
                        Product_Name_Translate__c: this.data[i].Product_Name_Translate__c,
                        Product_Code__c: this.data[i].Product_Code__c,
                        Manufacturer_part_number__c: this.data[i].Manufacturer_part_number__c
                    }
                ];

            } */
            //this.preselectedrowslist = this.preselectedproductsineditmode;

            console.log('data is rendered in products')
            // This will save the Multi Level Selection While Filtering in Search Box.

            console.log(
                "this is the final preselected list " + this.preselectedrowslist1
            )   
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
        }
    }
    get finaldata() {
        console.log('data is sent to datatable')
        if (this.predata.length === 0) {
            this.tableIsEmpty = true;
        }
        else {
            this.tableIsEmpty = false;
        }
        return this.predata;
    }

    /* @wire(getAsset, { searchKey: "$searchKey", preselectedrowslistasset: "$preselectedrowslistasset", selectedjobid: "$selectedjobid" })
    asset(result1) {
        this.result1 = result1;
        console.log('data of asset ' + JSON.stringify(result1));

        if (result1.data) {
            console.log('data of asset ' + JSON.stringify(result1));
            this.data1 = this.result1.data;
            this.predata1 = result1.data;
            this.predata1 = [];
            for (let i = 0; i < this.data1.length; i++) {
                console.log('predata1 entered into for loop')
                if (this.data1[i].Asset__r.Product2.Product_Name_Translate__c != null) {
                    this.productnametranslate = this.data1[i].Asset__r.Product2.Product_Name_Translate__c;
                    console.log(this.data1[i].Asset__r.Product2.Product_Name_Translate__c);
                }
                else {
                    this.productnametranslate = '';
                }
                if (this.data1[i].Asset__r.Product2.Product_Code__c != null) {
                    this.productcode = this.data1[i].Asset__r.Product2.Product_Code__c;
                }
                else {
                    this.productcode = '';
                }
                if (this.data1[i].Asset__r.Product2.Product_Family__r != null) {
                    if (this.data1[i].Asset__r.Product2.Product_Family__r.Product_Name_Translate__c != null) {
                        this.productfamilytranslate = this.data1[i].Asset__r.Product2.Product_Family__r.Product_Name_Translate__c;
                    }
                    else {
                        this.productfamilytranslate = '';
                    }
                }
                if (this.data1[i].Asset__r.Product2.Manufacturer_part_number__c != null) {
                    this.productmanufacturer = this.data1[i].Asset__r.Product2.Manufacturer_part_number__c;
                }
                else {
                    this.productmanufacturer = '';
                }
                this.predata1 = [
                    ...this.predata1,
                    {
                        Id: this.data1[i].Asset__c,
                        SerialNumber: this.data1[i].Asset__r.SerialNumber,
                        //Label__c: this.data1[i].Asset__r.Label__c,
                        Manufacturer_ID__c: this.data1[i].Asset__r.Manufacturer_ID__c,
                        Product2Id: this.data1[i].Asset__r.Product2Id,
                        Product_Name_Translate__c: this.productnametranslate,
                        Product_Code__c: this.productcode,
                        Product_Family__rProduct_Name_Translate__c: this.productfamilytranslate,
                        Manufacturer_part_number__c: this.productmanufacturer

                    }
                ];

            }
            console.log('predata1 entered into after for loop' + this.predata1)
            this.error = undefined;
        } else if (result1.error) {
            this.error = result1.error;
        }
    } */

    get finaldataasset() {
        console.log('predata1 ' + this.predata1)
        console.log('data is sent to datatable asset')
        return this.predata1;
    }


    @track openmodel = false;
    openmodalproduct() {
        this.openmodel = true;
        refreshApex(this.result);
        refreshApex(this.result1);
        this.selectedRows = [];

        console.log('recordtype ' + this.selectedrecordtype);
        console.log("job id " + this.jobid);
        console.log("serachkey" + this.searchKey);

        console.log("product page job" + this.jobid);
        const str = this.jobid;
        this.selectedjobid = str.slice(0, -3);


        this.viewproduct = true;
        this.viewasset = false;

    }
    /* openmodalasset() {
        this.openmodel = true;
        refreshApex(this.result);
        refreshApex(this.result1);
        this.selectedRows = [];

        console.log('recordtype' + this.selectedrecordtype);
        console.log("job id " + this.jobid);
        console.log("serachkey" + this.searchKey);

        console.log("product page job" + this.jobid);
        const str = this.jobid;
        this.selectedjobid = str.slice(0, -3);


        this.viewproduct = false;
        this.viewasset = true;

    } */
    closeModal() {
        this.openmodel = false;
    }

    goBackStep() {
        this.component1 = true;
        this.component2 = false;
        this.selectedRows = [];
    }

    saveMethod() {
        // eslint-disable-next-line no-alert

        const viewproductchange = new CustomEvent("viewproductchange", {
            detail: this.openmodal
        });
        this.dispatchEvent(viewproductchange);

        this.nextisdisplayed = true;
        this.saveisdisplayed = false;
        this.component1 = true;
        this.component2 = false;

        this.closeModal();
    }


    nextMethod() {
        console.log('preselectedlist ::::::::::::' + this.preselectedrowslist)
        // eslint-disable-next-line no-console
        if (this.selectedRows.length > 0) {

            if (this.component1 === true) {
                if (this.viewproduct === true) {
                    for (let i = 0; i < this.selectedRows.length; i++) {
                        this.tempproducts.push(this.selectedRows[i].id);
                    }
                    this.selectedproducts = this.tempproducts;

                    console.log("--- Selected products: " + this.selectedproducts);

                    createAccountProduct({
                        atjid: this.selectedjobid,
                        selectedproducts: this.selectedproducts
                    })
                        .then({})
                        .catch(error => {
                            // eslint-disable-next-line no-console
                            console.log(error);
                        });
                } else if (this.viewasset === true) {
                    for (let i = 0; i < this.selectedRows.length; i++) {
                        this.tempasset.push(this.selectedRows[i].Id);
                    }
                    this.selectedasset = this.tempasset;
                    console.log("selectedasset Js::" + this.selectedasset);
                    createAccountAsset({
                        atjid: this.selectedjobid,
                        selectedasset: this.selectedasset
                    })
                        .then({})
                        .catch(error => {
                            // eslint-disable-next-line no-console
                            console.log(error);
                        });
                }
                console.log("nextbutton is clicked");
                this.component1 = false;
                this.component2 = true;
                this.nextisdisplayed = false;
                this.saveisdisplayed = true;
                this.tempproducts = [];
                this.tempasset = [];
            }
        }
        else {
            const evt = new ShowToastEvent({
                message: 'please select rows',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }

    }

    backMethod() {
        if (this.component2 === true) {
            this.component1 = true;
            this.component2 = false;

            this.isdisablednext = false;
            this.isdisabledback = true;

        }
        this.refresh();
        return refreshApex(this.result);
    }
}