import { LightningElement,wire, track, api } from 'lwc';
import getorderproducts from "@salesforce/apex/CustomOrderProductsSelectionController.getorderproducts";
import createorderproducts from "@salesforce/apex/CustomOrderProductsSelectionController.createorderproducts";
import ProductSelection from '@salesforce/label/c.CustomOrderProductPath_ProductSelection';
import QuantityConfiguration from '@salesforce/label/c.CustomOrderProductPath_QuantityConfiguration';
import PriceConfiguration from '@salesforce/label/c.CustomOrderProductPath_PriceConfiguration';


import mainTitle from '@salesforce/label/c.CustomOrderProductsSelection_MainTitle';
import ProductName from '@salesforce/label/c.CustomOrderProductsSelection_ProductName';
import ProductCode from '@salesforce/label/c.CustomOrderProductsSelection_ProductCode';
import ProductFamily from '@salesforce/label/c.CustomOrderProductsSelection_ProductFamily';
import Manufacturerpartnumber from '@salesforce/label/c.CustomOrderProductsSelection_Manufacturer_Part_Number';
import { refreshApex } from "@salesforce/apex";


export default class CustomOrderProductSelection extends LightningElement {

    @api orderId;
    @track searchKey = '';
    @track preselectedproducts = [];
    @track orderId;
    @track data;
    @track selectedproducts = [];
    @track selectedpricebookentry = [];
    @track checkboxvalue;
    @track selectedproductidvalue;
    @track isLoading = false;

    label = {
        mainTitle,
        ProductName,
        ProductCode,
        ProductFamily,
        Manufacturerpartnumber,
        PriceConfiguration,
        QuantityConfiguration,
        ProductSelection
    };

    @wire(getorderproducts, { orderId: "$orderId", searchKey: "$searchKey" ,preselectedproducts :"$preselectedproducts"}) 
    orderproducts;

    renderedCallback(){
        let searchBarInput = this.template.querySelector('lightning-input');

        if(searchBarInput) {
            searchBarInput.focus();
        }

        refreshApex(this.orderproducts);
        console.log('orderid: ' + this.orderId);
    }


    @api createproducts(){
        this.isLoading = true;

        createorderproducts({
            orderId: this.orderId,
            selectedproducts: this.selectedproducts,
            selectedpricebookentry : this.selectedpricebookentry
        }).then(() => {
            this.isLoading = false;

            const productCreationFinishedEvent = new CustomEvent('creationfinished');
            this.dispatchEvent(productCreationFinishedEvent);
        })
        .catch(error => {
            this.isLoading = false;
            // eslint-disable-next-line no-console
            console.log(error);
        });
    }

    allSelected(event) {
        console.log('ALL SELECTED');

        let selectedRows = this.template.querySelectorAll('lightning-input');
        let allChecked = event.target.checked;

        console.log('allChecked? ' + allChecked);
        if(allChecked) {
            for(let i = 0; i < selectedRows.length; i++) {
                if(selectedRows[i].type === 'checkbox') {
                    selectedRows[i].checked = event.target.checked;
                    let productIdValue = selectedRows[i].value;

                    if(productIdValue != null && productIdValue != undefined && productIdValue.length > 0) {
                        if(!this.selectedproducts.includes(this.productIdValue)) {
                            console.log('Pushing ' + productIdValue + ' in selectedProducts...');
                            this.selectedproducts.push(productIdValue);
                        }
                    }
                }
            }

            const checkboxselectednextactivated = new CustomEvent('mycheckboxselectednextactivated', {detail: this.orderId});
            this.dispatchEvent(checkboxselectednextactivated);
        }
        else {
            for (let i = 0; i < selectedRows.length; i++) {
                if (selectedRows[i].type === 'checkbox') {
                    selectedRows[i].checked = this.allChecked;

                }
            }
            this.selectedproducts = [];

            const checkboxselectednextdeactivated = new CustomEvent('mycheckboxselectednextdeactivated', {detail: this.orderId});
            this.dispatchEvent(checkboxselectednextdeactivated);
        }
    }

    checkboxisselected(event){
        this.checkboxvalue =  event.target.checked;
        this.selectedproductidvalue = event.target.value ;

        if(this.checkboxvalue){
            if(!this.selectedproducts.includes(this.selectedproductidvalue)) {
                this.selectedproducts.push(event.target.value)
                console.log('checkboxselected id '+event.target.value)
            }

            const checkboxselectednextactivated = new CustomEvent('mycheckboxselectednextactivated', {detail: this.orderId});
            this.dispatchEvent(checkboxselectednextactivated);
        }
        else{
            this.selectedproducts = this.selectedproducts.filter(x => {
                return x != this.selectedproductidvalue ;
            })

            if(this.selectedproducts.length  < 1){
                const checkboxselectednextdeactivated = new CustomEvent('mycheckboxselectednextdeactivated', {detail: this.orderId});
                this.dispatchEvent(checkboxselectednextdeactivated);
            }
        }
    }

    handleKeyChange(event){

        const searchKey = event.target.value;
        this.searchKey = searchKey;
        console.log('searchvalue'+this.searchKey);

        let selectedRows = this.template.querySelectorAll('lightning-input');

        this.preselectedproducts = [];

        // based on selected row getting values of the contact
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].checked && selectedRows[i].type === 'checkbox') {
           
                this.preselectedproducts.push(selectedRows[i].value)
                console.log('asdfadsf'+selectedRows[i].value)
            }
        }
    }
    
}