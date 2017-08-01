/*************************************************************************
*
* PURPOSE: Load the CM Factory Value 
*
* CLASS: CMFactoryValueDao
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/  
public with sharing class CMFactoryValueDao  extends BaseDao 
{  
    private static final CMFactoryValueDao dao = new CMFactoryValueDao();
 
    private CMFactoryValueDao(){  super('CM_Factory_Value__c'); }
    
    public static CMFactoryValueDao getInstance() {
        return dao;
    }
    
    public CM_Factory_Value__c getById(String recordId) {
        return (CM_Factory_Value__c)getSObjectById(recordId); 
    }
    
    public List<CM_Factory_Value__c> getByVersion(String versionId) 
    {
        return (List<CM_Factory_Value__c>)getSObjects('CM_Version__c = ' + quote(versionId) , ''); 
    }

}