/*************************************************************************
*
* PURPOSE: Unit Tests for the RFQViewController
*
* CLASS: RFQViewControllerTest
* CREATED: 8/15/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
***************************************************************************/
@isTest
private class RFQViewControllerTest {

	public static testmethod ApexPages.Standardcontroller setupController() {
		RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
		ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);

		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(rfq);
		return sc;

	}

	private static testmethod RFQViewController testMessages() {
		ApexPages.Standardcontroller sc = setupController();
		ApexPages.currentPage().getParameters().put('message','some error');
		ApexPages.currentPage().getParameters().put('type','error');
		RFQViewController rfqcont = new RFQViewController(sc);
		system.assert(ApexPages.currentPage().getParameters().get('message') == 'some error');

		ApexPages.currentPage().getParameters().put('message','some info');
		ApexPages.currentPage().getParameters().put('type','info');
		rfqcont = new RFQViewController(sc);
		system.assert(ApexPages.currentPage().getParameters().get('message') == 'some info');

		ApexPages.currentPage().getParameters().put('message','some warn');
		ApexPages.currentPage().getParameters().put('type','warn');
		rfqcont = new RFQViewController(sc);
		system.assert(ApexPages.currentPage().getParameters().get('message') == 'some warn');

		ApexPages.currentPage().getParameters().put('message','some confirm');
		ApexPages.currentPage().getParameters().put('type','confirm');
		rfqcont = new RFQViewController(sc);
		system.assert(ApexPages.currentPage().getParameters().get('message') == 'some confirm');

		return rfqcont;
		
	}

	private static testmethod void testAssignToMe() {
		RFQViewController rfqcont = testMessages();
		PageReference pg = rfqcont.assignToMe();
		system.assert(pg.getUrl().contains('/apex/RFQView'));

	}

	private static testmethod void testAssignToBPG() {
		RFQViewController rfqcont = testMessages();
		PageReference pg = rfqcont.assignToBPG();
		system.assert(pg.getUrl().contains('error'));
	}

}