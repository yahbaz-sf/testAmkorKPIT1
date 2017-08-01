public with sharing class SAPPricingAttributeController extends BaseController {
	
	public SAP_Pricing_Attribute__c attribute {get; set;}
	
	public SAPPricingAttributeController(ApexPages.Standardcontroller sc) {
		attribute = (SAP_Pricing_Attribute__c)sc.getRecord();
	}
	
	public PageReference enableForPackageFamily() {
		return new PageReference('/apex/SAPPackageAttributeCreate?id='+attribute.Id);
	}
}