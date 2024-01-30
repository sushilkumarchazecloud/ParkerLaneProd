/**
 * @Author  :   Balkishan Kachawa
 * @Date    :   1-December-2019
 * Opening parenthesis 
 * */
public class OparenthesisOperation extends Operation{
    
     public OparenthesisOperation()
    {
        super('(');
    }
 
    
    public override Boolean resolve(BaseType a,BaseType b){
        return null; 
    } 

}