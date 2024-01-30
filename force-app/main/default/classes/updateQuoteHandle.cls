public class updateQuoteHandle {
    
    @AuraEnabled 
    public static string updateQuote(string recid){
        system.debug('recid'+recid);
        
        updateQuotesByProductBatch obj = new updateQuotesByProductBatch(recid);
     	Database.executeBatch(obj, 20);
		return 'success';
    }
}