/*************************************************************************
*
* PURPOSE: DAO for the Factory__c object
*
* CLASS: FactoryDao
* CREATED: 7/10/2012 Ethos Solutions - www.ethos.com  
* AUTHOR: Nathan Pilkington 
***************************************************************************/ 

public with sharing class FactoryDao extends BaseDao {
	private static FactoryDao dao = new FactoryDao();
	private FactoryDao() {
		super('Factory__c');
	}

	public static FactoryDao getInstance() {
		return dao;
	}

	public List<Factory__c> getAllFactories() {
		return getSObjectsList();
	}

	public Factory__c getFactoryByName(String factoryName) {
		return [select Id, Name from Factory__c where Name =: factoryName];
	}
}