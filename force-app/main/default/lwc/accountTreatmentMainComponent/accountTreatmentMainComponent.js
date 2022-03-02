/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from "@salesforce/apex";
import getrecordnameandtreatment from "@salesforce/apex/ATMainComponentController.getrecordnameandtreatment";
import checkForAddressSelectionPage from "@salesforce/apex/ATMainComponentController.checkForAddressSelectionPage";
import removePermSet from '@salesforce/apex/AccountTreatmentController.removePermSet';
import autoscheduleProcess from '@salesforce/apex/ATMainComponentController.autoscheduleProcess';
import getAccountTreatmentRecordType from '@salesforce/apex/ATMainComponentController.getAccountTreatmentRecordType';
import getDefaultAddressesNumber from '@salesforce/apex/ATMainComponentController.getDefaultAddressesNumber';
import getTodayDatetime from '@salesforce/apex/ATMainComponentController.getTodayDatetime';
import checkPrescriptionFilled from '@salesforce/apex/ATMainComponentController.checkPrescriptionFilled';


import backButton from '@salesforce/label/c.AT_BackButton';
import nextButton from '@salesforce/label/c.AT_NextButton';
import finishButton from '@salesforce/label/c.AT_FinishButton';
import AutoschedulingInProgressTitle from '@salesforce/label/c.Autoscheduling_InProgress_Title';
import AutoschedulingInProgressMessage from '@salesforce/label/c.Autoscheduling_InProgress_Message';
import AutoschedulingErrorTitle from '@salesforce/label/c.Autoscheduling_Error_Title';
import AutoschedulingNoDefaultATATitle from '@salesforce/label/c.Autoscheduling_NoDefaultATA_Title';
import AutoschedulingNoDefaultATAMessage from '@salesforce/label/c.Autoscheduling_NoDefaultATA_Message';

export default class AccountTreatmentMainComponent extends NavigationMixin(LightningElement) {


    @api currentStep = 'step-1';
    @track component1 = false;
    @track component2 = false;
    @track component3 = false;
    @track component4 = false;
    @track component5 = false;
    @track result;
    @track selectedcontracttempedit;
    @track recordidtempedit;
    @track validationofat;


    @track isdisablednext = false;
    @track isdisabledback = true;
    @track ishiddenbackbutton = false;
    @track labelofnext = 'next';
    @track mode;
    @track data;
    @track recordid2;
    @track showFinishModal = false;
    @track showSpinner = false;
    @track defaultAddressesNumber;
    @track showAddressSelectionPageValue;
    @track isPrescriptionFilledValue;

    @api recordid;
    @api selectedrecordtype;
    @api therapy;
    @api selectedcontract;
    @api buttonsareactive = false;
    @track accountidinmain;


    @api accountRecordId;
    @api executionMode;
    @api accountTreatmentRecordId;
    @api contractTreatmentRecordId;
    @api showAddressSelectionPage = false;
    @api accountTreatmentName;
    @api accountTreatmentRecordType;
    @api startDateForSales;
    @api isPrescriptionFilled = false;

    isAddressSelected = false;



    @wire(getrecordnameandtreatment, { accounttreatmentrecordid: '$recordid2' })
    name({ data }) {

        if (data) {
            for (let i = 0; i < data.length; i++) {
                //console.log(JSON.stringify(data))
                this.selectedrecordtype = data[i].RecordType.DeveloperName;
                this.selectedcontract = data[i].Contract_Treatment__c;
                console.log(data[i].RecordType.DeveloperName)
                console.log(data[i].Treatment_Type__c)
                if (data[i].Treatment_Type__c === undefined) {
                    this.therapy = null;
                    console.log('chechking in rent  Therapy Type' + this.therapy)
                }
                else {

                    this.therapy = data[i].Treatment_Type__c;
                    console.log('chechking in rent  Therapy Type if not undefined' + this.therapy)
                }



                /* this.therapy = this.result.RecordType.Name  ;
                this.selectedrecordtype = this.result.Treatment_Type__c ;
                console.log('editmode therapy'+this.therapy) 
                console.log('edit mode thrarpy type'+this.selectedrecordtype)   */
            }
        }
    }


    label = {
        nextButton,
        backButton,
        finishButton
    };

    @wire(checkForAddressSelectionPage, { accountTreatmentId: '$recordid' })
    setShowAddressSelectionPage(value) {
        console.log('Wire for setShowAddressSelectionPage...');
        console.log('recordId in setShowAddressSelectionPage wire: ' + this.recordid);

        this.showAddressSelectionPageValue = value;
        const{data, error} = value;

        console.log('WIRE, data: ' + data);

        if (this.recordid !== undefined) {
            if(data != undefined && data != null) {
                console.log('Data: ' + data);

                this.showAddressSelectionPage = data;
                console.log('RecordId in MainComponent: ' + this.recordid);

                // Getting Record Type of AT

                getAccountTreatmentRecordType({
                    accountTreatmentId: this.recordid
                }).then(result => {
                    this.accountTreatmentRecordType = result
                }).catch(error => {
                    console.log('Error' + error);
                });
            }
            if(error) {
                console.log('ERROR:');
                console.log(error);
            }  
        }
    }

    @wire(checkPrescriptionFilled, {accountTreatmentId: '$recordid'})
    setIsPrescriptionFilled(value) {
        this.isPrescriptionFilledValue = value;

        const{data, error} = value;

        if(this.recordid != undefined) {
            if(data != undefined) {
                this.isPrescriptionFilled = data;
            }
            if(error) {
                console.log('ERROR: ');
                console.log(error);
            }
        }
    }

    renderedCallback() {
        refreshApex(this.showAddressSelectionPageValue);
        refreshApex(this.isPrescriptionFilledValue);

        getTodayDatetime().then(result => {
            this.startDateForSales = result;
            console.log('startDateForSales after rendered in Main: ' + this.startDateForSales);
        });
        console.log('RENDEREDCALLBACK: RecordId: ' + this.recordid);
        console.log('RENDEREDCALLBACK accountId:::::: ' + this.accountRecordId);
        console.log('RENDEREDCAllBACK accountIdInMain:::::::: ' + this.accountidinmain);
        console.log('RENDEREDCALLBACK: isPrescriptionFilled: ' + this.isPrescriptionFilled);
    }

    connectedCallback() {

        this.accountidinmain = this.accountRecordId;
        console.log('--- this.accountRecordId: ' + this.accountRecordId);
        this.labelofnext = this.label.nextButton;
        if (this.executionMode === 'edit') {
            console.log('--- EDIT MODE ---');
            this.selectedcontract = this.contractTreatmentRecordId;
            this.recordid = this.accountTreatmentRecordId;
            this.recordid2 = this.accountTreatmentRecordId;
            this.component1 = false;
            this.ishiddenbackbutton = true;
            this.component2 = true;
            this.component3 = false;
            this.component4 = false;
            this.component5 = false;
            this.isdisabledback = false;
            this.buttonsareactive = true;
        } else {
            this.component1 = true;
        }

    }

    disconnectedCallback() {
        removePermSet().then(() => {
            console.log('Permission Set removed')
        });
    }


    handleCustomEvent(event) {
        this.recordid = event.detail;
        console.log('event execution parent' + this.recordid);

    }
    handledetectchange() {
        this.buttonsareactive = false;
    }

    handleCustomEventone(event) {
        this.selectedrecordtype = event.detail;
        console.log('event in parent recordtype' + this.selectedrecordtype)
    }

    handleCustomEventtwo(event) {
        this.therapy = event.detail;
        console.log('event in parent therapy' + this.therapy)
    }

    handleCustomEventthree(event) {
        this.selectedcontract = event.detail;
        console.log('event in parent contract' + this.selectedcontract)
    }

    handleCloseFinishModal() {
        this.showFinishModal = false;
    }

    handleDateChange(event) {
        this.startDateForSales = event.detail;
        console.log('NEW STARTDATEFORSALES IN MAIN: ' + this.startDateForSales);
    }

    nextMethod() {

        refreshApex(this.showAddressSelectionPageValue);

        // eslint-disable-next-line no-console
        console.log('nextbutton is clicked');

        if (this.component4 === true) {
            this.accountTreatmentName = this.template.querySelector("c-job-list").passAccountTreatmentName();
            console.log('Account Treatment Name in MainComponent: ' + this.accountTreatmentName);
            if (this.showAddressSelectionPage === false) {
                if (this.recordid) {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recordid,
                            objectApiName: 'Account_Treatment__c',
                            actionName: 'view'
                        },
                    });

                } else {
                    let testURL = window.location.href;
                    let newURL = new URL(testURL).searchParams;

                    this.accountidinmain = newURL.get('c__accountRecordId');
                    console.log('id ===> ' + this.accountidinmain);

                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.accountidinmain,
                            objectApiName: 'Account',
                            actionName: 'view'
                        },
                    });
                }

                console.log('this navigation executed');

                this.component1 = true;
                this.component2 = false;
                this.component3 = false;
                this.component4 = false;
                this.component5 = false;
                this.labelofnext = this.label.nextButton;
                removePermSet().then(() => {
                    console.log('Permission Set removed')
                });
            }

            else if (this.showAddressSelectionPage === true) {
                this.component1 = false;
                this.component2 = false;
                this.component3 = false;
                this.component4 = false;
                this.component5 = true;
                this.labelofnext = this.label.finishButton;
                this.currentStep = 'step-5';
            }
        }


        else if (this.component3 === true) {
            this.template.querySelector("c-account-treatment-job-selection").createaccountjobs();
            console.log('executed in next create account jobs ')

            this.component1 = false;
            this.component2 = false;
            this.component3 = false;
            this.currentStep = 'step-4';
            this.component4 = true;
            this.component5 = false;
            this.isdisablednext = false;
            if (this.showAddressSelectionPage === false) {
                this.labelofnext = this.label.finishButton;
            }
            else {
                this.labelofnext = this.label.nextButton;
            }
            this.ishiddenbackbutton = false;

        }

        else if (this.component2 === true) {
            this.component1 = false;
            this.component2 = false;
            this.component3 = true;
            this.ishiddenbackbutton = false;
            this.component4 = false;
            this.component5 = false;
            this.currentStep = 'step-3';
            this.isdisablednext = false;
        }

        else if (this.component1 === true) {

            const validationofat = this.template.querySelector("c-select-contract-treatment").handleValidationofAt();

            console.log('validation in main component ' + validationofat)

            if (validationofat === true) {
                this.template.querySelector("c-select-contract-treatment").createAccountTreatment();
                console.log('executed in next ')

                this.component1 = false;
                this.ishiddenbackbutton = true;
                this.component2 = true;
                this.component3 = false;
                this.component4 = false;
                this.component5 = false;
                this.currentStep = 'step-2';
                this.isdisabledback = false;
                this.buttonsareactive = true;

            }
        }

        else if (this.component5 === true) {
            this.isAddressSelected = this.template.querySelector("c-account-treatment-address-selection").returnSomethingSelected();
            console.log('IsAddressSelected in MainComponent: ' + this.isAddressSelected);
            getDefaultAddressesNumber({
                accountTreatmentId: this.recordid
            }).then((result) => {
                this.defaultAddressesNumber = result;
                console.log('DefaultAddressesNumber::::::::::::::::::::::::::::::::::: ' + this.defaultAddressesNumber);
            });
            this.showFinishModal = true;
        }

    }

    backMethod() {
        if (this.component2 === true) {

            console.log('back component 2 true');
            this.component1 = true;
            this.currentStep = 'step-1';
            this.component2 = false;
            this.component3 = false;
            this.component4 = false;
            this.component5 = false;
            this.isdisablednext = false;
        }



        if (this.component1 === true) {
            this.isdisabledback = true;
        }


        if (this.component3 === true) {
            console.log('back component 3 true');
            this.component1 = false;
            this.component2 = true;
            this.currentStep = 'step-2';
            this.component3 = false;
            this.component4 = false;
            this.component5 = false;
            this.isdisablednext = false;
            this.ishiddenbackbutton = true;

        }

        if (this.component4 === true) {
            console.log('back component 4 true');


            this.component1 = false;
            this.component2 = false;
            this.component3 = true;
            this.currentStep = 'step-3';
            this.component4 = false;
            this.component5 = false;
            this.labelofnext = this.label.nextButton;
        }


        if (this.component5 === true) {
            console.log('back component 5 true');
            this.component1 = false;
            this.component2 = false;
            this.component3 = false;
            this.component4 = true;
            this.currentStep = 'step-4';
            this.component5 = false;
            this.isdisablednext = false;
            this.labelofnext = this.label.nextButton;
        }

    }

    handleModalYesClick() {
        console.log('Handling Yes click in MainComponent');
        if (this.defaultAddressesNumber > 0) {
            this.showFinishModal = false;
            this.showSpinner = true;

            if(this.accountTreatmentRecordType == 'AccountTreatment_Therapy') {
                autoscheduleProcess({
                    accountTreatmentId: this.recordid,
                    startDateForSales: null
                }).then(() => {
                    console.log('Done');
                    this.showSpinner = false;

                    // Navigation
                    if (this.recordid) {
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.recordid,
                                objectApiName: 'Account_Treatment__c',
                                actionName: 'view'
                            },
                        });

                    } else {
                        let testURL = window.location.href;
                        let newURL = new URL(testURL).searchParams;

                        this.accountidinmain = newURL.get('c__accountRecordId');
                        console.log('id ===> ' + this.accountidinmain);

                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.accountidinmain,
                                objectApiName: 'Account',
                                actionName: 'view'
                            },
                        });
                    }

                    console.log('this navigation executed');

                    this.component1 = true;
                    this.component2 = false;
                    this.component3 = false;
                    this.component4 = false;
                    this.component5 = false;
                    this.labelofnext = this.label.nextButton;
                    removePermSet().then(() => {
                        console.log('Permission Set removed')
                    });

                    const evt = new ShowToastEvent({
                        title: AutoschedulingInProgressTitle,
                        message: AutoschedulingInProgressMessage,
                        variant: "success"
                    });
                    this.dispatchEvent(evt);
                }).catch((error) => {
                    console.log('Error: ' + error);
                    const evt = new ShowToastEvent({
                        title: AutoschedulingErrorTitle,
                        //message: "Record ID: " + event.detail.id,
                        variant: "error"
                    });
                    this.dispatchEvent(evt);

                    // Navigation
                    if (this.recordid) {
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.recordid,
                                objectApiName: 'Account_Treatment__c',
                                actionName: 'view'
                            },
                        });

                    } else {
                        let testURL = window.location.href;
                        let newURL = new URL(testURL).searchParams;

                        this.accountidinmain = newURL.get('c__accountRecordId');
                        console.log('id ===> ' + this.accountidinmain);

                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.accountidinmain,
                                objectApiName: 'Account',
                                actionName: 'view'
                            },
                        });
                    }

                    console.log('this navigation executed');

                    this.component1 = true;
                    this.component2 = false;
                    this.component3 = false;
                    this.component4 = false;
                    this.component5 = false;
                    this.labelofnext = this.label.nextButton;
                    removePermSet().then(() => {
                        console.log('Permission Set removed')
                    });
                });
            }
            else if((this.accountTreatmentRecordType == 'AccountTreatment_Sales' || this.accountTreatmentRecordType === 'AccountTreatment_RentMaintenance'
            || this.accountTreatmentRecordType === 'AccountTreatment_Maintenance') && this.startDateForSales != undefined) {
                autoscheduleProcess({
                    accountTreatmentId: this.recordid,
                    startDateForSales: this.startDateForSales
                }).then(() => {
                    console.log('Done');
                    this.showSpinner = false;

                    // Navigation
                    if (this.recordid) {
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.recordid,
                                objectApiName: 'Account_Treatment__c',
                                actionName: 'view'
                            },
                        });

                    } else {
                        let testURL = window.location.href;
                        let newURL = new URL(testURL).searchParams;

                        this.accountidinmain = newURL.get('c__accountRecordId');
                        console.log('id ===> ' + this.accountidinmain);

                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.accountidinmain,
                                objectApiName: 'Account',
                                actionName: 'view'
                            },
                        });
                    }

                    console.log('this navigation executed');

                    this.component1 = true;
                    this.component2 = false;
                    this.component3 = false;
                    this.component4 = false;
                    this.component5 = false;
                    this.labelofnext = this.label.nextButton;
                    removePermSet().then(() => {
                        console.log('Permission Set removed')
                    });

                    const evt = new ShowToastEvent({
                        title: AutoschedulingInProgressTitle,
                        message: AutoschedulingInProgressMessage,
                        variant: "success"
                    });
                    this.dispatchEvent(evt);
                }).catch((error) => {
                    console.log('Error: ' + error);
                    const evt = new ShowToastEvent({
                        title: AutoschedulingErrorTitle,
                        //message: "Record ID: " + event.detail.id,
                        variant: "error"
                    });
                    this.dispatchEvent(evt);

                    // Navigation
                    if (this.recordid) {
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.recordid,
                                objectApiName: 'Account_Treatment__c',
                                actionName: 'view'
                            },
                        });

                    } else {
                        let testURL = window.location.href;
                        let newURL = new URL(testURL).searchParams;

                        this.accountidinmain = newURL.get('c__accountRecordId');
                        console.log('id ===> ' + this.accountidinmain);

                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.accountidinmain,
                                objectApiName: 'Account',
                                actionName: 'view'
                            },
                        });
                    }

                    console.log('this navigation executed');

                    this.component1 = true;
                    this.component2 = false;
                    this.component3 = false;
                    this.component4 = false;
                    this.component5 = false;
                    this.labelofnext = this.label.nextButton;
                    removePermSet().then(() => {
                        console.log('Permission Set removed')
                    });
                });
            }
        }
        else if (this.defaultAddressesNumber === 0) {
            const evt = new ShowToastEvent({
                title: AutoschedulingNoDefaultATATitle,
                message: AutoschedulingNoDefaultATAMessage,
                variant: "warning"
            });
            this.dispatchEvent(evt);
        }
    }

    handleModalNoClick() {
        this.showFinishModal = false;
        if (this.recordid) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordid,
                    objectApiName: 'Account_Treatment__c',
                    actionName: 'view'
                },
            });

        } else {
            let testURL = window.location.href;
            let newURL = new URL(testURL).searchParams;

            this.accountidinmain = newURL.get('c__accountRecordId');
            console.log('id ===> ' + this.accountidinmain);

            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.accountidinmain,
                    objectApiName: 'Account',
                    actionName: 'view'
                },
            });
        }

        console.log('this navigation executed');

        this.component1 = true;
        this.component2 = false;
        this.component3 = false;
        this.component4 = false;
        this.component5 = false;
        this.labelofnext = this.label.nextButton;
        removePermSet().then(() => {
            console.log('Permission Set removed')
        });
    }

    handleATJActivitiesScheduled() {
        if(this.showAddressSelectionPage === true) {
            this.showAddressSelectionPage = false;
        }
    }
}