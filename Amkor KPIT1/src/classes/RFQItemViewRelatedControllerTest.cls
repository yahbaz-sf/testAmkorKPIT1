/*************************************************************************
*
* PURPOSE: Test the RFQItemViewRelatedController class
*
* CLASS: RFQItemViewRelatedControllerTest
* CREATED: 5/22/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/
@isTest
private class RFQItemViewRelatedControllerTest {

    static testMethod void testSimpleSearch() {
    	Test.setMock(WebServiceMock.class, new SAPTransmitRespMock());
		RFQ_Item__c rfqItem = setupData();
		
		ApexPages.currentPage().getParameters().put('mode', 'simple');
		ApexPages.currentPage().getParameters().put('cpnId', rfqItem.Configured_Part_Number__c);
		ApexPages.currentPage().getParameters().put('rfqItemId', rfqItem.Id);
		
		Test.startTest();
		
		RFQItemViewRelatedController cont = new RFQItemViewRelatedController();
		
		System.assertEquals(2, cont.results.size(), 'Should have two RFQ Items with the CPN');
		
		Test.stopTest();
    }
    
    static testMethod void testAdvancedSearch() {
    	Test.setMock(WebServiceMock.class, new SAPTransmitRespMock());
		RFQ_Item__c rfqItem = setupData();
		
		ApexPages.currentPage().getParameters().put('mode', 'advanced');
		ApexPages.currentPage().getParameters().put('cpnId', rfqItem.Configured_Part_Number__c);
		ApexPages.currentPage().getParameters().put('rfqItemId', rfqItem.Id);
		
		Account a = [Select Id from Account limit 1];
		
		Test.startTest();

		RFQItemViewRelatedController cont = new RFQItemViewRelatedController();
		cont.accountHolder = new SAP_Billing_Item__c(Account__c = a.Id);
		cont.startDateHolder = new RFQ__c(Due_Date__c = Date.today().addDays(-1));
		cont.endDateHolder = new RFQ__c(Due_Date__c = Date.today().addDays(3));
		
		System.assertEquals(null, cont.results,  'Advanced search should not auto-search');
		
		PageReference ref = cont.performSearch();
		
		System.assertEquals(2, cont.results.size(), 'Should have got 2 records based on the search criteria');
		
		Test.stopTest();
    }
    
    private static RFQ_Item__c setupData() {
    	Account a = SharedUnitTestUtils.createTestSBU();
    	
    	//Bhanu - 3-Mar-2016 : 597492 Missing NRE on EXCEL + "Projected_Revenue__c" is now mandatory
		//Providing Mandatory field "Projected_Revenue__c" on RFQ Object in TestSetup
    	//RFQ__c newRfq = new RFQ__c(SBU_Name__c = a.Id, RFQ_Name__c = 'Test RFQ');
    	RFQ__c newRfq = new RFQ__c(SBU_Name__c = a.Id, RFQ_Name__c = 'Test RFQ', Projected_Revenue__c = 1234);
    	insert newRfq;
    	
    	Configured_Part_Number__c cpn = new Configured_Part_Number__c();
    	insert cpn;
    	
    	Configured_Part_Number__c cpn2 = new Configured_Part_Number__c();
    	insert cpn2;
    	
    	RFQ_Item__c rfq1 = new RFQ_Item__c(RFQ__c = newRfq.Id, Configured_Part_Number__c = cpn.Id, Status__c = RFQItemDao.STATUS_PROGRAM_WIN);
    	RFQ_Item__c rfq2 = new RFQ_Item__c(RFQ__c = newRfq.Id, Configured_Part_Number__c = cpn.Id, Status__c = RFQItemDao.STATUS_PROGRAM_LOSS);
    	RFQ_Item__c rfq3 = new RFQ_Item__c(RFQ__c = newRfq.Id, Configured_Part_Number__c = cpn.Id, Status__c = RFQItemDao.STATUS_PRODUCTION_WIN);
    	RFQ_Item__c rfq4 = new RFQ_Item__c(RFQ__c = newRfq.Id, Configured_Part_Number__c = cpn2.Id, Status__c = RFQItemDao.STATUS_PROGRAM_WIN);
    	
    	insert rfq1;
    	insert rfq2;
    	insert rfq3;
    	insert rfq4;
    	
    	return rfq1;
    }
}