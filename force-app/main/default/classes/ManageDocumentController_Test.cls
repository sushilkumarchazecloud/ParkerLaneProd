@isTest
private class ManageDocumentController_Test {
    static testMethod void checkApplicantTwo(){
         Opportunity opp = new Opportunity(Name='Test', StageName='open', CloseDate= Date.today());
         Insert opp;
        Manage_Document__c Md = new Manage_Document__c(isJoint__c = true, Application_Type__c ='Home Loan Refinance;Home Purchase', Category__c='Identification', Document__c='Passport');
        Insert Md;
        Contact con = new Contact(LastName = 'Test', Email='test@tet.com');
        insert con;
        OpportunityContactRole Oc = new OpportunityContactRole();
        Oc.IsPrimary = true;
        oc.ContactId= con.Id;
        oc.OpportunityId = opp.Id;
        insert oc;
        boolean test = ManageDocumentController.checkApplicantTwo(opp.Id);
        //object op1 = ManageDocumentController.getApplicantOne();
        object opJ = ManageDocumentController.getJointApplication();
        object SC = ManageDocumentController.getSelectedCategory('Home Loan Refinance');
        Md.IsJoint__c = false;
        update Md;
        object op2 = ManageDocumentController.getApplicantTwo();
        object op1 = ManageDocumentController.getApplicantOne();
        ManageDocumentController.sendMail('balkishan.kachawa@gmail.com','sushil.verma6@gmail.com','hello how are you?');
        ManageDocumentController.createDocumentRequest('[{"label":"ApplicantOne","value":[{"categry":"Income","selectedItem":[{"label":"Payslips : 2 recent consecutive (no older than 6 weeks)","value":"Payslips","Discription":"","isBankStatment":false}]},{"categry":"Identification","selectedItem":[{"label":"Driver’s license (front and back)","value":"Driver’s license (front and back)","Discription":"","isBankStatment":false},{"label":"Medicare Card","value":"Medicare Card","Discription":"","isBankStatment":false}]}]},{"label":"JointApp","value":[{"categry":"Assets","selectedItem":[{"label":"Recent council rates notice","value":"Recent council rates notice","Discription":"","isBankStatment":false}]},{"categry":"Living Expenses","selectedItem":[{"label":"Last 3 months transaction bank statements","value":"Last 3 months transaction bank statements","Discription":"","isBankStatment":true}]}]}]',true, opp.Id,true);
    }
}