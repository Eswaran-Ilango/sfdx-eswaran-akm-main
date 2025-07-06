trigger CandidateTrigger on Candidate__c (before update, after update) {
    
    if(Trigger.isUpdate) {  
        if(Trigger.isBefore) {
            CandidateTriggerHandler.setScoreOnStatusUpdate(Trigger.New);
        }

        if(Trigger.isAfter) {
            CandidateTriggerHandler.setTotalScoreOnStatusUpdate(Trigger.NewMap, Trigger.OldMap);    
        }  
    }

}