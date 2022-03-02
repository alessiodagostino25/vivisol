import { LightningElement, api, wire } from 'lwc';
import {refreshApex} from '@salesforce/apex';
import getOrderItemIds from '@salesforce/apex/OrderItemCardListController.getOrderItemIds';
import getOrderStatus from '@salesforce/apex/OrderItemCardListController.getOrderStatus';
import ProductSelection from '@salesforce/label/c.CustomOrderProductPath_ProductSelection';
import QuantityConfiguration from '@salesforce/label/c.CustomOrderProductPath_QuantityConfiguration';
import PriceConfiguration from '@salesforce/label/c.CustomOrderProductPath_PriceConfiguration';

export default class OrderItemCardList extends LightningElement {

    @api orderId;
    @api isLoading = false ;
    //orderId = '8019E0000006wAbQAI'; //MOCK
    orderSent = false;
    orderStatus;
    showDeleteModal = false;

    label = {
    
        PriceConfiguration,
        QuantityConfiguration,
        ProductSelection

    };

    @wire(getOrderItemIds, {orderId: '$orderId'})
    orderItemIds;
    connectedCallback(){
        this.isLoading = true;
        setTimeout(() => {
            this.isLoading = false;
        }, 2000);
    }
    renderedCallback() {

        getOrderStatus({orderId: this.orderId}).then(result => {
          
            if(result === 'Sent') {
                this.orderSent = true;
                console.log('Order is Sent!');
            }
            refreshApex(this.orderItemIds);
        })
        .catch(error => {
            this.error = error;
            console.log('Error while retrieving orderStatus: ' + this.error);
        });

    }

    handleDeletedOrderItem() {
        refreshApex(this.orderItemIds);
        console.log('eliminato');
    }
}