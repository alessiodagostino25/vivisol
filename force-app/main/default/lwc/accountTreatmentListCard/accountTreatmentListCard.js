/* eslint-disable no-console */
import { LightningElement,track, wire } from 'lwc';
import getAccountTreatmentList from '@salesforce/apex/TreatmentListCardController.getAccountTreatmentList';
 
export default class AccountTreatmentListCard extends LightningElement {
        @track data ;
        @track error ;
        @track  columns = [
            { label: 'Patient Name', fieldName: 'Name' },
        
        ];
        
        
        @wire(getAccountTreatmentList)
        getlist(result) {
            this.result = result;
            if (result.data) {
                this.data = result.data;
                console.log('data is rendered')

     
            } else if (result.error) {
                this.error = result.error;
            }
        }

}