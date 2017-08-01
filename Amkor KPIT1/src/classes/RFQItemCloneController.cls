public with sharing class RFQItemCloneController extends RFQItemController {
	
	public RFQItemCloneController(ApexPages.StandardController sc) {
		super(sc);
	}  
	
	public PageReference cancel() {
		return new PageReference('/apex/RFQItemView?id=' + wrapper.rfqItem.Id);
	}
	
	public PageReference cloneToCurrent() {
		RFQILayout layout = PFFieldDefDao.getInstance().getBULayoutForWrapper(wrapper);
		RFQItemWrapper cloneWrapper = RFQItemDao.getInstance().cloneLineItem(wrapper, RFQItemDao.STATUS_NEW, false, layout);
		return new PageReference('/apex/RFQItemView?id=' + cloneWrapper.rfqItem.Id);
	}
	
	public PageReference cloneToNew() {
		
		String rfqKey = Schema.SObjectType.RFQ__c.getKeyPrefix();
		String saveUrl = EncodingUtil.urlEncode('/apex/RFQItemCloneSave?id=' + wrapper.rfqItem.Id + '&rfqId=' + rfqKey,'UTF-8');
		return new PageReference('/'+rfqKey+'/e?retURL=%2F'+rfqKey+'%2Fo&saveURL=' + saveUrl);
	}
}