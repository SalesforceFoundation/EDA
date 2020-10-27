import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const errorToast = (title, message, messageData) => {
    showToast(title, message, messageData, 'error');
};

const showToast = (title, message, messageData, variant) => {
    const toastEvent = new ShowToastEvent({
        'title': title,
        'message': message,
        'messageData': messageData,
        'variant': variant
    });
    this.dispatchEvent(toastEvent);
};

export { errorToast };