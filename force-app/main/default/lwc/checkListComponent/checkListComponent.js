import { LightningElement, track, api } from 'lwc';
import saveAnswers from '@salesforce/apex/ChecklistController.saveAnswers';
import getAccordionSections from '@salesforce/apex/ChecklistController.getAccordionSections';
import getSelectedAnswers from '@salesforce/apex/ChecklistController.getSelectedAnswers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ChecklistComponent extends LightningElement {
    @api recordId;
    @track accordionSections = [];
    activeSections = [];
    isLoading = true;
    noRecord = false;


    async connectedCallback() {
        await this.loadAccordionSections();
        this.loadSelectedAnswers();
        //console.log(JSON.stringify(this.accordionSections));

    }

    loadAccordionSections() {
        this.isLoading = true; // Set isLoading to true before making the apex call

        return new Promise((resolve, reject) => {
            getAccordionSections()
                .then(result => {
                    this.accordionSections = result;
                    this.accordionSections.map(section => {
                        this.activeSections.push(section.name);
                    });
                    //console.log(this.recordId);
                    //console.log(JSON.stringify(this.accordionSections));
                    this.isLoading = false;
                    resolve();
                })
                .catch(error => {
                    this.isLoading = false; // Set isLoading to false if an error occurs
                    // Handle any errors
                    reject(error);
                });
        });
    }

    loadSelectedAnswers() {
        this.isLoading = true; // Set isLoading to true before making the apex call
    
        getSelectedAnswers({ recordId: this.recordId })
            .then(result => {
                const selectedAnswers = JSON.parse(result);
                this.accordionSections = this.accordionSections.map(section => {
                    const questions = section.questions.map(question => {
                        const selectedAnswer = selectedAnswers.find(
                            ans => ans.CheckListQuestion__c === question.Id
                        );
    
                        // If question is inactive and doesn't have an answer, exclude it
                        if (!question.IsActive && !selectedAnswer) {
                            return null;
                        }
    
                        if (selectedAnswer) {
                            return { ...question, SelectedValue: selectedAnswer.Answer__c };
                        } else if (question.Type === 'Text') {
                            return { ...question, SelectedValue: '' }; // Set empty value for Text type question
                        }
    
                        return question;
                    });
                    
    
                    // Filter out null (inactive) questions
                    const activeQuestions = questions.filter(question => question !== null);
    
                    return { ...section, questions: activeQuestions };
                });
                
                this.accordionSections = this.accordionSections.filter(section => section.questions.length > 0);
                
                //console.log(JSON.stringify(this.accordionSections));
                // Populate the combobox options for each question
                this.accordionSections = this.accordionSections.map(section => {
                    const questions = section.questions.map(question => {
                        const options = question.Options.map(option => {
                            return { label: option, value: option };
                        });
                        if (question.Options.includes('N/A')) {
                            const selectedAnswer = selectedAnswers.find(
                                ans => ans.CheckListQuestion__c === question.Id
                            );
                            if (selectedAnswer && selectedAnswer.Answer__c !== 'N/A') {
                                return { ...question, Options: options, SelectedValue: selectedAnswer.Answer__c };
                            }
                            return { ...question, Options: options, SelectedValue: 'N/A' };
                        }
    
                        return { ...question, Options: options };
                    });
                    return { ...section, questions };
                });
    
                this.accordionSections = this.accordionSections.map(section => {
                    const questions = section.questions.map(question => {
                        return {
                            ...question,
                            isPickList: question.Type === 'PickList',
                            isText: question.Type === 'Text'
                        };
                    });
                    return { ...section, questions };
                });
    
                // Additional logic to calculate NA counts
                this.updateSectionLabels();
    
                this.isLoading = false; // Set isLoading to false after data is loaded
                console.log(JSON.stringify(this.accordionSections));
                if(this.accordionSections.length >0){
                this.noRecord= true;
              } 
                

            })
            .catch(error => {
                // Handle any errors
                this.isLoading = false; // Set isLoading to false if an error occurs
            });
    }
    
    handleChange(event) {
        const questionId = event.target.dataset.questionId;
        const selectedValue = event.target.value;
    
        this.accordionSections = this.accordionSections.map(section => {
            const questions = section.questions.map(question => {
                if (question.Id === questionId) {
                    return { ...question, SelectedValue: selectedValue };
                }
                return question;
            });
            return { ...section, questions };
        });
    
        // Update the section labels whenever the selected value of a question changes
        
    }
    
    updateSectionLabels() {
        this.accordionSections = this.accordionSections.map(section => {
            const naCount = section.questions.filter(question => question.SelectedValue != 'N/A').length;
            const questionCount = section.questions.length;
            const sectionLabel = section.name + ' (' + naCount + '/' + questionCount + ')';
            return { ...section, naCount, questionCount, sectionLabel };
        });
    }
    
    handleSave() {
        this.isLoading = true;
        const answersToSave = [];
        this.accordionSections.forEach(section => {
            section.questions.forEach(question => {
                if(question.IsActive)
                    answersToSave.push({
                        CheckListQuestion__c: question.Id,
                        Answer__c: question.SelectedValue,
                        Case__c: this.recordId
                    });
                
            });
        });
        console.log(JSON.stringify(this.accordionSections));
        this.updateSectionLabels();
        
        saveAnswers({ answers: answersToSave })
            .then(result => {
                // Handle success
    
                this.showToast('Success', 'Records saved successfully', 'success');
                this.isLoading = false;
                this.accordionSections = this.accordionSections.map(section => {
                    const questions = section.questions.map(question => {
                        const selectedAnswer = answersToSave.find(ans => ans.CheckListQuestion__c === question.Id);
                        if (selectedAnswer) {
                            return { ...question, SelectedValue: selectedAnswer.Answer__c };
                        }
                        return question;
                    });
                    return { ...section, questions };
                });
            })
            .catch(error => {
                // Handle error
                this.showToast('Error', 'An error occurred while saving records', 'error');
            });
    }
    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}