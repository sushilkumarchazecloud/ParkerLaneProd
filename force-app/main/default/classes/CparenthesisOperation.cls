/**
 * @Author  :   Balkishan Kachawa
 * @Date    :   1-December-2019
 * @Desc    :   Classes to implement BPM (Business Process Management ) rule engine 
 * */
public class CparenthesisOperation extends Operation{
    
     public CparenthesisOperation()
    {
        super(')');
    } 
    public override Boolean resolve(BaseType a,BaseType b){
        return null; 
    } 

}