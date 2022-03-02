import { LightningElement,track , wire ,api } from 'lwc';
import getOrderProductList from '@salesforce/apex/customOrderRelatedListController.getOrderProductList';

export default class CustomOrderRelatedList extends LightningElement {

    @api orderId ;
    @track orderId2 ;
    @track data ;


    @track actions = [
        { label: 'Link Asset', name: 'Link Asset' },
        { label: 'Delete', name: 'delete' },
    ];


    @track  columns = [
        { label: 'Product', fieldName: 'Product2.Product_Name_Translate__c',  type: "text" },
        { label: 'Product Code', fieldName: 'Product2.Product_Code__c',  type: "text" },
        { label: 'Quantity', fieldName: 'Quantity' ,  type: "number" },
        { label: 'UnitPrice', fieldName: 'UnitPrice' ,  type: "number"},
        { label: 'TotalPrice', fieldName: 'TotalPrice',  type: "number" },

        { 
            type: 'button',
            typeAttributes:  {
                label: 'LinkAsset', 
                name: 'LinkAsset', 
                title: 'LinkAsset', 
                disabled: false, 
              },
        },
        {
            type: 'action',
            typeAttributes: { rowActions: this.actions },
        },

    
    ];

    

   

    renderedCallback(){
        console.log('order id '+this.orderId) ;
    
    }

  
    
    @wire(getOrderProductList,{orderId : "$orderId" })
    getlist(result) {
        this.result = result;
        if (this.result.data) {
            this.data =  this.result.data;
            console.log('data is rendered')
            console.log('data for order list'+JSON.stringify(this.data) ) ;

 
        } else if (result.error) {
            this.error = result.error;
        }
    }

    
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.deleteRow(row);
                break;
            case 'show_details':
                this.showRowDetails(row);
                break;
            default:
        }
    }

    deleteRow(row) {
        const { id } = row;
        const index = this.findRowIndexById(id);
        if (index !== -1) {
            this.data = this.data
                .slice(0, index)
                .concat(this.data.slice(index + 1));
        }
    }

    findRowIndexById(id) {
        let ret = -1;
        this.data.some((row, index) => {
            if (row.id === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }

    showRowDetails(row) {
        this.record = row;
    }





}