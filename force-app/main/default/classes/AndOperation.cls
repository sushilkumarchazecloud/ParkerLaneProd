/**
 * @Author  :   Balkishan Kachawa
 * @Date    :   1-December-2019
 * @Desc    :   Classes to implement BPM (Business Process Management ) rule engine 
 * */
public class AndOperation extends Operation
{    
    public AndOperation(String symbol)
    {
        super(symbol);
    } 

    public override Boolean resolve(BaseType a,BaseType b){ 
        return a.getBooleanValue() && b.getBooleanValue(); 
    } 
}