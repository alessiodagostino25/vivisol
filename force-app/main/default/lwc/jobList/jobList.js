/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-console */

import { LightningElement, wire, track, api } from 'lwc';
import getselectJobs from '@salesforce/apex/JobListController.getselectJobs';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { refreshApex } from '@salesforce/apex';
import getaccounttreatmentstatus from "@salesforce/apex/JobListController.getaccounttreatmentstatus";
import getAccountTreatmentName from "@salesforce/apex/accountTreatmentJobSelectionController.getAccountTreatmentName";

import mainTitle from '@salesforce/label/c.AT_AccountTreatmentJobList_MainTitle';

export default class jobList extends LightningElement {

    selecjobs = [];
    @track jobs;
    @api recordid;
    @api recordid2;
    @api selectedrecordtype;
    @api accounttreatmentstatus ; 
    @api showAddressSelectionPage;
    @track i = 0 ;
    @track atstatus = [] ;
    @track nameofaccounttreatment;

    label = {
        mainTitle
    };

    @wire(getselectJobs, { recordid2: "$recordid2" })
    jobs;

    @wire(getAccountTreatmentName,{ atid : "$recordid"})
    nameofat({data}){
      if(data){
        console.log('data of name '+JSON.stringify(data))
        this.nameofaccounttreatment = data[0].Name ;
        console.log('name of atid'+this.nameofaccounttreatment)
        }
    }

    @wire(CurrentPageReference) 
    pageRef;

    connectedCallback() {
        registerListener('selectedjobs', this.handleselectedjobs, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    renderedCallback() {
        if(this.i < 1) {
            getaccounttreatmentstatus({
                atid: this.recordid
            })
            .then((result) => 
                {
                    this.atstatus = result ; 
                    console.log('Account Treatment Id: ' + this.recordid);
                    console.log('Account Treatment RecordType: ' + this.selectedrecordtype);
                    console.log('status of accout treatment'+result) ;
                    console.log('status of accout treatment'+this.atstatus[0].Status__c ) ;
                    console.log('status of accout treatment'+JSON.stringify(this.atstatus)) ;
                    console.log('status of accout treatment'+JSON.stringify(result)) ;
                    if(this.atstatus[0].Status__c != 'W'){

                        this.accounttreatmentstatus = true ;
                    }else{
                        this.accounttreatmentstatus = false ;

                    }
                    
                
            }).catch(error => {
                this.error = error;
                console.log('ERROR IN DELETING RECORD: ' + this.error);
            });

            this.i = 1 ;
        }

        clearTimeout(this.timeoutId); // no-op if invalid id
        this.timeoutId = setTimeout(this.doExpensiveThing.bind(this), 500); // Adjust as necessary
        return refreshApex(this.jobs);
    }

    @api
    passAccountTreatmentName() {
        return this.nameofaccounttreatment;
    }

    doExpensiveThing() {
        // Do something here
        this.recordid2 = this.recordid;
    }

    handledeleterefresh() {
        refreshApex(this.jobs);
        console.log('refresh method worked')
    }

    handleselectedjobs(value) {
        let JSONObj = JSON.stringify(value)
        console.log(JSONObj);

        this.selecjobs = JSONObj;

        console.log(this.selecjobs);
        // eslint-disable-next-line no-undef
    }

    handleActivitiesScheduled() {
        const activitiesScheduledEvent = new CustomEvent('activitiesscheduled');
        this.dispatchEvent(activitiesScheduledEvent);
    }
}