import { LightningElement } from 'lwc';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import INDUSTRY from '@salesforce/schema/Account.Industry';
import ANNUAL_REVENUE from '@salesforce/schema/Account.AnnualRevenue';
import PARENT_ACCOUNT from '@salesforce/schema/Account.ParentId';


export default class DataConnectivity extends LightningElement {

    objectName=ACCOUNT_OBJECT;
    fieldList=[NAME_FIELD,INDUSTRY,ANNUAL_REVENUE,PARENT_ACCOUNT];

    



}