public class pass {
    public integer sum(integer x,integer y){ // pass by values or passing parameters
        integer z;
        z=x+y;
        return z;
        
        
    }
    
    public static void recursiveMethod(Integer count) {
        System.debug('Count: ' + count);
        if (count < 997) {  // This will exceed the limit
            recursiveMethod(count + 1);
        }
    }

}