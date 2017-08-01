/*************************************************************************
*
* PURPOSE: 
*
* CLASS: AccountPGSettingDao
* CREATED: 5/15/2013 Ethos Solutions - www.ethos.com
* AUTHOR: 
***************************************************************************/
public with sharing class AccountPGSettingDao extends BaseDao {
	
	private static final AccountPGSettingDao dao = new AccountPGSettingDao();
	
	private AccountPGSettingDao(){  super('Account_PG_Setting__c'); }
	
	public static AccountPGSettingDao getInstance() {
        return dao;
    }
    
    public Account_PG_Setting__c getById(String id) {
    	return (Account_PG_Setting__c)getSObjectById(id);
    }
    
    public List<Account_PG_Setting__c> getByAccount(String accountId) 
    {
    	return (List<Account_PG_Setting__c>)getSObjects('Account__c = ' + quote(accountId)); 
    }
    
    public Account_PG_Setting__c getByAccountPG(String accountId, String pgId) 
    {
    	List<Account_PG_Setting__c> retList = getSObjects('Account__c = ' + quote(accountId) + ' AND Product_Group__c = ' + quote(pgId));
    	return retList == null || retList.size() == 0 ? null : retList[0]; 
    }
}