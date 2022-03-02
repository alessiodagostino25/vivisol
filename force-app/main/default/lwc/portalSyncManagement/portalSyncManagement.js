import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

// Labels
import Sync from '@salesforce/label/c.Sync_Portals';
import NotSync from '@salesforce/label/c.NotSync_Portals';
import Pending from '@salesforce/label/c.Pending_Portals';
import Retry from '@salesforce/label/c.Retry';

// Account fields
import ACCOUNT_SYNC_FIELD from '@salesforce/schema/Account.Is_Portal_Sync__c';

// Contact-Contact Relation fields
import CONTACT_RELATION_SYNC_FIELD from '@salesforce/schema/HealthCloudGA__ContactContactRelation__c.Is_Portal_Sync__c';

// CTJP fields
import CTJP_SYNC_FIELD from '@salesforce/schema/Contract_Treatment_Job_Product__c.Is_Portal_Sync__c';

// Contract Framework fields
import CONTRACT_FRAMEWORK_SYNC_FIELD from '@salesforce/schema/Contract_Framework__c.Is_Portal_Sync__c';

// Asset fields
import ASSET_SYNC_FIELD from '@salesforce/schema/Asset.Is_Portal_Sync__c';

// Work Order fields
import WORKORDER_SYNC_FIELD from '@salesforce/schema/WorkOrder.Is_Portal_Sync__c';

// PAPH fields
import PAPH_SYNC_FIELD from '@salesforce/schema/Product_Asset_Patient_History__c.Is_Portal_Sync__c';

// Account Treatment fields
import ACCOUNT_TREATMENT_SYNC_FIELD from '@salesforce/schema/Account_Treatment__c.Is_Portal_Sync__c';

// Prescription fields
import PRESCRIPTION_SYNC_FIELD from '@salesforce/schema/Prescription__c.Is_Portal_Sync__c';

// Address fields
import ADDRESS_SYNC_FIELD from '@salesforce/schema/Address.Is_Portal_Sync__c';

export default class PortalSyncManagement extends LightningElement {
    labels = {
        Sync,
        NotSync,
        Retry,
        Pending
    }

    @track queryFields = [];
    @track isSynced;
    @track isNotSynced;
    @track isPending;

    @api recordId;
    @api objectApiName;

    @wire(getRecord, { recordId: '$recordId', fields: '$queryFields' })
    getRecord(value) {
        console.log('Wire...');

        const{data, error} = value;

        if(data) {
            let syncFieldValue = data.fields.Is_Portal_Sync__c.value;
            console.log('syncFieldValue: ' + syncFieldValue);

            if(syncFieldValue === '01') {
                this.isSynced = true;
                this.isNotSynced = false;
                this.isPending = false;
            }
            else if(syncFieldValue === '02') {
                this.isSynced = false;
                this.isNotSynced = true;
                this.isPending = false;
            }
            else if(syncFieldValue === '03') {
                this.isSynced = false;
                this.isNotSynced = false;
                this.isPending = true;
            }
        }
        if(error) {
            console.log('ERROR!!!');
            console.log(error.body.message);
        }
    }

    connectedCallback() {
        console.log('portalSyncManagement connected...');
        console.log('objectApiName: ' + this.objectApiName);
        console.log('recordId: ' + this.recordId);

        // Even if the field names of the different objects are the same (isCreatedSAP__c and isSyncSAP__c), getRecords is not working without imported fields

        if(this.objectApiName === 'Account') {
            this.queryFields.push(ACCOUNT_SYNC_FIELD);
        }
        else if(this.objectApiName === 'HealthCloudGA__ContactContactRelation__c') {
            this.queryFields.push(CONTACT_RELATION_SYNC_FIELD);
        }
        else if(this.objectApiName === 'Contract_Treatment_Job_Product__c') {
            this.queryFields.push(CTJP_SYNC_FIELD);
        }
        else if(this.objectApiName === 'Contract_Framework__c') {
            this.queryFields.push(CONTRACT_FRAMEWORK_SYNC_FIELD);
        }
        else if(this.objectApiName === 'Asset') {
            this.queryFields.push(ASSET_SYNC_FIELD);
        }
        else if(this.objectApiName === 'WorkOrder') {
            this.queryFields.push(WORKORDER_SYNC_FIELD);
        }
        else if(this.objectApiName === 'Product_Asset_Patient_History__c') {
            this.queryFields.push(PAPH_SYNC_FIELD);
        }
        else if(this.objectApiName === 'Account_Treatment__c') {
            this.queryFields.push(ACCOUNT_TREATMENT_SYNC_FIELD);
        }
        else if(this.objectApiName === 'Prescription__c') {
            this.queryFields.push(PRESCRIPTION_SYNC_FIELD);
        }
        else if(this.objectApiName === 'Address') {
            this.queryFields.push(ADDRESS_SYNC_FIELD);
        }
    }
}