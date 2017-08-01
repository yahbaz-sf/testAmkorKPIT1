/*************************************************************************
*
* PURPOSE: Unit Tests for SAPGoldBase 
*
* CLASS: ProductGroupDaoTest
* CREATED: 7/12/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
@isTest
private class SAPGoldBaseDaoTest {
	
	/*
    

	private static testmethod void testGetByAccountAndNewest() {
		
		Account a = new Account(Name='test', AccountNumber='12345678');
		insert a;
		a = AccountDao.getInstance().getAccountByNumber('12345678').get(0);


		insert new SAP_Gold_Base__c(Valid_From_date__c = Date.today(), Account__c = a.Id);
		List<SAP_Gold_Base__c> newestList = SAPGoldBaseDao.getInstance().getByAccountAndNewest(a.Id);
		System.assert(newestList.size() == 1);
		System.assert(newestList[0].Newest__c);

		insert new SAP_Gold_Base__c(Valid_From_date__c = Date.today() + 2, Account__c = a.Id);
		newestList = SAPGoldBaseDao.getInstance().getByAccountAndNewest(a.Id);

		System.assert(newestList.size() == 1);


	}
	

	private static testmethod void testGetById() {
		Account a = new Account(Name='test', AccountNumber='12345678');
		insert a;
		a = AccountDao.getInstance().getAccountByNumber('12345678')[0];

		SAP_Gold_Base__c testBase = new SAP_Gold_Base__c(Valid_From_date__c = Date.today(), Account__c = a.Id);
		insert testBase;
		testBase = [select id, Valid_From_date__c, Account__c, Newest__c from SAP_Gold_Base__c where Account__c =: a.Id];

		SAP_Gold_Base__c testBase2 = SAPGoldBaseDao.getInstance().getById(testBase.Id);
		System.assert(testBase.Id == testBase2.Id);
		System.assert(testBase.Newest__c);
	
	}

	*/
}