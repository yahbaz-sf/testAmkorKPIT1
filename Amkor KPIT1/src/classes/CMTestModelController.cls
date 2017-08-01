/*************************************************************************
*
* PURPOSE: Controller class for the maint of the CM Package Family Values
*
* CLASS: CMPFValuesController
* CREATED: 6/22/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
public with sharing class CMTestModelController 
{
	public String versionId {get; set;}
	public CM_Test_Model__c rec {get; set;}
	public CM_Version__c ver {get; set;}
	
	public Boolean isNew {get{return rec.id == null;}}
	public Boolean isPending {get{return ver != null && ver.Status__c == 'Pending';}}
	
	//---Constructor 
	public CMTestModelController(ApexPages.StandardController controller)
	{
		rec = (CM_Test_Model__c)controller.getRecord();
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
			rec = CMTestModelDao.getInstance().getById(recId);		//---If already exists, then reload with full fields
			versionId = rec.CM_Version__c;
		}
		
		ver = CMVersionDao.getInstance().getById(versionId);
		if (ver == null) ver = new CM_Version__c();				//---Protect from null error
		
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