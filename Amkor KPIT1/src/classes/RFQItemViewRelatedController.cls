/*************************************************************************
*
* PURPOSE: Controller for the RFQ Item view related page
*
* CLASS: RFQItemViewRelatedController
* CREATED: 5/22/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/
public with sharing class RFQItemViewRelatedController extends BaseController {
	
	public Id sourceRfqItemId { get; set; }
	public Id cpnId { get; set; }
	public Boolean isAdvancedSearch { get; set; }
	
	// Holder objects that the search query input fields can attach to
	// Can't use straight class properties because apex:inputFields will only work on sObjects
	// TODO There has to be a better way to do this...
	public SAP_Billing_Item__c accountHolder { get; set; }
	public RFQ__c startDateHolder { get; set; }
	public RFQ__c endDateHolder { get; set; }
	
	public List<RFQ_Item__c> results { get; set; }
	  
	public RFQItemViewRelatedController() {
		String mode = getParam('mode');
		
		cpnId = getParam('cpnId');
		isAdvancedSearch = StringUtils.isMatch(mode, 'advanced');
		sourceRfqItemId = getParam('rfqItemId');
		
		accountHolder = new SAP_Billing_Item__c();
		startDateHolder = new RFQ__c();
		endDateHolder = new RFQ__c();
		
		if (!isAdvancedSearch) {
			results = RFQItemDao.getInstance().getSimilarItems(cpnId, 10);
		}
	}
	
	
	public PageReference performSearch() {
		results = RFQItemDao.getInstance().getSimilarItems(startDateHolder.SBU_Name__c, startDateHolder.Due_Date__c, endDateHolder.Due_Date__c, cpnId);
		
		return null;
	}

}