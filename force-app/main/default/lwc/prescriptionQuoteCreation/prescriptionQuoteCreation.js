import { LightningElement, api } from 'lwc';

// Labels
import InformationLabel from '@salesforce/label/c.CT_ProductConfigurationModal_SectionInformation';
import ProductLabel from '@salesforce/label/c.SectionTitle_Product';
import SaveLabel from '@salesforce/label/c.createQuoteLineItem_SaveButton';
import NewQuoteLabel from '@salesforce/label/c.Generic_New_Quote';
import UnitOfMeasureLabel from '@salesforce/label/c.Generic_Unit_Of_Measure';
import QuantityLabel from '@salesforce/label/c.CT_ProductConfigStep_TableQuantity';
import NoElementsLabel from '@salesforce/label/c.Generic_NoElements';

// Apex actions
import getPrescription from '@salesforce/apex/PrescriptionQuoteCreationController.getPrescription';
import getWOLIs from '@salesforce/apex/PrescriptionQuoteCreationController.getWOLIs';
import createQuoteAndItems from '@salesforce/apex/PrescriptionQuoteCreationController.createQuoteAndItems';

const COLUMNS_SALES = [
    { label: 'Work Order Line Item', fieldName: 'numberValue', type: 'text' },
    { label: ProductLabel, fieldName: 'productNameTranslate', type: 'text', wrapText: true},
    { label: QuantityLabel, fieldName: 'quantity', type: 'number', cellAttributes: { alignment: "left" }},
    { label: UnitOfMeasureLabel, fieldName: 'unitOfMeasure', type: 'text', cellAttributes: { alignment: "left" }},
    {
        /* initialWidth: 30, */
        type: 'button-icon',
        typeAttributes:
        {
            iconName: 'utility:delete',
            name: 'delete',
            iconClass: 'slds-icon-text-error'
        }
    }
];

export default class PrescriptionQuoteCreation extends LightningElement {
    labels = {
        InformationLabel,
        SaveLabel,
        NewQuoteLabel,
        NoElementsLabel
    };
    salesRT = 'SALES';
    isLoading = true;
    prescription;
    quoteName;
    quoteContractFrameworkId;
    quoteApproverId;
    quoteAccountBillTo;
    quoteAccountSoldTo;
    quoteShipTo;
    quoteLocationId;
    quoteApprovalPeriod;
    workOrderLineItems = [];
    tableData;
    columns;
    formFields;

    @api recordId;

    get isTableEmpty() {
        if(this.tableData) {
            return (this.tableData.length <= 0);
        }

        return true;
    }

    connectedCallback() {
        console.log('prescriptionQuoteCreation connected...');
        console.log('recordId: ' + this.recordId);

        getPrescription({
            prescriptionId: this.recordId
        }).then(result => {
            this.prescription = result;

            console.log('PRESCRIPTION:');
            console.log(this.prescription);

            if(this.prescription) {
                if(this.prescription.name && this.prescription.patient) {
                    this.quoteName = this.prescription.name + ' - ' + this.prescription.patient.externalId;
                    this.quoteShipTo = this.prescription.patient.id;
                }

                if(this.prescription.contractFramework) {
                    this.quoteContractFrameworkId = this.prescription.contractFramework.id;
                    this.quoteAccountSoldTo = this.prescription.contractFramework.customerId;
                }

                this.quoteApproverId = this.prescription.approverId;
                this.quoteAccountBillTo = this.prescription.billTo;
                this.quoteLocationId = this.prescription.addressId;

                /* if(!this.prescription.previousId || (this.prescription.previousId).length == 0) {
                    this.quoteApprovalPeriod = '1';
                } */

                // Setting up the datatable based on the RecordType (thus changing columns and tableData)

                if(this.prescription.recordType.developerName == this.salesRT) {
                    console.log(JSON.stringify(this.prescription));

                    this.columns = COLUMNS_SALES;

                    getWOLIs({
                        prescriptionJSON: JSON.stringify(this.prescription)
                    }).then(result => {
                        console.log('WOLIs: ');
                        console.log(result);
                        this.tableData = result;

                        this.isLoading = false;
                    }).catch(error => {
                        console.log('ERROR:');
                        console.log(JSON.stringify(error));
            
                        this.isLoading = false;
                    });
                }
                else {
                    // TODO
                }
            }
        }).catch(error => {
            console.log('ERROR:');
            console.log(JSON.stringify(error));

            this.isLoading = false;
        });
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    handleSave() {
        console.log('handleSave...');

        if(this.prescription.recordType.developerName == this.salesRT) {
            // this.template.querySelector('lightning-record-edit-form').submit();
            this.template.querySelector('lightning-button').click();
        }
    }

    handleRowAction(event) {
        console.log('action: ' + event.detail.action.name);
        console.log('row id: ' + event.detail.row.id);

        let action = event.detail.action.name;
        let rowId = event.detail.row.id;

        if(action == 'delete') {
            console.log('Removing row ' + rowId);
            this.tableData = this.tableData.filter(x => x.id != rowId);
        }
    }

    handleFormSubmit(event) {
        console.log('handleFormSubmit...');
        event.preventDefault();
        this.formFields = event.detail.fields;
        
        // TODO quote creation

        createQuoteAndItems({
            prescriptionJSON: JSON.stringify(this.prescription),
            fieldMap: this.formFields
        }).then({
            // TODO
        }).catch(error => {
            console.log('ERROR:');
            console.log(JSON.stringify(error));
        });
    }
}