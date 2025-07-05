public with sharing class ChecklistController {

    @AuraEnabled(cacheable=true)
    public static List<AccordionSection> getAccordionSections() {
        List<AccordionSection> accordionSections = new List<AccordionSection>();

        // Query the CheckListQuestion__c object to retrieve the data
        List<CheckListQuestion__c> questions = [SELECT Id, Question__c, Section__c, Options__c, Type__c, Notes__c, IsActive__c 
                                                FROM CheckListQuestion__c 
                                                WHERE Question__c != '' AND Section__c != ''];

        // Map to hold the answers for each question
        Map<Id, List<SecondCheckListAnswer__c>> questionAnswersMap = new Map<Id, List<SecondCheckListAnswer__c>>();

        // Retrieve all the answers for the questions
        List<SecondCheckListAnswer__c> allAnswers = [SELECT Id, CheckListQuestion__c, Case__c, Answer__c 
                                                     FROM SecondCheckListAnswer__c 
                                                     WHERE CheckListQuestion__c IN :questions];

        // Group the answers by question Id
        for (SecondCheckListAnswer__c answer : allAnswers) {
            if (!questionAnswersMap.containsKey(answer.CheckListQuestion__c)) {
                questionAnswersMap.put(answer.CheckListQuestion__c, new List<SecondCheckListAnswer__c>());
            }
            questionAnswersMap.get(answer.CheckListQuestion__c).add(answer);
        }

        Map<String, AccordionSection> sectionMap = new Map<String, AccordionSection>();

        for (CheckListQuestion__c question : questions) {
            String sectionName = question.Section__c;

            if (!sectionMap.containsKey(sectionName)) {
                sectionMap.put(sectionName, new AccordionSection(sectionName, new List<Question>()));
            }

            // Split the Options__c field by semicolon to create options list
            List<String> options = new List<String>();

            if (question.Type__c == 'PickList') {
                options = question.Options__c != null ? question.Options__c.split(';') : new List<String>();
            }

            List<SecondCheckListAnswer__c> answers = questionAnswersMap.containsKey(question.Id) 
                                                     ? questionAnswersMap.get(question.Id)
                                                     : new List<SecondCheckListAnswer__c>();

            sectionMap.get(sectionName).questions.add(new Question(question.Id, question.Question__c, '', options, question.Type__c, question.Notes__c, question.IsActive__c, answers));
                     
        }

        accordionSections.addAll(sectionMap.values());

        return accordionSections;
    }

    @AuraEnabled
    public static void saveAnswers(List<SecondCheckListAnswer__c> answers) {
        if (answers == null || answers.isEmpty()) {
            return; // Exit the method if there are no answers to process
        }

        Set<String> questionIds = new Set<String>();
        for (SecondCheckListAnswer__c answer : answers) {
            questionIds.add(answer.CheckListQuestion__c);
        }

        List<SecondCheckListAnswer__c> existingAnswers = [
            SELECT Id, CheckListQuestion__c, Answer__c
            FROM SecondCheckListAnswer__c
            WHERE CheckListQuestion__c IN :questionIds AND Case__c = :answers[0].Case__c
        ];

        Map<String, SecondCheckListAnswer__c> existingAnswerMap = new Map<String, SecondCheckListAnswer__c>();
        for (SecondCheckListAnswer__c existingAnswer : existingAnswers) {
            existingAnswerMap.put(existingAnswer.CheckListQuestion__c, existingAnswer);
        }

        List<SecondCheckListAnswer__c> answersToUpdate = new List<SecondCheckListAnswer__c>();
        List<SecondCheckListAnswer__c> answersToInsert = new List<SecondCheckListAnswer__c>();

        for (SecondCheckListAnswer__c answer : answers) {
            SecondCheckListAnswer__c existingAnswer = existingAnswerMap.get(answer.CheckListQuestion__c);
            if (existingAnswer != null) {
                existingAnswer.Answer__c = answer.Answer__c;
                answersToUpdate.add(existingAnswer);
            } else {
                // Set the Case__c field for new records
                answer.Case__c = answers[0].Case__c;
                answersToInsert.add(answer);
            }
        }

        update answersToUpdate;

        if (answersToInsert.size() > 0) {
            insert answersToInsert;
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getSelectedAnswers(Id recordId) {
        List<SecondCheckListAnswer__c> selectedAnswers = [
            SELECT CheckListQuestion__c, Answer__c
            FROM SecondCheckListAnswer__c
            WHERE Case__c = :recordId
        ];
        return JSON.serialize(selectedAnswers);
    }

    // Inner classes to structure the data
    public class AccordionSection {
        @AuraEnabled
        public String name;

        @AuraEnabled
        public List<Question> questions;

        @AuraEnabled
        public Integer naCount;

        @AuraEnabled
        public Integer questionCount;

        @AuraEnabled
        public String getSectionLabel() {
            return name + ' (' + naCount + '/' + questionCount + ')';
        }

        public AccordionSection(String name, List<Question> questions) {
            this.name = name;
            this.questions = questions;
            this.naCount = 0;
            this.questionCount = questions.size();
        }
    }

    public class Question {
        @AuraEnabled
        public String Id;

        @AuraEnabled
        public String Name;

        @AuraEnabled
        public String SelectedValue { get; set; }

        @AuraEnabled
        public List<String> Options { get; set; }

        @AuraEnabled
        public String Type { get; set; }

        @AuraEnabled
        public String notes { get; set; }

        @AuraEnabled
        public Boolean IsActive { get; set; }

        @AuraEnabled
        public List<SecondCheckListAnswer__c> answers { get; set; }


        

        public Question(String Id, String Name, String SelectedValue, List<String> Options, String Type,  String notes, Boolean IsActive, List<SecondCheckListAnswer__c> answers ) {
            this.Id = Id;
            this.Name = Name;
            this.SelectedValue = SelectedValue;
            this.Options = Options;
            this.Type = Type;
            this.notes = notes;
            this.IsActive = IsActive;
            this.answers = answers;

        }
        
    }



}