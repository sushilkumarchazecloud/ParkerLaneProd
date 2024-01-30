public class TriggerContentDocumentLink {
	public void OnBeforeInsert(List<ContentDocumentLink> newContentDocumentLink){
        for(ContentDocumentLink cdl:newContentDocumentLink) {
            cdl.Visibility='AllUsers';
           // cdl.sharetype='C';
        }
    }
}