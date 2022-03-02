import { LightningElement, api, track } from 'lwc';
import getQuoteLineItemByIdsMethod from '@salesforce/apex/QuoteLineItemController.getQuoteLineItemByIds';
//import { refreshApex } from '@salesforce/apex';
import backButton from '@salesforce/label/c.createQuoteLineItem_BackButton';
import labelNextButton from '@salesforce/label/c.createQuoteLineItem_NextButton';
export default class QuoteLineItemConfigurePriceQuantity extends LightningElement {

    @api page2=false;
    @api page1;
    @api page3;
    @api recordId;
    @api listItems = [];
    @api selectedProducts;
    @api quoteLineItemsCreated = [];
    @api quoteLineItemId;
    @api productId;
    @api recordsToAnalize;
    @api quoteStatus;
    @api reloadStep2=false;
    @api isLoading = false;
    
    label = {labelNextButton,backButton};

    renderedCallback(){        
        if(this.page2 && this.reloadStep2){            
          this.reloadStep2 = false;
          this.isLoading = true;
            setTimeout(() => {
                this.isLoading = false;
            }, 2000);
              
        }
    }

    nextStep(event){
        var next = true;

        this.template.querySelectorAll('c-quote-line-item-configuration-detail').forEach(element => {
            next &= element.checkRequiredField();
        });

        if(next){
            this.template.querySelectorAll('c-quote-line-item-configuration-detail').forEach(element => {
                element.handleSubmit();
            }); 
            const quoteLineCreated = new CustomEvent("nextbuttonstep", 
            {  detail: {recordsToAnalizeStep3: this.recordsToAnalize }
            });
            this.dispatchEvent(quoteLineCreated);
        } 

    }

    handleBack() {        
        this.page2 = false;
        const exitpricequantity = new CustomEvent('exitpricequantity', {
            detail: this.page2   
        });
        this.dispatchEvent(exitpricequantity); 
        
    }

    handleDeleteQuote(event){
        console.log('quoteLineItemConfigurePriceQuantity.handleDeleteQuote...');
        this.isLoading = true;
        var itemIdToDelete = event.detail;
        let remainItemId= [];

        for( var i = 0; i < this.recordsToAnalize.length; i++){
            if(this.recordsToAnalize[i].Id != itemIdToDelete) {                    
                remainItemId.push(this.recordsToAnalize[i].id);
            }
        }

        getQuoteLineItemByIdsMethod({
            quoteLineItemsIds: remainItemId
        })
        .then(result => {
            this.recordsToAnalize = result;
            this.isLoading = false;
            //refreshApex(this.recordsToAnalize);
        })
        .catch((error) => {
            /* var message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
                console.log('ERROR '+ message); */
            console.log('ERROR');
            console.log(JSON.stringify(error));
        });
    }
}