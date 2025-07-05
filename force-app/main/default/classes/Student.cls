public class Student {
    
    	Integer rollNo;
        String name;
    	String department;
        List<Integer>markList;
    	Integer total=0;
    	final integer PASSMARK=35;
        String result;
        
    
    public Student(Integer rollNo,String name,String department,List<Integer>markList)
    {
        this.rollNo=rollNo;
      	this.name=name;
         this.department=department;
        this.markList=markList;
          
    }
    
    public void calculateTotal()
    {
        for(Integer mark:markList){
            total=total+mark;
        }
       calculateResult(); 
    }
    
     private void calculateResult()
     {
      	 result='Pass'; 
         for(Integer mark:markList){
            if(mark<PASSMARK)
            {
               result='Fail';
               break;
            }
        }
         printStudentInfo();
         
     }
    private void printStudentInfo()
    {
        system.debug('******************');
        system.debug('RollNo::'+rollNo);
        system.debug('Name::'+name);
        system.debug('TotalMarks::'+total);
        system.debug('Result::'+result);
        system.debug('******************');
    }
    
    
    
    
    

}