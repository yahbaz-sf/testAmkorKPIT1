/*************************************************************************
*
* PURPOSE: Load CM PF Value
*
* CLASS: CMPFValuesDao
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMPFValueDao extends BaseDao 
{  
    private static final CMPFValueDao dao = new CMPFValueDao();
 
    private CMPFValueDao(){  super('CM_PF_Value__c'); }
    
    public static CMPFValueDao getInstance() {
        return dao;
    }
    
    public CM_PF_Value__c getById(String recordId) {
        return (CM_PF_Value__c)getSObjectById(recordId); 
    }
    
    public List<CM_PF_Value__c> getByVersion(String versionId) 
    {
    	return (List<CM_PF_Value__c>)getSObjects('CM_Version__c = ' + quote(versionId) , ''); 
    }
       
    public List<CM_PF_Value__c> getByPFAndVersion(String versionId, String pfId) 
    {
    	return (List<CM_PF_Value__c>)getSObjects('CM_Version__c = ' + quote(versionId) + 'AND Package_Family__c = ' + quote(pfId) , ''); 
    }

    public List<CM_PF_Value__c> getBySubPFAndVersion(String versionId, String subPf) {
        return (List<CM_PF_Value__c>)getSObjects('CM_Version__c = ' + quote(versionId) + 'AND PF_Sub_Class_1__c = ' + quote(subPf) , ''); 
    } 
}