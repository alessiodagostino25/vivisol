import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

// Labels
import View from "@salesforce/label/c.Generic_View";
import Preview from "@salesforce/label/c.WAMFile_Preview";

// Apex actions
import getDocumentIdToShow from "@salesforce/apex/WAMFileRetrievalController.getDocumentIdToShow";

// Other stuff
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class WamFileRetrieval extends NavigationMixin(LightningElement) {
    labels = {
        View,
        Preview
    }

    @api recordId;

    @track isLoading;
    @track contentDocumentIds;

    connectedCallback() {
        console.log('WAMFileRetrieval connected...');

        this.isLoading = true;

        // Getting the Document Ids to show (via API call to WAM or via query if already present)

        getDocumentIdToShow({
            storedDocumentId: this.recordId
        }).then((result) => {
            console.log(result);

            if(result != undefined && result != null) {
                if(this.contentDocumentIds === undefined || this.contentDocumentIds === null || this.contentDocumentIds.length === 0) {
                    this.contentDocumentIds = result;
                }
                else {
                    this.contentDocumentIds = this.contentDocumentIds + ',' + result;
                }
            }
            
            console.log('contentDocumentIds after retrieve: ' + this.contentDocumentIds);
            this.isLoading = false;
        }).catch((error) => {
            const evt = new ShowToastEvent({
                title: "Error",
                message: "An error occurred while trying to retrieve this document",
                variant: "error"
            });
            this.dispatchEvent(evt); 

            console.log('ERROR: ');
            console.log(error);

            this.isLoading = false;
        });
    }

    handleViewClick() {
        if(this.contentDocumentIds != null && this.contentDocumentIds != undefined) {
            this.navigateToFiles();
        }
        else {
            const evt = new ShowToastEvent({
                title: "No document found",
                variant: "error"
            });
            this.dispatchEvent(evt); 
        }
    }

    // Navigating to file preview of given Ids

    navigateToFiles() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                recordIds: this.contentDocumentIds
            }
        });
    }
}