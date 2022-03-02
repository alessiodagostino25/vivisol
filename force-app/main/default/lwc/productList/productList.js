/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-console */
import { LightningElement, wire, track, api } from 'lwc';
import getSelectedProducts from '@salesforce/apex/ProductListController.getSelectedProducts';
import { refreshApex } from '@salesforce/apex';

import mainTitle from '@salesforce/label/c.AT_ProductConfigurationPage_MainTitle';

export default class ProductList extends LightningElement {


    @track searchKey = [];
    @api selectedjobid;
    @api selectedjobid2;
    @api product;
    @api jobname ;
    @track jobnametobold ;
    @track labelofmaintitle ;
    @api accounttreatmentstatus ;

    label ={
        mainTitle
    };

    renderedCallback() {
        clearTimeout(this.timeoutId); // no-op if invalid id
        this.timeoutId = setTimeout(this.doExpensiveThing.bind(this), 1000); // Adjust as necessary

        console.log('product list component')
        this.jobnametobold = this.jobname.bold();
        console.log('job name in bold'+this.jobnametobold)
        this.labelofmaintitle = this.label.mainTitle+this.jobnametobold ;
    }

    handlerefreshproduct() {
        refreshApex(this.products);
        console.log('refresh method worked')
    }

    doExpensiveThing() {
        this.selectedjobid2 = this.selectedjobid;
        console.log('selected job id' + this.selectedjobid2);
        refreshApex(this.products)
    }

    @wire(getSelectedProducts, { selectedjobid2: '$selectedjobid2' })
    products
}