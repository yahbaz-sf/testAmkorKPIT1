/*************************************************************************
*
* PURPOSE: Load the CM Test Model Objects
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/  
public with sharing class CMTestModelDao  extends BaseDao 
{  
    private static final CMTestModelDao dao = new CMTestModelDao();
 
    private CMTestModelDao(){  super('CM_Test_Model__c'); }
    
    public static CMTestModelDao getInstance() {
        return dao;
    }
    
    public CM_Test_Model__c getById(String recordId) {
        return (CM_Test_Model__c)getSObjectById(recordId); 
    }
    
    public List<CM_Test_Model__c> getByVersion(String versionId) 
    {
        return (List<CM_Test_Model__c>)getSObjects('CM_Version__c = ' + quote(versionId) , ''); 
    }
    
    public List<CM_Test_Model__c> getByNameVersionAndFactory(String name, Id versionId, String factory) 
    {
    	return (List<CM_Test_Model__c>)getSObjects('Name = ' + quote(name) + ' AND CM_Version__c = ' + quote(versionId) + 'AND Factory__c = ' + quote(factory), ''); 
    }
}