public class MassCaseDelete {
    public List<Case> cases{get;private set;}
    public MassCaseDelete(ApexPages.StandardSetController stdSetController){
        cases = (List<Case>) stdSetController.getSelected();
    }
    public PageReference deleteRecords() {
        try {
            if(cases.size() > 0){
                delete cases;    
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e);
        }
        //return new ApexPages.StandardSetController(cases).cancel();
        PageReference reference=new PageReference('https://lanecorp.lightning.force.com/lightning/o/Case/list?filterName=Recent');
        reference.setRedirect(true);
        return reference;
    }
    
    public PageReference ret() {
        PageReference reference=new PageReference('https://lanecorp.lightning.force.com/lightning/o/Case/list?filterName=Recent');
        reference.setRedirect(true);
        return reference;
    }
}