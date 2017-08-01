/*************************************************************************
*
* PURPOSE: Controller for Component used to display FCM results
*
* CLASS: CMFCMDisplayController
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMFCMDisplayController 
{
	public CMFCMBuilderBase fcmBuilder {get; private set;}
	public CMBuilder builder{get; set{fcmBuilder = (CMFCMBuilderBase)value;}}
	public Boolean isEdit {get; set;}
	public Boolean isDeleteAllowed {get; set;}
	public Boolean noCostModel {get; set;}
	
	//---Adding BOM, Item Dropdown changed.
	public PageReference bomItemChanged()  
	{
		fcmBuilder.bomItemChanged();
		return null;
	}
	
	//---Adding Process, Item Dropdown changed.
	public PageReference processItemChanged()  
	{
		fcmBuilder.processItemChanged();
		return null;
	}
	
	
	//---Action for adding a BOM
	public PageReference addBom() 
	{
		fcmBuilder.bomAdded();
		return null;
	}

	//---Action for deleting a BOM	
	public PageReference deleteBom()
	{
		String itemBomId = System.currentPageReference().getParameters().get('itemBomId');
		fcmBuilder.bomDeleted(itemBomId);
		return null;
	}
	
	//---Action for adding a Process
	public PageReference addProcess() 
	{
		System.debug(LoggingLevel.Error, '###noCostModelComponent: ' + noCostModel);
		System.debug(LoggingLevel.Error, '###isEditMode: ' + isEdit);
		fcmBuilder.processAdded();
		return null;
	}

	//---Action for deleting a Process	
	public PageReference deleteProcess()
	{
		String itemProcessId = System.currentPageReference().getParameters().get('itemProcessId');
		fcmBuilder.processDeleted(itemProcessId);
		return null;
	}
	
	
	//---User requests a recalculate
	public PageReference recalculateAction()
	{
		fcmBuilder.calculateNew();
		return null;
	}
	
	public PageReference clearAction()
	{
		fcmBuilder.clearCalc();
		return null;
	}
}