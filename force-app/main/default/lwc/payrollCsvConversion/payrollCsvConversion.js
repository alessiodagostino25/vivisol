import { LightningElement, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Apex actions
import convertCSV from '@salesforce/apex/PayrollCSVConversionController.convertCSV';

// Labels
import InvalidYearTitle from '@salesforce/label/c.PayrollCSVConversion_InvalidYear_Title';
import SuccessToastTitle from '@salesforce/label/c.PayrollCSVConversion_SuccessToast_Title';
import SuccessToastMessage from '@salesforce/label/c.PayrollCSVConversion_SuccessToast_Message';
import HeaderTitle from '@salesforce/label/c.PayrollCSVConversion_Header_Title';
import FileUploadLabel from '@salesforce/label/c.PayrollCSVConversion_FileUpload_Label';
import ButtonLabel from '@salesforce/label/c.PayrollCSVConversion_Button_Label';

export default class PayrollCsvConversion extends LightningElement {
    labels = {
        InvalidYearTitle,
        SuccessToastTitle,
        SuccessToastMessage,
        HeaderTitle,
        FileUploadLabel,
        ButtonLabel
    };
    uploadedContentDocumentId;
    selectedMonth;
    selectedYear;
    selectedCompanyId;

    @track isLoading = false;

    get acceptedFormats() {
        return ['.csv'];
    }

    get isButtonDisabled() {
        if(this.selectedMonth != null && this.selectedMonth != undefined && this.selectedMonth != '' && this.selectedYear != null && this.selectedYear != undefined && 
            this.selectedYear != '' && this.selectedCompanyId != null && this.selectedCompanyId != undefined && this.selectedCompanyId != '' && 
            this.uploadedContentDocumentId != null && this.uploadedContentDocumentId != undefined) {
                return false;
        }
        
        return true;
    }

    connectedCallback() {
        console.log('payrollCsvConversion connected...');
    }

    handleConvertClick() {
        console.log('Selected Month: ' + this.selectedMonth);
        console.log('Selected Year: ' + this.selectedYear);
        console.log('Selected Company: ' + this.selectedCompanyId);
        console.log('Uploaded ContentDocumentId: ' + this.uploadedContentDocumentId);

        if(this.selectedMonth != null && this.selectedMonth != undefined && this.selectedMonth != '' && this.selectedYear != null && this.selectedYear != undefined && 
            this.selectedYear != '' && this.selectedCompanyId != null && this.selectedCompanyId != undefined && this.selectedCompanyId != '' && 
            this.uploadedContentDocumentId != null && this.uploadedContentDocumentId != undefined) {
                if(this.selectedYear.length != 4) {
                    const evt = new ShowToastEvent({
                        title: InvalidYearTitle,
                        variant: "warning"
                    });
                    this.dispatchEvent(evt);
                }
                else {
                    this.isLoading = true;

                    // Converting CSV

                    convertCSV({
                        contentDocumentId: this.uploadedContentDocumentId,
                        month: this.selectedMonth,
                        year: this.selectedYear,
                        companyId: this.selectedCompanyId
                    }).then(() => {
                        const evt = new ShowToastEvent({
                            title: SuccessToastTitle,
                            message: SuccessToastMessage,
                            variant: "success"
                        });
                        this.dispatchEvent(evt);

                        this.resetFields();
                        this.isLoading = false;
                    }).catch((error) => {
                        const evt = new ShowToastEvent({
                            title: error.body.message,
                            variant: "error"
                        });
                        this.dispatchEvent(evt);

                        console.log('ERROR');
                        console.log(JSON.stringify(error));

                        this.isLoading = false;
                    })
                }
        }
    }

    handleUploadFinished(event) {
        let uploadedFiles = event.detail.files;

        if(uploadedFiles != null && uploadedFiles.length > 0) {
            let firstFile = uploadedFiles[0];

            if(firstFile != null && firstFile.documentId != null) {
                this.uploadedContentDocumentId = firstFile.documentId;
            }
        }
    }

    handleMonthChange(event) {
        this.selectedMonth = event.detail.value;
    }

    handleYearChange(event) {
        this.selectedYear = event.detail.value;
    }

    handleCompanyIdChange(event) {
        this.selectedCompanyId = event.detail.value[0];
    }

    resetFields() {
        this.uploadedContentDocumentId = undefined;
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
     }
}