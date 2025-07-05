public class ConstructorDemo {

    Integer amount;
    
    public ConstructorDemo(){
        amount=10000;
        system.debug('Empty constructor');
        system.debug('Amount::'+amount);
        
    }
    public ConstructorDemo(Integer amount){
        this.amount=amount;
        system.debug('Amount::'+this.amount);
        system.debug('parameterised constructor');
    }
    
    /*public void setAmount(){
		amount=10000;        
    }
    public void setAmount(Integer amount){
        this.amount=amount;
        system.debug('Amount::'+this.amount);
    }*/
    
}