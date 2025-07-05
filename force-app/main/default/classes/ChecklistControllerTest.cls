@IsTest
public class ChecklistControllerTest {

    @IsTest
    public static void testGetAccordionSections() {
        // Create test data
        ChecklistController.AccordionSection expectedSection = new ChecklistController.AccordionSection('Section 1', new List<ChecklistController.Question>());
    
        // Set up the mock data
        CheckListQuestion__c question = new CheckListQuestion__c(
            Name = 'Question 1',
            Section__c = 'Section 1',
            Options__c = 'Option 1;Option 2',
            Type__c = 'PickList'
        );
    
        // Insert the test data
        insert question;
    
        // Assign actual question ID to the expected question
        expectedSection.questions.add(new ChecklistController.Question(
            question.Id, // Assign the actual question ID
            question.Name,
            '',
            new List<String>{'Option 1', 'Option 2'},
            'PickList'
        ));
    
        List<ChecklistController.AccordionSection> expectedSections = new List<ChecklistController.AccordionSection>();
        expectedSections.add(expectedSection);
    
        // Call the controller method
        Test.startTest();
        List<ChecklistController.AccordionSection> actualSections = ChecklistController.getAccordionSections();
        Test.stopTest();
    
        // Convert expected and actual sections to JSON strings for comparison
        String expectedSectionsJson = JSON.serialize(expectedSections);
        String actualSectionsJson = JSON.serialize(actualSections);
    
        // Verify the result
        System.assertEquals(expectedSectionsJson, actualSectionsJson);
    }




    @IsTest
    public static void testSaveAnswers() {
        // Create test data
        Case testCase = new Case();
        insert testCase;
        
        CheckListQuestion__c question = new CheckListQuestion__c(
            Name = 'Question 1',
            Section__c = 'Section 1',
            Options__c = 'Option 1;Option 2',
            Type__c = 'PickList'
        );
        insert question;
        
        ChecklistController.Question controllerQuestion = new ChecklistController.Question(question.Id, question.Name, '', new List<String>(), question.Type__c);
        
        SecondCheckListAnswer__c answer = new SecondCheckListAnswer__c(
            CheckListQuestion__c = question.Id,
            Answer__c = 'Option 1',
            Case__c = testCase.Id
        );
        
        // Call the controller method
        Test.startTest();
        ChecklistController.saveAnswers(new List<SecondCheckListAnswer__c>{ answer });
        Test.stopTest();
        
        // Verify the result
        List<SecondCheckListAnswer__c> savedAnswers = [SELECT CheckListQuestion__c, Answer__c FROM SecondCheckListAnswer__c];
        System.assertEquals(1, savedAnswers.size());
        System.assertEquals(answer.CheckListQuestion__c, savedAnswers[0].CheckListQuestion__c);
        System.assertEquals(answer.Answer__c, savedAnswers[0].Answer__c);
    }

    @IsTest
    public static void testGetSelectedAnswers() {
        // Create test data
        Case testCase = new Case();
        insert testCase;
        
        CheckListQuestion__c question = new CheckListQuestion__c(
            Name = 'Question 1',
            Section__c = 'Section 1',
            Options__c = 'Option 1;Option 2',
            Type__c = 'PickList'
        );
        insert question;
        
        SecondCheckListAnswer__c answer = new SecondCheckListAnswer__c(
            CheckListQuestion__c = question.Id,
            Answer__c = 'Option 1',
            Case__c = testCase.Id
        );
        insert answer;
        
        // Call the controller method
        Test.startTest();
        String selectedAnswersJson = ChecklistController.getSelectedAnswers(testCase.Id);
        Test.stopTest();
        
        // Verify the result
        List<SecondCheckListAnswer__c> selectedAnswers = (List<SecondCheckListAnswer__c>)JSON.deserialize(selectedAnswersJson, List<SecondCheckListAnswer__c>.class);
        System.assertEquals(1, selectedAnswers.size());
        System.assertEquals(answer.CheckListQuestion__c, selectedAnswers[0].CheckListQuestion__c);
        System.assertEquals(answer.Answer__c, selectedAnswers[0].Answer__c);
    }
    
    @IsTest
    public static void testSaveAnswers_UpdateExistingAnswers() {
        // Create test data
        Case testCase = new Case();
        insert testCase;
        
        CheckListQuestion__c question = new CheckListQuestion__c(
            Name = 'Question 1',
            Section__c = 'Section 1',
            Options__c = 'Option 1;Option 2',
            Type__c = 'PickList'
        );
        insert question;
        
        SecondCheckListAnswer__c existingAnswer = new SecondCheckListAnswer__c(
            CheckListQuestion__c = question.Id,
            Answer__c = 'Option 1',
            Case__c = testCase.Id
        );
        insert existingAnswer;
        
        SecondCheckListAnswer__c newAnswer = new SecondCheckListAnswer__c(
            CheckListQuestion__c = question.Id,
            Answer__c = 'Option 2',
            Case__c = testCase.Id
        );
        
        // Call the controller method
        Test.startTest();
        ChecklistController.saveAnswers(new List<SecondCheckListAnswer__c>{ newAnswer });
        Test.stopTest();
        
        // Verify the result
        List<SecondCheckListAnswer__c> updatedAnswers = [SELECT CheckListQuestion__c, Answer__c FROM SecondCheckListAnswer__c];
        System.assertEquals(1, updatedAnswers.size());
        System.assertEquals(existingAnswer.CheckListQuestion__c, updatedAnswers[0].CheckListQuestion__c);
        System.assertEquals(newAnswer.Answer__c, updatedAnswers[0].Answer__c);
    }
    
    @IsTest
    public static void testSaveAnswers_InsertNewAnswers() {
        // Create test data
        Case testCase = new Case();
        insert testCase;
        
        CheckListQuestion__c question = new CheckListQuestion__c(
            Name = 'Question 1',
            Section__c = 'Section 1',
            Options__c = 'Option 1;Option 2',
            Type__c = 'PickList'
        );
        insert question;
        
        ChecklistController.Question controllerQuestion = new ChecklistController.Question(question.Id, question.Name, '', new List<String>(), question.Type__c);
        
        SecondCheckListAnswer__c answer = new SecondCheckListAnswer__c(
            CheckListQuestion__c = question.Id,
            Answer__c = 'Option 1',
            Case__c = testCase.Id
        );
        
        // Call the controller method
        Test.startTest();
        ChecklistController.saveAnswers(new List<SecondCheckListAnswer__c>{ answer });
        Test.stopTest();
        
        // Verify the result
        List<SecondCheckListAnswer__c> savedAnswers = [SELECT CheckListQuestion__c, Answer__c FROM SecondCheckListAnswer__c];
        System.assertEquals(1, savedAnswers.size());
        System.assertEquals(answer.CheckListQuestion__c, savedAnswers[0].CheckListQuestion__c);
        System.assertEquals(answer.Answer__c, savedAnswers[0].Answer__c);
    }

    @IsTest
public static void testSaveAnswers_NoAnswersToUpdateOrInsert() {
    // Create test data
    Case testCase = new Case();
    insert testCase;

    // Call the controller method with an empty list
    Test.startTest();
    ChecklistController.saveAnswers(new List<SecondCheckListAnswer__c>());
    Test.stopTest();

    // Verify the result
    List<SecondCheckListAnswer__c> savedAnswers = [SELECT CheckListQuestion__c, Answer__c FROM SecondCheckListAnswer__c];
    System.assertEquals(0, savedAnswers.size());
}
    @IsTest
    public static void testGetSelectedAnswers_NoSelectedAnswers() {
        // Create test data
        Case testCase = new Case();
        insert testCase;
        
        // Call the controller method
        Test.startTest();
        String selectedAnswersJson = ChecklistController.getSelectedAnswers(testCase.Id);
        Test.stopTest();
        
        // Verify the result
        List<SecondCheckListAnswer__c> selectedAnswers = (List<SecondCheckListAnswer__c>)JSON.deserialize(selectedAnswersJson, List<SecondCheckListAnswer__c>.class);
        System.assertEquals(0, selectedAnswers.size());
    }

    
}