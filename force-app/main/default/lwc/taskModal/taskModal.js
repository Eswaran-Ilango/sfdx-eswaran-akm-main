import { api ,track} from 'lwc';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createTask from '@salesforce/apex/CreateTaskController.createTask';
import getActiveUsers from '@salesforce/apex/CreateTaskController.getActiveUsers';

export default class TaskModal extends LightningModal {
    
    @api Id; // Account Id

    @track taskSubject = '';
    @track taskDueDate = '';
    @track taskDescription = '';
    @track taskOwnerId = '';
    @track ownerOptions = [];

    handleSave() {
        
        this.close(this.createTask());
    }

    handleCancel() {
        this.close('okay');
    }

    connectedCallback() {
        this.loadActiveUsers();
    }

    loadActiveUsers() {
        getActiveUsers()
            .then(result => {
                console.log(result);
                this.ownerOptions = result.map(user => {
                    return { label: user.Name, value: user.Id };
                });
            })
            .catch(error => {
                console.error('Error retrieving active users:', error);
            });
    }

    handleSubjectChange(event) {
        this.taskSubject = event.target.value;
    }

    handleDueDateChange(event) {
        this.taskDueDate = event.target.value;
    }

    handleDescriptionChange(event) {
        this.taskDescription = event.target.value;
    }

    handleOwnerChange(event) {
        this.taskOwnerId = event.target.value;
    }

    createTask() {
        const task = {
            Subject: this.taskSubject,
            ActivityDate: this.taskDueDate,
            Description: this.taskDescription,
            WhatId: this.Id,
            WhoId: null,
            OwnerId: this.taskOwnerId,
            Priority: 'Normal',
            Status: 'Not Started'
        };
        
        createTask({ task })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Task created',
                        variant: 'success'
                    })
                );
                this.clearFields();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating task',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    clearFields() {
        this.taskSubject = '';
        this.taskDueDate = '';
        this.taskDescription = '';
        this.taskOwnerId = '';
    }
}