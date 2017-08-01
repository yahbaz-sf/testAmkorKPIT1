@isTest
private class AccountTeamMemberControllerTest {

	private static testMethod void testContructor() {
		Account acct = SharedUnitTestUtils.createTestSBU();
		User u = SharedUnitTestUtils.createTestUser();
		insert new AccountTeamMember(AccountId = acct.Id,UserId = u.Id, TeamMemberRole = 'Central Quote Rep');
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(acct);

		AccountTeamMemberController cont = new AccountTeamMemberController(sc);
		system.assertEquals(cont.mems.size(), 1);

	}

	private static testMethod void testAdd() {
		Account acct = SharedUnitTestUtils.createTestSBU();
		User u = SharedUnitTestUtils.createTestUser();
		//insert new AccountTeamMember(AccountId = acct.Id,UserId = u.Id, TeamMemberRole = 'Central Quote Rep');
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(acct);

		AccountTeamMemberController cont = new AccountTeamMemberController(sc);
		//these should fail
		cont.addMember();
		system.assertEquals(cont.mems.size(), 0);
		cont.newMem.UserId = u.Id;
		cont.addMember();
		system.assertEquals(cont.mems.size(), 0);

		cont.newMem.TeamMemberRole = 'Central Quote Rep';
		cont.addMember();
		system.assertEquals(cont.mems.size(), 1);

	}		

	private static testMethod void testDelete() {
		Account acct = SharedUnitTestUtils.createTestSBU();
		User u = SharedUnitTestUtils.createTestUser();
		AccountTeamMember a = new AccountTeamMember(AccountId = acct.Id,UserId = u.Id, TeamMemberRole = 'Central Quote Rep');
		insert a;
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(acct);

		AccountTeamMemberController cont = new AccountTeamMemberController(sc);
		system.assertEquals(cont.mems.size(), 1);

		//these should fail
		ApexPages.currentPage().getParameters().put('delId', a.Id);
		ApexPages.currentPage().getParameters().put('uId', u.Id);

		cont.deleteMember();
		system.assertEquals(cont.mems.size(), 0);
	}		
	
}