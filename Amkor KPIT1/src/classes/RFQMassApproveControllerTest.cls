/*************************************************************************
*
* PURPOSE: Tests the RFQMassApproveController Class
*
* CLASS: RFQMassApproveControllerTest
* CREATED: 1/15/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
***************************************************************************/

@isTest
private class RFQMassApproveControllerTest {
	
	public static RFQMassApproveController setup() {
		RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
		Package_Family__c pf = SharedUnitTestUtils.createTestPackageFamily();
		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem(pf.Name, rfq);
		wrapper.rfqitem.Status__c = RFQItemDao.STATUS_PRICE_PENDING_BU;
		wrapper.rfqitem.Has_Been_BU_Imported__c = true;
		RFQItemDao.getInstance().saveLineItem(wrapper);
		ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);
		RFQMassApproveController cont = new RFQMassApproveController();

		return cont;
	} 

	private static testMethod void testCancel() {
		RFQMassApproveController cont = setup();
		PageReference pg = cont.returnToRfq();
		system.assert(StringUtils.contains(pg.getUrl(),'/apex/RFQView?id='));
	}

	private static testMethod void testgetProductGroupOptions() {
		RFQMassApproveController cont = setup();
		List<SelectOption> options = cont.getProductGroupOptions();
		//*-- Select --* && Product group returned
		system.assert(options.size() == 2, options.size());
	}

	private static testMethod void testApprove() {
		RFQMassApproveController cont = setup();
		cont.selectedProductGroup = [select Id from Product_Group__c where Name =:'Unit Test Product Group'].id;
		cont.setItemList();
		system.assert(cont.currentItems.size()==1, cont.currentItems.size());
		cont.currentItems[0].selected = true;
		cont.currentItems[0].approvalComment = 'Test Approval Comment';
		cont.massApprove();
		system.assert(cont.selectedItems.size()==1, cont.currentItems.size());
		cont.selectedItems[0].approvalComment = 'Test Approval Comment';
		RFQItemWrapper wrapper = RFQItemDao.getInstance().getWrapperById(cont.selectedItems[0].item.Id);
		ApprovalUtils.startApproval(wrapper.rfqitem.Id, 'Starting Test Approval');
		cont.submitNextItemApprove();
		wrapper = RFQItemDao.getInstance().getWrapperById(cont.currentItems[0].item.Id);
		system.assert(wrapper.rfqitem.Status__c == RFQItemDao.STATUS_PRICE_COMPLETE, wrapper.rfqitem.Status__c);
	}

	private static testMethod void testReject() {
		RFQMassApproveController cont = setup();
		cont.selectedProductGroup = [select Id from Product_Group__c where Name =:'Unit Test Product Group'].id;
		cont.setItemList();
		system.assert(cont.currentItems.size()==1, cont.currentItems.size());
		cont.currentItems[0].selected = true;
		cont.currentItems[0].approvalComment = 'Test Approval Comment';
		cont.massApprove();
		system.assert(cont.selectedItems.size()==1, cont.currentItems.size());
		RFQItemWrapper wrapper = RFQItemDao.getInstance().getWrapperById(cont.selectedItems[0].item.Id);
		ApprovalUtils.startApproval(wrapper.rfqitem.Id, 'Starting Test Approval');
		cont.submitNextItemReject();
		wrapper = RFQItemDao.getInstance().getWrapperById(cont.currentItems[0].item.Id);
		system.assert(wrapper.rfqitem.Status__c == RFQItemDao.STATUS_PRICE_DECLINED, wrapper.rfqitem.Status__c);
	}

	private static testMethod void testNoBid() {
		RFQMassApproveController cont = setup();
		cont.selectedProductGroup = [select Id from Product_Group__c where Name =:'Unit Test Product Group'].id;
		cont.setItemList();
		system.assert(cont.currentItems.size()==1, cont.currentItems.size());
		cont.currentItems[0].selected = true;
		cont.currentItems[0].approvalComment = 'Test Approval Comment';
		cont.massApprove();
		system.assert(cont.selectedItems.size()==1, cont.currentItems.size());
		RFQItemWrapper wrapper = RFQItemDao.getInstance().getWrapperById(cont.selectedItems[0].item.Id);
		ApprovalUtils.startApproval(wrapper.rfqitem.Id, 'Starting Test Approval');
		cont.submitNextItemNoBid();
		wrapper = RFQItemDao.getInstance().getWrapperById(cont.currentItems[0].item.Id);
		system.assert(wrapper.rfqitem.Status__c == RFQItemDao.STATUS_NO_BID, wrapper.rfqitem.Status__c);
	}
}