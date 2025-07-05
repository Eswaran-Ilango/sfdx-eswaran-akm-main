public with sharing class TaskController {
    @AuraEnabled(cacheable=true)
    public static List<User> getActiveUsers() {
        return [SELECT Id, Name FROM User WHERE IsActive = true];
    }

    @AuraEnabled
    public static void createTask(Task task) {
        insert task;
    }
}