public class ListDemo {

    static List<String>fullName=new List<String>();
   
    public static List<String> getFullName(List<String>firstName,List<String>lastName)
    {
        for(integer index=0;index<firstName.size();index++)
        {
            fullName.add(firstName[index]+' '+lastName[index]);
        }
        return fullName;
        
    }
}