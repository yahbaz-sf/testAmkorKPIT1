/*************************************************************************
*
* PURPOSE: Controller class for the maint of the FCM Assumptions
*
* CLASS: FCMAssumptionController
* CREATED: 6/12/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class FCMAssumptionController 
{
	public String versionId {get; set;}
	public FCM_Assumption__c rec {get; set;}
	public CM_Version__c ver {get; set;}
	
	public Boolean isNew {get{return rec.id == null;}}
	public Boolean isPending {get{return ver != null && ver.Status__c == 'Pending';}}
	
	//---Constructor 
	public FCMAssumptionController(ApexPages.StandardController controller)
	{
		rec = (FCM_Assumption__c)controller.getRecord();
	}
	
	//---Setup Action
	public PageReference setupAction() 
	{		
		versionId = ApexPages.currentPage().getParameters().get('versionId');
		String recId = rec.id;
		
		if (recId == null) 
		{
			rec.CM_Version__c = versionId;
		}
		else
		{
			rec = FCMAssumptionDao.getInstance().getById(recId);		//---If already exists, then reload with full fields
			versionId = rec.CM_Version__c;
		}
		
		ver = CMVersionDao.getInstance().getById(versionId);
		if (ver == null) ver = new CM_Version__c();				//---Protect from null error
		
		if (recId == null) rec.Product_Group__c = ver.Product_Group__c;
		
		return null;
	}
	
	//---Edit Action
	public PageReference editAction()
	{
		return new PageReference('/' + rec.id + '/e');
	}
	
	//---Delete Action
	public PageReference deleteAction()
	{
		PageReference pRef = new PageReference('/' + rec.CM_version__c);
		
		delete rec;
		return pRef;
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
		if (isNew) return new PageReference('/' + versionId);
		return new PageReference('/' + rec.id);
	}
}