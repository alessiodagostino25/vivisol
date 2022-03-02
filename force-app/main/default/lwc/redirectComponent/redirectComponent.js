import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class RedirectComponent extends NavigationMixin(LightningElement) {

    @api redirectrecordid;

    connectedCallback() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.redirectrecordid,
                actionName: 'view'
            },
        });
    }
}