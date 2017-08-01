@isTest
private class AccountDaoTest {

	private static testMethod void testAccountInstallDummy() {
        Test.startTest();
		AccountDao.installAccounts();
		Test.stopTest();
	}

}