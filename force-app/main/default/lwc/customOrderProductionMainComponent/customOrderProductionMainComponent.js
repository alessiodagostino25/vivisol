import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import backButton from '@salesforce/label/c.AT_BackButton';
import nextButton from '@salesforce/label/c.AT_NextButton';
import finishButton from '@salesforce/label/c.AT_FinishButton';
import HeaderTitle from '@salesforce/label/c.CustomOrderProduct_HeaderTitle';
import numberoforderproducts from "@salesforce/apex/CustomOrderProductsSelectionController.numberoforderproducts";
import { refreshApex } from "@salesforce/apex";

export default class CustomOrderProductionMainComponent extends NavigationMixin(LightningElement) {

    label = {
        nextButton,
        backButton,
        finishButton,
        HeaderTitle
    };

    @track component1 = true;
    @track component2 = false;
    @track component3 = false;
    @track isdisablednext = true;
    @track ineditmode = false;
    @track numberoforderproductsdata = [];

    @api recordId;

    renderedCallback() {
        //refreshApex(this.numberoforderproducts);

        numberoforderproducts({
            orderId: this.recordId
        }).then(result => {
            console.log('number of products ' + JSON.stringify(result))
            console.log('length of orderitems' + result.length)


            if (result.length >= 1) {
                this.isdisablednext = false;
                this.ineditmode = true;

            }
        })
    }
    /* @wire(numberoforderproducts, { orderId: "$recordId" })
    numberoforderproducts({ data }) {
        if (data) {

            console.log('number of products ' + JSON.stringify(data))
            console.log('length of orderitems' + data.length)


            if (data.length >= 1) {
                this.isdisablednext = false;
                this.ineditmode = true;

            }
        }
    } */

    handlenextbutton() {
        this.isdisablednext = false;
    }

    handlenextbuttondeactivation() {
        if (this.ineditmode == false) {
            this.isdisablednext = true;
        }
    }

    nextMethod() {
        // eslint-disable-next-line no-console
        console.log('nextbutton is clicked');
        if (this.component2 === true) {
            this.component1 = false;
            this.component2 = false;
            this.component3 = true;
        }

        if (this.component1 === true) {
            // After finishing, customOrderProductSelection will send an event handled by handleFinishedProductsCreation to go to the next page

            this.template.querySelector("c-custom-order-product-selection").createproducts();
        }
    }

    backMethod() {

        if (this.component2 === true) {
            this.component1 = true;
            this.component2 = false;
            this.component3 = false;
        }
        if (this.component3 === true) {
            this.component1 = false;
            this.component2 = true;
            this.component3 = false;
        }
    }


    handleFinishClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Order',
                actionName: 'view'
            },
        });
        const closeclickedevt = new CustomEvent('closetabclicked', {
            detail: { close },
        });

        // Fire the custom event
        this.dispatchEvent(closeclickedevt);

        console.log('this navigation executed');
    }

    handleFinishedProductsCreation() {
        this.component1 = false;
        this.component2 = true;
        this.component3 = false;
    }

}