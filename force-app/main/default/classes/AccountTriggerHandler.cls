public class AccountTriggerHandler {
    
    
    List<Account>triggerNew;
    List<Account>triggerOld;
    Map<Id,Account>triggerOldMap;
    Map<Id,Account>triggerNewMap;
    
    public AccountTriggerHandler(){       
        
        triggerNew=(List<Account>)Trigger.New;
        triggerOld=(List<Account>)Trigger.Old;
        triggerOldMap=(Map<Id,Account>)Trigger.OldMap;
        triggerNewMap=(Map<Id,Account>)Trigger.NewMap;
   
        
    } 
    public void doAction(){
        
        Switch on Trigger.OperationType
        {
            when BEFORE_INSERT
            {
                onBeforeInsert();
            }
            when AFTER_INSERT
            {
                onAfterInsert();
            }
            when BEFORE_UPDATE
            {
                onBeforeUpdate();
            }
            when AFTER_UPDATE
            {
                onAfterUpdate();
            }
        }
    }
    
    public void onBeforeInsert(){
        inactiveAccwithNoDescription();
        
    }
    public void onAfterInsert(){
        
    }
    public void onBeforeUpdate(){
        
    }
    public void onAfterupdate(){
        
    }
    
    public void inactiveAccwithNoDescription(){
        
        for(Account rec:triggerNew)
        {
            if(rec.Active__c.equals('No'))
            {
               rec.adderror('account should not be inactive  with no description');
            }
        }
        
    }
    

}