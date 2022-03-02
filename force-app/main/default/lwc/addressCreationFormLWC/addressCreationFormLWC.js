import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ADDRESS_OBJECT from '@salesforce/schema/Account';
import COUNTRY_FIELD from '@salesforce/schema/Account.BillingCountryCode';
import PROVINCE_FIELD from '@salesforce/schema/Account.BillingStateCode';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class AddressCreationFormLWC extends LightningElement {

    @api street;
    @api city;
    @api postalcode ;
    @api statecode ;
    @api country ;
    @track addressRecordTypeId;

    countryOptions;
    provincevaluesoptions;

    picklistValues;

    @wire(getObjectInfo, { objectApiName: ADDRESS_OBJECT })
    getoObjectData({ error, data }) {
        if (data) {
            this.addressRecordTypeId = data.defaultRecordTypeId;
            console.log(data);
            console.log('defaultRecordTypeId: ' + data);
        } else if (error) {
            // perform your logic related to error 
        }
    };

    @wire(getPicklistValues, {
        recordTypeId: '$addressRecordTypeId',
        fieldApiName: COUNTRY_FIELD
    })
    getPicklistValues1({ error, data }) {
        if (data) {
            console.log(data.values);
          
            this.countryOptions = data.values;
            console.log('picklistValues!!!!!!!: ' + this.addressRecordTypeId);
        } else if (error) {
            // perform your logic related to error 
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$addressRecordTypeId',
        fieldApiName: PROVINCE_FIELD
    })
    getPicklistValuesprovince({ error, data }) {
        if (data) {
            console.log(data.values);    
            this.provincevalues = data ;
        } else if (error) {
            // perform your logic related to error 
        }
    }

    get getCountryOptions() {
        return this.countryOptions;
    }
    get getprovincevaluesoptions(){
        return this.provincevaluesoptions ;
    }



    handleClick() {
        console.log('street: ' + this.street);
        console.log('city: ' + this.city);
        console.log('picklist ' + this.picklistValues);
    }

    handleChange(event) {
       
     
        let key = this.provincevalues.controllerValues[event.detail.country];
        this.provincevaluesoptions = this.provincevalues.values.filter(opt => opt.validFor.includes(key));
        this.city = event.target.city;
        this.street = event.target.street;
        this.postalcode = event.target.postalCode ;
        this.statecode = event.target.province ;
        this.country = event.target.country ;
            // This is the event we use to notify flow
            const attributeChangeEventcity = new FlowAttributeChangeEvent('city', this.city  );
            this.dispatchEvent(attributeChangeEventcity);
            const attributeChangeEventstreet = new FlowAttributeChangeEvent('street', this.street  );
            this.dispatchEvent(attributeChangeEventstreet);
            const attributeChangeEventpostalcode = new FlowAttributeChangeEvent('postalcode', this.postalcode  );
            this.dispatchEvent(attributeChangeEventpostalcode);
            const attributeChangeEventstatecode = new FlowAttributeChangeEvent('statecode', this.statecode  );
            this.dispatchEvent(attributeChangeEventstatecode);
            const attributeChangeEventcountry = new FlowAttributeChangeEvent('country', this.country );
            this.dispatchEvent(attributeChangeEventcountry);

           
 
    }
  
        

}