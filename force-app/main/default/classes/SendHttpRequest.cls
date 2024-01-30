public class SendHttpRequest{    
    
    //method to make callout and get the response 
    
    @future(callout=true) 
    Public static void UpsertLeads(){
        
        //String variable to store the end point url
        String endPoint = 'https://www.solarquotes.com.au/webservice/UpsideDownsideService/';
        
        //String to store the password
        String Password = '$U&aEJeGO2*LK!?L';
        
        //String to Store the UserName
        String UserName = 'upside';
        
        //String to Store the EndDate 
        String StartDate =system.now().addMinutes(-36).format('yyyy-MM-dd HH:mm:ss','Australia/Adelaide');
        
        //String to Store the Startdate
        String EndDate = system.now().addMinutes(-30).format('yyyy-MM-dd HH:mm:ss','Australia/Adelaide');
        
        //String Store the Encrypted password in Md5 
        String EncryptedPassword = EncodingUtil.convertToHex(crypto.generateDigest('MD5',Blob.valueOf(Password)));
        
        // String to store the body of request to sent
        String body = '<request><login>'+UserName+'</login><password>'+EncryptedPassword+'</password><startDate>'+StartDate+'</startDate><endDate>'+EndDate+'</endDate></request>';
        //String body = '<request><login>upside</login><password>b1f741f726f2c28765417a3a3b54796d</password><startDate>2018-12-18 22:11:32</startDate><endDate>2018-12-19 22:11:32</endDate></request>';
        System.debug('Body For Request'+body);
        //Http request variable to send the request 
        HttpRequest req = new HttpRequest();
        
        //setting the endPoint
        req.setEndpoint(endPoint);
        
        //setting the method
        req.setMethod('POST');
        
        //setting the body 
        req.setBody(body);
        
        
        Http http = new Http();
        
        //http response variable
        HTTPResponse response; 
        
        String bodystr;
        LeadParser leadParserObject = new LeadParser();
        //get the response 
        if(!Test.isRunningtest()){
            response = http.send(req);            
        
        System.debug('@$ response ' + response);
        System.debug('@$ response.getBody() ' + response.getBody());
        System.debug('@$ response.getBodyDocument() ' + response.getBodyDocument());

        //to read xml
       /* dom.Document docx;
        if(response!=null)
            docx = response.getBodyDocument();*/

        //Creating object
        
        bodystr = response.getBody();
        System.debug('====bodystr ---'+bodystr);
        }
        if(Test.isRunningtest())
            bodystr = '<?xml version="1.0" encoding="UTF-8"?><response><lead><id>289021</id><name>dan</name><lastName>collard</lastName><phone>0403052301</phone><email>junglebarry@gmail.com</email><size>Not Sure. Please help me decide</size><timeframe>In the next 4 weeks</timeframe><quarterlyBill/><ownTheRoofSpace>Yes</ownTheRoofSpace><typeOfRoof>Other</typeOfRoof><minimumTenSquareMetersNorthFacing>I\'m not sure - Please Help Me Out</minimumTenSquareMetersNorthFacing><roofSlope/><shade/><direction>Not Sure</direction><stories/><features>None</features><submittedDate>2016-11-24 15:25:19</submittedDate><dispatchedDate>2016-11-24 16:00:06</dispatchedDate><address>87 Wilkes Road Hampton</address><installationAddressLineOne>87 Wilkes Road</installationAddressLineOne><installationAddressLineTwo/><installationSuburb>Hampton</installationSuburb><installationState>QLD</installationState><installationPostcode>4352</installationPostcode><installationCountry>Australia</installationCountry><mailingAddressLineOne/><mailingAddressLineTwo/><mailingSuburb/><mailingState/><mailingPostcode/><mailingCountry/><availableForConversation/><importantNotes>This customer has indicated that they are looking to arrange their own finance independently.</importantNotes><supplier><name>Enwise Electrical and Refrigeration Toowoomba</name><address>PO Box 2650, Toowommba ,QLD Emerald</address><contact><type>Sales</type><name> </name><phone/><email/></contact><contact><type>Leads</type><name>Justin Scutt</name><phone>07 49820 420</phone><email>tonylloydjones@enwise.com.au</email></contact><contact><type>Main</type><name>Justin Scutt</name><phone/><email>justinscutt@enwise.com.au</email></contact></supplier><supplier><name>Green Solar</name><address>, Greenslopes ,QLD </address><contact><type>Sales</type><name> </name><phone/><email/></contact><contact><type>Leads</type><name>Paul  Thistleton</name><phone>0421 351 929</phone><email>paul@green-solar.com.au</email></contact><contact><type>Main</type><name>Paul Thistleton</name><phone/><email>paul@green-solar.com.au</email></contact></supplier><supplier><name>Excel Solar Pty Ltd</name><address>5 Tointon Street, Toowoomba ,QLD 4350</address><contact><type>Sales</type><name> </name><phone/><email/></contact><contact><type>Leads</type><name>Terry Davis</name><phone>0746387344</phone><email>paul.lemming@excelsolar.com.au</email></contact><contact><type>Main</type><name>Terry Davis</name><phone/><email>terrydavis@excelsolar.com.au</email></contact></supplier></lead><lead><id>289024</id><name>roberto</name><lastName>cassandro</lastName><phone>0431420581</phone><email>robertocassandro@gmail.com</email><size>4kW</size><timeframe>In the next year</timeframe><quarterlyBill>Less than $500</quarterlyBill><ownTheRoofSpace>Yes</ownTheRoofSpace><typeOfRoof>Asbestos</typeOfRoof><minimumTenSquareMetersNorthFacing>I\'m not sure - Please Help Me Out</minimumTenSquareMetersNorthFacing><roofSlope/><shade/><direction>Not Sure</direction><stories/><features>Microinverters</features><submittedDate>2016-11-24 15:35:14</submittedDate><dispatchedDate>2016-11-24 16:10:02</dispatchedDate><address>34 Mark Street St Marys</address><installationAddressLineOne>34 Mark Street</installationAddressLineOne><installationAddressLineTwo/><installationSuburb>St Marys</installationSuburb><installationState>NSW</installationState><installationPostcode>2760</installationPostcode><installationCountry>Australia</installationCountry><mailingAddressLineOne/><mailingAddressLineTwo/><mailingSuburb/><mailingState/><mailingPostcode/><mailingCountry/><availableForConversation/><importantNotes>This customer has indicated that they are looking to arrange their own finance independently.</importantNotes><supplier><name>Solaray Energy Pty Ltd</name><address>Unit 13, 9 Kilto Crescent, Glendenning  ,NSW 2761</address><contact><type>Sales</type><name> </name><phone/><email/></contact><contact><type>Leads</type><name>Jonathan Fisk</name><phone>02 8090 4299</phone><email>webenquiry@solaray.com.au</email></contact><contact><type>Main</type><name>Jonathan Fisk</name><phone/><email>jfisk@solaray.com.au</email></contact></supplier></lead><lead><id>289028</id><name>Jason</name><lastName>Watson</lastName><phone>0409899502</phone><email>jlwatson@newhue.com.au</email><size>5kW</size><timeframe>In the next 6 months</timeframe><quarterlyBill>$500-$1000</quarterlyBill><ownTheRoofSpace>Yes</ownTheRoofSpace><typeOfRoof>Tile</typeOfRoof><minimumTenSquareMetersNorthFacing>I\'m not sure - Please Help Me Out</minimumTenSquareMetersNorthFacing><roofSlope/><shade/><direction>Not Sure</direction><stories/><features>None</features><submittedDate>2016-11-24 16:00:53</submittedDate><dispatchedDate>2016-11-24 16:35:03</dispatchedDate><address>26 Robin Street Camira</address><installationAddressLineOne>26 Robin Street</installationAddressLineOne><installationAddressLineTwo/><installationSuburb>Camira</installationSuburb><installationState>QLD</installationState><installationPostcode>4300</installationPostcode><installationCountry>Australia</installationCountry><mailingAddressLineOne/><mailingAddressLineTwo/><mailingSuburb/><mailingState/><mailingPostcode/><mailingCountry/><availableForConversation/><importantNotes>On the Nth side of my house I have trees in a council easement that shade my roof pretty heavily in winter as the day goes by.  Can;t do much with that but willing to trim trees in my yard.  I\'m hoping a combination of Est, Wst, and Nth panels may be able to work using the shed/carport for some Nth facing panels. My house roof is not big, it\'s only 100m sq and has a skylight in the middle.  Google earth will show all. thanks     This customer has indicated that they are looking to arrange their own finance independently.</importantNotes><supplier><name>MC Electrical</name><address>1/29 Links Av. North,, Eagle Farm Brisbane ,QLD 4009</address><contact><type>Sales</type><name> </name><phone/><email/></contact><contact><type>Leads</type><name>Mark Cavanagh</name><phone>07 3268 3832</phone><email>tenielle@mcelectrical.com.au</email></contact><contact><type>Main</type><name>Mark Cavanagh</name><phone/><email>mark@mcelectrical.com.au</email></contact></supplier><supplier><name>Absolute Energy Solutions</name><address>, Milton ,QLD </address><contact><type>Sales</type><name> </name><phone/><email/></contact><contact><type>Leads</type><name>Joshua McCulloch</name><phone>1300 783 277</phone><email>admin@aesol.com.au</email></contact><contact><type>Main</type><name>Joshua McCulloch</name><phone/><email>josh@aesol.com.au</email></contact></supplier><supplier><name>SAE Group</name><address>P O Box 6882, serves parts of ,QLD 2486</address><contact><type>Sales</type><name> </name><phone/><email/></contact><contact><type>Leads</type><name>Amy Todd</name><phone>07 5635 2487</phone><email>sales@saegroup.com.au</email></contact><contact><type>Main</type><name>Glen Ashton</name><phone/><email>glen@saegroup.com.au</email></contact></supplier></lead><lead><id>289029</id><name>Peter</name><lastName>Moodie</lastName><phone>03 59893093</phone><email>pamoodie@bigpond.com</email><size>Not Sure. Please help me decide</size><timeframe>In the next 6 months</timeframe><quarterlyBill>Less than $500</quarterlyBill><ownTheRoofSpace>Yes</ownTheRoofSpace><typeOfRoof>Tin / Colourbond</typeOfRoof><minimumTenSquareMetersNorthFacing>I\'m not sure - Please Help Me Out</minimumTenSquareMetersNorthFacing><roofSlope/><shade/><direction>Not Sure</direction><stories/><features>None</features><submittedDate>2016-11-24 16:09:52</submittedDate><dispatchedDate>2016-11-24 16:40:04</dispatchedDate><address>11 Eatons Cutting Red Hill</address><installationAddressLineOne>11 Eatons Cutting</installationAddressLineOne><installationAddressLineTwo/><installationSuburb>Red Hill</installationSuburb><installationState>VIC</installationState><installationPostcode>3937</installationPostcode><installationCountry>Australia</installationCountry><mailingAddressLineOne/><mailingAddressLineTwo/><mailingSuburb/><mailingState/><mailingPostcode/><mailingCountry/><availableForConversation/><importantNotes>Full electric home. 2 occupantsThis customer has indicated that they are looking to arrange their own finance independently.</importantNotes><supplier><name>Energy Aware Victoria</name><address>214 Balaclava Road, Caulfield North ,VIC 3161</address><contact><type>Sales</type><name> </name><phone/><email/></contact><contact><type>Leads</type><name>Nick Burrows</name><phone>1300 658 411</phone><email>leads@energyaware.com.au</email></contact><contact><type>Main</type><name>Joshua Venn</name><phone/><email>joshuav@energyaware.com.au</email></contact></supplier></lead></response>';

        if(bodystr !=null){
            List<Lead> newLeads = leadParserObject.parseLead(bodystr);
            System.debug('@$ newLeads ' + newLeads);
            System.debug('@$ newLeads ' + Lead.fields.LeadId__c);
            if(newLeads != null && !newLeads.isEmpty()){  
               
               Database.UpsertResult[] srList = Database.upsert(newLeads,Lead.fields.LeadId__c,false);

                // Iterate through each returned result
                for (Database.UpsertResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted ID: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Fields that affected this error: ' + err.getFields());
                        }
                    }
                }
               Map<String,Supplier__c> supliermap = leadParserObject.supliermap;
               Map<String,Supplier_Contact__c> suplierContactmap = leadParserObject.suplierContactmap;
               List<Supplier__c> suplierlst = new List<Supplier__c>();
               List<Supplier_Contact__c> suplierconlst = new List<Supplier_Contact__c>();
               
               for(Lead ld : newLeads){
                   integer count = 1;
                   while(count <= 3){
                       String mapkey = 'SP-'+count+'-'+ld.LeadId__c;
                       if(supliermap.containskey(mapkey)){
                           Supplier__c sp = supliermap.get(mapkey);
                           sp.Lead__c = ld.id;
                           suplierlst.add(sp);                           
                       }
                       count++;
                   }
               }
               if(suplierlst.size()>0){
                   Database.upsert(suplierlst,Supplier__c.fields.Lead_Id__c,false);
                   System.debug('@@ suplierContactmap==>'+suplierContactmap);
                   Set<String> keyset = new Set<String>();
                   for(Supplier__c sp : suplierlst){
                       List<String> splitlst = sp.Lead_Id__c.split('-');
                       Integer spcount = 1;
                       
                       
                        while(spcount <= 3){   
                           String mapkey2 = 'SPC-'+spcount+'-'+splitlst[2];   
                           System.debug('@@ mapkey2==>'+mapkey2);             
                           if(suplierContactmap.containskey(mapkey2) && !keyset.contains(mapkey2)){
                               Supplier_Contact__c spc = suplierContactmap.get(mapkey2);
                               spc.Supplier__c = sp.Id;
                               suplierconlst.add(spc);
                               keyset.add(mapkey2);
                           }
                           spcount++;
                       }
                   } 
               }                          
              
               if(suplierconlst.size()>0)
                   Database.upsert(suplierconlst,Supplier_Contact__c.fields.Lead_Id__c,false);
             }
             
             System.debug('@@ newLeads==>'+newLeads);
        }
        
    }
}