/*************************************************************************
*
* PURPOSE: CMMarginVersionDao
*
* CLASS: CMMarginVersionDao
* CREATED: 7/10/2013 Ethos Solutions - www.ethos.com
* AUTHOR: 
***************************************************************************/
public with sharing class CMMarginVersionDao extends BaseDao 
{
	private static final CMMarginVersionDao CMMarginVersionDao = new CMMarginVersionDao();
	
	private CMMarginVersionDao(){  super('CM_Margin_Version__c'); }
	
	public static CMMarginVersionDao getInstance() {
        return CMMarginVersionDao; 
    }
    
    public CM_Margin_Version__c getById(String versionId) {
    	return (CM_Margin_Version__c)getSObjectById(versionId);
    }
    
	//---Get the list of Versions by Payer Group and Status
    public List<CM_Margin_Version__c> getByPGAndStatus(String pgId, String status) 
    {	
    	return (List<CM_Margin_Version__c>)getSObjects('Product_Group__c =' + BaseDao.quote(pgId) + ' and Status__c =' + BaseDao.quote(status), 'Version__c desc');
    }
    
    public List<CM_Margin_Version__c> getByPG(String pgId) 
    {	
    	return (List<CM_Margin_Version__c>)getSObjects('Product_Group__c =' + BaseDao.quote(pgId), 'Version__c desc');
    }
    
    //---Get the next Version Number
    public Decimal getNextVersionNum(String pgId)
    {
    	Decimal returnVal = 1;
    	
    	List<CM_Margin_Version__c> verList = getByPG(pgId);
    	
    	if (verList != null && verList.size() > 0) 
    	{
    		returnVal = verList[0].Version__c + 1;
    	}
    	
    	return returnVal;
    }
}