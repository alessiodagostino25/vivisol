import { LightningElement, track, api } from 'lwc';

// Apex actions
import deleteContractAsset from '@salesforce/apex/CTJAssetSelectionController.deleteContractAsset';

// Labels
import Delete from '@salesforce/label/c.AccountTreatment_DeleteButton';
import Details from '@salesforce/label/c.SectionTitle_Details';
import Cancel from '@salesforce/label/c.Btn_Cancel';
import DeleteMessage from '@salesforce/label/c.Asset_DeleteMessage';
import DeleteHeader from '@salesforce/label/c.Asset_DeleteHeader';
import ManageStatus from '@salesforce/label/c.AccountTreatment_ManageStatus';

// Other stuff
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ContractTreatmentJobAssetCard extends LightningElement {
    labels = {
        Delete,
        Details,
        Cancel,
        DeleteMessage,
        DeleteHeader,
        ManageStatus
    }

    @api contractAssetId;
    @api serialNumber;
    @api frameworkIsActive;
    @api productName;

    @track showDeleteModal = false;
    @track showManageStatusModal = false;
    @track isLoading = true;

    get manageStatusDisabled() {
        if(this.frameworkIsActive === true) {
            return false;
        }
        else {
            return true;
        }
    }

    connectedCallback() {
        console.log('contractTreatmentJobAssetCard connected...');
    }

    handleOnLoad() {
        this.isLoading = false;
    }

    handleStatusSubmit() {
        const evt = new ShowToastEvent({
            title: "Status Updated",
            //message: "Record ID: " + this.contractTreatmentJobId,
            variant: "success"
        });
        this.dispatchEvent(evt);
        this.showManageStatusModal = false;
    }

    openDeleteModal() {
        this.showDeleteModal = true;
    }

    closeDeleteModal() {
        this.showDeleteModal = false;
    }

    openManageStatusModal() {
        this.showManageStatusModal = true;
    }

    closeManageStatusModal() {
        this.showManageStatusModal = false;
    }

    handleDelete() {
        deleteContractAsset({
            contractAssetId: this.contractAssetId
        }).then(() => {
            const evt = new ShowToastEvent({
                title: "Contract Asset deleted",
                variant: "success"
            });
            this.dispatchEvent(evt);

            const deleteEvent = new CustomEvent('delete');
            this.dispatchEvent(deleteEvent);
        }).catch((error) => {
            console.log('Error: ' + error);

            const evt = new ShowToastEvent({
                title: "Error",
                message: "An error occurred while trying to delete this record.",
                variant: "error"
            });
            this.dispatchEvent(evt);
        });
    }

    handleSuccess() {
        this.isLoading = false;
        
        const evt = new ShowToastEvent({
            title: "Record Updated",
            //message: "Record ID: " + this.contractTreatmentJobId,
            variant: "success"
        });
        this.dispatchEvent(evt);
    }

    handleError() {
        this.isLoading = false;

        const evt = new ShowToastEvent({
            title: "Error",
            message: "An error occurred while trying to update this record.",
            variant: "error"
        });
        this.dispatchEvent(evt);
    }

    handleSubmit() {
        this.isLoading = true;
    }
}