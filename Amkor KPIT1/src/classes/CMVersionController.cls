/*************************************************************************
*
* PURPOSE: Controller for CM Version pages
*
* CLASS: 
* CREATED: 6/10/2013 Ethos Solutions - www.ethos.com 
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMVersionController 
{
	public CM_Version__c rec {get; set;}
	public List<FCM_BOM__c> bomList {get; set;}
	public List<FCM_Process__c> processList {get; set;}
	public List<FCM_Assumption__c> assumptionList {get; set;}
	public List<CM_PF_Value__c> valueList{get; set;}
	public List<CM_Test_Model__c> modelList {get; set;}
	public List<CM_Factory_Value__c> factValueList {get; set;}
	
	public CMVersionController()
	{}
	
	//---Controller extension constructor
	public CMVersionController(ApexPages.StandardController controller)
	{
		rec = (CM_Version__c)controller.getRecord();
	}
	
	//---Controller extension constructor
	public CMVersionController(ApexPages.StandardSetController controller)
	{}
	
	public Boolean isNew {get{return rec.id == null;}}
	public Boolean isPending {get{return rec != null && rec.Status__c == 'Pending';}}
	public Boolean isActive {get{return rec != null && rec.Status__c == 'Active';}}
	public Boolean isArchive {get{return rec != null && rec.Status__c == 'Archive';}}
	public Boolean isDeleted {get{return rec != null && rec.Status__c == 'Deleted';}}
	
	public Boolean hasPending {get {return hasPendingVersions();}}
	public Boolean hasActive {get {return hasActiveVersions();}}
	
	//---Check if there are pending versions
	private Boolean hasPendingVersions()
	{		
		List<CM_Version__c> verList = CMVersionDao.getInstance().getByPGAndStatus(rec.Product_Group__c, 'Pending'); 
		
		if (verList != null && verList.size() > 0) return true;
		return false;
	}
	
	//---Check if there are active versions
	private Boolean hasActiveVersions()
	{		
		List<CM_Version__c> verList = CMVersionDao.getInstance().getByPGAndStatus(rec.Product_Group__c, 'Active'); 
		
		if (verList != null && verList.size() > 0) return true;
		return false;
	}
	
	//---Load the page of data 
	private void loadPage()
	{
		if (isNew)
		{
			bomList = new List<FCM_BOM__c>();
			processList  = new List<FCM_Process__c>();
			assumptionList  = new List<FCM_Assumption__c>();
			valueList = new List<CM_PF_Value__c>();
			modelList = new List<CM_Test_Model__c>();
			factValueList = new List<CM_Factory_Value__c>();
		}
		else
		{
			rec = CMVersionDao.getInstance().getById(rec.id);				//---Reload to get all attributes
		
			//---Only display top level Items
			bomList = new List<FCM_BOM__c>();
			List<FCM_BOM__c> tBomList = FCMBOMDao.getInstance().getByVersion(rec.id);
			
			if (tBomList != null)
			{
				for(FCM_BOM__c row : tBomList) 
				{
					if (row.Type__c == 'Item') bomList.add(row);		
				}
			}
			
			//---Only display top level Items			
			processList = new List<FCM_Process__c>();
			List<FCM_Process__c> tProcList = FCMProcessDao.getInstance().getByVersion(rec.id);
			
			if (tProcList != null)
			{
				for(FCM_Process__c row : tProcList) 
				{
					if (row.Type__c == 'Item') processList.add(row);		
				}
			}
			
			assumptionList = FCMAssumptionDao.getInstance().getByVersion(rec.id);
			valueList = CMPFValueDao.getInstance().getByVersion(rec.id);
			modelList = CMTestModelDao.getInstance().getByVersion(rec.id);
			factValueList = CMFactoryValueDao.getInstance().getByVersion(rec.id);
		}
	}
	
	//---Setup for the View Page
	public PageReference setupViewAction()
	{
		loadPage();
		return null;
	}
	
	//---Setup for the Edit Page
	public PageReference setupEditAction()
	{
		loadPage();
		return null;
	}
	
	//---Edit Action
	public PageReference editAction()
	{
		return new PageReference('/' + rec.id + '/e');
	}
	
	//---Show the Pending Version
	public PageReference showPendingAction()
	{
		List<CM_Version__c> verList = CMVersionDao.getInstance().getByPGAndStatus(rec.Product_Group__c, 'Pending');
		
		if (verList != null && verList.size() > 0) return new PageReference('/' + verList[0].id);
		return null;
	}
	
	//---Show the Active Version
	public PageReference showActiveAction()
	{
		List<CM_Version__c> verList = CMVersionDao.getInstance().getByPGAndStatus(rec.Product_Group__c, 'Active');
		
		if (verList != null && verList.size() > 0) return new PageReference('/' + verList[0].id);
		return null;
	} 
	
	//---Make Pending Version
	public PageReference makePendingAction()
	{
		List<CM_Version__c> verList = CMVersionDao.getInstance().getByPGAndStatus(rec.Product_Group__c, 'Pending'); 
		
		if (verList != null && verList.size() > 0) 
		{
			//---TODO - Already a Pending Version, cannot make another
			return null;
		}
		else
		{
			CM_Version__c pendVer = makeNewPending(rec.Product_Group__c);
			return new PageReference('/' + pendVer.id);
		}
		
		return null;
	} 
	
	//---Make Active Version
	public PageReference makeActiveAction()
	{
		if (rec.Status__c != 'Pending')
		{
			//---TODO - Can only make a Pending Active
			return null;
		}
		
		List<CM_Version__c> verList = CMVersionDao.getInstance().getByPGAndStatus(rec.Product_Group__c, 'Active');
		
		if (verList != null && verList.size() > 0) 
		{
			//---Make all current Active (should only be 1) Archive
			for (CM_Version__c row : verList) row.Status__c = 'Archive';
			update verList;
		}
		
		//---Make current record Active
		rec.Status__c = 'Active';
		update rec;
		
		return new PageReference('/' + rec.id);		//---Reload Page
	} 
	
	//---Delete Action
	public PageReference deleteAction()
	{
		if (rec.Status__c != 'Pending')
		{
			//---TODO - Can only make a Pending Deleted
			return null;
		}
		
		//---Make current record Deleted
		rec.Status__c = 'Deleted';
		update rec;
		
		return showActiveAction();
	} 
	
	//---Save Action
	public PageReference saveAction()
	{
		upsert rec;
		return new PageReference('/' + rec.id);
	} 
	
	//---Cancel Action
	public PageReference cancelAction()
	{
		return isNew ? new PageReference('/' + rec.Product_Group__c) : new PageReference('/' + rec.id);
	} 
	
	//---View active record from List
	public PageReference viewActiveListAction()
	{
		String pgId = ApexPages.currentPage().getParameters().get('pgId');
		
		List<CM_Version__c> verList = CMVersionDao.getInstance().getByPGAndStatus(pgId, 'Active');
		
		if (verList != null && verList.size() > 0) 
		{
			return new PageReference('/' + verList[0].id);		//---Navigate to Active
		}
		return new PageReference('/' + pgId);
	}
	

	//---View pending record from List
	public PageReference viewPendingListAction()
	{
		String pgId = ApexPages.currentPage().getParameters().get('pgId');
		
		List<CM_Version__c> verList = CMVersionDao.getInstance().getByPGAndStatus(pgId, 'Pending');
		
		if (verList != null && verList.size() > 0) 
		{
			return new PageReference('/' + verList[0].id);		//---Navigate to Pending
		}
		else
		{
			CM_Version__c pendVer = makeNewPending(pgId);
			return new PageReference('/' + pendVer.id);
		}
		return new PageReference('/' + pgId);
	}
	
	//---Make a new Pending Version
	private CM_Version__c makeNewPending(String pgId)
	{
		Decimal nextVerNum = CMVersionDao.getInstance().getNextVersionNum(pgId);
		
		CM_Version__c actVer = null;
		CM_Version__c pendVer = null;
		
		List<CM_Version__c> verList = CMVersionDao.getInstance().getByPGAndStatus(pgId, 'Active');
		if (verList != null && verList.size() > 0) actVer = verList[0];	
		
		if (actVer == null)
		{
			//---No Active Ver found
			pendVer = new CM_Version__c(Product_Group__c = pgId, Version__c=nextVerNum, Status__c='Pending');
			insert pendVer;
		}
		else
		{	
			//---Clone from Active Ver
			pendVer = actVer.clone(false, true, false, false);
			pendVer.Version__c = nextVerNum;
			pendVer.Status__c = 'Pending';
			insert pendVer;
			
			//---Clone BOM (with children and match conditions)
			List<FCM_Match_Condition__c> matchList = FCMMatchConditionDao.getInstance().getAllByBomVersion(actVer.id);
			
			List<FCM_BOM__c> sourceBomList = FCMBOMDao.getInstance().getByVersion(actVer.id);
			List<FCM_BOM__c> cloneBomList = cloneChildList(sourceBomList, pendVer.id, 'Parent_BOM__c', matchList, 'FCM_BOM__c');
					
			//---Clone Process (with children and match conditions) 
			matchList = FCMMatchConditionDao.getInstance().getAllByProcessVersion(actVer.id);
			
			List<FCM_Process__c> sourceProcessList = FCMProcessDao.getInstance().getByVersion(actVer.id);
			List<FCM_Process__c> cloneProcessList = cloneChildList(sourceProcessList, pendVer.id, 'Parent_Process__c', matchList, 'FCM_Process__c');
			
			//---Clone Assumptions
			List<FCM_Assumption__c> sourceAssumptionList = FCMAssumptionDao.getInstance().getByVersion(actVer.id);
			List<FCM_Assumption__c> cloneAssumptionList = cloneChildList(sourceAssumptionList, pendVer.id, null, null, null);
			
			
			//---Clone PF Values
			List<CM_PF_Value__c> sourceValueList = CMPFValueDao.getInstance().getByVersion(actVer.id);
			List<CM_PF_Value__c> cloneValueList = cloneChildList(sourceValueList, pendVer.id, null, null, null);

			//---Clone Test Models
			List<CM_Test_Model__c> sourceModelList = CMTestModelDao.getInstance().getByVersion(actVer.id);
			List<CM_Test_Model__c> cloneModelList = cloneChildList(sourceModelList, pendVer.id, null, null, null);

			//---Clone Factory Values
			List<CM_Factory_Value__c> sourceFactoryValueList = CMFactoryValueDao.getInstance().getByVersion(actVer.id);
			List<CM_Factory_Value__c> cloneFactoryValueList = cloneChildList(sourceModelList, pendVer.id, null, null, null);


		}
		
		return pendVer;
	}
	
	//---Clone a child list
	private List<SObject> cloneChildList(List<SObject> sourceList, String verId, String parentFieldName, List<FCM_Match_Condition__c> sourceMatchList, String matchParentField)
	{
		List<SObject> cloneList = new List<SObject>();
		
		Map<String, String> keyMap = new Map<String, String>();
		
		if (sourceList != null)
		{
			for(SObject row : sourceList)
			{
				SObject cloneObj = row.clone(false, true, false, false);
				cloneObj.put('CM_Version__c', verId);
				cloneList.add( cloneObj);
			}
			
			insert cloneList;
			
			if (parentFieldName != null)
			{
				Integer counter = 0;
				for(SObject row : sourceList)
				{
					keyMap.put(sourceList[counter].id, cloneList[counter].id);	//---Record old and new key	
					counter++;
				}
			
				for(SObject row : cloneList)
				{
					String parentVal = (String)row.get(parentFieldName);		//---Lookup the old key
				
					if (parentVal != null)
					{
						String newKey = keyMap.get(parentVal);					//---Get the new key
						row.put(parentFieldName, newKey);
					}
				}
				
				update cloneList;
			}
			
			//---Update Source Match List
			if (sourceMatchList != null)
			{
				List<FCM_Match_Condition__c> cloneMatchList = new List<FCM_Match_Condition__c>();
				
				for(FCM_Match_Condition__c row : sourceMatchList)
				{
					FCM_Match_Condition__c cloneObj = row.clone(false, true, false, false);
					
					String origParent = (String)cloneObj.get(matchParentField);
					String newParent = keyMap.get(origParent);
					cloneObj.put(matchParentField,  newParent);
					
					cloneMatchList.add( cloneObj);
				}
				
				insert cloneMatchList;
			}
		}
		
		return cloneList;
	}
}