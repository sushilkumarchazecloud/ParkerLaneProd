/**
 * @Author  :   Balkishan Kachawa
 * @Date    :   1-December-2019
 * @Desc    :   Classes to implement BPM (Business Process Management ) rule engine
 *          :   Simple Marker interface to achieve run time polymorphism
 * */
public abstract class Operation implements Expression
{ 
    
    protected String symbol;  

    public Operation(String symbol)  
    {
        this.symbol = symbol;
    } 
    public abstract Boolean resolve(BaseType a,BaseType b);
 
    public String getSymbol()
    {
        return this.symbol;
    } 
}