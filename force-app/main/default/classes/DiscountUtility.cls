public class DiscountUtility {
    
    Decimal discount=0;
    String rating;
    Integer amount;
    final Decimal DISCOUNT_HOT_FIFTYTHOUSAND=0.20;
    final Decimal DISCOUNT_HOT_FOURTYTHOUSAND=0.10;
     
    public Decimal calculateDiscount(String rating,Integer amount){
        
        this.rating=rating;
        this.amount=amount;
        
        if(rating=='Hot'&& amount>50000)
        {
            discount=DISCOUNT_HOT_FIFTYTHOUSAND;
            return discount;
        }
         else if(rating=='Hot'&& amount>40000)
        {
            discount=DISCOUNT_HOT_FOURTYTHOUSAND;
            return discount;
        } 
        else return discount;
        
    }

}