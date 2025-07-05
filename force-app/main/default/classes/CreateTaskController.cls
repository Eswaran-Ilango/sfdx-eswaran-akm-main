public with sharing class CreateTaskController {
    @AuraEnabled(cacheable=true)
    public static List<User> getActiveUsers() {
        return [SELECT Id, Name FROM User WHERE IsActive = true];
    }

    @AuraEnabled
    public static void createTask(Task task) {
        insert task;
    }

    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountRecords() {
        return [SELECT Id, Name , Selected_Value__c FROM Account];
    }
    
    
    





}