/*************************************************************************
*
* PURPOSE: Tests for the RFQ Item Escalation page
*
* CLASS: RFQItemEscalationControllerTest
* CREATED: 4/4/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/

@isTest
private class RFQItemEscalationControllerTest {
	
	/**
    * Tests the escalation constructor for the usual conditions
    */
	private static testmethod void testConstructor() {
	    
	    RFQItemEscalationController rfqItemCont = setupController();
	    
	    Test.startTest();
	    System.assert(rfqItemCont.layout != null);
	    System.assert(rfqItemCont.layout.sectionMap != null);
	    System.assert(rfqItemCont.wrapper.specificRfqItem != null);
	    System.assert(rfqItemCont.wrapper.wireConfigurations.size() > 0);
	    Test.stopTest();
	}
	
	private static testmethod void testCancel() {
		
		RFQItemEscalationController rfqItemCont = setupController();
	    rfqItemCont.wrapper.rfqItem.Status__c = 'Price Submit';

	    // In an actual use case if status is price submit then isNew would be false
	    rfqItemCont.isNewItem = false;
	    
	    Test.startTest();
		PageReference pg =  rfqItemCont.cancelItem();
		DebugUtils.getInstance().log('URL is: ' + pg.getUrl());
		System.assert(pg.getUrl().contains('RFQItemView'));
		Test.stopTest();
	}
	
	public static RFQItemEscalationController setupController() {
		
		//make sure the sections and a layout exist
	    RFQAdminInstaller.install();
	    PBGAInstaller.install();
	    
	 
	    RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
	    
	    //fake like we are at the create screen
	    ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);
		CreateRFQItemController cont = new CreateRFQItemController();
		cont.numberOfWires = '1';
	    CreateRFQItemControllerTest.testDoUserSelection(cont, 'PBGA');
	    
	    cont.createLineItem();
	    
	    RFQ_Item__c rfqItem = cont.rfqItem;
	    
	    ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(rfqItem);
	    RFQItemEscalationController  rfqItemCont = new RFQItemEscalationController(sc);
	    return rfqItemCont;
	}

}