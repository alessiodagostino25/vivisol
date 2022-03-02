import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Labels
import ScheduleActivitiesButtonLabel from '@salesforce/label/c.ATJ_ScheduleActivities_Button';
import TaskStartDateLabel from '@salesforce/label/c.ATJ_ScheduleActivities_TaskStartDate';
import WorkOrderStartDateLabel from '@salesforce/label/c.ATJ_ScheduleActivities_WorkOrderStartDate'
import CancelButtonLabel from '@salesforce/label/c.Btn_Cancel';
import AutoschedulingInProgressTitle from '@salesforce/label/c.Autoscheduling_InProgress_Title';
import AutoschedulingInProgressMessage from '@salesforce/label/c.Autoscheduling_InProgress_Message';
import AutoschedulingErrorTitle from '@salesforce/label/c.Autoscheduling_Error_Title';
import InvalidDatesTitleLabel from '@salesforce/label/c.ATJ_ScheduleActivities_InvalidDates_Title';
import InvalidDatesMessageLabel from '@salesforce/label/c.ATJ_ScheduleActivities_InvalidDates_Message';

// Apex actions
import getTodayDatetime from '@salesforce/apex/ATMainComponentController.getTodayDatetime';
import getATJ from '@salesforce/apex/ATJScheduleActivitiesController.getATJ';
import scheduleActivities from '@salesforce/apex/ATJScheduleActivitiesController.scheduleActivities';

export default class AtjScheduleActivitiesModal extends LightningElement {
    labels = {
        ScheduleActivitiesButtonLabel,
        TaskStartDateLabel,
        WorkOrderStartDateLabel,
        CancelButtonLabel
    };
    accountTreatmentJob;
    startDatetimeWO;
    startDatetimeTask;
    todayDatetime;

    @track isLoading = true;
    @track showTaskStartDate = false;
    @track showWorkOrderStartDate = false;

    @api accountTreatmentJobId;

    get todayDatetime() {
        return 
    }

    connectedCallback() {
        console.log('atjScheduleActivitiesModal connected...');

        getTodayDatetime().then(result => {
            this.todayDatetime = result;
            /* this.startDatetimeTask = result;
            this.startDatetimeWO = result; */

            getATJ({
                accountTreatmentJobId: this.accountTreatmentJobId
            }).then(result => {
                this.accountTreatmentJob = result;
                console.log('accountTreatmentJob: ' + JSON.stringify(this.accountTreatmentJob));
    
                this.showTaskStartDate = this.accountTreatmentJob.Task__c;
                this.showWorkOrderStartDate = this.accountTreatmentJob.Work_Order__c;

                if(this.showTaskStartDate) {
                    this.startDatetimeTask = this.todayDatetime;
                }
                if(this.showWorkOrderStartDate) {
                    this.startDatetimeWO = this.todayDatetime;
                }

                this.isLoading = false;
            }).catch(error => {
                console.log('ERROR');
                console.log(JSON.stringify(error));
                
                this.isLoading = false;
            });
        }).catch(error => {
            console.log('ERROR');
            console.log(JSON.stringify(error));
        });
    }

    handleTaskDateChange(event) {
        this.startDatetimeTask = event.detail.value;
        console.log('startDatetimeTask: ' + this.startDatetimeTask);
    }

    handleWODateChange(event) {
        this.startDatetimeWO = event.detail.value;
        console.log('startDatetimeWO: ' + this.startDatetimeWO);
    }

    closeModal() {
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }

    scheduleActivities() {
        console.log('Scheduling activities for ATJ ' + this.accountTreatmentJobId + '...');
        console.log('startDatetimeWO: ' + this.startDatetimeWO);
        console.log('startDatetimeTask: ' + this.startDatetimeTask);

        if((this.startDatetimeWO != undefined && this.startDatetimeWO != null && this.startDatetimeTask != null && this.startDatetimeTask != undefined && 
        this.startDatetimeTask <= this.startDatetimeWO) ||
        (this.startDatetimeWO == null && this.startDatetimeTask != null) || 
        (this.startDatetimeWO != null && this.startDatetimeTask == null)) {
            this.isLoading = true;

            scheduleActivities({
                accountTreatmentJobId: this.accountTreatmentJobId,
                startDatetimeWO: this.startDatetimeWO,
                startDatetimeTask: this.startDatetimeTask
            }).then(() => {
                const evt = new ShowToastEvent({
                    title: AutoschedulingInProgressTitle,
                    message: AutoschedulingInProgressMessage,
                    variant: "success"
                });
                this.dispatchEvent(evt);

                const activitiesScheduledEvent = new CustomEvent('activitiesscheduled');
                this.dispatchEvent(activitiesScheduledEvent);

                this.closeModal();
                this.isLoading = false;
            }).catch(error => {
                console.log('ERROR IN AUTOSCHEDULING ACTIVITIES');
                console.log(JSON.stringify(error));

                const evt = new ShowToastEvent({
                    title: AutoschedulingErrorTitle,
                    variant: "error"
                });
                this.dispatchEvent(evt);

                this.isLoading = false;
            });
        }
        else {
            const evt = new ShowToastEvent({
                title: InvalidDatesTitleLabel,
                message: InvalidDatesMessageLabel,
                variant: "warning"
            });
            this.dispatchEvent(evt);
        }
    }
}