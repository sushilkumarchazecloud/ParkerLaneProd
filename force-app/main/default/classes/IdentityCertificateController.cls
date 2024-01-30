public class IdentityCertificateController {
    //public string voiId = '';	
    public static opportunity opp{get; set;}
    public static contact con{get; set;}
    public static VOI_Detail__c voi{get; set;}
    public static String frontDL {get; set;}
    public static String frontDLURL {get; set;}
    
    public static String BackDL {get; set;}
    public static String BackDLURL {get; set;}
    
    public static String Passport {get; set;}
    public static String PassportURL {get; set;}
    
    public static String Snap {get; set;}
    public static String SnapURL {get; set;}
   
    public static String paksBackDate {get; set;}
    public static String paksBacktime {get; set;}
    
    public static String videoCreateDate {get; set;}
    public static String videoCreatetime {get; set;}
    
    public static String verifyDate {get; set;}
    public static String data {get; set;}
    
    public IdentityCertificateController(){
        id voiId = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('id') : '';
        voi = [select Id,matchVerification__c, name,LastModifiedDate,verified_by_selfie_ID__c,Code_Match_Status__c, contact__r.name,contact__r.id,CreatedDate,Code_Not_Required__c from VOi_detail__c where Id =: voiId LIMIT 1];
        System.debug('Code_Match_Status__c ==========='+voi.Code_Match_Status__c);
        System.debug('ID =='+voi.ID);
        Voi_status__c vois = [select id, name,LastModifiedDate,Opportunity__c,Opportunity__r.id,Date_submitted__c, VOI_detail__c from VOI_Status__c WHERE VOI_detail__r.id = : voi.id LIMIT 1];
        
        List<string> stringdata = new List<string>();
        string link = '/sfc/servlet.shepherd/version/download/';
       dateTime videoCretedate;
        
        try{
            stringdata = getImageData('Passport');
            if(stringdata != null && stringdata.size() > 0){
                Passport = stringdata[1];
                PassportURL = link+Passport;   
            }   
        }catch(Exception ex){
            System.debug(ex.getMessage());
            stringdata = getImageData('DLFront');
            frontDL = stringdata[1];
            frontDLURL = link+frontDL;
            
            stringdata = getImageData('BackDL');
            BackDL = stringdata[1];
            BackDLURL = link+BackDL;
            
        }            
        
        try{
        stringdata = getImageData('video');
        videoCretedate = dateTime.valueOf(stringdata[0]);
        
        System.debug('stringdata---+'+videoCretedate);
        }Catch(Exception e){
            System.debug(e.getMessage());
            videoCretedate = system.now();
        }
        opp = [select id,Purpose__c, name,Packs_Out_Date__c from opportunity WHERE id =: vois.Opportunity__r.id  LIMIT 1];
        
        paksBacktime = monthCOnvert((vois.Date_submitted__c != null ? vois.Date_submitted__c : vois.LastModifiedDate))[0];
        
        paksBackDate = monthCOnvert((vois.Date_submitted__c != null ? vois.Date_submitted__c : vois.LastModifiedDate))[1];
        
        //-----------------------------------------------------------------------------
        
        videoCreatetime = monthCOnvert(videoCretedate)[0];
        
        videoCreateDate = monthCOnvert(videoCretedate)[1];
        
        //-----------------------------------------------------------------------------
    	Boolean isSelfi = false;
    	verifyDate = monthCOnvert(voi.LastModifiedDate)[1];
       
        try{
        stringdata = getImageData('Selfi');
        Snap = stringdata[1];
        SnapURL = link+Snap;
        }Catch(Exception ex){
            System.debug('me-'+ex);    
            isSelfi = true;
        }
       
        if(isSelfi){
            try{
                stringdata = getImageData('VideoSnap');
                Snap = stringdata[1];
                SnapURL = link+Snap;
            }Catch(Exception ex){
                System.debug('me-'+ex);    
            }
        }
       
   }
    
    
    
    public static contact getContact(){
        try{
            con = [select id,Residential_Address__c,Residential_Address_1__c, Year__c,Primary_Employer_Name__c, name from contact where id =: voi.Contact__r.id LIMIT 1];
        }Catch(Exception ex){
            System.debug('excep---'+ex.getCause() + ex.getMessage() + ex.getLineNumber());
        }
        return con;
    }
    
    public static List<string> getImageData(string docName){
        id voiId  = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('id') : '';
        list<ContentVersion> CVList = new List<ContentVersion>();
        list<String> VersionDataList = new List<String>();
        List<String> Temp = new List<string>();
        Set<Id> CDId = new Set<Id>();
        string DocNameforQ = '';
        string forUpdated = '';
        System.debug('docName'+docName);
         string olderName = '';
        VOI_Detail__c vs = [Select id, contact__r.Name From VOI_Detail__c WHERE id =: voiId LIMIT 1];
        if(docName == 'DLFront'){
            DocNameforQ = 'DL Front '+vs.contact__r.Name;
            System.debug('DocNameforQ---'+DocNameforQ);
            olderName = docName;
            forUpdated = 'DL Front%';
        }
        else if(docName == 'BackDL'){
            DocNameforQ = 'DL Back '+vs.contact__r.Name;
            olderName = docName;
            forUpdated = 'DL Back%';
        }
        else if(docName == 'Selfi'){
            DocNameforQ = 'Selfie holding DL '+vs.contact__r.Name;
            olderName = docName;
        }
        else if(docName == 'Passport'){
            DocNameforQ = 'passport '+vs.contact__r.Name;
            olderName = docName;
            forUpdated = 'passport%';
        }
        else{
            DocNameforQ = docName;
        }
        System.debug('DocNameforQ'+DocNameforQ);
        for(ContentDocumentLink Cd : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: voiId]){
            CDId.add(Cd.ContentDocumentId);
        }
        System.debug('CDId--->'+CDId);
        
        CVList = [SELECT Id,createddate FROM ContentVersion WHERE ContentDocumentId = : CDId AND (Title =: DocNameforQ OR Title =: olderName OR Title Like : forUpdated) order by createddate DESC LIMIT 1];
        string st = string.valueOf(CVList[0].createddate); 
        Temp.add(st);
        for(ContentVersion Cd : CVList){
            VersionDataList.add(Cd.Id);
        }
        if(VersionDataList != null){
            if(VersionDataList.size() > 0){
                Temp.add(VersionDataList[0]);
            }    
        }
        return Temp;
    }
	
    public List<string> monthCOnvert(dateTime dat){
        
        List<string> datetimeconverted = new List<string>();
        List<string> data = string.valueOf(dat).split(' ');
        dateTime tim =  dat;
        string team = tim.format('h:mm a');
        
        datetimeconverted.add(team);
        
        integer nm = dat.month();
        
        string mnth = '';
        if(nm == 1){
            mnth = 'January';
        }
        else if(nm == 2){
            mnth = 'February';
        }
        else if(nm == 3){
            mnth = 'March';
        }
        else if(nm == 4){
            mnth = 'April';
        }
        else if(nm == 5){
            mnth = 'May'; 
        }
        else if(nm == 6){
            mnth = 'June';
        }
        else if(nm == 7){
            mnth = 'July';
        }
        else if(nm == 8){
            mnth = 'August';
        }
        else if(nm == 9){
            mnth = 'September';
        }
        else if(nm == 10){
            mnth = 'October';
        }
        else if(nm == 11){
            mnth = 'November';
        }
        else if(nm == 12){
            mnth = 'December'; 
        }
        else{
            mnth = '';
        }
        
        string st = dat.day() + ' ' + mnth + ' ' + dat.year();
        
        datetimeconverted.add(st);
        return datetimeconverted;
    }
    
  
}