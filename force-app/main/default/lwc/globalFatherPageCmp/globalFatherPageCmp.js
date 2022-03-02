/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getNameFromId from '@salesforce/apex/ContractTreatmentController.getNameFromId';
//import assignPermSetNew from '@salesforce/apex/ContractTreatmentController.assignPermSetNew';
import removePermSet from '@salesforce/apex/ContractTreatmentController.removePermSet';
import getFrameworkStatus from '@salesforce/apex/ContractTreatmentController.getFrameworkStatus';
import getContractFramework from '@salesforce/apex/ContractFrameworkDAO.getCFsFromIds';
import checkForSLAWarning from '@salesforce/apex/ContractTreatmentController.checkForSLAWarning';

import CT_NoSLA_Title from '@salesforce/label/c.CT_NoSLA_Title';
import CT_NoSLA_Message from '@salesforce/label/c.CT_NoSLA_Message';

export default class GlobalFatherPageCmp extends LightningElement {

    @api currentStep = 'step-1';
    @api contractFrameworkId;
    @api contractTreatmentRecordId;
    @api jobDetail;
    @api corporateTreatmentId;
    @api contractTreatmentJobId;
    @api contractTreatmentName;
    @api createdProducts; 
    @api mode;
    @api contractTreatmentList = [];
    @api showAssetButton = false;
    @api salesOrgCode;

    @track page1 = false;
    @track page2;
    @track page2a;
    @track page2b;
    @track page3;
    @track showDefaultBOMConfiguration = false;

    contractFramework;
    frameworkStatus;
    frameworkIsActive = false;
    frameworkIsInactive = false;
    jobIdForBOMConfiguration;
    contractFrameworkQueryFields = ['Contract_Type__c', 'Sales_Org_Code__c'];

    next() {
        if (this.page1 === true) {
            this.page1 = false;
            this.page2 = true;
            this.currentStep = 'step-2';
            getNameFromId({
                contractTreatmentRecordId : this.contractTreatmentRecordId
            }).then((result) => {
                this.contractTreatmentName = result;
                console.log('ContractTreatmentName in globalFather::::::::::::::::::: ' + this.contractTreatmentName);  //PASS DOWN TO LIMITS AND SHOW IN HEADING 
            });
            
        } else if (this.page2 === true) {
            checkForSLAWarning({
                contractTreatmentId: this.contractTreatmentRecordId
            }).then(result => {
                if(result === true) {
                    const evt = new ShowToastEvent({
                        title: CT_NoSLA_Title,
                        message: CT_NoSLA_Message,
                        variant: "warning"
                    });
                    this.dispatchEvent(evt);
                }
            });
            
            this.page2 = false;
            this.page3 = true;
            this.currentStep = 'step-3';
        } else if (this.page3 === true) {
            this.page3 = false;
            this.page4 = true;
            this.currentStep = 'step-4';
        }
    }

    back() {
        if (this.page2 === true) {
            this.page2 = false;
            this.page1 = true;
            this.currentStep = 'step-1';
            console.log('Contract Treatment Id is: ' + this.contractTreatmentRecordId);
        } else if (this.page2a === true) {
            this.page2a = false;
            this.page2 = true;
        } else if (this.page2b === true) {
            this.page2b = false;
            this.page2 = true;
        } else if (this.page3 === true) {
            this.page3 = false;
            this.page2 = true;
            this.currentStep = 'step-2';
        } else if (this.page4 === true) {
            this.page4 = false;
            this.page3 = true;
            this.currentStep = 'step-3';
        }
    }

    handleCreated(event) {
        this.contractTreatmentRecordId = event.detail;
        console.log("Contract Treatment Id is: " + this.contractTreatmentRecordId);
        this.next();
    }

    handleContractCreated(event) {
        this.corporateTreatmentId = event.detail;
        console.log('Corporate Treatment Id passed is: ' + this.corporateTreatmentId);
    }

    /*handleContrName(event) {
        this.contractTreatmentName = event.detail;
        console.log('Contract Treatment Name is: ' + this.contractTreatmentName);
    }*/

    handleEntrySLA(event) {
        this.page2a = true;
        this.page2 = false;
        this.contractTreatmentJobId = event.detail;
        console.log('This is page2a: ' + this.page2a);
        console.log('This is page2: ' + this.page2);
        console.log('Contract Treatment Job Id passed to SLA is: ' + this.contractTreatmentJobId);
    }

    handleEntryProduct(event) {
        this.page2 = false;
        this.page2b = true;
        this.contractTreatmentJobId = event.detail;
        console.log('This is page2b: ' + this.page2b);
        console.log('This is page2: ' + this.page2);
    }

    handleBackToJobs(event) {
        this.createdProducts = event.detail;
        console.log('Numero CreatedProducts nel GLOBALFATHER:::::::::::::::::::::::::::::::::::: ' + this.createdProducts);
        this.page2b = false;
        this.page2 = true;
    }

    handleDefaultBOMConfiguration(event) {
        this.jobIdForBOMConfiguration = event.detail;
        this.page2 = false;
        this.showDefaultBOMConfiguration = true;
    }

    handleExitBOMConfiguration() {
        this.showDefaultBOMConfiguration = false;
        this.page2 = true;
    }

    handleExitLimits(event) {
        this.page3 = false;
        this.page2 = true;
    }

    renderedCallback() {
        //console.log('Contract Treatment Id: ' + this.contractTreatmentRecordId);
        //console.log('Status: ' + this.status);
        console.log('Mode: ' + this.mode);
        console.log('ContractFrameworkId in globalFather: ' + this.contractFrameworkId);

        /*if (this.status === 'active') {
            this.status = true
        } else if (this.status === 'draft') {
            this.status = false
        } else false;*/

        //console.log('Status: ' + this.status);

        // Only if we are in Edit Mode. If we are in create, we use the Draft setup (Delete and no Manage Status)
        if(this.mode == 'edit') {
            this.frameworkStatus = getFrameworkStatus({
                contractFrameworkId: this.contractFrameworkId
            }).then((result) => {
                console.log('Result getFrameworkStatus: ' + result);
                if(result !== 'Draft') {
                    this.frameworkIsActive = true;
                }
                if(result === 'Inactive') {
                    this.frameworkIsInactive = true;
                }
                console.log('Framework is Active? ' + this.frameworkIsActive);
            }).catch((error) => {
                console.log('Error in getFrameworkStatus: ' + error);
            });
        }
    }

    connectedCallback() {
        /* assignPermSet().then(() => {
            console.log('Permission Set assigned')
        }); */

        let recordIdList = [this.contractFrameworkId];

        getContractFramework({
            queryFields: this.contractFrameworkQueryFields,
            relatedIds: recordIdList
        }).then((result) => {
            console.log('Contract Framework, Contract Type: ' + result[0].Contract_Type__c);
            console.log('Contract Framework, SalesOrgCode: ' + result[0].Sales_Org_Code__c);

            this.contractFramework = result[0];
            this.salesOrgCode = result[0].Sales_Org_Code__c;

            if(this.contractFramework.Contract_Type__c === 'ZS3') {
                this.showAssetButton = true;
            }

            this.page1 = true;
        }).catch((error) => {
            console.log('Error: ' + error);
        });
    }

    /*constructor() {
        super();
        assignPermSet().then(() => {
            console.log('Permission Set assigned');
        })
    }*/

    disconnectedCallback() {
        removePermSet().then(() => {
            console.log('Permission Set removed')
        });
    }

}