import { LightningElement, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getJsonForXero from '@salesforce/apex/InvoiceController.getJsonForXero';
import createInvoice from '@salesforce/apex/InvoiceController.createInvoice';

export default class CreateInvoice extends NavigationMixin(LightningElement) {
    urlParams = {};
    jsonData = '';
    showJson = false;
    isLoading = false;

    columns = [
        { label: 'Parameter', fieldName: 'key', type: 'text' },
        { label: 'Value', fieldName: 'value', type: 'text' }
    ];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlParams = currentPageReference.state || {};
        }
    }

    get parameterEntries() {
        return Object.entries(this.urlParams).map(([key, value]) => ({ key, value }));
    }

    handleShowJson() {
        // isLoading = true;
         console.log('button clicked');
         console.log('version2'+this.urlParams.c__origin_record);
          console.log('orginrecordid'+this.urlParams['c__origin_record'] || this.urlParams.origin_record);
         /*if (!originRecordId) {
            console.error('Missing required parameters:', { originRecordId});
            this.isLoading = false;
            return;
        }*/
    getJsonForXero({ 
       originRecordId: this.urlParams['c__origin_record'] || this.urlParams.origin_record || null
            //invoiceDueDate: this.urlParams['c__invoice_due_date'] || this.urlParams.invoice_due_date || null
    })
    .then(result => {
        console.log('message'+result);
            this.jsonData = result;
            this.showJson = true;
    })
    .catch(error => {
        console.error('Error fetching JSON:', error);
    });
    }


    handleCreateInvoice() {
        createInvoice({ 
            originRecordId: this.urlParams.c__origin_record, 
            invoiceDueDate: this.urlParams.c__invoice_due_date,
            requiredQuantity: this.requiredQuantity
        })
        .then(result => {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: result,
                    objectApiName: 'Invoice__c',
                    actionName: 'view'
                }
            });
        })
        .catch(error => {
            console.error('Error creating Invoice:', error);
        });
    }
    handleQuantityChange(event) {
       this.requiredQuantity = event.target.value;}
}