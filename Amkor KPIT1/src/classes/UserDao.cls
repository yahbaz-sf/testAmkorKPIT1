public with sharing class UserDao extends BaseDao {
	
	private static final UserDao UserDao = new UserDao();
	
	private UserDao(){  super('User'); }
	
	public static UserDao getInstance() {
        return UserDao;
    }
    
    public User getCurrentUser() {
    	String userId = UserInfo.getUserId();
    	return getUserById(userId);
    }
    
    public User getUserById(String userId) {
    	return (User)getSObjectById(userId);
    }
    
    public List<User> getBuUsers() {
    	RFQ_System_Settings__c settings = RFQ_System_Settings__c.getOrgDefaults();
				
		if (settings == null || StringUtils.isBlank(settings.BU_Pricer_Profile__c)) {
			System.debug(LoggingLevel.Error, 'Couldn\'t get BU users because settings obj not set up, please run the RFQAdminInstaller');
			return null;
		}
				
    	List<Profile> profiles = [Select Id from Profile where Name =: settings.BU_Pricer_Profile__c];
    	
    	if (profiles.size() == 0) {
    		System.debug(LoggingLevel.Error, 'Couldn\'t get BU users because the profile hasn\'t been set up yet.');
    		return null;
    	}
    	
    	return (List<User>)getSObjects('ProfileId = ' + quote(profiles[0].Id));
    }
    
    public User getUserByEmployeeNumber(String empNumber) {
    	List<User> users = getSObjects('EmployeeNumber = ' + quote(empNumber));
    	
    	if (users != null && users.size() > 0) {
    		return users[0];
    	}
    	
    	return null;
    }

    public User getUserBySAPPartnerNumber(string empNumber) {
        List<User> users = getSObjects('SAP_Partner_Number__c = ' + quote(empNumber) + ' AND IsActive = true');

        if(users != null && users.size() > 0) {
            return users[0];
        }
        return null;
    }

    public List<User> getUsersBySAPPartnerNumbers(Set<String> sapIds) {
        return (List<User>)getSObjectByIdSet('SAP_Partner_Number__c', sapIds, 'IsActive = true');
    }

    @future
    public static void deleteAccountTeamForInactiveUser(Set<Id> userIds)
    {
        if(userIds.size() > 0) 
        {
            delete [select Id from AccountTeamMember where UserId in: userIds];
            delete [select Id from RFQ__Share where UserOrGroupId in: userIds];
        }
    }

}