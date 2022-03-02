/* eslint-disable no-console */
import { LightningElement, api, track, wire } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from "@salesforce/apex";

// Labels
import deleteButton from '@salesforce/label/c.AT_JobTile_DeleteButton';
import deleteModalMainTitle from '@salesforce/label/c.AT_JobTile_DeleteModal_Title';
import deleteModalMainBody from '@salesforce/label/c.AT_JobTile_DeleteModal_Body';
import viewProductsButton from '@salesforce/label/c.AT_JobTile_ViewProductsButton';
import deliveryChannelSuccess from '@salesforce/label/c.AT_JobTile_DeliveryChannel_SuccessToast';
import frequencySuccess from '@salesforce/label/c.AT_JobTile_Frequency_SuccessToast';
import ManageStatus from '@salesforce/label/c.AccountTreatment_ManageStatus';
import ManageStatus_BodyTitle from '@salesforce/label/c.AccountTreatmentJob_ManageStatus_BodyTitle';
import updateChildModalTitle from '@salesforce/label/c.CT_JobConfiguration_ModalPropagateTitle';
import updateChildModalBody from '@salesforce/label/c.CT_JobConfiguration_ModalPropagateBody';
import deliveryButton from '@salesforce/label/c.CT_JobConfiguration_ModalPropagateDeliveryButton';
import frequencyButton from '@salesforce/label/c.CT_JobConfiguration_ModalPropagateFrequencyButton';
import updateChildButton from '@salesforce/label/c.CT_JobConfiguration_UpdateChildsButton';
import cancel from '@salesforce/label/c.Btn_Cancel';
import ScheduleActivitiesButtonLabel from '@salesforce/label/c.ATJ_ScheduleActivities_Button';

// Apex actions
import getPreviouslySelectedProducts from "@salesforce/apex/JobTileController.getPreviouslySelectedProducts";
import deleteproductsrelatedtoatj from "@salesforce/apex/JobTileController.deleteproductsrelatedtoatj";
import checkShowFrequencyButton from '@salesforce/apex/JobTileController.getShowFrequencyButton';
import checkShowDeliveryButton from '@salesforce/apex/JobTileController.getShowDeliveryButton';
import propagateDeliveryChannel from '@salesforce/apex/JobTileController.propagateDeliveryChannel';
import propagateFrequencyChange from '@salesforce/apex/JobTileController.propagateFrequency';
import getIsScheduleActivitiesDisabled from '@salesforce/apex/JobTileController.getIsScheduleActivitiesDisabled';

export default class JobTile extends LightningElement {

    @api job;

    @api selectedrecordtype;
    @api selectedjobid;
    @track openmodal1 = false;
    @track openmodal = false;
    @track productselection = false;
    @track selectedproductview = true;
    @track result;
    @track atjobid;
    @track managestatusdisabled;
    @track showManageStatusModal;
    @track deletechanged;
    @track isLoading = true;
    @track isScheduleActivitiesDisabled = true;
    @track showScheduleActivitiesModal = false;

    showUpdateChildModal = false;
    showDeliveryButton = false;
    showFrequencyButton = false;
    showUpdateChildButton = false;

    @api accounttreatmentstatus;

    label = {
        deleteButton,
        deleteModalMainTitle,
        deleteModalMainBody,
        viewProductsButton,
        ManageStatus,
        ManageStatus_BodyTitle,
        updateChildModalTitle,
        updateChildModalBody,
        deliveryButton,
        frequencyButton,
        updateChildButton,
        cancel,
        deliveryChannelSuccess,
        frequencySuccess,
        ScheduleActivitiesButtonLabel
    };

    @wire(getPreviouslySelectedProducts, { atjobid: "$atjobid" })
    atpsre(result) {
        this.result = result;
        console.log('data in jobtile ' + JSON.stringify(this.result))
        if (this.result.data) {
            console.log('result . data in job tile ')
            this.selectedproductview = false;
        }
    }

    connectedCallback() {
        this.checkButtonsVisibility();
        this.setIsScheduleActivitiesDisabled();
    }

    renderedCallback() {
        if (this.accounttreatmentstatus === true) {
            this.managestatusdisabled = false;
        } else {
            this.managestatusdisabled = true;
        }

        this.deletechanged = '\xa0\xa0\xa0\xa0\xa0\xa0\xa0' + deleteButton + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';

        this.atjobid = this.job.Id;
        let testURL = window.location.href;

        let newURL = new URL(testURL).searchParams;
        this.mode = newURL.get('c__mode');

        if (this.mode === 'edit') {
            this.selectedproductview = false;
        }
        console.log('job ' + this.job.Id)
        return refreshApex(this.result);
    }

    setIsScheduleActivitiesDisabled() {
        getIsScheduleActivitiesDisabled({
            accountTreatmentJobId: this.job.Id
        }).then(result => {
            this.isScheduleActivitiesDisabled = result;
            console.log('isScheduleActivitiesDisabled: ' + this.isScheduleActivitiesDisabled);
        }).catch(error => {
            console.log('ERROR');
            console.log(JSON.stringify(error));
        })
    }

    handleviewproductchange() {
        this.selectedproductview = false;
    }

    handleManageStatus() {
        this.showManageStatusModal = true;
    }

    handleStatusSubmit() {
        const evt = new ShowToastEvent({
            title: "Account Treatment Job Status updated ",

            variant: "success"
        });
        this.dispatchEvent(evt);
        this.showManageStatusModal = false;
    }

    closemanagestatus(){
        this.showManageStatusModal = false;
    }

    handledelete() {
        this.openmodal = true;
        console.log('button is pressed ')
    }

    closedelete() {
        this.openmodal = false;
        console.log('close is pressed')
    }

    saveMethod() {
        deleteproductsrelatedtoatj()
            .then(result => {
                console.log('delete of products is executed');

            })
            .catch(error => {
                this.error = error;
            });


        // eslint-disable-next-line no-alert
        deleteRecord(this.job.Id)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record deleted',
                        variant: 'success'
                    })
                );
                const deleterefresh = new CustomEvent('deleterefresh', {
                    detail: this.job.Id

                });
                
                this.closedelete();

                this.dispatchEvent(deleterefresh);
                console.log('deletee refresh')
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );

                this.closedelete();
            });
        
    }

    handlesuccess() {
        this.checkButtonsVisibility();
        this.setIsScheduleActivitiesDisabled();
        this.productselection = false;
    }

    displayproduct() {
        this.openmodal1 = true;
        console.log('button view product is pressed');
    }

    closedisplayproduct() {
        this.openmodal1 = false;
        console.log('close button view product is pressed');
    }

    handleOnLoad() {
        this.isLoading = false;
    }

    handleClickDeliveryChannel() {
        propagateDeliveryChannel({ accountTreatmentJobId: this.job.Id })
            .then(result => {
                this.showUpdateChildModal = false;
                this.showDeliveryButton = false;
                this.checkShowUpdateChildButtons();
                const evt = new ShowToastEvent({
                    title: this.label.deliveryChannelSuccess,
                    variant: "success"
                });
                this.dispatchEvent(evt);
            })
            .catch(error => {
                this.showUpdateChildModal = false;
                this.checkShowUpdateChildButtons();
                const evt = new ShowToastEvent({
                    title: this.label.deliveryChannelSuccess,
                    variant: "success"
                });
                this.dispatchEvent(evt);
            });
    }

    handleClickFrequency() {
        propagateFrequencyChange({ accountTreatmentJobId: this.job.Id })
            .then(result => {
                console.log('call done!');
                this.showFrequencyButton = false;
                this.showUpdateChildModal = false;
                this.checkShowUpdateChildButtons();
                const evt = new ShowToastEvent({
                    title: this.label.frequencySuccess,
                    variant: "success"
                });
                this.dispatchEvent(evt);
            })
            .catch(error => {
                this.showUpdateChildModal = false;
                this.checkShowUpdateChildButtons();
                const evt = new ShowToastEvent({
                    title: this.label.frequencySuccess,
                    variant: "success"
                });
                this.dispatchEvent(evt);
            });
    }

    handleClickShowChildModal() {
        this.showUpdateChildModal = true;
    }

    handleClickHideChildModal() {
        this.showUpdateChildModal = false;
    }

    checkShowUpdateChildButtons() {
        if (this.showDeliveryButton == true || this.showFrequencyButton == true) {
            this.showUpdateChildButton = true;
        } else {
            this.showUpdateChildButton = false;
        }
    }

    checkButtonsVisibility(){
        checkShowDeliveryButton({ accountTreatmentJobId: this.job.Id })
        .then(result => {
            this.showDeliveryButton = result;
            this.checkShowUpdateChildButtons();
        })
        .catch(error => {
            this.showUpdateChildModal = false;
            this.checkShowUpdateChildButtons();
        });
        checkShowFrequencyButton({ accountTreatmentJobId: this.job.Id })
        .then(result => {
            this.showFrequencyButton = result;
            this.checkShowUpdateChildButtons();
        })
        .catch(error => {
            this.showUpdateChildModal = false;
            this.checkShowUpdateChildButtons();
        });
    }

    handleScheduleActivities() {
        console.log('Schedule Activities clicked!');
        this.showScheduleActivitiesModal = true;
    }

    closeScheduleActivitiesModal() {
        this.showScheduleActivitiesModal = false;
    }

    handleActivitiesScheduled() {
        this.isScheduleActivitiesDisabled = true;
        const activitiesScheduledEvent = new CustomEvent('activitiesscheduled');
        this.dispatchEvent(activitiesScheduledEvent);
    }
}