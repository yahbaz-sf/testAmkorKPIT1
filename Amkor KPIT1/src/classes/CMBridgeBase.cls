/*************************************************************************
*
* PURPOSE: Base class for the Bridge (Read/Write) for the Cost mode.
*
* CLASS: CMBridgeBase
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/ 
public virtual class CMBridgeBase 
{
	public CMSettings settings {get; set;}
	public RFQItemWrapper wrapper {get; set;} 
	
	public String accountId {get; set;}				
	public Product_Group__c pg	{get; set;}
	public Account_PG_Setting__c acctPgSetting {get; set;}
	
	public CM_Version__c ver {get; set;}
	public CM_Margin_Version__c mVer {get; set;}
	public CM_PF_Value__c pfValue {get; set;}

	public Boolean noCostModel {get { return wrapper.packageFamily.No_Cost_Model__c || wrapper.rfqItem.Do_Not_Auto_Price__c;}}

	public Boolean hasAutomaticMargin {get; set;}

	public DebugUtils debug {get {return DebugUtils.getInstance();} }
	
	public virtual void setup()
	{
		loadAccount();
		loadPg();
		loadVersion();
		loadAccountPg();
		loadMarginVersion();
		loadPFValue();

		//default to false, gets set if the cost model finds a margin
		hasAutomaticMargin = false;
	}
	
	public virtual void loadAccount()
	{
		accountId = RFQItemDao.getInstance().getAccountIdFromItemId(wrapper.rfqItem.id);
	}
	
	public virtual void loadPg()
	{
		pg = ProductGroupDao.getInstance().getById(wrapper.packageFamily.Product_Group__c);
	}
	
	public virtual void loadAccountPg()
	{
		acctPgSetting = AccountPGSettingDao.getInstance().getByAccountPG(accountId, wrapper.packageFamily.Product_Group__c);
		if (acctPgSetting != null)
		{
			if (acctPgSetting.Tier__c != null && acctPgSetting.Tier__c != 0) wrapper.rfqItem.Customer_Tier__c = acctPgSetting.Tier__c;
		}
		else
		{
			//set Tier on customer object. default to 3 if no tier set
			wrapper.rfqItem.Customer_Tier__c = 3;
		}
		//update wrapper.rfqItem;
	}
	
	//---Load the Version, checking if should use Pending version
	public virtual void loadVersion()
	{
		List<CM_Version__c> verList = null;
		
		
		if (settings == null) 
		    settings = new CMSettings();
		
		//Ashish - 5-OCT-2016 - SF-107 - SOQL issue in RFQICreateVolumeCloneController
		//Commenting out SOQL queries on Cost Model Objects
		//Commenting out below code to prevent SOQL on CM_Version__c, so that always new CM_Version__c should be initialised
		/*if (settings.usePending)
		{
			verList = CMVersionDao.getInstance().getByPGAndStatus(wrapper.packageFamily.Product_Group__c, 'Pending');
			if (verList != null && verList.size() > 0) ver = verList[0];
		}
		
		if (ver == null)
		{
			verList = CMVersionDao.getInstance().getByPGAndStatus(wrapper.packageFamily.Product_Group__c, 'Active');
			if (verList != null && verList.size() > 0) ver = verList[0];
		}*/
		
		if (ver == null)
		{
			//---If no version, create a blank one to prevent errors
			ver = new CM_Version__c(Product_Group__c=wrapper.packageFamily.Product_Group__c, Status__c='Pending');
		}
	}

	public virtual void loadMarginVersion()
	{
		//Ashish - 5-OCT-2016 - SF-107 - SOQL issue in RFQICreateVolumeCloneController
		//Commenting out SOQL queries on Cost Model Objects
		//Commenting out below code to prevent SOQL on CM_Margin_Version__c, so that always new CM_Margin_Version__c should be initialised
		/*List<CM_Margin_Version__c> mVerList = CMMarginVersionDao.getInstance().getByPGAndStatus(wrapper.packageFamily.Product_Group__c, 'Active');
		if (mVerList != null && mVerList.size() > 0) mVer = mVerList[0];
        */
        
		if (mVer == null)
		{
			//---If no version, create a blank one to prevent errors
			mVer = new CM_Margin_Version__c(Product_Group__c=wrapper.packageFamily.Product_Group__c, Status__c='Pending');
		}
	}

	public virtual void loadPFValue()
	{
		//Ashish - 5-OCT-2016 - SF-107 - SOQL issue in RFQICreateVolumeCloneController
		//Commenting out SOQL queries on Cost Model Objects
		//Commenting out below code to prevent SOQL on CM_PF_Value__c, so that always new CM_PF_Value__c should be initialised
		/*List<CM_PF_Value__c> cmPfValueList = CMPFValueDao.getInstance().getByPFAndVersion(ver.id, wrapper.packageFamily.id); 
		if (cmPfValueList.size() == 0) pfValue = new CM_PF_Value__c();
		else pfValue = cmPfValueList[0];*/
		
		pfValue = new CM_PF_Value__c();
    }
	
	
	//---Get decimal value from attribute
	public Decimal getDecimal(sObject obj, String fieldName, Decimal defVal) 
	{
		
		if(obj == null) return defVal;
        if(obj.get(fieldName) == null) return defVal;
        return Decimal.valueOf(String.valueOf(obj.get(fieldName)));
	}

	public String getString (sObject obj, String fieldName)
    {
        if(obj.get(fieldName) == null) return '';
        return String.valueOf(obj.get(fieldName));
    }
	
}