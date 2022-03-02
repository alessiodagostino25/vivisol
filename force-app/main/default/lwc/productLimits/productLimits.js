/* eslint-disable no-console */
import { LightningElement, track/*, wire*/, api} from 'lwc';
//import getContractProductLimitController from '@salesforce/apex/ContractProductLimitController.getContractProductLimitController';
//import getProducts from '@salesforce/apex/ProductLimitsController.getProducts';
//import createLimits from '@salesforce/apex/ProductLimitsController.createLimits';
import updateLimitsToActive from '@salesforce/apex/ProductLimitsController.updateLimitsToActive';
import { NavigationMixin } from 'lightning/navigation';
import removePermSet from '@salesforce/apex/ContractTreatmentController.removePermSet';
//import { refreshApex } from '@salesforce/apex';

/*const columns = [
    { label: 'Product Name Translate', fieldName: 'Name', type: 'text'},     //TODO: EDIT FOR PRODUCTS
    { label: 'Product Code ', fieldName: 'Product_Code' },
    //{ label: 'ID Prodotto', fieldName: 'productId'},
    { label: 'Family Name', fieldName: 'family_name'},
    { label: 'Manufacturer Part Number', fieldName: 'manufacturer_number'}
];*/

export default class ProductLimits extends NavigationMixin(LightningElement) {

    @api contractTreatmentRecordId;
    @api page3;
    @track viewProductSelection = true;
    @track viewLimitsConfiguration = false;
    @api selectedProducts = [];
    @api limits = [];
    @api contractTreatmentName;

    //IMPLEMENTARE CHIAMATA PER FARE GET DEI LIMITI QUANDO PREMO NEXT DALLA SELECTION E PASSARNE I RISULTATI A productLimitsConfig DA MOSTRARE


    handleBack() {
        if(this.viewProductSelection === true) {
            this.page3 = false;
            const exitLimits = new CustomEvent('exitlimits', {
                detail: this.page3   //EDIT WITH WHAT I WILL PASS TO FATHER
            });
            this.dispatchEvent(exitLimits); 
        }
        else if(this.viewLimitsConfiguration === true) {
            this.viewLimitsConfiguration = false;
            this.viewProductSelection = true;
        } 
    }

    handleNext() {
        if(this.viewProductSelection === true) {
            console.log('IN HANDLE NEXT');
            this.selectedProducts = this.template.querySelector('c-prod-selection-limit-config').passProductIds();
            console.log('SELECTED PRODUCTS SIZE IN productLimit:::: ' + this.selectedProducts.length);
            /*createLimits({
                productIds: this.selectedProducts,
                contractTreatmentId: this.contractTreatmentRecordId
            }).then(result => {
                //console.log('Length RESULT in productLimits: ' + result.length);
                //this.limits = result;
                this.viewProductSelection = false;
                this.viewLimitsConfiguration = true;
            }).catch(error => {
                console.log('ERROR IN RETRIEVING CREATED LIMITS: ' + error);
            });*/
            updateLimitsToActive({
                productIds: this.selectedProducts,
                contractTreatmentId: this.contractTreatmentRecordId
            }).then(() => {
                this.viewProductSelection = false;
                this.viewLimitsConfiguration = true;
            })
            /* this.viewProductSelection = false;
            this.viewLimitsConfiguration = true; */
            //console.log('Length CREATED LIMITS IN productLimit: ' + this.limits.length);
            
        }
        /*else if(this.viewLimitsConfiguration === true) {
            this.page3 = false;
            const exitLimits = new CustomEvent('exitlimits', {
                detail: this.page3   //EDIT WITH WHAT I WILL PASS TO FATHER
            });
            this.dispatchEvent(exitLimits); 
        }*/
    }

    handleFinish() {
        this.page3 = false;
  
        /*let testURL = window.location.href;

        let newURL = new URL(testURL).searchParams;


        this.frameworkidinmain = newURL.get('c__recordId');
        console.log('id ===> ' + this.frameworkidinmain);
            
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.frameworkidinmain,
                        objectApiName: 'Contract_Framework__c',
                        actionName: 'view'
                    },
                });
                */
        
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.contractTreatmentRecordId,
                objectApiName: 'Contract_Treatment__c',
                actionName: 'view'
            },
        });

        console.log('this navigation executed');
        const exitLimits = new CustomEvent('exitlimits', {
            detail: this.page3   //EDIT WITH WHAT I WILL PASS TO FATHER
        });
        this.dispatchEvent(exitLimits); 

        // Removing permission sets
        removePermSet().then(() => {
            console.log('Permission Set removed')
        });
    }

    renderedCallback() {
        console.log('ContractTreatmentName IN PRODUCTLIMITS::::: ' + this.contractTreatmentName);
    }
}