public with sharing class RFQNewOppController extends BaseController{

    public Opportunity newOpp {get; set;}
    public Boolean showUpside {get; set;}

	public RFQNewOppController(ApexPages.StandardController sc) {
        //User currentUser = 
        newOpp = new Opportunity();
        showUpside = false;
    }

    public PageReference saveOnly() {
    	saveOpp();
    	PageReference pg = new ApexPages.StandardController(newOpp).view();
        pg.setRedirect(true);
        return pg;
    }

    public PageReference saveAndNew() {
    	saveOpp();

    	PageReference pg = new PageReference('/apex/RFQNewOpp');
    	pg.setRedirect(true);
    	return pg;
    }

    private void saveOpp() {
        RecordType rt = [select Id, Name from RecordType where Name = 'Existing Opp' AND sObjectType = 'Opportunity' limit 1];
        newOpp.RecordTypeId = rt.Id;
        insert newOpp;
    }

    public PageReference cancel() {
    	PageReference pg = new PageReference('/006/o');
    	pg.setRedirect(true);
    	return pg;
    }

    public PageReference shouldShowUpside() {
    	showUpside = true;
    	return null;
    }

    public PageReference shouldHideUpside() {
    	showUpside = false;
    	return null;
    }

    public List<SelectOption> getPackageFamilies() {
        
        List<Package_Family__c> packageFamilies 
            = PackageFamilyDao.getInstance().getAllPackageFamilies();
        packageFamilies.sort();
 
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        for(Package_Family__c packageFamily : packageFamilies) {
            if(packageFamily.Name != 'ALL') options.add(new SelectOption(packageFamily.Id,packageFamily.Name));
        }
        return options;
    }
}