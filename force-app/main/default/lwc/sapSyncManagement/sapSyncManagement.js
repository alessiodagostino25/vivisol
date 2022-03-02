import { LightningElement, api } from 'lwc';

// Labels
import SAPSyncStatus from '@salesforce/label/c.SAP_SyncStatus';
import SAPForcedSync from '@salesforce/label/c.SAP_ForcedSyncTab';
import SAPFields from '@salesforce/label/c.SAP_FieldsTab';
import SAPLogsTab from '@salesforce/label/c.SAP_LogsTab';
import PortalStatusTab from '@salesforce/label/c.Portals_StatusTab';

export default class SapSyncManagement extends LightningElement {
    labels = {
        SAPSyncStatus,
        SAPForcedSync,
        SAPFields,
        SAPLogsTab,
        PortalStatusTab
    };
    
    @api recordId;
    @api objectApiName;

    connectedCallback() {
        console.log('SAPSyncManagement connected...');
        console.log('objectApiName: ' + this.objectApiName);
        console.log('recordId: ' + this.recordId);
    }

    get showSAPForcedSync() {
        if(this.objectApiName === 'Measurement__c' || this.objectApiName === 'Rebate__c' || this.objectApiName === 'EndOfMonthHeader__c' ||
        this.objectApiName === 'HealthCloudGA__ContactContactRelation__c' || this.objectApiName === 'Contract_Treatment_Job_Product__c' ||
        this.objectApiName === 'Asset'|| this.objectApiName === 'Product_Asset_Patient_History__c' ||
        this.objectApiName === 'Account_Treatment__c' || this.objectApiName === 'Prescription__c') {
            return false;
        }
        else {
            return true;
        }
    }

    get showSAPSyncFieldsManagement() {
        if(this.objectApiName === 'Rebate__c' || this.objectApiName === 'EndOfMonthHeader__c' || this.objectApiName === 'HealthCloudGA__ContactContactRelation__c' || 
        this.objectApiName === 'Contract_Treatment_Job_Product__c' ||
        this.objectApiName === 'Asset' || this.objectApiName === 'Product_Asset_Patient_History__c' ||
        this.objectApiName === 'Account_Treatment__c' || this.objectApiName === 'Prescription__c') {
            return false;
        }
        else {
            return true;
        }
    }

    get showPortalStatusTab() {
        if(this.objectApiName === 'Account' || this.objectApiName === 'HealthCloudGA__ContactContactRelation__c' || 
        this.objectApiName === 'Contract_Treatment_Job_Product__c' || this.objectApiName === 'Contract_Framework__c' || this.objectApiName === 'Asset' ||
        this.objectApiName === 'WorkOrder' || this.objectApiName === 'Product_Asset_Patient_History__c' || this.objectApiName === 'Account_Treatment__c' ||
        this.objectApiName === 'Prescription__c' || this.objectApiName === 'Address') {
            return true;
        }
        else {
            return false;
        }
    }

    get showSAPSyncStatusTab() {
        if(this.objectApiName === 'HealthCloudGA__ContactContactRelation__c' || this.objectApiName === 'Contract_Treatment_Job_Product__c' ||
        this.objectApiName === 'Asset' || this.objectApiName === 'Product_Asset_Patient_History__c' ||
        this.objectApiName === 'Account_Treatment__c' || this.objectApiName === 'Prescription__c') {
            return false;
        }
        else {
            return true;
        }
    }
}