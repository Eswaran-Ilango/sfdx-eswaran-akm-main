import { ShowToastEvent } from "lightning/platformShowToastEvent";

export function showToastNotification(titleText, messageText, variant) {
    const evt = new ShowToastEvent({
      title: titleText,
      message: messageText,
      variant: variant,
    });
    this.dispatchEvent(evt);
}