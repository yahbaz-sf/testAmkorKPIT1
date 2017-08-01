/*************************************************************************
*
* PURPOSE: Controller for CM Margin Version pages
*
* CLASS: 
* CREATED: 7/10/2013 Ethos Solutions - www.ethos.com  x
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMMarginVersionController 
{
	public CM_Margin_Version__c rec {get; set;}
	public List<CM_Margin__c> marginList {get; set;}
	
	public CMMarginVersionController()
	{}
	
	//---Controller extension constructor
	public CMMarginVersionController(ApexPages.StandardController controller)
	{
		rec = (CM_Margin_Version__c)controller.getRecord();
	}
	
	//---Controller extension constructor
	public CMMarginVersionController(ApexPages.StandardSetController controller)
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
		List<CM_Margin_Version__c> verList = CMMarginVersionDao.getInstance().getByPGAndStatus(rec.Product_Group__c, 'Pending'); 
		
		if (verList != null && verList.size() > 0) return true;
		return false;
	}
	
	//---Check if there are active versions
	private Boolean hasActiveVersions()
	{		
		List<CM_Margin_Version__c> verList = CMMarginVersionDao.getInstance().getByPGAndStatus(rec.Product_Group__c, 'Active'); 
		
		if (verList != null && verList.size() > 0) return true;
		return false;
	}
	
	//---Load the page of data 
	private void loadPage()
	{
		if (isNew)
		{
			marginList = new List<CM_Margin__c>();
		}
		else
		{
			rec = CMMarginVersionDao.getInstance().getById(rec.id);				//---Reload to get all attributes
		
			marginList = CMMarginDao.getInstance().getByVersion(rec.id);
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
		List<CM_Margin_Version__c> verList = CMMarginVersionDao.getInstance().getByPGAndStatus(rec.Product_Group__c, 'Pending');
		
		if (verList != null && verList.size() > 0) return new PageReference('/' + verList[0].id);
		return null;
	}
	
	//---Show the Active Version
	public PageReference showActiveAction()
	{
		List<CM_Margin_Version__c> verList = CMMarginVersionDao.getInstance().getByPGAndStatus(rec.Product_Group__c, 'Active');
		
		if (verList != null && verList.size() > 0) return new PageReference('/' + verList[0].id);
		return null;
	} 
	
	//---Make Pending Version
	public PageReference makePendingAction()
	{
		List<CM_Margin_Version__c> verList = CMMarginVersionDao.getInstance().getByPGAndStatus(rec.Product_Group__c, 'Pending'); 
		
		if (verList != null && verList.size() > 0) 
		{
			//---TODO - Already a Pending Version, cannot make another
			return null;
		}
		else
		{
			CM_Margin_Version__c pendVer = makeNewPending(rec.Product_Group__c);
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
		
		List<CM_Margin_Version__c> verList = CMMarginVersionDao.getInstance().getByPGAndStatus(rec.Product_Group__c, 'Active');
		
		if (verList != null && verList.size() > 0) 
		{
			//---Make all current Active (should only be 1) Archive
			for (CM_Margin_Version__c row : verList) row.Status__c = 'Archive';
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
		
		List<CM_Margin_Version__c> verList = CMMarginVersionDao.getInstance().getByPGAndStatus(pgId, 'Active');
		
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
		
		List<CM_Margin_Version__c> verList = CMMarginVersionDao.getInstance().getByPGAndStatus(pgId, 'Pending');
		
		if (verList != null && verList.size() > 0) 
		{
			return new PageReference('/' + verList[0].id);		//---Navigate to Pending
		}
		else
		{
			CM_Margin_Version__c pendVer = makeNewPending(pgId);
			return new PageReference('/' + pendVer.id);
		}
		return new PageReference('/' + pgId);
	}
	
	//---Make a new Pending Version
	private CM_Margin_Version__c makeNewPending(String pgId)
	{
		Decimal nextVerNum = CMMarginVersionDao.getInstance().getNextVersionNum(pgId);
		
		CM_Margin_Version__c actVer = null;
		CM_Margin_Version__c pendVer = null;
		
		List<CM_Margin_Version__c> verList = CMMarginVersionDao.getInstance().getByPGAndStatus(pgId, 'Active');
		if (verList != null && verList.size() > 0) actVer = verList[0];	
		
		if (actVer == null)
		{
			//---No Active Ver found
			pendVer = new CM_Margin_Version__c(Product_Group__c = pgId, Version__c=nextVerNum, Status__c='Pending');
			insert pendVer;
		}
		else
		{	
			//---Clone from Active Ver
			pendVer = actVer.clone(false, true, false, false);
			pendVer.Version__c = nextVerNum;
			pendVer.Status__c = 'Pending';
			insert pendVer;
			
			//---Clone Margin
			List<CM_Margin__c> sourceMarginList = CMMarginDao.getInstance().getByVersion(actVer.id);
			List<CM_Margin__c> cloneMarginList = cloneChildList(sourceMarginList, pendVer.id);
		}
		
		return pendVer;
	}
	
	//---Clone a child list
	private List<SObject> cloneChildList(List<SObject> sourceList, String verId)
	{
		List<SObject> cloneList = new List<SObject>();
		
		Map<String, String> keyMap = new Map<String, String>();
		
		if (sourceList != null)
		{
			for(SObject row : sourceList)
			{
				SObject cloneObj = row.clone(false, true, false, false);
				cloneObj.put('CM_Margin_Version__c', verId);
				cloneList.add( cloneObj);
			}
			
			insert cloneList;
		}
		
		return cloneList;
	}
}