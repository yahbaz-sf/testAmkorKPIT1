trigger UserInactive on User (after insert, after update) {
	User[] newItems = Trigger.New;
	Set<Id> userIds = new Set<Id>();

	for(User u : newItems) {
		if(!u.IsActive) userIds.add(u.Id);
	}

	//https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_dml_non_mix_sobjects.htm
	UserDao.deleteAccountTeamForInactiveUser(userIds);
}