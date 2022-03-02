import { LightningElement,wire,api,track } from 'lwc';
import getorderitemslist from "@salesforce/apex/customOrderProductEditController.getorderitemslist";
import getOrderStatus from '@salesforce/apex/customOrderProductEditController.getOrderStatus';

import ProductSelection from '@salesforce/label/c.CustomOrderProductPath_ProductSelection';
import QuantityConfiguration from '@salesforce/label/c.CustomOrderProductPath_QuantityConfiguration';
import PriceConfiguration from '@salesforce/label/c.CustomOrderProductPath_PriceConfiguration';
import box from '@salesforce/label/c.CustomOrderProductEdit_Box';
import Description from '@salesforce/label/c.CustomOrderProductEdit_Description';
import unitofmeasure from '@salesforce/label/c.CustomOrderProductEdit_unitofmeasure';
import Name from '@salesforce/label/c.CustomOrderProductEdit_Name';
import Quantity from '@salesforce/label/c.CustomOrderProductEdit_Quantity';
import { refreshApex } from "@salesforce/apex";

export default class CustomOrderProductEdit extends LightningElement {

 
    @track searchKey = '' ;
    @track preselectedproducts = [] ;
    @api orderId ;
    @track data  ;
    @track selectedproducts = [] ;
    @track selectedpricebookentry = [] ;
    @track orderSent = false ;
    @track orderStatus ;
    @track isLoading = false;


    renderedCallback(){
        console.log('orderid in price edit'+this.orderId);
        
         getOrderStatus({orderId: this.orderId}).then((result) => {
             console.log('order status'+JSON.stringify(result))
        
             if(result === 'Sent') {
                this.orderSent = true;
                console.log('Order is Sent!');
            } 
        })
        .catch(error => {
            this.error = error;
            console.log('Error while retrieving orderStatus: ' + this.error);
        }); 
       
        refreshApex(this.orderproducts);
        clearTimeout(this.timeoutId); 
        this.timeoutId = setTimeout(this.doExpensiveThing.bind(this), 5000);
        refreshApex(this.orderproducts);
        console.log('refreshed') ;

    }


    label = {
        unitofmeasure,
        box,
        Description,
        Name,
        Quantity,
        PriceConfiguration,
        QuantityConfiguration,
        ProductSelection


    };

    @wire(getorderitemslist, { orderId: "$orderId"}) 
    orderproducts;
    doExpensiveThing(){}

    handledeleteorderitem(){
        refreshApex(this.orderproducts);

    }
}