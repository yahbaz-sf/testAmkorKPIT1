/*************************************************************************
*
* PURPOSE: Controller class for the maint of the FCM BOMs, handles layering parent to child
*
* CLASS: FCMBOMController
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class FCMBOMController
{
	public FCM_BOM__c rec {get; set;}
	public FCM_BOM__c parentRec {get; set;}
	public CM_Version__c ver {get; set;}
	
	public Boolean isItem {get{return rec.Type__c == 'Item';}}
	public Boolean changeCategoryAllowed {get; set;}
	public Boolean deleteAllowed {get; set;}
	
	public List<FCMLayeredField> dataFieldList {get; set;}
	public List<FCM_BOM__c> variantList {get; set;}
	public List<FCM_Match_Condition__c> matchList {get; set;}
	
	private Map<String, FCMLayeredField> fieldMap;
	
	public Boolean isPending {get{return ver != null && ver.Status__c == 'Pending';}}
	
	//---Constructor 
	public FCMBOMController(ApexPages.StandardController controller)
	{
		rec = (FCM_BOM__c)controller.getRecord();
		variantList = new List<FCM_BOM__c>();
		changeCategoryAllowed = false;
		deleteAllowed = false;
	}
	
	public PageReference setupAction() 
	{		
		String recId = rec.id;
		String versionid = ApexPages.currentPage().getParameters().get('versionId');
		
		if (recId == null) 
		{
			String parentId = ApexPages.currentPage().getParameters().get('parentId');
			
			if (parentId != null) parentRec = FCMBOMDao.getInstance().getById(parentId); 
			
			if (parentRec == null)
			{
				rec.Type__c = 'Item';
				if (versionId != null) rec.CM_Version__c = versionId;
			}
			else
			{
				rec.Parent_BOM__c = parentRec.id;
				rec.Type__c = 'Variant';
				rec.Category__c = parentRec.Category__c;
				rec.CM_Version__c = parentRec.CM_Version__c;
			}
		}
		else
		{
			rec = FCMBOMDao.getInstance().getById(recId);		//---If already exists, then reload with full fields
			if (isItem)
			{
				 variantList = FCMBOMDao.getInstance().getByParentId(rec.id);
			}
			else
			{
				if (rec.Parent_BOM__c != null)parentRec = FCMBOMDao.getInstance().getById(rec.Parent_BOM__c);
			}
			
			matchList = FCMMatchConditionDao.getInstance().getAllByBom(rec.id);
			versionId = rec.CM_Version__c;
		}
		
		ver = CMVersionDao.getInstance().getById(versionId);
		if (ver == null) ver = new CM_Version__c();				//---Protect from null error
		
		if (recId == null) rec.Product_Group__c = ver.Product_Group__c;
		
		setupFields();
		
		changeCategoryAllowed = rec.Type__c == 'Item' && variantList.size() == 0;
		deleteAllowed = !(rec.Type__c == 'Item' && variantList.size() > 0);
			
		return null;
	}
	
	private void buildFullFieldMap()
	{
		fieldMap = new Map<String, FCMLayeredField>();
		
		addFieldDef( 'Description', 'Description'); 
		addFieldDef( 'SID', 'SID'); 
		addFieldDef( 'UOM', 'UOM'); 
		addFieldDef( 'Purchase_Price', 'Purchase Price'); 
		addFieldDef( 'Standard_Usage', 'Standard Usage'); 
		addFieldDef( 'Usage_Scrap_Rate', 'Usage Scrap Rate'); 
		addFieldDef( 'Mfg_Cost', 'Mfg Cost'); 
		addFieldDef( 'Troy_Oz_Cost', 'Troy Oz Cost'); 
		addFieldDef( 'Cost_Per_Unit', 'Cost Per Unit'); 
		addFieldDef( 'Index', 'Index'); 
		addFieldDef( 'Time_Per_Wire', 'Time Per Wire'); 
		addFieldDef( 'Usage_Rate', 'Usage Rate'); 
		addFieldDef( 'Group', 'Group'); 
	}
	
	private void addFieldDef(String baseName, String label)
	{
		fieldMap.put( baseName, new FCMLayeredField(baseName, label)); 
	}
	
	//---Setup the display values and layered fields
	private void setupFields()
	{
		buildFullFieldMap();
			
		dataFieldList = new List<FCMLayeredField>();
		
		addCurrentFieldDef('SID');
		addCurrentFieldDef('Cost_Per_Unit');		
		addCurrentFieldDef('UOM');
		addCurrentFieldDef('Standard_Usage');
		addCurrentFieldDef('Usage_Scrap_Rate');
		addCurrentFieldDef('Description');
		addCurrentFieldDef('Purchase_Price');		
		addCurrentFieldDef('Mfg_Cost');
		addCurrentFieldDef('Troy_Oz_Cost');
		addCurrentFieldDef('Cost_Per_Unit');
		addCurrentFieldDef('Index');
		addCurrentFieldDef('Time_Per_Wire');
		addCurrentFieldDef('Usage_Rate');
		addCurrentFieldDef('Group');
		
		//if (rec.Category__c == 'Mold')
		//{
		//	addCurrentFieldDef('Description');
		//	addCurrentFieldDef('SID');
		//	addCurrentFieldDef('Cost_Per_Unit');		
		//	addCurrentFieldDef('UOM');
		//	addCurrentFieldDef('Standard_Usage');
		//	addCurrentFieldDef('Usage_Scrap_Rate');
		//	addCurrentFieldDef('Purchase_Price');
		//} 
		//else if (rec.Category__c == 'AuWire')
		
		for(FCMLayeredField row : dataFieldList ) row.isSelected = true;		//---Mark the fields that are selected
		
		List<FCMLayeredField> allFields = fieldMap.values();
		
		for(FCMLayeredField row : allFields)
		{
			if (isItem && row.isSelected) rec.put(row.orName, true);		//---Set the appropriate OR field to true
			
			if (!row.isSelected)
			{
				rec.put(row.orName, false);									//---Clear OR field
				rec.put(row.localName, null);								//---Clear Local value
			}
		}
	}
	
	private void addCurrentFieldDef(String baseName)
	{
		FCMLayeredField selField = fieldMap.get(baseName);
		
		if (selField == null)
		{
			//---TODO, write the missed field to the log
		}
		else
		{
			dataFieldList.add(selField);
		}
	}
	
	//---Called when the category is changed
	public PageReference updateCategory()
	{
		setupFields();
		refreshCalc();
		return null;
	}
	
	//---A refresh caused by any possible change to values
	public PageReference updateValues()
	{
		refreshCalc();
		return null;
	}
	
	//---Called to refresh the calculations and inheritance
	private void refreshCalc()
	{
		CMBOMCalcBase.updateBomCalc(rec, parentRec); 
	}
	
	//---Save action
	public PageReference saveAction()
	{
		updateValues();
		upsert rec;
		
		return new PageReference('/' + rec.id);
	}
	
	//---Edit button selected
	public PageReference editAction()
	{
		return new PageReference('/' + rec.id + '/e');
	}
	
	//---Update canceled
	public PageReference cancelAction()
	{
		String retUrl = ApexPages.currentPage().getParameters().get('retURL');
		if (retUrl != null) return new PageReference(retUrl);
		
		if (rec.id == null)
		{
			if (parentRec == null)
			{
				//---TODO, goto list page
				return new PageReference('/');
			}
			else
			{
				return new PageReference('/' + parentRec.id);
			}
		}
		return new PageReference('/' + rec.id);
	}
	
	//---Add a Variant action
	public PageReference addVariantAction() 
	{
		return new PageReference('/apex/FCMBOMEdit?parentId=' + rec.id);
	}
	
	//---Delete a BOM
	public PageReference deleteAction() 
	{
		PageReference pRef = null;
		
		//---Variant and valid Parent BOM
		if (!isItem && rec.Parent_BOM__c != null) pRef = new PageReference('/' + rec.Parent_BOM__c  );
		
		//---Go to the Version
		if (pRef == null && rec.CM_Version__c != null) pRef = new PageReference('/' + rec.CM_Version__c  );
		
		//---Nowhere to go, then root
		if (pRef == null) pRef = new PageReference('/');
		
		//---Delete the rec
		delete rec;
		
		return pRef;
	}
	
	public PageReference cloneAction()
	{
		FCM_BOM__c cloneObj = rec.clone(false, true);
		cloneObj.name = 'COPY';
		cloneObj.Sequence__c += 10;
		
		insert cloneObj;
		
		return new PageReference('/' + cloneObj.id);
	}
}