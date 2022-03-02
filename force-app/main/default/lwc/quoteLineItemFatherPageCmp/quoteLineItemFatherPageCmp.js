import { LightningElement, api, track, wire } from 'lwc';
import labelTitleWizard from '@salesforce/label/c.createQuoteLineItem_TitleWizard';
import getQuoteLineItemsMethod from '@salesforce/apex/QuoteLineItemController.getQuoteLineItems';
import getAllProductsMethod from '@salesforce/apex/QuoteLineItemController.getAllProducts';

export default class QuoteLineItemFatherPageCmp extends LightningElement {
       
    @api currentStep = 'step-1';
    @api recordId;
    @api mode;
    @api reloadStep1 = false;
    @api reloadStep2;
    @api reloadStep3;
    @api quoteStatus;

    @api finishClicked=false;
    
    @api recordsToAnalize;
    @track page1 = true;
    @track page2=false;
    @track page3=false;

    @api listItems;
    @api isButtonDisabled;
    @api searchData;
    @api totalProducts;
    @api selected;
    @api selectedProducts = [];
    @api strSearchProductName;
    

    label = {labelTitleWizard};

    connectedCallback() {        
        document.title = "Quote " + this.recordId;    
        console.log('--- quoteStatus: ' + this.quoteStatus);
    }

    renderedCallback(){
        document.title = "Quote " + this.recordId;
    }

    //Next function, verified all next button
    next() {
        if (this.page1 === true) {
            this.page1 = false;
            this.page2 = true;
            this.reloadStep2 = true;    
            this.page3 = false;
            this.reloadStep3 = false; 
            this.currentStep = 'step-2';
        } else if (this.page2 === true) {
            this.page1 = false;
            this.page2 = false;
            this.reloadStep2 = false;    
            this.page3 = true;
            this.reloadStep3 = true; 
            this.currentStep = 'step-3';
        } else if (this.page3 === true) {
            this.page3 = false;
            this.reloadStep3 = false; 
            
        }
    }

    //Back function, verified all back button
    back() {
        if (this.page2 === true) {
            this.selectedProducts = [];
            this.strSearchProductName = '';
            getQuoteLineItemsMethod({quoteId : this.recordId})
            .then(result => {      
                this.listItems = result;
                if(result.length > 0){
                    this.mode = 'edit';
                    this.isButtonDisabled = false; 
                } else {
                    this.mode = 'create';
                    this.isButtonDisabled = true;
                }

                getAllProductsMethod({id : this.recordId, pricebookentryList:  this.selectedProducts})
                    .then(result => {                        
                        this.searchData = result;     
                        this.totalProducts = 0;
                        this.totalProducts = this.searchData.length;
                        this.selected = 'Show Selected (' + this.selectedProducts.length + '/' + this.totalProducts +  ')';

                        this.page3 = false;
                        this.reloadStep3 = false; 
                        this.page2 = false;
                        this.reloadStep2 = false;    
                        this.page1 = true;
                        this.currentStep = 'step-1';


                        console.log('BACK: ' + this.currentStep);
                    })
                    .catch(error => {
                        this.searchData = undefined;
                        window.console.log('error  ' + error);
                        if(error) {
                            console.log('Error message: ' + error.body.message);
                        }
                    })
            })
            .catch(error => {           
                window.console.log('error  ' + error);
                if(error) {
                    console.log('Error message: ' + error.body.message);
                }
            })
            
        } else if (this.page3 === true) {
            this.page1 = false;
            this.page3 = false;
            this.reloadStep3 = false; 
            this.page2 = true;
            this.reloadStep2 = true;    
            this.currentStep = 'step-2';
        }
    }


    //The function (Next button step 1) close the first step to open second step
    handlenextbuttonsteptwo(event){             
        this.recordsToAnalize = event.detail;
        this.next();
    }

    //The function (Next button step 2) close the second step to open third step
    handlenextbuttonstepthree(event){  
        this.recordsToAnalize = event.detail.recordsToAnalizeStep3;      
        this.next();
    }

    //The function (Back button step 2) exit the second step to open the first step
    handleExitPriceQuantity(event){        
        this.back();
        this.currentStep = 'step-1';
        
    }

    //The function (Back button step 3) exit the third step to open the second step
    handleExitPriceEdit(event){  
        this.recordsToAnalize = event.detail;  
        this.back();
        this.currentStep = 'step-2';
    }


    //Finish event, close tab and redirect to Father
    closeclicked(event){        
        this.finishClicked = event.detail;
        
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: this.finishClicked
        });
         this.dispatchEvent(closeclickedevt); 
         //eval("$A.get('e.force:refreshView').fire();");

    }
}