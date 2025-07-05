import { LightningElement } from 'lwc';
import { showToastNotification } from 'c/utility';


export default class TestUtilityFunctionsCom extends LightningElement {

    connectedCallback() {
        showToastNotification.call(this, 'Success', 'You have successfully sent a toast', 'success');
    }
}