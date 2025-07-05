trigger ChecklistQuestionTrigger on CheckListQuestion__c (before delete) {
    
    
    if(Trigger.isBefore&&Trigger.isDelete){
        for(CheckListQuestion__c question:Trigger.Old){          
            if( question.AnswersCount__c != 0){
                question.addError('Questions cannot be deleted with Answers Included');
            }
           
        }
    }

}