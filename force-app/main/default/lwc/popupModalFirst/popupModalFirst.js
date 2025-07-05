import { LightningElement } from 'lwc';

export default class PopupModalFirst extends LightningElement {

    modal;


    openModal() {
        this.modal = true;
    }

    closeModal() {
        this.modal = false;
    }


}