/**
 * @Author  :   Balkishan Kachawa
 * @Date    :   1-December-2019
 * @Desc    :   Classes to implement BPM (Business Process Management ) rule engine
 *          :   Simple Marker interface to achieve run time polymorphism
 * */
public class OROperation extends Operation
{    
    public OROperation(String symbol)
    {
        super(symbol);
    } 
    
    public override Boolean resolve(BaseType a,BaseType b){ 
        return a.getBooleanValue() || b.getBooleanValue();  
    } 
      
}