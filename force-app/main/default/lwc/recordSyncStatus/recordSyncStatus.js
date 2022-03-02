import { LightningElement, track, api, wire } from 'lwc';

// Account fields and methods
import ACCOUNT_SYNC_FIELD from '@salesforce/schema/Account.IsSyncSAP__c';
import ACCOUNT_CREATED_FIELD from '@salesforce/schema/Account.IsCreatedSAP__c';
import accountCreateCallout from '@salesforce/apex/AccountService.futureCreateCallout';
import accountUpdateCallout from '@salesforce/apex/AccountService.futureUpdateCallout';

// Account Sales Organization fields and methods
import ASO_SYNC_FIELD from '@salesforce/schema/Account_Sales_Organization__c.IsSyncSAP__c';
import ASO_CREATED_FIELD from '@salesforce/schema/Account_Sales_Organization__c.IsCreatedSAP__c';
import ASOCreateCallout from '@salesforce/apex/ASOService.futureCreateCallout';
import ASOUpdateCallout from '@salesforce/apex/ASOService.futureUpdateCallout';

// Address fields and methods
import ADDRESS_SYNC_FIELD from '@salesforce/schema/Address.IsSyncSAP__c';
import ADDRESS_CREATED_FIELD from '@salesforce/schema/Address.IsCreatedSAP__c';
import addressCreationEvent from '@salesforce/apex/AddressService.publishAddressCreationEvents';
import addressUpdateEvent from '@salesforce/apex/AddressService.publishAddressUpdateEvents';

// Account Company fields and methods
import ACCOUNT_COMPANY_SYNC_FIELD from '@salesforce/schema/Account_Company__c.IsSyncSAP__c';
import ACCOUNT_COMPANY_CREATED_FIELD from '@salesforce/schema/Account_Company__c.IsCreatedSAP__c';
import accountCompanyCreateCallout from '@salesforce/apex/AccountCompanyService.futureCreateCallout';
import accountCompanyUpdateCallout from '@salesforce/apex/AccountCompanyService.futureUpdateCallout';

// Contract Frameork fields and methods
import CONTRACT_FRAMEWORK_SYNC_FIELD from '@salesforce/schema/Contract_Framework__c.IsSyncSAP__c';
import CONTRACT_FRAMEWORK_CREATED_FIELD from '@salesforce/schema/Contract_Framework__c.IsCreatedSAP__c';
import contractFrameworkEvent from '@salesforce/apex/ContractFrameworkEventHelper.createEvent';

// Work Order fields and methods
import WORK_ORDER_SYNC_FIELD from '@salesforce/schema/WorkOrder.IsSyncSAP__c';
import workOrderUpdate from '@salesforce/apex/WorkOrderService.retrySAPSync';

// Product Request fields and methods
import PRODUCT_REQUEST_SYNC_FIELD from '@salesforce/schema/ProductRequest.IsSyncSAP__c';
import productRequestUpdateCallout from '@salesforce/apex/ProductRequestService.handleProductRequestUpdate';
import getProductRequestFromId from '@salesforce/apex/ProductRequestService.getProductRequestFromId';

// Measurement fields and methods
import MEASUREMENT_CREATED_FIELD from '@salesforce/schema/Measurement__c.IsCreatedSAP__c';
import measurementCreateCallout from '@salesforce/apex/MeasurementService.makeCalloutWrapperWithIds';

// Rebate fields
import REBATE_SYNC_FIELD from '@salesforce/schema/Rebate__c.IsSyncSAP__c';

// End Of Month Header fields
import EOM_SYNC_FIELD from '@salesforce/schema/EndOfMonthHeader__c.IsSyncSAP__c';

// Labels
import SyncSAP from '@salesforce/label/c.Sync_SAP';
import NotSyncSAP from '@salesforce/label/c.NotSync_SAP';
import PendingSAP from '@salesforce/label/c.Pending_SAP';
import Retry from '@salesforce/label/c.Retry';
import SyncButton from '@salesforce/label/c.SAP_SyncButton';

// Other stuff
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class RecordSyncStatus extends LightningElement {
    labels = {
        SyncSAP,
        NotSyncSAP,
        Retry,
        SyncButton,
        PendingSAP
    }
    recordIdsForMethods = [];
    record;
    intervalId;
    timeoutId;

    @api recordId;
    @api objectApiName;

    @track queryFields = [];
    @track isSync;
    @track isCreated;
    @track isPending;
    @track isLoading;
    @track isWaitingCallout = false;

    @wire(getRecord, { recordId: '$recordId', fields: '$queryFields' })
    getRecord(value) {
        console.log('Wire...');
        this.isLoading = true;
        this.record = value;
        const{data, error} = value;

        if(data) {
            console.log(data);

            let syncFieldValue;

            // For Measurement__c, which has not the IsSyncSAP__c field, the field which the component depends on is IsCreatedSAP__c. So this will be used as isSync variable
            
            if(this.objectApiName != 'Measurement__c') {
                syncFieldValue = data.fields.IsSyncSAP__c.value;
            }
            else {
                syncFieldValue = data.fields.IsCreatedSAP__c.value;
            }

            if(data.fields.IsCreatedSAP__c != undefined && data.fields.IsCreatedSAP__c != null) {
                let createdFieldValue = data.fields.IsCreatedSAP__c.value;
                this.isCreated = createdFieldValue;
            }
            else {
                // If the IsCreatedSAP__c field doesn't exist, we are on a WorkOrder/ProductRequest. I set this to true, so that I'll only consider IsSyncSAP__c

                this.isCreated = true;
            }

            if(syncFieldValue === 'Sync' || syncFieldValue === true || syncFieldValue === 'Success') {
                this.isSync = true;
                this.isPending = false;
            }

            else if(syncFieldValue === 'NotSync' || syncFieldValue === false || syncFieldValue === null || syncFieldValue === undefined || syncFieldValue === 'Error') {
                this.isSync = false;
                this.isPending = false;
            }

            else if(syncFieldValue === 'Pending') {
                this.isSync = false;
                this.isPending = true;
            }
            
            if(this.isWaitingCallout === false) {
                this.isLoading = false;
            }

            console.log('isCreated from WIRE: ' + this.isCreated);
            console.log('isSync from WIRE: ' + this.isSync);
            console.log('isPending from WIRE: ' + this.isPending);
        }
        if(error) {
            console.log('ERROR!!!');
            console.log(error.body.message);

            if(error.body.message === 'Object ProductRequest is not supported in UI API') {
                return this.imperativeGetRecord();
            }
        }
    }

    // ProductRequest is not supported by uiRecordApi, so I need to query it manually

    imperativeGetRecord() {
        console.log('Imperative Get Record...');

        getProductRequestFromId({
            relatedId: this.recordId
        }).then((value => {
            console.log('VALUE FROM IMPERATIVE GET RECORD:');
            console.log(JSON.stringify(value));

            this.isCreated = true;
            this.isPending = false;

            if(value.IsSyncSAP__c != null && value.IsSyncSAP__c != undefined) {
                if(value.IsSyncSAP__c === 'Sync') {
                    this.isSync = true;
                }
                else {
                    this.isSync = false;
                }
            }
            else {
                this.isSync = false;
            }

            if(this.isWaitingCallout === false) {
                this.isLoading = false;
            }

            console.log('isCreated from WIRE: ' + this.isCreated);
            console.log('isSync from WIRE: ' + this.isSync);
            console.log('isPending from WIRE: ' + this.isPending);
        }))
    }

    connectedCallback() {
        console.log('recordSyncStatus connected...');
        console.log('objectApiName: ' + this.objectApiName);
        console.log('recordId: ' + this.recordId);

        // Even if the field names of the different objects are the same (isCreatedSAP__c and isSyncSAP__c), getRecords is not working without imported fields

        if(this.objectApiName === 'Account') {
            this.queryFields.push(ACCOUNT_CREATED_FIELD);
            this.queryFields.push(ACCOUNT_SYNC_FIELD);
        }
        else if(this.objectApiName === 'Account_Sales_Organization__c') {
            this.queryFields.push(ASO_CREATED_FIELD);
            this.queryFields.push(ASO_SYNC_FIELD);
        }
        else if(this.objectApiName === 'Address') {
            this.queryFields.push(ADDRESS_CREATED_FIELD);
            this.queryFields.push(ADDRESS_SYNC_FIELD);
        }
        else if(this.objectApiName === 'Account_Company__c') {
            this.queryFields.push(ACCOUNT_COMPANY_CREATED_FIELD);
            this.queryFields.push(ACCOUNT_COMPANY_SYNC_FIELD);
        }
        else if(this.objectApiName === 'Contract_Framework__c') {
            this.queryFields.push(CONTRACT_FRAMEWORK_CREATED_FIELD);
            this.queryFields.push(CONTRACT_FRAMEWORK_SYNC_FIELD);
        }
        else if(this.objectApiName === 'WorkOrder') {
            this.queryFields.push(WORK_ORDER_SYNC_FIELD);
        }
        else if(this.objectApiName === 'ProductRequest') {
            this.queryFields.push(PRODUCT_REQUEST_SYNC_FIELD);
        }
        else if(this.objectApiName === 'Measurement__c') {
            this.queryFields.push(MEASUREMENT_CREATED_FIELD);
        }
        else if(this.objectApiName === 'Rebate__c') {
            this.queryFields.push(REBATE_SYNC_FIELD);
        }
        else if(this.objectApiName === 'EndOfMonthHeader__c') {
            this.queryFields.push(EOM_SYNC_FIELD);
        }

        this.recordIdsForMethods.push(this.recordId);

        // Refreshing the component every 10 secs (delayed by 5 seconds)

        this.timeoutId = setTimeout(() => {
            this.intervalId = setInterval(() => {
                this.refreshRecord();
            }, 10000);
        }, 5000);
    }

    disconnectedCallback() {
        clearInterval(this.intervalId);
        clearTimeout(this.timeoutId);
    }

    refreshRecord() {
        console.log('Refreshing...');
        
        //this.isLoading = true;
        //this.isWaitingCallout = false;
        //refreshApex(this.record);
        refreshApex(this.record).then(() => {
            this.isLoading = false;
        });
        //this.isLoading = false;
    }

    setLoading() {
        console.log('Setting loading...');
        this.isWaitingCallout = true;
        this.isLoading = true;
    }

    handleClick() {
        this.isLoading = true;

        if(this.objectApiName != 'ProductRequest') {
            refreshApex(this.record).then(() => {
                console.log('isCreated: ' + this.isCreated);
                console.log('isSync: ' + this.isSync);

                // Account callouts

                if(this.objectApiName === 'Account') {
                    if(this.isCreated == true && this.isSync == false) {
                        console.log('Trying Update Callout...');
                        accountUpdateCallout( {
                            accountIds: this.recordIdsForMethods
                        }).then(() => {
                            this.handleUpdateCalloutResult();
                        });
                    }
                    else if(this.isCreated == false) {
                        console.log('Trying Create Callout...');
                        accountCreateCallout( {
                            accountIds: this.recordIdsForMethods
                        }).then(() => {
                            this.handleCreateCalloutResult();
                        });
                    }
                    else if(this.isCreated == true && this.isSync === true) {
                        this.handleNoCalloutNeeded();
                    }
                }

                // Account Sales Organization callouts

                if(this.objectApiName === 'Account_Sales_Organization__c') {
                    if(this.isCreated == true && this.isSync == false) {
                        console.log('Trying Update Callout...');
                        ASOUpdateCallout( {
                            relatedIds: this.recordIdsForMethods
                        }).then(() => {
                            this.handleUpdateCalloutResult();
                        });
                    }
                    else if(this.isCreated == false) {
                        console.log('Trying Create Callout...');
                        ASOCreateCallout( {
                            relatedIds: this.recordIdsForMethods
                        }).then(() => {
                            this.handleCreateCalloutResult();
                        });
                    }
                    else if(this.isCreated == true && this.isSync === true) {
                        this.handleNoCalloutNeeded();
                    }
                }

                // Address events publishing

                if(this.objectApiName === 'Address') {
                    if(this.isCreated == true && this.isSync == false) {
                        console.log('Trying Update Event publishing...');
                        addressUpdateEvent( {
                            addressIds: this.recordIdsForMethods
                        }).then(() => {
                            this.handleUpdateCalloutResult();
                        });
                    }
                    else if(this.isCreated == false) {
                        console.log('Trying Create Event publishing...');
                        addressCreationEvent( {
                            addressIds: this.recordIdsForMethods
                        }).then(() => {
                            this.handleCreateCalloutResult();
                        });
                    }
                    else if(this.isCreated == true && this.isSync === true) {
                        this.handleNoCalloutNeeded();
                    }
                }

                // Contract Framework event publishing

                if(this.objectApiName === 'Contract_Framework__c') {
                    if(this.isSync === false) {
                        console.log('Trying Update Event publishing...');
                        contractFrameworkEvent( {
                            cfIds: this.recordIdsForMethods
                        }).then(() => {
                            this.handleUpdateCalloutResult();
                        });
                    }
                    else if(this.isSync === true) {
                        this.handleNoCalloutNeeded();
                    }
                }

                // Work Order updates to force Sync

                if(this.objectApiName === 'WorkOrder') {
                    if(this.isCreated == true) {
                        console.log('Trying WorkOrder update...');
                        workOrderUpdate({
                            workOrderIds: this.recordIdsForMethods
                        }).then(() => {
                            this.handleUpdateCalloutResult();
                        });
                    }
                }

                // Account Company callouts

                if(this.objectApiName === 'Account_Company__c') {
                    if(this.isCreated == true && this.isSync == false) {
                        console.log('Trying Update Callout...');
                        accountCompanyUpdateCallout( {
                            relatedIds: this.recordIdsForMethods
                        }).then(() => {
                            this.handleUpdateCalloutResult();
                        });
                    }
                    else if(this.isCreated == false) {
                        console.log('Trying Create Callout...');
                        accountCompanyCreateCallout( {
                            relatedIds: this.recordIdsForMethods
                        }).then(() => {
                            this.handleCreateCalloutResult();
                        });
                    }
                    else if(this.isCreated == true && this.isSync === true) {
                        this.handleNoCalloutNeeded();
                    }
                }

                // Measurement callouts

                if(this.objectApiName === 'Measurement__c') {
                    if(this.isCreated == false) {
                        console.log('Trying Update Callout...');
                        measurementCreateCallout( {
                            relatedIds: this.recordIdsForMethods
                        }).then(() => {
                            this.handleUpdateCalloutResult();
                        });
                    }
                    else if(this.isCreated == true) {
                        this.handleNoCalloutNeeded();
                    }
                }
            }); 
        }
        else {
            // Product Request callout

            if(this.isCreated == true && this.isSync == false) {
                console.log('Trying Update Callout...');
                productRequestUpdateCallout( {
                    productRequestIds: this.recordIdsForMethods
                }).then(() => {
                    this.handleUpdateCalloutResult();
                });
            }
            else if(this.isCreated == true && this.isSync === true) {
                this.handleNoCalloutNeeded();
            }
        }
    }

    // This is what to do after an update callout

    handleUpdateCalloutResult() {
        // this.isLoading = false;
        if(this.objectApiName != 'ProductRequest') {
            refreshApex(this.record).then(() => {
                if(this.isSync === false && (this.isPending === false || this.isPending === undefined)) {
                    const evt = new ShowToastEvent({
                        title: "Record not correctly synced",
                        message: "An error occurred while trying to sync this record with SAP.",
                        variant: "error"
                    });
                    this.dispatchEvent(evt); 
                }
                else if(this.isSync === true) {
                    const evt = new ShowToastEvent({
                        title: "Record correctly synced",
                        message: "The record is now in sync with SAP.",
                        variant: "success"
                    });
                    this.dispatchEvent(evt); 
                }
                else if(this.isSync === false && this.isPending === true) {
                    const evt = new ShowToastEvent({
                        title: "Record Pending",
                        message: "The record synchronization with SAP is still pending.",
                        variant: "success"
                    });
                    this.dispatchEvent(evt); 
                }
            });
        }
        else {
            this.imperativeGetRecord();

            if(this.isSync === false && this.isPending === false) {
                const evt = new ShowToastEvent({
                    title: "Record not correctly synced",
                    message: "An error occurred while trying to sync this record with SAP.",
                    variant: "error"
                });
                this.dispatchEvent(evt); 
            }
            else if(this.isSync === true) {
                const evt = new ShowToastEvent({
                    title: "Record correctly synced",
                    message: "The record is now in sync with SAP.",
                    variant: "success"
                });
                this.dispatchEvent(evt); 
            }
            else if(this.isSync === false && this.isPending === true) {
                const evt = new ShowToastEvent({
                    title: "Record Pending",
                    message: "The record synchronization with SAP is still pending.",
                    variant: "success"
                });
                this.dispatchEvent(evt); 
            }
        }
    }

    // This is what to do after a creation callout

    handleCreateCalloutResult() {
        // this.isLoading = false;
        refreshApex(this.record).then(() => {
            if(this.isCreated === false) {
                const evt = new ShowToastEvent({
                    title: "Record not correctly synced",
                    message: "An error occurred while trying to sync this record with SAP",
                    variant: "error"
                });
                this.dispatchEvent(evt); 
            }
            else if(this.isCreated === true && this.isSync === true) {
                const evt = new ShowToastEvent({
                    title: "Record correctly synced",
                    message: "The record is now in sync with SAP",
                    variant: "success"
                });
                this.dispatchEvent(evt); 
            }
        });
    }

    // This is what to do when no callout is needed

    handleNoCalloutNeeded() {
        console.log('Not trying any callout');
        this.isLoading = false;

        const evt = new ShowToastEvent({
            title: "Record already correctly synced",
            message: "The record is already in sync with SAP",
            variant: "success"
        });
        this.dispatchEvent(evt); 
    }

    get isSyncButtonDisabled() {
        if(this.isSync === true || this.isPending === true || this.objectApiName === 'Rebate__c' || this.objectApiName === 'EndOfMonthHeader__c') {
            return true;
        }
    }
}