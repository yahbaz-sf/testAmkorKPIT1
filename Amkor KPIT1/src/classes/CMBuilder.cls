/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public abstract class CMBuilder 
{
	public List<CMDebug> debugList {get; set;}
	protected CMBridgeBase bridge {get; set;}
	public CMSettings settings {get; set;}

	public DebugUtils debug {get {return DebugUtils.getInstance();} }

	//AMK-2263, AMK-2268 changed c/p section, removing substrate markup and assembly %gm
    //from some PFs with a substrate
    public static Set<String> pfsWithNoSubstrate = new Set<String>
    {
    	'PBGA',
    	'FC BGA'
    };

	public CMBuilder()
	{
		debugList = new List<CMDebug>();
	}
	//public abstract void loadSettings(RFQItemWrapper pWrapper);
	
	public void setup(RFQItemWrapper pWrapper)
	{
		setup(pWrapper, true);
	}

	public virtual void setup(RFQItemWrapper pWrapper, Boolean needsBridgeSetup)
	{
		bridge.settings = settings;
		bridge.wrapper = pWrapper;	

		//for bulkifying the cost models - for a list of cloned items, all items
		//loaded by the bridge will be the same, so the same builder can be used
		//to reduce soql limits
		if (needsBridgeSetup) bridge.setup();
	}
	
	    
	public virtual void calculateNew(RFQItemWrapper itemWrapper, CMSettings settings){
		setup(itemWrapper);
		loadSettings(itemWrapper, true);					
		try 
		{
			if(!(itemWrapper.packageFamily.No_Cost_Model__c || itemWrapper.rfqItem.Do_Not_Auto_Price__c)) {
				calcCostModel(itemWrapper );
			}
			calcResults(itemWrapper, true);
			calcMulti(itemWrapper, getHasSubstrate(itemWrapper));
			//update itemWrapper.specificRfqItem;

		}
		catch(Exception e) 
		{
			debugList.add( new CMDebug('Error: ' + e));
			DebugUtils.write('e', e);
			DebugUtils.write('e.getStackTraceString()', e.getStackTraceString());
		}
	}
      
	public abstract void loadSettings(RFQItemWrapper itemWrapper, Boolean isReloaded);

	protected virtual void loadSettingsByPFAttributes(RFQITemWrapper itemWrapper, Boolean isReloaded, List<String> attributes, List<String> pfAttributes){

		//check if pf settings needs to reload or not
		List<Boolean> booleanList = getPFSettingsLoadingList(itemWrapper, attributes, isReloaded);
		Boolean isLoadingNeeded = false;
		for(Boolean isloading : booleanList){
			isLoadingNeeded = isLoading || isLoadingNeeded;
		}
		
		if(!isLoadingNeeded) return;
		
		//load cm version
		List<CM_Version__c> verList = CMVersionDao.getInstance().getByPGAndStatus(itemWrapper.packageFamily.Product_Group__c, 'Active');
		//suppose only one is active
		if(verList.size() == 0) return;
		List<CM_PF_Value__c> cmPfValueList = CMPFValueDao.getInstance().getByPFAndVersion(verList[0].id, itemWrapper.packageFamily.id); 
		if (cmPfValueList.size() == 0) return;
		
		loadPFSettings(itemWrapper, cmPfValueList[0], booleanList, attributes, pfAttributes);		
		update itemWrapper.specificRfqItem;
	}


	protected List<Boolean> getPFSettingsLoadingList(RFQItemWrapper itemWrapper, List<String> attributes, Boolean isReloaded){
		List<Boolean> booleanList = new List<Boolean>();
		for(String attr : attributes){
			if(itemWrapper.specificRfqItem.get(attr) != null && !isReloaded)
				booleanList.add(false);
			else
				booleanList.add(true);
		}
		return booleanList;
	}

	protected void loadPFSettings(RFQItemWrapper itemWrapper, CM_PF_Value__c cmPfValue, List<Boolean> booleanList, List<String> attributes, List<String> pfAttributes){
		for(Integer i = 0 ; i < booleanList.size(); i++){
			if(booleanList[i])
				itemWrapper.specificRfqItem.put(attributes[i], (Decimal)cmPfValue.get(pfAttributes[i]));
		}
	}
		
	public virtual void calculateAll(RFQItemWrapper itemWrapper, Boolean isUpdate, CMSettings settings){
		calculateAll(itemWrapper, isUpdate, settings, true);
	}

	public virtual void calculateAll(RFQItemWrapper itemWrapper, Boolean isUpdate, CMSettings settings, Boolean needsBridgeSetup){
	
		setup(itemWrapper, needsBridgeSetup);
		loadSettings(itemWrapper, false);	
		try 

		{
			if(!(itemWrapper.packageFamily.No_Cost_Model__c || itemWrapper.rfqItem.Do_Not_Auto_Price__c))
			{
				calcCostModel(itemWrapper);
				//only recalculate the multi volumes (total cost, etc) if there is a cost model
				//otherwise you blow up the changes the the user made

				if (itemWrapper.packageFamily.Copy_Fields_To_multivolume__c) calcMulti(itemWrapper, getHasSubstrate(itemWrapper));
			}
			calcResults(itemWrapper, true);	

			itemWrapper.calculateAuPricing();		
			//update itemWrapper.specificRfqItem;   


    	}
    	catch(Exception e) 
    	{
    		DebugUtils.write('e', e);
    		DebugUtils.write('e.getStackTraceString()', e.getStackTraceString());
    		debugList.add( new CMDebug('Error: ' + e));
    	}

	}
	
		

	public virtual void displayResults(RFQItemWrapper itemWrapper, Boolean isUpdate)	
	{
		
		setup(itemWrapper);
		loadSettings(itemWrapper, false);						
		try 
		{		
    		calcResults(itemWrapper, false);
    		//if(isUpdate)
    			//update itemWrapper.specificRfqItem;
    	}
    	catch(Exception e) 
    	{
    		DebugUtils.write('e', e);
    		DebugUtils.write('e.getStackTraceString()', e.getStackTraceString());
    		debugList.add( new CMDebug('Error: ' + e));
    	}
	}

	public virtual Boolean shouldProcessAdderCostRules() {
		return false;
	}

	public virtual void processAdderCostRules(RFQItemWrapper wrapper) {
		// Currently implemented for MLF  only
	}

	protected abstract void calcCostModel(RFQItemWrapper itemWrapper);

	protected abstract void calcResults(RFQItemWrapper itemWrapper, Boolean runCostModel);

	//public abstract void displayResults(RFQItemWrapper itemWrapper, Boolean isMER, Boolean isUpdate);
	public abstract void onAttributeChange(RFQItemWrapper itemWrapper, String attributeName);

	protected Decimal getDecimal (sObject obj, String fieldName, Decimal defVal) 
    {
        if(obj == null) return defVal;
        if(obj.get(fieldName) == null) return defVal;
        return Decimal.valueOf(String.valueOf(obj.get(fieldName)));
    }

    public abstract void setEditabilityforNoCostModel(RFQILayout layout);

    public void addError(String mesg){
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, mesg) );
    }

    public virtual Boolean isBUPriceNull(RFQItemWrapper itemWrapper)
    {
    	return itemWrapper.specificRfqItem.get('BU_Price__c') == null;
    }

    public virtual void calcMulti(RFQItemWrapper itemWrapper, Boolean hasSubstrate)
    {
		for (RFQIVolume volume : itemWrapper.volumeList)
		{
			calcMulti(itemWrapper, volume.index - 1, hasSubstrate);
		}
    }

    //method to calc each volume independtly, in order to reprice one without the others
    public virtual void calcMulti(RFQItemWrapper itemWrapper, Integer index, Boolean hasSubstrate)
    {
    	Map<String, String> fieldMap = getFieldMap();
    	RFQIVolume volume = itemWrapper.volumeList[index];
    	
    	//default values to 0, in case the correspending value doesn't exist in fieldMap
		volume.price = 0;
		volume.margin = 0;
		volume.subsMarkup = 0;
		volume.marginNoSubstrate = 0;
		volume.subsCost = 0;
		volume.othersCost = 0;
		volume.costLessSubs = 0;
		volume.baseBUPrice = 0;

		//AMK-1601
		RFQ_Item__c tempRFQI = (RFQ_Item__c)itemWrapper.specificRfqItem.getsObject('RFQ_Item__r');
		volume.goldBillingFlag = (String)tempRFQI.RFQ__r.getsObject('SBU_Name__r').get('Gold_Billing_Flag__c');
		
		if (volume.goldBillingFlag == null || volume.goldBillingFlag == 'Transactionally' || volume.goldBillingFlag == '') 
			volume.auAdder = DataUtils.getString(itemWrapper.specificRfqItem, 'Au_Adder__c', '');
		else 
			volume.auAdder = 'Inclusive';

		Integer precision = 6; 
		//AMK-2328 - Per peter, always make them type everything in. This came up because the rules for when to copy down 
		//total cost became too complex - is there a substrate, is materials substrate entered, is there a total cost field
		//when there is a substrate, do they enter total cost or (cost less subs AND materials substrate)
		//AMK-2488 - do not copy new prices from the parent to the multivolume when the item is in escalation status
		if (!itemWrapper.packageFamily.Copy_Fields_To_multivolume__c || !itemWrapper.getAreMultivolumesEditableInEscalation()) return;
    	volume.needsRecalc = false;

		//only copy margin, price, etc if the margin is automatically calculated by the system.
		//Otherwise, make them enter values. Per Peter
		if (bridge != null && bridge.hasAutomaticMargin != null && bridge.hasAutomaticMargin)
		{
			if (fieldMap.get('price') != null)
				volume.price = DataUtils.getDecimal(itemWrapper.specificRfqItem, fieldMap.get('price'), 0).setScale(precision);

			if (fieldMap.get('margin') != null)
				volume.margin = DataUtils.getDecimal(itemWrapper.specificRfqItem, fieldMap.get('margin'), 0).setScale(precision);


			if (fieldMap.get('marginNoSubstrate') != null)
				volume.marginNoSubstrate = DataUtils.getDecimal(itemWrapper.specificRfqItem, fieldMap.get('marginNoSubstrate'), 0).setScale(precision);

			//AMK-1601
			if (volume.auAdder == 'Inclusive')
			{
				volume.baseBUPrice = volume.price.setScale(precision);
			}
			else
			{
				Decimal adder = volume.auAdder == null || String.isBlank(volume.auAdder) ? 0 : Decimal.valueOf(volume.auAdder);
				volume.baseBUPrice = (volume.price - adder).setScale(precision);
			}

		}
		if (fieldMap.get('subsMarkup') != null)
			volume.subsMarkup = DataUtils.getDecimal(itemWrapper.specificRfqItem, fieldMap.get('subsMarkup'), 0).setScale(precision);

		if (fieldMap.get('subsCost') != null)
			volume.subsCost = DataUtils.getDecimal(itemWrapper.specificRfqItem, fieldMap.get('subsCost'), 0).setScale(precision);

		if (fieldMap.get('othersCost') != null)
			volume.othersCost = DataUtils.getDecimal(itemWrapper.specificRfqItem, fieldMap.get('othersCost'), 0).setScale(precision);

		if (fieldMap.get('totalCost') != null)
			volume.costLessSubs = (DataUtils.getDecimal(itemWrapper.specificRfqItem, fieldMap.get('totalCost'), 0)).setScale(precision);

		if (hasSubstrate)
			volume.costLessSubs -= volume.subsCost;

		if (fieldMap.get('subtotal') != null) {
			volume.subTotals = new List<Decimal>();
			volume.subTotalInd = new List<Integer>();
			volume.price = 0;
			Integer count = 0;
			for(sObject s : itemWrapper.serviceConfigurations) {
				Decimal sub = DataUtils.getDecimal(s, fieldMap.get('subtotal'), 0);
				volume.subTotals.add(sub);
				volume.subTotalInd.add(count++);
				volume.price += sub;
			}
		}

		if (itemWrapper.rfqItem.Package_Family_Name__c == AMKVARS.PF_TEST)
		{
			copyTestFields(itemWrapper, volume, index);
		}
    }

    public void copyTestFields(RFQItemWrapper itemWrapper, RFQIVolume volume, Integer index)
    {
    	//TODO - post test services
		Integer count = 0;
		volume.testInsertionsTotals = new RFQIVolume.RFQITestInsertion();
		//volume.subTotalInd = new List<Integer>();
    	volume.testInsertions = new List<RFQIVolume.RFQITestInsertion>();
    	for (sObject insertion : itemWrapper.insertionConfigurations)
    	{
    		RFQIVolume.RFQITestInsertion testVolume = new RFQIVolume.RFQITestInsertion();
			testVolume.testTime = DataUtils.getDecimal(insertion, 'Insertion_Test_Time__c', 0).setScale(6);
			testVolume.sitesInParallel = DataUtils.getDecimal(insertion, 'Number_of_Sites_in_Parallel__c', 0).setScale(6);
			testVolume.indexTime = DataUtils.getDecimal(insertion, 'Insertion_Index_Time__c', 0).setScale(6);
			testVolume.testerValue = DataUtils.getDecimal(insertion, 'Insertion_Tester_Value__c', 0).setScale(6);
			testVolume.handlerValue = DataUtils.getDecimal(insertion, 'Insertion_Handler_Value__c', 0).setScale(6);
			testVolume.buCostHour = DataUtils.getDecimal(insertion, 'Insertion_BU_Cost__c', 0).setScale(6);
			testVolume.buPriceHour = DataUtils.getDecimal(insertion, 'Insertion_BU_Price_Per_Hour__c', 0).setScale(6);
			testVolume.buPriceSecond = DataUtils.getDecimal(insertion, 'Insertion_BU_Price_Per_Second__c', 0).setScale(6);
			testVolume.buPriceMinute = (testVolume.buPriceHour / 60).setScale(6);
			testVolume.buPriceUnit = DataUtils.getDecimal(insertion, 'BU_Price_Per_Unit_Final__c', 0).setScale(6);
			testVolume.buPriceMonthly = DataUtils.getDecimal(insertion, 'Insertion_BU_Price_Monthly_Charge__c', 0).setScale(6);
			volume.testInsertions.add(testVolume);
			//volume.subTotalInd.add(count++);
    	}

    	volume.totalTestInsertions();

    	String quoteUOM = (String)itemWrapper.specificRfqItem.get('Test_Quote_Unit_of_Measure__c');
        if (quoteUOM == '/Hr')
        {
            volume.price = volume.testInsertionsTotals.buPriceHour;
        }
        else if (quoteUOM == '/Sec')
        {
            volume.price = volume.testInsertionsTotals.buPriceSecond;
        }
        else if (quoteUOM == '/Min')
        {
            volume.price = volume.testInsertionsTotals.buPriceMinute;
        }
        else if (quoteUOM == '/Unit' || quoteUOM == '/Wafer')
        {
            volume.price = volume.testInsertionsTotals.buPriceUnit;
        }
        else if (quoteUOM == '/Month')
        {
            volume.price = volume.testInsertionsTotals.buPriceMonthly;
        }
    }

    public virtual Map<String, String> getFieldMap()
    {
    	Map<String, String> fieldMap = new Map<String, String>();

    	fieldMap.put('price', 'BU_Price__c');
    	//fieldMap.put('margin', '');
    	//fieldMap.put('subsMarkup', '');
    	//fieldMap.put('marginNoSubstrate', '');
    	//fieldMap.put('totalCost', '');
    	//fieldMap.put('subsCost', '');
    	//fieldMap.put('othersCost', ''); //PBGA, FC BGA only
    	//fieldMap.put('subtotal', 'Sub_Total__c'); ENG services

		return fieldMap;
    }

    public static Boolean getHasSubstrate(RFQItemWrapper itemWrapper)
    {
    	return itemWrapper.packageFamily.Has_Substrate__c && !(itemWrapper.packageFamily.Hide_Substrate_Multivolume__c);
    }

    public static Set<String> getPfsWithNoSubstrate()
    {
    	return pfsWithNoSubstrate;
    }

    public static CMBuilder getCMBuilderByWrapper(RFQItemWrapper itemWrapper){
        try
        {
            String cmModel;
            if (!StringUtils.isBlank(itemWrapper.packageFamily.Cost_Model_Implementation__c)) cmModel = itemWrapper.packageFamily.Cost_Model_Implementation__c;
            else cmModel = itemWrapper.productGroup.Cost_Model_Implementation__c;
            Type t = Type.forName(cmModel);
            return (CMBuilder)t.newInstance();
        }
        catch(Exception e)
        {
            Type t = Type.forName('CMDefaultBuilder');
            return (CMBuilder)t.newInstance();
        }
    }

}