public class SOQLRelationship {

    
    public static void displayCustomObj(){
        
       /*List<student_detail__c> lstStudent=[	SELECT
        									Id,student_Name__c,dept__c
        									FROM student_detail__c];
        
        for(student_detail__c stu:lstStudent){
            system.debug(stu.Id);
             system.debug(stu.student_Name__c);
             system.debug(stu.dept__c);
        }
    } 
        
	List<student_detail__c> lstStudent=[	SELECT
        									Id,student_Name__c,dept__r.Name,dept__r.dept_hod__c
        									FROM student_detail__c];
        
        for(student_detail__c stu:lstStudent){
            system.debug(stu.Id);
             system.debug(stu.student_Name__c);
             system.debug(stu.dept__r.Name);
             system.debug(stu.dept__r.dept_hod__c);
            
        }*/ 
        //parent to child--custom object
        
        	List<dept__c> lstDept=[			SELECT
        									Id,Name,dept_hod__c,(SELECT student_Name__c FROM student_details__r )
        									FROM dept__c];
        for(dept__c dept:lstDept){
            
           system.debug('===========================');
            
            system.debug(dept.Name);
            
            for(student_detail__c stu:dept.student_details__r){
                
                 system.debug(stu.student_Name__c);
            }
             system.debug('==========================='); 
        
        }
        
        
        
        
    }
}