public class SaveAndOpenPDF{
    
    public String oppId{get;set;}
    public SaveAndOpenPDF(ApexPages.StandardController stdController){
        oppId = stdController.getRecord().id;
    }
    
    public PageReference savePDF(){
    
        Opportunity opp = new Opportunity();
        
        opp = [SELECT Applicant_1__r.LastName, Applicant_2__r.LastName,(Select Customer_Amount__c,Product__r.Name
                            From Quotes where Application__c = true) 
                            From Opportunity where Id =: oppId][0];
                            
        String pdfName = 'Credit Proposal '+opp.Applicant_1__r.LastName;
        if(opp.Applicant_2__r.LastName != '')
            pdfName = pdfName+' & '+opp.Applicant_2__r.LastName;
        
        pdfName = pdfName+' '+opp.Quotes[0].Product__r.Name+', '+opp.Quotes[0].Customer_Amount__c+', '+String.valueof(Datetime.now())+'.pdf';
                            
        Attachment attachment = new Attachment();
        attachment.ParentId = oppId;
        attachment.name = pdfName;
        PageReference pdf = Page.SaveAndOpenApplicaton;
        pdf.getParameters().put('id', oppId);
        pdf.setRedirect(true);
        
        if(!Test.isRunningTest()){
            attachment.Body = pdf.getContent();
        }else{
            attachment.Body = Blob.valueOf('test');
        }
        attachment.ContentType = 'application/pdf';
        insert attachment;
        
        return new PageReference('/apex/SaveAndOpenApplicaton?id='+oppId);
    }
}