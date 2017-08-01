/*************************************************************************
*
* PURPOSE: 
*
* CLASS: AccountFileMapDao
* CREATED: 3/12/2012 Ethos Solutions - www.ethos.com
* AUTHOR: 
***************************************************************************/
public with sharing class AccountFileMapDao extends BaseDao  {
	
    private static final AccountFileMapDao AccountFileMapDao = new AccountFileMapDao();
    private ColumnDao ColumnDao;
    private PfMapDao PfMapDao;
    private PfFieldMapDao PfFieldMapDao;
	 
    private static String activeRtId;
    private static String inactiveRtId;
    private static String draftRtId;
	 
    private AccountFileMapDao() {  
	 	super('RFQ_Ac_Map__c'); 
	 	ColumnDao = new ColumnDao();
	 	PfMapDao = new PfMapDao();
	 	PfFieldMapDao = new PfFieldMapDao();
    }
	 
	public static AccountFileMapDao getInstance() {
        return AccountFileMapDao;
    }
    
    public RFQ_Ac_Map__c getMapById(String mapId) {
    	return (RFQ_Ac_Map__c)getSObjectById(mapId);
    }
    
    public List<RFQ_Ac_Map__c> getActiveMapsByAccountId(String accountId) {
    	return (List<RFQ_Ac_Map__c>)getSObjects('Account__c = ' + quote(accountId) + ' and RecordTypeId = ' + quote(getActiveRtId()));
    }
    
    public List<RFQ_Ac_Map_Column__c> getMapColumnsByMapId(String mapId) {
    	return ColumnDao.getMapColumnsByMapId(mapId);
    }
    
    public List<RFQ_Ac_Map_Pf__c> getPfMapsByMapId(String mapId) {
		return PfMapDao.getPfMapsByMapId(mapId);
	}
	
	public List<RFQ_Ac_Map_Pf_Column__c> getPfFieldMapsByParentId(String parentId) {
		return PfFieldMapDao.getPfFieldMapsByParentId(parentId);
	} 
	
	public String getActiveRtId() {
		
		if (StringUtils.isBlank(activeRtId)) {
			activeRtId =  RecordTypeUtils.getRecordTypeId('RFQ_Ac_Map__c', 'Active'); 
		}
		return activeRtId;
	}
	
	public String getInactiveRtId() {
		
		if (StringUtils.isBlank(inactiveRtId)) {
			inactiveRtId = RecordTypeUtils.getRecordTypeId('RFQ_Ac_Map__c', 'Inactive'); 
		}
		return inactiveRtId;
	}
	
	public String getDraftRtId() {
		
		if (StringUtils.isBlank(draftRtId)) {
			draftRtId = RecordTypeUtils.getRecordTypeId('RFQ_Ac_Map__c', 'Draft');
		}
		return draftRtId;
	}
     
    public with sharing class ColumnDao extends BaseDao {
    	
    	public ColumnDao() { super('RFQ_Ac_Map_Column__c'); }
	   
	    public List<RFQ_Ac_Map_Column__c> getMapColumnsByMapId(String mapId) {
	    	return (List<RFQ_Ac_Map_Column__c>)getSObjects('RFQ_Ac_Map__c = ' + quote(mapId));
	    }
    }
    
    public with sharing class PfMapDao extends BaseDao {
    	
    	public PfMapDao() { super('RFQ_Ac_Map_Pf__c'); }
    	
    	public List<RFQ_Ac_Map_Pf__c> getPfMapsByMapId(String mapId) {
    		return (List<RFQ_Ac_Map_Pf__c>)getSObjects('RFQ_Ac_Map__c = ' + quote(mapId));
    	}
    }
    
    public with sharing class PfFieldMapDao extends BaseDao {
    	
    	public PfFieldMapDao() { 

    		super('RFQ_Ac_Map_Pf_Column__c');
    		addFields(new Set<String>{'RFQI_PF_Field_Def__r.Required__c', 'RFQI_PF_Field_Def__r.Object_API_Name__c', 'RFQI_PF_Field_Def__r.Not_Required_on_Import__c', 'RFQI_PF_Field_Def__r.RFQI_Field_Def__r.Name','RFQI_PF_Field_Def__r.RFQI_Section__r.Name','RFQI_PF_Field_Def__r.RFQI_Field_Def__r.Object__c'}); 
    	}
    	
    	public List<RFQ_Ac_Map_Pf_Column__c> getPfFieldMapsByParentId(String parentId) {
    		return (List<RFQ_Ac_Map_Pf_Column__c>)getSObjects('RFQ_Ac_Map_Pf__c = ' + quote(parentId));
    	}
    	
    }
}