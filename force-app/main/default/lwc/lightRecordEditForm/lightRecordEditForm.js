import { LightningElement,api } from 'lwc';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';
import ANNUAL_REVENUE_FIELD from '@salesforce/schema/Account.AnnualRevenue';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';

import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class LightRecordEditForm extends LightningElement {

    @api recordId
    @api objectApiName

    fieldsList={
        //objectName:ACCOUNT_OBJECT,
        nameField:NAME_FIELD,
        industryField:INDUSTRY_FIELD,
        annualRevenueField:ANNUAL_REVENUE_FIELD,
        phoneField:PHONE_FIELD
        
    }

    submitHandler(event)
    {
        console.log(event.detail);
        console.log(event.detail.fields);
    }
    successHandler(event)
    {
        
        console.log(event.detail.id)
        console.log(event.detail.fields);
        this.dispatchEvent(new ShowToastEvent({
            title:'Record Updated',
            message:event.detail.message,
            variant:'success'
        }));

       

    }

    errorHandler(event)
    {
        console.log(event);
        this.dispatchEvent(new ShowToastEvent({
            title:'Error creating Data',
            message:event.detail.message ,
            variant:'error'
        }));

    }


}