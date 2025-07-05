import { LightningElement, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getAccountRecords from '@salesforce/apex/CreateTaskController.getAccountRecords';
import createOrUpdateCustomObjectRecord from '@salesforce/apex/CreateTaskController.createOrUpdateCustomObjectRecord';

const FIELDS = ['Account.Name', 'Account.Selected_Value__c'];

export default class AccountAccordion extends LightningElement {
    @track accounts = [];
    @track error;
    @track selectedValues = {};

    valueOptions = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ];

    @wire(getAccountRecords)
    wiredAccounts({ error, data }) {
        if (data) {
            this.accounts = data.map(account => ({
                Id: account.Id,
                Name: account.Name,
                selectedValue: account.Selected_Value__c || ''
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.accounts = undefined;
        }
    }

    handleValueChange(event) {
        const accountId = event.target.dataset.id;
        const selectedValue = event.target.value;
        this.selectedValues[accountId] = selectedValue;
    }

    handleSave() {
        const recordsToSave = Object.keys(this.selectedValues).map(accountId => ({
            Account__c: accountId,
            Selected_Value__c: this.selectedValues[accountId]
        }));

        createOrUpdateCustomObjectRecord({ records: recordsToSave })
            .then(result => {
                // Handle success
                this.refreshRecords();
                // Clear selected values
                this.selectedValues = {};
            })
            .catch(error => {
                // Handle error
                console.error('Error saving records:', error);
            });
    }

    refreshRecords() {
        return refreshApex(this.wiredAccounts);
    }
}