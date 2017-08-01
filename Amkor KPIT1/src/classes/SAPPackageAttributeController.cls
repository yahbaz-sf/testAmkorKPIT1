public with sharing class SAPPackageAttributeController extends BaseController{
	
	public SAP_Package_Attribute__c attribute {get; set;}
	
	public SAPPackageAttributeController(ApexPages.Standardcontroller sc) {
		attribute = (SAP_Package_Attribute__c)sc.getRecord();
	}
	
	public PageReference enable() {
	    attribute.Status__c = 'Active';
	    update attribute;	
		return new PageReference('/'+attribute.Id);
	}
}