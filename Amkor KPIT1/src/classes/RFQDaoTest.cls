/*************************************************************************
*
* PURPOSE: Test the methods in RFQDao.cls
*
* CLASS: RFQDao
* CREATED: 8/7/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Alejandro Molina
***************************************************************************/
@isTest
public class RFQDaoTest {
	
	public static testmethod void testSave() {

        Account testAccount = SharedUnitTestUtils.createTestSBU();

		Test.startTest();
		RFQDao dao = RFQDao.getInstance();
		RFQ__c testRFQ = new RFQ__c();

		testRFQ.SBU_Name__c = testAccount.Id;
		testRFQ.RFQ_Name__c = 'Test RFQ';
		
		//Bhanu - 3-Mar-2016 : 597492 Missing NRE on EXCEL + "Projected_Revenue__c" is now mandatory
		//Providing Mandatory field "Projected_Revenue__c" on RFQ Object in TestSetup
		testRFQ.Projected_Revenue__c = 1234;
		
		insert testRFQ;
		testRFQ = dao.save(testRFQ);
		Test.stopTest();
	}
	public static testmethod void testGreater() {
        
        Account testAccount = SharedUnitTestUtils.createTestSBU();

		Test.startTest();
		RFQDao dao = RFQDao.getInstance();
		RFQ__c testRFQ = new RFQ__c();

		testRFQ.SBU_Name__c = testAccount.Id;
		testRFQ.RFQ_Name__c = 'Test RFQ';
		
		//Bhanu - 3-Mar-2016 : 597492 Missing NRE on EXCEL + "Projected_Revenue__c" is now mandatory
		//Providing Mandatory field "Projected_Revenue__c" on RFQ Object in TestSetup
		testRFQ.Projected_Revenue__c = 1234;
		
		insert testRFQ;

		testRFQ.Status__c = 'In Progress';
		system.assert(dao.statusGreaterOrEqual(testRFQ, 'New / Revision'));
		Test.stopTest();
	}

	public static testmethod void testLess() {
		Account testAccount = SharedUnitTestUtils.createTestSBU();
		Test.startTest();
		RFQDao dao = RFQDao.getInstance();
		RFQ__c testRFQ = new RFQ__c();



		testRFQ.SBU_Name__c = testAccount.Id;
		testRFQ.RFQ_Name__c = 'Test RFQ';
		
		//Bhanu - 3-Mar-2016 : 597492 Missing NRE on EXCEL + "Projected_Revenue__c" is now mandatory
		//Providing Mandatory field "Projected_Revenue__c" on RFQ Object in TestSetup
		testRFQ.Projected_Revenue__c = 1234;
		
		insert testRFQ;

		testRFQ.Status__c = 'In Progress';
		system.assert(dao.statusLessOrEqual(testRFQ, 'Closed'));
		Test.stopTest();
	}
}