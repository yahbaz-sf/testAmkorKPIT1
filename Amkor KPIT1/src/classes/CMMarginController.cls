/*************************************************************************
*
* PURPOSE: Controller class for the maint of the FCM Margins
*
* CLASS: CMMarginController
* CREATED: 6/12/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMMarginController 
{
	public String versionId {get; set;}
	public CM_Margin__c rec {get; set;}
	public CM_Margin_Version__c ver {get; set;}
	
	public Boolean isNew {get{return rec.id == null;}}
	public Boolean isPending {get{return ver != null && ver.Status__c == 'Pending';}}
	
	//---Constructor 
	public CMMarginController(ApexPages.StandardController controller)
	{
		rec = (CM_Margin__c)controller.getRecord();
	}
	
	//---Setup Action
	public PageReference setupAction() 
	{		
		versionId = ApexPages.currentPage().getParameters().get('versionId');
		String recId = rec.id;
		
		if (recId == null) 
		{
			rec.CM_Margin_Version__c = versionId;
		}
		else
		{
			rec = CMMarginDao.getInstance().getById(recId);		//---If already exists, then reload with full fields 
			versionId = rec.CM_Margin_Version__c;
		}
		
		ver = CMMarginVersionDao.getInstance().getById(versionId);
		if (ver == null) ver = new CM_Margin_Version__c();				//---Protect from null error
		
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
		PageReference pRef = new PageReference('/' + rec.CM_Margin_Version__c);
		
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