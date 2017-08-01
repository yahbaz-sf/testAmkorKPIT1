/*************************************************************************
*
* PURPOSE: Controller class for the maint of the FCM MatchConditions
*
* CLASS: FCMMatchConditionController
* CREATED: 6/12/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class FCMMatchConditionController 
{
	public String versionId {get; set;}
	
	public String bomId {get; set;}
	public String processId {get; set;}
	
	public FCM_Match_Condition__c rec {get; set;}
	public CM_Version__c ver {get; set;}
	
	public Boolean isNew {get{return rec.id == null;}}
	
	public Boolean isBom {get{return rec.FCM_BOM__c != null;}}
	public Boolean isProcess {get{return rec.FCM_Process__c != null;}}
	
	
	public Boolean isAlways {get{return rec.Match_Type__c != null && rec.Match_Type__c.contains('Always');}}
	
	public Boolean isTextValue {get{return rec.Match_Type__c != null && rec.Match_Type__c.contains('TextValue');}}
	public Boolean isNumericValue {get{return rec.Match_Type__c != null && rec.Match_Type__c.contains('NumberValue');}}
	public Boolean isBooleanValue {get{return rec.Match_Type__c != null && rec.Match_Type__c.contains('Boolean');}}
	

	public Boolean isPending {get{return ver != null && ver.Status__c == 'Pending';}}
	
	//---Constructor 
	public FCMMatchConditionController(ApexPages.StandardController controller)
	{
		rec = (FCM_Match_Condition__c)controller.getRecord();
	}
	
	//---Setup Action
	public PageReference setupAction() 
	{		
		bomId = ApexPages.currentPage().getParameters().get('bomId');
		processId = ApexPages.currentPage().getParameters().get('processId');
		
		String recId = rec.id;
		
		if (recId == null) 
		{
			rec.FCM_BOM__c = bomId;
			rec.FCM_Process__c = processId;
		}
		else
		{
			rec = FCMMatchConditionDao.getInstance().getById(recId);		//---If already exists, then reload with full fields
			
			bomId = rec.FCM_BOM__c;
			processId = rec.FCM_Process__c;
		}
		
		FCM_BOM__c bom = FCMBOMDao.getInstance().getById(bomId);
		FCM_Process__c proc = FCMProcessDao.getInstance().getById(processId);
		
		if (bom != null) versionId = bom.CM_Version__c;
		if (proc != null) versionId = proc.CM_Version__c;
		
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
		PageReference pRef = getDefaultDestination();
		
		delete rec;
		return pRef;
	}
	
	//---Get the default destination
	private PageReference getDefaultDestination()
	{
		PageReference pRef = new PageReference('/');
		
		if (rec.FCM_BOM__c != null) pRef = new PageReference('/' + rec.FCM_BOM__c);
		if (rec.FCM_Process__c != null) pRef = new PageReference('/' + rec.FCM_Process__c);
		
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
		if (isNew) return getDefaultDestination();
		return new PageReference('/' + rec.id);
	}
}