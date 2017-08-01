public with sharing class RFQItemCloneSaveController extends BaseController {
	
	private RFQItemWrapper originalWrapper;
	private String rfqId;
	
	public RFQItemCloneSaveController() {
		
		rfqId = getParam('newid');
		system.debug('--->RFQItemCloneSaveController, rfqId : ' + rfqId);
		String rfqItemId = getParam('id');
		originalWrapper = RFQItemDao.getInstance().getWrapperById(rfqItemId);
		
	}
	
	public PageReference cloneItem() {
		
		RFQILayout layout = PFFieldDefDao.getInstance().getBULayoutForWrapper(originalWrapper);
		RFQItemWrapper cloneWrapper = RFQItemDao.getInstance().cloneLineItem(originalWrapper, RFQItemDao.STATUS_NEW, false, layout);
		cloneWrapper.rfqItem.RFQ__c = rfqId;
		system.debug('--->RFQItemCloneSaveController.cloneItem, cloneWrapper.rfqItem : ' + cloneWrapper.rfqItem);
		if (!RFQItemDao.getInstance().saveLineItem(cloneWrapper)) return null;
		return new PageReference('/' + cloneWrapper.rfqItem.Id);
	}

}