/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-console */
import { LightningElement, track/*, wire*/, api, wire } from 'lwc';
import createCTJP from '@salesforce/apex/CorporateTreatmentJobProductController.createCTJP';
import getCorporateJobFromContractJob from '@salesforce/apex/ContractTreatmentJobController.getCorporateJobFromContractJob';
import getCorporateTreatment from '@salesforce/apex/ContractTreatmentJobController.getCorporateTreatment';
import ProductConfigBack from '@salesforce/label/c.CT_ProductConfig_Back';
import ProductConfigNext from '@salesforce/label/c.CT_ProductConfig_Next';
import ProductConfigBackToJobs from '@salesforce/label/c.CT_ProductConfig_BackToJobs';
/*import getCTJP from '@salesforce/apex/CorporateTreatmentJobProductController.getCTJP';
import getFamilyIds from '@salesforce/apex/CorporateTreatmentJobProductController.getFamilyIds';
import getProductIds from '@salesforce/apex/CorporateTreatmentJobProductController.getProductIds';*/
//import getSelectedProducts from '@salesforce/apex/CorporateTreatmentJobProductController.getSelectedProducts';

export default class ProductConfiguration extends LightningElement {

    @api page2b;
    @track viewFamilySelection = true;
    @api viewProductSelection = false;
    @api viewProductConfigurationStep = false;
    @api currentStep = 'step-1';
    fatherButtonsDisabled = true; //value coming from father component: if I enter in child component, Father's ones are disables and I show child's ones. CHANGE TO @api!!!
    @api selectedFamilies = [];
    @api selectedProducts = [];
    @api createdProducts = [];
    /*@api insertedFamilies;
    @api insertedProducts;*/

    //@api createdProductsIds;
    @api familiesAndProducts = [];
    error;
    tempFamAndProd = [];

    @api contractFrameworkRecordId;  //ok
    @api corporateTreatmentId; //NON ARRIVA
    @api corporateTreatmentJob; //NON ARRIVA
    @api contractTreatmentJobId;  //ok
    @api contractTreatmentJobName;
    @api frameworkIsActive;
    @api frameworkIsInactive;
    @track isLoading;

    label = {
        ProductConfigBack,
        ProductConfigNext,
        ProductConfigBackToJobs
    };

    @wire(getCorporateJobFromContractJob, { contractTreatmentJobId: '$contractTreatmentJobId' })
    getCorporateTreatmentJob({ error, data }) {
        if (data) {
            this.corporateTreatmentJob = data;
            console.log('CorporateTreatmentJob in productConfiguration::::: ' + this.corporateTreatmentJob);
        }
    }

    @wire(getCorporateTreatment, { contractTreatmentJobId: '$contractTreatmentJobId' })
    getCorporateTreatmentId({ error, data }) {
        if (data) {
            this.corporateTreatmentId = data;
            console.log('CorporateTreatmentId in productConfiguration:::::: ' + this.corporateTreatmentId);
        }
    }

    renderedCallback() {
        console.log('SELECTED FAMILIES NEL PADRE: ' + this.selectedFamilies);
        console.log('SELECTED PRODUCTS NEL PADRE: ' + this.selectedProducts);
        console.log('ContractFramework nel padre: ' + this.contractFrameworkRecordId);
        console.log('ContractTreatmentJobId nel padre: ' + this.contractTreatmentJobId);
    }

    handleNextClick() {
        if (this.viewFamilySelection === true) {
            this.isLoading = true;

            //ADD LOGIC FOR OTHER PAGES (IF I AM ON THIS PAGE THEN GO TO THIS ONE)
            if (this.selectedFamilies.length === 0) {
                console.log('IF SELECTED FAMILIES è NULL');
                let returnValue = this.template.querySelector('c-family-selection').passProductIds();
                console.log('RETURN VALUE: ' + returnValue);
                if (returnValue.length !== 0) {
                    console.log('QUERYSELECTOR NON NULL');
                    this.selectedFamilies = returnValue;
                }
            }
            else {
                console.log('ELSE SELECTED FAMILIES NON è NULL');
                let returnValue = this.template.querySelector('c-family-selection').passProductIds();
                console.log('RETURN VALUE: ' + returnValue);
                if (returnValue.length !== 0) {
                    console.log('QUERYSELECTOR NON NULL');
                    for (let i = 0; i < returnValue.length; i++) {
                        this.selectedFamilies.push(returnValue[i]);
                    }
                    //this.selectedFamilies.push(returnValue);
                }
            }
            console.log('Famiglie selezionate arrivate al padre: ' + this.selectedFamilies);
            this.viewFamilySelection = false;
            this.viewProductSelection = true;
            this.currentStep = 'step-2';
            this.isLoading = false;

        }
        else if (this.viewProductSelection === true) {
            this.isLoading = true;

            this.selectedProducts = this.template.querySelector('c-product-selection').passProductIds();
            console.log('PRODOTTI SELEZIONATI ARRIVATI AL PADRE: ' + this.selectedProducts);
            for (let i = 0; i < this.selectedFamilies.length; i++) {
                this.familiesAndProducts.push(this.selectedFamilies[i]);
            }
            for (let i = 0; i < this.selectedProducts.length; i++) {
                this.familiesAndProducts.push(this.selectedProducts[i]);
            }
            console.log('FAMILIES AND PRODUCTS NEL PADRE: ' + this.familiesAndProducts);
            createCTJP({
                productsToCreate: this.familiesAndProducts,
                contractTreatmentJob: this.contractTreatmentJobId
            }).then(() => {
                console.log('SUCCESS');
                this.viewProductSelection = false;
                this.viewProductConfigurationStep = true;
                this.currentStep = 'step-3';
                this.selectedFamilies = [];
                this.selectedProducts = [];
                this.familiesAndProducts = [];
                this.isLoading = false;
                console.log('FamiliesAndProducts SVUOTATO: ' + this.familiesAndProducts);
            }).catch(error => {
                this.error = error;
                console.log('ERROR NEL RESULT DELLA CREATE: ' + this.error.data);

                this.isLoading = false;
            });
        }
        else if (this.viewProductConfigurationStep === true) {
            let methodReturn = this.template.querySelector('c-product-configuration-step').passCreatedProducts();
            for (let i = 0; i < methodReturn.length; i++) {
                this.createdProducts.push(methodReturn[i]);
            }
            console.log('CREATED PRODUCTS IN productCOnfiguration::: ' + this.createdProducts);
            console.log('NUMERO CREATED PRODUCTS IN productConfiguration:::::::::::::::::::::::::::::::: ' + this.createdProducts.length);
            this.viewProductConfigurationStep = false;
            this.page2b = false;
            const finishedConfig = new CustomEvent('finishedconfig', {
                detail: this.createdProducts
            });
            this.dispatchEvent(finishedConfig);
        }
    }

    handleBackClick() {
        if (this.viewProductSelection === true) {
            //this.selectedFamilies = []; //THIS IS NEW, COULD CAUSE PROBS
            this.viewProductSelection = false;
            this.viewFamilySelection = true;
            this.currentStep = 'step-1';
        }
        else if (this.viewFamilySelection === true) {
            this.page2b = false;
            const exitConfig = new CustomEvent('exitconfig', {
                detail: this.createdProducts
            });
            this.dispatchEvent(exitConfig);
        }
        else if (this.viewProductConfigurationStep === true) {
            this.viewProductConfigurationStep = false;
            this.viewProductSelection = true;
            this.currentStep = 'step-2';
        }
    }
}