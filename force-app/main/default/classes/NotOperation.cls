/**
 * @Author  :   Balkishan Kachawa
 * @Date    :   1-December-2019
 * @Desc    :   Classes to implement BPM (Business Process Management ) rule engine 
 * */
public class NotOperation extends Operation
{    
    public NotOperation(String symbol)
    {
        super(symbol);
    } 
    
    public override Boolean resolve(BaseType a,BaseType b){ 
        if( (a.getType() == BaseType.enumType.INTEGER_TYPE || a.getType() == BaseType.enumType.DECIMAL_TYPE)
            && b.getType() == BaseType.enumType.LIST_DECIMAL)           
        {
            for(Decimal bVal : b.getValuesSet()){
                if((Decimal) a.getValue() != bVal){
                    return true;
                }
            }
            return false;
        }  
        return a.getValue() != b.getValue(); 
    }  
}