@isTest
private class RFQItemCloseSaveControllerTest {
	private static testmethod void testPF() {
		RFQItemCloneSaveController cont = setupController();
		Test.startTest();
		PageReference pf = cont.cloneItem();
		system.assert(pf != null);
		Test.stopTest();
		
	}
	
	public static RFQItemCloneSaveController setupController() {
		
		//make sure the sections and a layout exist
	    RFQAdminInstaller.install();
	    DualLeadframeInstaller.installTest();
	    
	    RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
	    
	    //fake like we are at the create screen
	    ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);
		CreateRFQItemController cont = new CreateRFQItemController();
	    CreateRFQItemControllerTest.testDoUserSelection(cont);
	    
	    //create a line item, this should create an RFQ_Item__c pointing to RFQ__c
	    //as well as a RFQI_SOIC_150mil_body__c object pointing to RFQ__c
	    cont.createLineItem();
	    
	    RFQ_Item__c rfqItem = cont.rfqItem;
	    
	    ApexPages.currentPage().getParameters().put('id',rfqItem.Id);
	    RFQItemCloneSaveController rfqItemCont = new RFQItemCloneSaveController();
	    return rfqItemCont;
	}
    
}