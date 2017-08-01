/*************************************************************************
* 
* PURPOSE: Test methods for RFQController 
*          
* CLASS: RFQControllerTest
* CREATED: 03/06/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
@isTest
private class RFQControllerTest {
	
	/**
    * Tests constructor initialization for RFQController
    */
	private static testmethod void testConstructor() {
		RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
		ApexPages.StandardController sc = new ApexPages.StandardController(rfq);
		RFQController cont = new RFQController(sc);
		System.assert(cont != null);
	}
	
	/**
    * Tests Add Item button on the RFQ View page
    */
	private static testmethod void testAddItem() {
        RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
		ApexPages.StandardController sc = new ApexPages.StandardController(rfq);
		RFQController cont = new RFQController(sc);
		System.assert(cont.addItem() != null);
	}

}