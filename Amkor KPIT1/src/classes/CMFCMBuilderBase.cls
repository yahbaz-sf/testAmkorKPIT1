/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com  
* AUTHOR: Steve Simpson
***************************************************************************/
public virtual with sharing class CMFCMBuilderBase extends CMBuilder
{
	//---Actual SObjects for storage  
	public RFQI_FCM__c itemFcm {get; set;}
	public List<RFQI_BOM__c> bomItemList {get; set;}
	public List<RFQI_Process__c> processItemList {get; set;}
		
	//---BOM Item and Variant Selection
	public Map<String, CMBOMItemSelect> bomItemSelectMap {get; set;}
	public List<SelectOption> bomItemSelectList {get; set;}
	public CMBOMItemSelect bomItemSelected {get; set;}
	
	public String bomItemSelectedId {get; set;}
	public String bomVariantSelectedId {get; set;}
	
	public Boolean showBomVariant {get {return bomItemSelected != null && bomItemSelected.bom.Has_Variants__c;}}
	public Boolean showBomAdd {get {return bomItemSelectedId != null && (!showBomVariant || bomVariantSelectedId != null);}}
	
	public Map<String, CMProcessItemSelect> processItemSelectMap {get; set;}
	public List<SelectOption> processItemSelectList {get; set;}
	public CMProcessItemSelect processItemSelected {get; set;}
	
	public String processItemSelectedId {get; set;}
	public String processVariantSelectedId {get; set;}
	
	public Boolean showProcessVariant {get {return processItemSelected != null && processItemSelected.proc.Has_Variants__c;}}
	public Boolean showProcessAdd {get {return processItemSelectedId != null && (!showBomVariant || processVariantSelectedId != null);}}
	
	protected CMFCMBridgeBase fcmBridge {get {return (CMFCMBridgeBase)bridge;}}
	public CMBOMCalcBase bomCalc {get; set;}
	protected CMProcessCalcBase processCalc {get; set;}
	protected Map<Package_Family__c, String> pfSubClassMap;

	public Map<String, List<RFQI_BOM__c>> multiVolumeBoms {get; set;}
	public Map<String, List<RFQI_Process__c>> multiVolumeProcs {get; set;}
	public Map<String, RFQI_FCM__c> multiVolumeFcms {get; set;}

	//To Do:
	
	public virtual override void loadSettings(RFQItemWrapper itemWrapper, Boolean isReloaded){
		if(fcmBridge.wrapper == null) setup(itemWrapper);
		
		
		
		if(fcmBridge.wrapper.specificRfqItem.get('BU_Price_Perc_GM__c') == null || isReloaded)
		{
			Decimal margin = fcmBridge.getMarginPercent();
			fcmBridge.wrapper.specificRfqItem.put('BU_Price_Perc_GM__c', margin);	
		}
	}
	
	//---Setup Calc references
	public virtual override void setup(RFQItemWrapper pWrapper, Boolean needsBridgeSetup) 
	{

		
		super.setup(pWrapper, needsBridgeSetup);
		
		if (needsBridgeSetup)
		{
			//setup pfSubClass to get sub class
			loadPfSubClassMap();

			loadBOMSettings();
			loadProcessSettings();		
		}
			
	}

	private void loadBOMSettings(){
		bomCalc.fcmBridge = fcmBridge;
		loadSelectionDataBOM();

	}

	private void loadProcessSettings(){
		processCalc.fcmBridge = fcmBridge;
		loadSelectionDataProcess();

	}

	// override if the cost model need subclass map 
	protected virtual void loadPfSubClassMap(){
		pfSubClassMap = null;		
	}

	private String getPfSubClass(String packageFamily){
		if(packageFamily == null || pfSubClassMap == null) return null;
		
		Set<Package_Family__c> pfSet = null;		
		pfSet = pfSubClassMap.keySet();
		
		if(pfSet == null) return null;
		for(Package_Family__c pf : pfSet) {			
			if(packageFamily.compareTo(pf.id) == 0.0){				
				return pfSubClassMap.get(pf);							
			}
		}
		return null;
	}

	public void calculateNew(){
		calculateNew(fcmBridge.wrapper, new CMSettings());
	}
	
	public override void calculateNew(RFQItemWrapper itemWrapper, CMSettings pSettings)
	{
		settings = pSettings;
		setup(itemWrapper);
		loadSettings(itemWrapper, true);
		debug.log('calculateNew');
		try{
			 //calculate();
			if(!(itemWrapper.packageFamily.No_Cost_Model__c || itemWrapper.rfqItem.Do_Not_Auto_Price__c)){
				buildNewFcm();
				calcCostModel(itemWrapper);
				fcmBridge.writeResults(itemFcm);	
				itemWrapper.calculateAuPricing();
				calcMulti(itemWrapper, getHasSubstrate(itemWrapper));
			}
			else{
				//itemFcm = RFQIFCMDao.getInstance().getLatest(bridge.wrapper.rfqItem.id);
				calcResults(itemWrapper, false);
				itemWrapper.calculateAuPricing();
				//update fcmBridge.wrapper.specificRfqItem;
				return;								
			}				
		}
		catch(Exception e){
			debug.log('Error in calculateNew', e);
			debug.log('e.getStackTraceString()', e.getStackTraceString());
		}
		
	}

	public override void calculateAll(RFQItemWrapper itemWrapper, Boolean isUpdate, CMSettings settings)
	{
		calculateAll(itemWrapper, isUpdate, settings, true);
	}
	
	//To Do: re-wrtie logic here
	public override void calculateAll(RFQItemWrapper itemWrapper, Boolean isUpdate, CMSettings pSettings, Boolean needsBridgeSetup){

		settings = pSettings;
		setup(itemWrapper, needsBridgeSetup);
		loadSettings(itemWrapper, false);
		debug.log('calculateAll');
		try{
			 //calculate();
			if(!(itemWrapper.packageFamily.No_Cost_Model__c || itemWrapper.rfqItem.Do_Not_Auto_Price__c)){
				loadFcmByWrapper();
				calcCostModel(itemWrapper);
				itemWrapper.calculateAuPricing();
				if (itemWrapper.packageFamily.Copy_Fields_To_multivolume__c) calcMulti(itemWrapper, getHasSubstrate(itemWrapper));
			}
			else{
				debug.log('calculateAll.calcResults');
				//itemFcm = RFQIFCMDao.getInstance().getLatest(bridge.wrapper.rfqItem.id);				
				calcResults(itemWrapper, false);
				itemWrapper.calculateAuPricing();
				//if(isUpdate)
					//update fcmBridge.wrapper.specificRfqItem;								
				return;
			}
			debug.log('calculateAll.writeResults');
			fcmBridge.writeResults(itemFcm, isUpdate);

		}
		catch(Exception e){
			debug.log('Error in calculateAll', e);
			debug.log('e.getStackTraceString()', e.getStackTraceString());
		}
	}

	public override void displayResults(RFQItemWrapper itemWrapper, Boolean isUpdate)
	{
				
		setup(itemWrapper);
		loadSettings(itemWrapper, false);
		debug.log('displayResults');
		if(!(itemWrapper.packageFamily.No_Cost_Model__c || itemWrapper.rfqItem.Do_Not_Auto_Price__c)){
			itemFcm = RFQIFCMDao.getInstance().getLatest(bridge.wrapper.rfqItem.id);
			if (itemFcm == null) buildNewFcm();
			calcResults(itemWrapper, true);
			fcmBridge.writeResults(itemFcm, isUpdate);

			//If has cost model, bomItemList and processItemList don't need to be calculated
			if(bomItemList == null)
				bomItemList = RFQIBOMDao.getInstance().getByFcmId(itemFcm.id); 
			if(processItemList == null)
				processItemList = RFQIProcessDao.getInstance().getByFcmId(itemFcm.id);
							
		}
		else{
			calcResults(itemWrapper, false);
			//if(isUpdate)
				//update fcmBridge.wrapper.specificRfqItem;						
		}

		itemWrapper.calculateAuPricing();

	}

	protected override void calcResults(RFQItemWrapper itemWrapper, Boolean runCostModel){
		debug.log('calcResults runCostModel=' + runCostModel);
		if(runCostModel)
			recalcSummaryWithCostModel();
		else
			recalcSummaryWithoutCostModel();
			
	}

	//---Display the restuls, recalculating if it has not already been run
	// protected override void displayResults(RFQItemWrapper itemWrapper)
	// {
	// 	displayResults(itemWrapper, false);
	// }
	
	//---Load the selection data BOM  
	private void loadSelectionDataBOM()
	{
		bomItemSelectMap = new Map<String, CMBOMItemSelect>();
		bomItemSelectList = new List<SelectOption>();
		bomItemSelected = null;
		
		
		List<FCM_BOM__c> bomList = FCMBOMDao.getInstance().getByVersion(bridge.ver.id);
		
		//---First pass, build the full map
		for(FCM_BOM__c row : bomList)
		{
			if (row.Type__c == 'Item')
			{	
				CMBOMItemSelect selObj = new CMBOMItemSelect();				//---Create the holder for variants
				selObj.bom = row;
				
				bomItemSelectMap.put(row.id, selObj);							//---Add to the map					
			}
		} 
		
		//---Add the variants, filtering where appropriate
		for(FCM_BOM__c row : bomList)
		{
			if (row.Type__c == 'Variant' && row.Parent_BOM__c != null)
			{

				String subClass = getPfSubClass(row.Package_Family__c); 

				CMBOMItemSelect selObj = bomItemSelectMap.get(row.Parent_BOM__c);
				
				
				if (selObj != null && bomCalc.shouldAllowVariant(row, subClass))
				{	
					selObj.variantMap.put(row.id, row);
					selObj.variantSelectList.add( new SelectOption(row.id, row.name));

				}
			}
		}
		
		//---Now process the Items again, adding the ones properly 
		for(FCM_BOM__c row : bomList)
		{	
			if (row.Type__c == 'Item')
			{
				CMBOMItemSelect selObj = bomItemSelectMap.get(row.id);
				
				if (selObj != null)																//---This should always exist
				{
					if (!selObj.bom.Has_Variants__c || selObj.variantSelectList.size() > 0.0)		//---If requires variants, then one must exist
					{												
						bomItemSelectList.add( new SelectOption(row.id, row.name));				//---Add to the Item selection drop down								
					}
				}
			}
		}
		
		if (bomItemSelectList.size() > 0.0)
		{			
			 bomItemSelectedId = bomItemSelectList[0].getValue();	//---Select the first item
			 bomItemChanged();
		}
	}
	
	//---Adding a BOM, the Item was changed
	public void bomItemChanged()
	{
		bomItemSelected = bomItemSelectMap.get(bomItemSelectedId);
		
		if (bomItemSelected != null && bomItemSelected.variantSelectList.size() > 0.0)
		{
			bomVariantSelectedId = bomItemSelected.variantSelectList[0].getValue();
		}
	}

	
	
	//---Load the selection data Process
	private void loadSelectionDataProcess()
	{
		processItemSelectMap = new Map<String, CMProcessItemSelect>();
		processItemSelectList = new List<SelectOption>();
		processItemSelected = null;
		//if(pfSubClassMap == null) loadPFSubClassMap();

		
		
		List<FCM_Process__c> processList = FCMProcessDao.getInstance().getByVersion(bridge.ver.id);
		

		
		//---First pass, build the full map
		for(FCM_Process__c row : processList)
		{
			if (row.Type__c == 'Item')
			{	
				CMProcessItemSelect selObj = new CMProcessItemSelect();			//---Create the holder for variants
				selObj.proc = row;
				
				processItemSelectMap.put(row.id, selObj);							//---Add to the map					
			}
		} 
		
		//---Add the variants, filtering where appropriate		
		for(FCM_Process__c row : processList)
		{
			if (row.Type__c == 'Variant' && row.Parent_Process__c != null)
			{
				CMProcessItemSelect selObj = processItemSelectMap.get(row.Parent_Process__c);				
				String subClass = getPfSubClass(row.Package_Family__c);
				
				
				if (selObj != null && processCalc.shouldAllowVariant(row, subClass))
				{
					selObj.variantMap.put(row.id, row);
					selObj.variantSelectList.add( new SelectOption(row.id, row.name));					
				}
			}
		}
		
		//---Now process the Items again, adding the ones properly
		for(FCM_Process__c row : processList)
		{
			if (row.Type__c == 'Item')
			{
				CMProcessItemSelect selObj = processItemSelectMap.get(row.id);
				
				if (selObj != null)																//---This should always exist
				{
					if (!selObj.proc.Has_Variants__c || selObj.variantSelectList.size() > 0.0)	//---If requires variants, then one must exist
					{						
						processItemSelectList.add( new SelectOption(row.id, row.name));				//---Add to the Item selection drop down
						
					}
				}
			}
		} 
		
		if (processItemSelectList.size() > 0.0)
		{

			 processItemSelectedId = processItemSelectList[0].getValue();	//---Select the first item
			 processItemChanged();
		}	

	}
	
	//---Adding a Process, the Item was changed
	public void processItemChanged()
	{
		processItemSelected = processItemSelectMap.get(processItemSelectedId);
		
		if (processItemSelected != null && processItemSelected.variantSelectList.size() > 0.0)
		{
			processVariantSelectedId = processItemSelected.variantSelectList[0].getValue();
		}
	}

	
	//---Recalculate the summrary data for the Item
	protected virtual void recalcSummaryValues()
	{
		update itemFcm;		//---Save any updates to the percent fields
		itemFcm = RFQIFCMDao.getInstance().getById(itemFcm.id);		//---Reload the Item FCM (with the updated roll up summaries)
		recalcSummaryValues(itemFcm);

		update itemFcm;					//---Update the top level item  
	}
	protected virtual void recalcSummaryValues(RFQI_FCM__c itemFcm)
	{
		
		//---BOM Totaling
		itemFcm.Material_Freight__c = itemFcm.Material_Freight_Percent__c * itemFcm.Sub_Total_Material_Cost__c/100;
		itemFcm.Material_Tooling__c = itemFcm.Material_Tooling_Percent__c * itemFcm.Sub_Total_Material_Cost__c/100;
		itemFcm.Material_Brokerage__c = itemFcm.Material_Brokerage_Percent__c * itemFcm.Sub_Total_Material_Cost__c/100;

		itemFcm.Total_Material_Cost__c = itemFcm.Sub_Total_Material_Cost__c + itemFcm.Material_Freight__c + itemFcm.Material_Tooling__c + itemFcm.Material_Brokerage__c;
		
		//---Process Totaling 
		itemFcm.Manufacturing_Overhead__c = itemFcm.Total_Cost_Per_Unit__c * itemFcm.Manuf_OH_To_Process_Cost__c;
		itemFcm.QA_Cost__c = itemFcm.Total_Cost_Per_Unit__c * itemFcm.QA_Cost_To_Process_Cost__c;
		itemFcm.Service_Group_Cost__c = itemFcm.Total_Cost_Per_Unit__c * itemFcm.Service_Cost_To_Process_Cost__c;
		itemFcm.CLAM__c = itemFcm.Total_Cost_Per_Unit__c + itemFcm.Manufacturing_Overhead__c + itemFcm.QA_Cost__c + itemFcm.Service_Group_Cost__c;
		
		//---Overall Total
		itemFcm.Total_Cost_of_Goods__c = itemFcm.Total_Material_Cost__c + itemFcm.CLAM__c;

		//---Overall Price
		itemFcm.Total_Price__c = itemFcm.Total_Cost_of_Goods__c / (1 - itemFcm.Margin_Percent__c/100.0);

		//---Percent Delta Target Price
		itemFcm.Delta_to_Target_Percent__c = (itemFcm.Sales_Target__c == 0.0) ? 0 : (itemFcm.Total_Price__c - itemFcm.Sales_Target__c)/itemFcm.Sales_Target__c * 100;
	}
	
	

	//---Recalculate the summrary data for the Item, without overwriting the manual values entered when no cost model 
	protected virtual void recalcSummaryWithoutCostModel()
	{
		// AMK-2698 Don't need to recalc due to wanting to enter in information on their own.
		// and not wanting the BU's to enter every specific information
		////Don't need to sue itemFcm
		////write summary attributes
		////itemFcm.CLAM__c 
		//fcmBridge.wrapper.clearPriceToCustomerIfRequired();
		//Decimal clamTotal = fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'CLAM_Direct_Labor__c', 0.0) +
		//					fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'CLAM_Indirect_Labor__c', 0.0) + 
		//					fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'CLAM_Depreciation__c', 0.0) + 
		//					fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'CLAM_Facilities__c', 0.0) +
		//					fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'QA_Cost__c', 0.0) +
		//					fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'Service_Group_Cost__c', 0.0) +
		//					fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'Manufacturing_Overhead__c', 0.0);

		////Material total
		//Decimal materialTotal  = fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'Materials_Leadframe__c', 0.0) +
		//					 fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'Materials_ODM__c', 0.0) +
		//					 fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'Materials_Total_Wire__c', 0.0);

		////Totoal sum
		//Decimal totalCostOfGoods = clamTotal + materialTotal;
		//Decimal margin = fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'BU_Price_Perc_GM__c', 0.0)/100.0;
		//Decimal totalPrice = 1 - margin == 0.0 ? 0 : totalCostOfGoods/(1 - margin );
		//Decimal salesTarget = fcmBridge.getSalesTarget();	
		//Decimal deltaToTargetPerc = salesTarget == 0.0 ? 0 : ((totalPrice - salesTarget)/ salesTarget )* 100;


		////write in calculated values
		//fcmBridge.wrapper.specificRfqItem.put('Materials_Subtotal__c', materialTotal);
		//fcmBridge.wrapper.specificRfqItem.put('Total_Cost__c', totalCostOfGoods);
		//fcmBridge.wrapper.specificRfqItem.put('BU_Price__c', totalPrice);
		//fcmBridge.wrapper.specificRfqItem.put('BU_Price_Perc_Delta_To_Target__c', deltaToTargetPerc);

		//Decimal varCost = 	fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'CLAM_Direct_Labor__c', 0) + 
		//					fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'Manufacturing_Overhead__c', 0) + 
		//					fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'Materials_Subtotal__c', 0); 
								
		//Decimal fixedCost = fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'CLAM_Indirect_Labor__c', 0) +
		//					fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'CLAM_Depreciation__c', 0) +
		//					fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'CLAM_Facilities__c', 0) +
		//					fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'QA_Cost__c', 0) +
		//					fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'Service_Group_Cost__c', 0); 	

		//fcmBridge.wrapper.specificRfqItem.put( 'Fixed_Costs__c', fixedCost);
		//fcmBridge.wrapper.specificRfqItem.put( 'Variable_Costs__c', varCost);
		//Decimal materialPct = totalCostOfGoods > 0 ? 100 *  materialTotal / totalCostOfGoods: 0;		
		//fcmBridge.wrapper.specificRfqItem.put( 'Materials_As_Perc_Cost__c', materialPct);

		//fcmBridge.calculatePackageItemValue(fcmBridge.wrapper, totalPrice);
	}

	//recalculate the % GM and % Delta fields on the RFQI when the BU Price has been manually updated
	protected virtual void recalcSummaryWithCostModel()
	{
		itemFcm.Sales_Target__c = fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'Sales_Target_Price__c', 0.0);
		if (itemFcm.Sales_Target__c == 0.0) itemFcm.Sales_Target__c = fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'Customer_Target_Price__c', 0.0);
		itemFcm.Total_Price__c = fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'BU_Price__c', 0.0);
		itemFcm.Margin_Percent__c = (itemFcm.Total_Price__c == 0.0) ? 0 : (1 - itemFcm.Total_Cost_of_Goods__c/itemFcm.Total_Price__c) * 100;
		itemFcm.Delta_to_Target_Percent__c = (itemFcm.Sales_Target__c == null || itemFcm.Sales_Target__c == 0.0) ? 0 : ((itemFcm.Total_Price__c - itemFcm.Sales_Target__c)/ itemFcm.Sales_Target__c)* 100;

		update itemFcm;
	}

	//Commented out in case we ever want to bring back
	//---The add bom button was selected
	public void bomAdded()
	{
		if (bomItemSelected == null)
		{
			warn('No BOM item selected');
			return;
		}
		
		if (bomItemSelected.bom.id != bomItemSelectedId)
		{
			warn('BOM Item out of synch');
			return;
		}
		
		FCM_BOM__c selectedBom = null;
		
		if (bomItemSelected.bom.Has_Variants__c != null && bomItemSelected.bom.Has_Variants__c == true)
		{
			selectedBom = bomItemSelected.variantMap.get(bomVariantSelectedId);
			
			if (selectedBom == null)
			{
				warn('Cound not find selected BOM Variant');
				return;
			}
		}
		else
		{
			selectedBom = bomItemSelected.bom;
		}
		
		if (selectedBom == null)
		{
			warn('No BOM item found, this should not happen here');
			return;
		}
		
		RFQI_BOM__c itemBom = new RFQI_BOM__c( RFQI_FCM__c=itemFcm.id, BOM__c=selectedBom.id, Sequence__c=selectedBom.Sequence__c);
		bomCalc.add(itemBom, selectedBom);
		insert itemBom;
			
		itemBom = RFQIBOMDao.getInstance().getById(itemBom.id); 	//---Reload with full attributes and related BOM
		bomItemList.add(itemBom);
			
		recalcSummaryValues();
	}
	
	//---Delete a bom item by id
	public void bomDeleted(String itemBomId)
	{
		RFQI_BOM__c selItem = null;
		Integer counter = 0;
		
		for(RFQI_BOM__c row : bomItemList)
		{
			if (row.id == itemBomId)
			{
				 selItem = row;
				 break;
			}
			
			counter++;
		}
		
		if (selItem != null) 
		{
			bomItemList.remove(counter);
			delete selItem;
		}
	}	
	
	//---The add process button was selected
	public void processAdded()
	{
		if (processItemSelected == null)
		{
			warn('No Process item selected');
			return;
		}
		
		if (processItemSelected.proc.id != processItemSelectedId)
		{
			warn('Proc Item out of synch');
			return;
		}
		
		FCM_Process__c selectedProcess = null;
		
		if (processItemSelected.proc.Has_Variants__c != null && processItemSelected.proc.Has_Variants__c == true)
		{
			selectedProcess = processItemSelected.variantMap.get(processVariantSelectedId);
			
			if (selectedProcess == null)
			{
				warn('Cound not find selected Process Variant');
				return;
			}
		}
		else
		{
			selectedProcess = processItemSelected.proc;
		}
		
		if (selectedProcess == null)
		{
			warn('No Process item found, this should not happen here');
			return;
		}
		
		RFQI_Process__c itemProcess = new RFQI_Process__c( RFQI_FCM__c=itemFcm.id, Process__c=selectedProcess.id, Sequence__c=selectedProcess.Sequence__c);
		processCalc.add(itemProcess, selectedProcess);
		insert itemProcess;
			
		itemProcess = RFQIProcessDao.getInstance().getById(itemProcess.id); 	//---Reload with full attributes and related Process
		processItemList.add(itemProcess);
			
		recalcSummaryValues();
		
		
	}
	
	//---Delete a bom item by id
	public void processDeleted(String itemProcessId)
	{
		RFQI_Process__c selItem = null;
		Integer counter = 0;
		
		for(RFQI_Process__c row : processItemList)
		{
			if (row.id == itemProcessId)
			{
				 selItem = row;
				 break;
			}
			
			counter++;
		}
		
		if (selItem != null) 
		{
			processItemList.remove(counter);
			delete selItem;
		}
	}
	

	protected override void calcCostModel(RFQItemWrapper itemWrapper){
		//buildNewFcm();
		try 
		{
			calcBOM();
		} 
		catch (Exception e) 
		{
			debug.log('Error in calcBom()', e);
			debug.log('e.getStackTraceString()', e.getStackTraceString());
		}

		try 
		{
			calcProcess();
		} 
		catch (Exception e) 
		{
			debug.log('Error in calcProcess()', e);
			debug.log('e.getStackTraceString()', e.getStackTraceString());
		}

		if (!bomItemList.isEmpty()) insert bomItemList;
		if (!processItemList.isEmpty()) insert processItemList;
		
		calcAndWriteResults();

	}
	
	private void loadFcmByWrapper()
	{
		debug.log('loadFcmByWrapper');
		//---Build the FCM object
		itemFcm = new RFQI_FCM__c();
		itemFcm.CM_Version__c = fcmBridge.ver.id;
		itemFcm.RFQ_Item__c = fcmBridge.wrapper.rfqItem.id;
		itemFcm.Material_Freight_Percent__c = fcmBridge.getMaterialFreightPercent();
		itemFcm.Material_Tooling_Percent__c = fcmBridge.getMaterialToolingPercent();
		itemFcm.Material_Brokerage_Percent__c = fcmBridge.getMaterialBrokeragePercent();
		itemFcm.Manuf_OH_To_Process_Cost__c = fcmBridge.getManufOHToProcessCost();
		itemFcm.QA_Cost_To_Process_Cost__c = fcmBridge.getQACostToProcessCost();
		itemFcm.Service_Cost_To_Process_Cost__c = fcmBridge.getServiceCostToProcessCost();
		getMarginPercent(itemFcm);
		itemFcm.Substrate_Markup_percent__c = fcmBridge.getSubstrateMarkup();
		itemFcm.Sales_Target__c = fcmBridge.getSalesTarget();
		
		//---Protect from any null values
		if (itemFcm.Material_Freight_Percent__c == null) itemFcm.Material_Freight_Percent__c = 0;
		if (itemFcm.Material_Tooling_Percent__c == null) itemFcm.Material_Tooling_Percent__c = 0;
		if (itemFcm.Material_Brokerage_Percent__c == null) itemFcm.Material_Brokerage_Percent__c = 0;
		if (itemFcm.Manuf_OH_To_Process_Cost__c == null) itemFcm.Manuf_OH_To_Process_Cost__c = 0;
		if (itemFcm.QA_Cost_To_Process_Cost__c == null) itemFcm.QA_Cost_To_Process_Cost__c = 0;
		if (itemFcm.Service_Cost_To_Process_Cost__c == null) itemFcm.Service_Cost_To_Process_Cost__c = 0;
		if (itemFcm.Margin_Percent__c == null) itemFcm.Margin_Percent__c = 0;
		if(itemFcm.Sales_Target__c == null) itemFcm.Sales_Target__c = 0;
		
		insert itemFcm;
		
		//---Setup the lists
		bomItemList = new List<RFQI_BOM__c>();
		processItemList = new List<RFQI_Process__c>();
	}

	protected virtual void getMarginPercent(RFQI_FCM__c itemFcm)
	{
		try 
		{
			itemFcm.Margin_Percent__c = getDecimal(fcmBridge.wrapper.specificRfqItem, 'BU_Price_Perc_GM__c', 0.0);
		} 
		catch (Exception e) 
		{
			debug.log('Error in getMarginPercent', e);
		}
	}

	
	//---Build a new FCM with no BOM/Proceess
	private void buildNewFcm()
	{
		debug.log('buildNewFcm');
		//---Build the FCM object
		itemFcm = new RFQI_FCM__c();
		itemFcm.CM_Version__c = fcmBridge.ver.id;
		itemFcm.RFQ_Item__c = fcmBridge.wrapper.rfqItem.id;
		itemFcm.Material_Freight_Percent__c = fcmBridge.getMaterialFreightPercent();
		itemFcm.Material_Tooling_Percent__c = fcmBridge.getMaterialToolingPercent();
		itemFcm.Material_Brokerage_Percent__c = fcmBridge.getMaterialBrokeragePercent();
		itemFcm.Manuf_OH_To_Process_Cost__c = fcmBridge.getManufOHToProcessCost();
		itemFcm.QA_Cost_To_Process_Cost__c = fcmBridge.getQACostToProcessCost();
		itemFcm.Service_Cost_To_Process_Cost__c = fcmBridge.getServiceCostToProcessCost();
		getMarginPercent(itemFcm);
		itemFcm.Substrate_Markup_percent__c = fcmBridge.getSubstrateMarkup();
		itemFcm.Margin_Percent__c = fcmBridge.getMarginPercent();
		itemFcm.Sales_Target__c = fcmBridge.getSalesTarget();
		
		//---Protect from any null values
		if (itemFcm.Material_Freight_Percent__c == null) itemFcm.Material_Freight_Percent__c = 0;
		if (itemFcm.Material_Tooling_Percent__c == null) itemFcm.Material_Tooling_Percent__c = 0;
		if (itemFcm.Material_Brokerage_Percent__c == null) itemFcm.Material_Brokerage_Percent__c = 0;
		if (itemFcm.Manuf_OH_To_Process_Cost__c == null) itemFcm.Manuf_OH_To_Process_Cost__c = 0;
		if (itemFcm.QA_Cost_To_Process_Cost__c == null) itemFcm.QA_Cost_To_Process_Cost__c = 0;
		if (itemFcm.Service_Cost_To_Process_Cost__c == null) itemFcm.Service_Cost_To_Process_Cost__c = 0;
		if (itemFcm.Margin_Percent__c == null) itemFcm.Margin_Percent__c = 0;
		if(itemFcm.Sales_Target__c == null) itemFcm.Sales_Target__c = 0;
		
		insert itemFcm;
		debug.log('itemFcm', itemFcm);
		//---Setup the lists
		bomItemList = new List<RFQI_BOM__c>();
		processItemList = new List<RFQI_Process__c>();
	}
	
	//---Calculate and write results
	private void calcAndWriteResults()
	{
		bomItemList = RFQIBOMDao.getInstance().getByFcmId(itemFcm.id); 
		processItemList = RFQIProcessDao.getInstance().getByFcmId(itemFcm.id);
		recalcSummaryValues();
		//fcmBridge.writeResults(itemFcm);					//---Write the results back through the wrapper
		//System.debug(LoggingLevel.ERROR, '#### end writing results in CMFCMBuilderBase');
	}
	
	//---Calculate the elements to add 
	private void calcBOM()
	{
		List<FCM_Match_Condition__c> matchList = FCMMatchConditionDao.getInstance().getAllByBomVersion(fcmBridge.ver.id);
		
		//---Process in order of the drop down
		for(SelectOption row : bomItemSelectList)
		{
			//---Check a BOM and its val
			bomItemSelected = bomItemSelectMap.get(row.getValue());
			
			if (bomItemSelected != null)
			{
				if (bomItemSelected.bom.Has_Variants__c != null && bomItemSelected.bom.Has_Variants__c == true)
				{
					for(FCM_BOM__c vRow : bomItemSelected.variantMap.values())
					{
						//---Process the Item
						if (shouldAutoAddBom(vRow, matchList, 'I')) 
						{
							RFQI_BOM__c itemBom = new RFQI_BOM__c( RFQI_FCM__c=itemFcm.id, BOM__c=vRow.id, Sequence__c=vRow.Sequence__c);
							bomCalc.add(itemBom, vRow);
							bomItemList.add(itemBom);
						}
						
						//---Process the Wires						
						for(SObject wRow : fcmBridge.wrapper.wireConfigurations)
						{																					
							fcmBridge.selectedWire = wRow;														
							
							if (shouldAutoAddBom(vRow, matchList, 'W'))
							{								
								RFQI_BOM__c itemBom = new RFQI_BOM__c( RFQI_FCM__c=itemFcm.id, BOM__c=vRow.id, Sequence__c=vRow.Sequence__c);								
								bomCalc.add(itemBom, vRow);
								bomItemList.add(itemBom);
							}
						}
						fcmBridge.selectedWire = null;
						
						//---Process the Dies
						fcmBridge.selectedDiePosition = 0;
						for(SObject dRow : fcmBridge.wrapper.dieConfigurations)
						{
							fcmBridge.selectedDiePosition++;
							fcmBridge.selectedDie = dRow;
							
							if (shouldAutoAddBom(vRow, matchList, 'D'))
							{
								RFQI_BOM__c itemBom = new RFQI_BOM__c( RFQI_FCM__c=itemFcm.id, BOM__c=vRow.id, Sequence__c=vRow.Sequence__c);
								bomCalc.add(itemBom, vRow);
								bomItemList.add(itemBom);
							}
						}
						fcmBridge.selectedDie = null;	
						fcmBridge.selectedDiePosition = 0;

						//---Process the Passives						
						for(SObject pRow : fcmBridge.wrapper.PassiveConfigurations)
						{																					
							fcmBridge.selectedPassive = pRow;														
							
							if (shouldAutoAddBom(vRow, matchList, 'P'))
							{								
								RFQI_BOM__c itemBom = new RFQI_BOM__c( RFQI_FCM__c=itemFcm.id, BOM__c=vRow.id, Sequence__c=vRow.Sequence__c);								
								bomCalc.add(itemBom, vRow);
								bomItemList.add(itemBom);
							}
						}
						fcmBridge.selectedPassive = null;
					}
				}
				else
				{
					//---Process the item
					if (shouldAutoAddBom(bomItemSelected.bom, matchList, 'I')) 
					{
						RFQI_BOM__c itemBom = new RFQI_BOM__c( RFQI_FCM__c=itemFcm.id, BOM__c=bomItemSelected.bom.id, Sequence__c=bomItemSelected.bom.Sequence__c);
						bomCalc.add(itemBom, bomItemSelected.bom);
						bomItemList.add(itemBom);
					}
					
					//---Process the Wires
					for(SObject wRow : fcmBridge.wrapper.wireConfigurations)
					{						
						fcmBridge.selectedWire = wRow;
							
						if (shouldAutoAddBom(bomItemSelected.bom, matchList, 'W'))
						{
							RFQI_BOM__c itemBom = new RFQI_BOM__c( RFQI_FCM__c=itemFcm.id, BOM__c=bomItemSelected.bom.id, Sequence__c=bomItemSelected.bom.Sequence__c);
							bomCalc.add(itemBom, bomItemSelected.bom);
							bomItemList.add(itemBom);
						}
					}
					fcmBridge.selectedWire = null;
						
					//---Process the Dies
					for(SObject dRow : fcmBridge.wrapper.dieConfigurations)
					{
						fcmBridge.selectedDie = dRow;
							
						if (shouldAutoAddBom(bomItemSelected.bom, matchList, 'D'))
						{
							RFQI_BOM__c itemBom = new RFQI_BOM__c( RFQI_FCM__c=itemFcm.id, BOM__c=bomItemSelected.bom.id, Sequence__c=bomItemSelected.bom.Sequence__c);
							bomCalc.add(itemBom, bomItemSelected.bom);
							bomItemList.add(itemBom);
						}
					}
					fcmBridge.selectedDie = null;	

					//---Process the Passives
					for(SObject pRow : fcmBridge.wrapper.passiveConfigurations)
					{						
						fcmBridge.selectedPassive = pRow;
						if (shouldAutoAddBom(bomItemSelected.bom, matchList, 'P'))
						{
							RFQI_BOM__c itemBom = new RFQI_BOM__c( RFQI_FCM__c=itemFcm.id, BOM__c=bomItemSelected.bom.id, Sequence__c=bomItemSelected.bom.Sequence__c);
							bomCalc.add(itemBom, bomItemSelected.bom);
							bomItemList.add(itemBom);
						}
					}
					fcmBridge.selectedWire = null;
				}
			}
		}

	}
	
	//---Sbould the BOM be added automatically
	private Boolean shouldAutoAddBom(FCM_BOM__c bom, List<FCM_Match_Condition__c> matchList, String matchType)
	{
		
		List<FCM_Match_Condition__c> bomMatch = new List<FCM_Match_Condition__c>();
		List<FCM_Match_Condition__c> parentBomMatch = new List<FCM_Match_Condition__c>();
		
		//---Load current and Parent Match Conditions
		for(FCM_Match_Condition__c row : matchList) 
		{
			if (row.FCM_BOM__c == bom.id) bomMatch.add(row);
			if (bom.Parent_BOM__c != null && row.FCM_BOM__c == bom.Parent_BOM__c) parentBomMatch.add(row);
		}
		
		return shouldAddMatchCheck(bomMatch, parentBomMatch, bom.name, matchType);
	}
	
	private Boolean shouldAddMatchCheck(List<FCM_Match_Condition__c> currMatches, List<FCM_Match_Condition__c> parentMatches, String objName, String matchType)
	{
		//---Check Current
		Integer currMatchCount = 0;

		Integer currMatchI = 0;
		Integer currMatchW = 0;
		Integer currMatchD = 0;
		Integer currMatchP = 0;

		for(FCM_Match_Condition__c row : currMatches) 
		{
			if (matchType == 'I' && isMatchedItem(row, objName)) currMatchI++;
			if (matchType == 'W' && isMatchedWire(row, objName)) currMatchW++;
			if (matchType == 'D' && isMatchedDie(row, objName)) currMatchD++;
			if (matchType == 'P' && isMatchedPassive(row, objName)) currMatchP++;
		}
		//---Check Parent
		Integer parentMatchCount = 0;

		Integer parentMatchI = 0;
		Integer parentMatchW = 0;
		Integer parentMatchD = 0;
		Integer parentMatchP = 0;

		for(FCM_Match_Condition__c row : parentMatches) 
		{
			if (matchType == 'I' && isMatchedItem(row, objName)) parentMatchI++;
			if (matchType == 'W' && isMatchedWire(row, objName)) parentMatchW++;
			if (matchType == 'D' && isMatchedDie(row, objName)) parentMatchD++;
			if (matchType == 'P' && isMatchedPassive(row, objName)) parentMatchP++;
		}

		//---If there is at least 1 W or 1 D match in either the parent or child, 
		//---then loop through checking for Item level filters
		if ((matchType == 'W' && (currMatchW+parentMatchW) > 0) || (matchType == 'D' && (currMatchD+parentMatchD) > 0) || (matchType == 'P' && (currMatchP+parentMatchP) > 0))
		{
			//---loop through child level filters
			for(FCM_Match_Condition__c row : currMatches) 
			{
				if (isMatchedItem(row, objName)) currMatchI++;
			}

			//---loop through parent level filters
			for(FCM_Match_Condition__c row : parentMatches) 
			{
				if (isMatchedItem(row, objName)) parentMatchI++;
			}
		}

		//---add results to find match
		currMatchCount = currMatchI + currMatchW + currMatchD + currMatchP;
		parentMatchCount = parentMatchI + parentMatchW + parentMatchD + parentMatchP;

		Boolean isCurrentMatch = currMatches.size() > 0 && currMatchCount == currMatches.size();
		Boolean isParentMatch = parentMatches.size() > 0 && parentMatchCount == parentMatches.size();

		if (isCurrentMatch && isParentMatch) return true;					//---Both match
		if (isCurrentMatch && parentMatches.size() == 0.0) return true;		//---Current and no unmatching parent conditions
		if (isParentMatch && currMatches.size() == 0.0) return true;			//---Parent and no unmatching current conditions
	
		return false;
	}
	
	//---Check for a single item match
	private Boolean isMatchedItem(FCM_Match_Condition__c matchCond, String objName)
	{

		if (matchCond.Match_Type__c == 'AlwaysItem') return true;
		
		try
		{
			if (matchCond.RFQI_Field_Def__c == null && matchCond.Match_Type__c != 'WireType' && matchCond.Match_Type__c != 'WireDiameter') return false;
				
			if (matchCond.Match_Type__c == 'ItemTextValue')
			{
				String itemValue;
				if(matchCond.RFQI_Field_Def__r.name == ('Factory__r.Name')) 
				{
        		    sObject factory = fcmBridge.wrapper.specificRfqItem.getSObject('Factory__r');
        		    if(factory != null) itemValue = (String)factory.get('Name');
        		}
                else {
					itemValue = (String)fcmBridge.wrapper.specificRfqItem.get(matchCond.RFQI_Field_Def__r.name);
                }

				if (itemValue == null || itemValue == '') return false;
				if (matchCond.Text_Value__c == null) return false; 
			
				if (matchCond.Operand__c == 'Contains') return itemValue.contains(matchCond.Text_Value__c);
				if (matchCond.Operand__c == 'NotContains') return !itemValue.contains(matchCond.Text_Value__c); 
				if (matchCond.Operand__c == 'Equals') return itemValue == matchCond.Text_Value__c;
			}
			else if (matchCond.Match_Type__c == 'ItemBoolean')
			{
				Boolean itemValue = (Boolean)fcmBridge.wrapper.specificRfqItem.get(matchCond.RFQI_Field_Def__r.name);
				if (matchCond.Operand__c == 'Equals') return itemValue == matchCond.Boolean_Value__c;
			}
			else if (matchCond.Match_Type__c == 'ItemNumberValue')
			{
				Boolean result;
				Decimal itemValue = (Decimal)fcmBridge.wrapper.specificRfqItem.get(matchCond.RFQI_Field_Def__r.name);

				if (itemValue == null ) result =  false;
				if (matchCond.Numeric_Value__c == null) result =  false; 

				if (matchCond.Operand__c == 'LessThanEqualTo') result =  itemValue <= matchCond.Numeric_Value__c;
				else if (matchCond.Operand__c == 'GreaterThanEqualTo') result =  itemValue >= matchCond.Numeric_Value__c; 
				else if (matchCond.Operand__c == 'Equals') result =  matchCond.Numeric_Value__c == itemValue;
				return result;
				
			}
			else if(matchCond.Match_Type__c == 'AnyPassiveContains')
			{
				//go through all passives looking for a value. If you want any passive to have the value, use Operand__c = 'Equals'/'Contains'
				//If you want no passives to have the value, use Operand__c='NotContains'
				for (sObject passive : fcmBridge.wrapper.passiveConfigurations)
				{
					debug.log('matchCond.RFQI_Field_Def__c', matchCond.RFQI_Field_Def__c);
					debug.log('matchCond.RFQI_Field_Def__r.Name', matchCond.RFQI_Field_Def__r.Name);
					debug.log('matchCond.Text_Value__c', matchCond.Text_Value__c);
					debug.log('matchCond.Operand__c', matchCond.Operand__c);
					String value = (String)passive.get(matchCond.RFQI_Field_Def__r.Name);
					if ( value!= null && value == matchCond.Text_Value__c) return matchCond.Operand__c == 'Equals';
					else if (value!= null && value.contains(matchCond.Text_Value__c)) return matchCond.Operand__c == 'Contains';

				}
				//if no matches are found, do not add
				//do add, though, if you are looking for match based on none equalling
				return matchCond.Operand__c == 'NotEquals' || matchCond.Operand__c == 'NotContains';
			}



		} 
		catch (Exception ex)
		{
			debug.log('Error checking match condition isMatchedItem', ex);
			debug.log('ex.getStackTraceString()', ex.getStackTraceString());
		}
		return false;
	}
	
	//---Check for a single wire match 
	private Boolean isMatchedWire(FCM_Match_Condition__c matchCond, String objName)
	{
		if (matchCond.Match_Type__c == 'AlwaysWire') return true;
		
		try
		{	
			if (matchCond.Match_Type__c == 'WireBoolean')
			{
				return fcmBridge.getWireFieldBooleanMatch( matchCond.RFQI_Field_Def__r.name, matchCond.Boolean_Value__c);
			}
			else if (matchCond.Match_Type__c == 'WireTextValue') 
			{
				String fieldVal = (String)fcmBridge.getWireFieldValue(matchCond.RFQI_Field_Def__r.name);
				
				//warn('xx fieldVal:' + fieldVal + '  matchCond:' + matchCond.Text_Value__c);
				
				if (fieldVal == null || fieldVal == '') return false;
				if (matchCond.Text_Value__c == null) return false;
				
				if (matchCond.Operand__c == 'Contains') return fieldVal.contains(matchCond.Text_Value__c);
				if (matchCond.Operand__c == 'NotContains') return !fieldVal.contains(matchCond.Text_Value__c); 
				if (matchCond.Operand__c == 'Equals') return fieldVal == matchCond.Text_Value__c;
				if (matchCond.Operand__c == 'ContainsOnlyOne') {
					//check if already existed
					for(RFQI_BOM__c itemBom : bomItemList)					
						if(itemBom.Name == objName)
							return false;					
					return fieldVal.contains(matchCond.Text_Value__c);
				}
			}
		} 
		catch (Exception ex)
		{
			debug.log('Error checking match condition isMatchedWire', ex); 
			debug.log('ex.getStackTraceString()', ex.getStackTraceString());
		}
		
		return false; 
	}
	
	//---Check for a single die match
	private Boolean isMatchedDie(FCM_Match_Condition__c matchCond, String objName)
	{
		if (matchCond.Match_Type__c == 'AlwaysDie') return true;
		
		try
		{	
			if (matchCond.Match_Type__c == 'DieBoolean')
			{
				return fcmBridge.getDieFieldBooleanMatch( matchCond.RFQI_Field_Def__r.name, matchCond.Boolean_Value__c);
			}
			else if (matchCond.Match_Type__c == 'DieTextValue')
			{
				String fieldVal = (String)fcmBridge.getDieFieldValue(matchCond.RFQI_Field_Def__r.name);
				if (fieldVal == null || fieldVal == '') return false;
				if (matchCond.Text_Value__c == null) return false;
				
				if (matchCond.Operand__c == 'Contains') return fieldVal.contains(matchCond.Text_Value__c);
				if (matchCond.Operand__c == 'NotContains') return !fieldVal.contains(matchCond.Text_Value__c); 
				if (matchCond.Operand__c == 'Equals') return fieldVal == matchCond.Text_Value__c;
			}
			else if (matchCond.Match_Type__c == 'DieCountMin')
			{
				return matchCond.Numeric_Value__c == null ? false : fcmBridge.wrapper.dieConfigurations.size() >= matchCond.Numeric_Value__c;
			}
			else if (matchCond.Match_Type__c == 'DiePosition')
			{
				return (matchCond.Numeric_Value__c == null || fcmBridge.selectedDiePosition == null) ? false : fcmBridge.selectedDiePosition == matchCond.Numeric_Value__c;
			}
		} 
		catch (Exception ex)
		{
			debug.log('Error checking match condition isMatchedDie', ex); 
			debug.log('ex.getStackTraceString()', ex.getStackTraceString());
		}
		
		return false;
	}

	//---Check for a single passive match 
	private Boolean isMatchedPassive(FCM_Match_Condition__c matchCond, String objName)
	{
		if (matchCond.Match_Type__c == 'AlwaysPassive') return true;
		
		try
		{	
			if (matchCond.Match_Type__c == 'PassiveBoolean')
			{
				return fcmBridge.getPassiveFieldBooleanMatch( matchCond.RFQI_Field_Def__r.name, matchCond.Boolean_Value__c);
			}
			else if (matchCond.Match_Type__c == 'PassiveTextValue') 
			{
				String fieldVal = (String)fcmBridge.getPassiveFieldValue(matchCond.RFQI_Field_Def__r.name);
				
				if (fieldVal == null || fieldVal == '') return false;
				if (matchCond.Text_Value__c == null) return false;
				
				if (matchCond.Operand__c == 'Contains') return fieldVal.contains(matchCond.Text_Value__c);
				if (matchCond.Operand__c == 'NotContains') return !fieldVal.contains(matchCond.Text_Value__c); 
				if (matchCond.Operand__c == 'Equals') return fieldVal == matchCond.Text_Value__c;
				if (matchCond.Operand__c == 'ContainsOnlyOne') {
					//check if already existed
					for(RFQI_BOM__c itemBom : bomItemList)					
						if(itemBom.Name == objName)
							return false;					
					return fieldVal.contains(matchCond.Text_Value__c);
				}
			}
		} 
		catch (Exception ex)
		{
			debug.log('Error checking match condition isMatchedPassive', ex);
			debug.log('ex.getStackTraceString()', ex.getStackTraceString()); 
		}
		return false; 
	}
	
	//---Calculate the elements to add 
	private void calcProcess()
	{
		List<FCM_Match_Condition__c> matchList = FCMMatchConditionDao.getInstance().getAllByProcessVersion(fcmBridge.ver.id);

		//---Process in order of the drop down
		for(SelectOption row : processItemSelectList)
		{
			//---Check a Process and its var
			processItemSelected = processItemSelectMap.get(row.getValue());
			if (processItemSelected != null)
			{
				if (processItemSelected.proc.Has_Variants__c != null && processItemSelected.proc.Has_Variants__c == true)
				{
					for(FCM_Process__c vRow : processItemSelected.variantMap.values())
					{
						if (shouldAutoAddProcess(vRow, matchList, 'I')) 
						{
							RFQI_Process__c itemProcess = new RFQI_Process__c( RFQI_FCM__c=itemFcm.id, Process__c=vRow.id, Sequence__c=vRow.Sequence__c);
							processCalc.add(itemProcess, vRow);
							processItemList.add(itemProcess);
						}
						
						//---Process the Wires
						for(SObject wRow : fcmBridge.wrapper.wireConfigurations)
						{
							fcmBridge.selectedWire = wRow;
							
							if (shouldAutoAddProcess(vRow, matchList, 'W'))
							{
								RFQI_Process__c itemProcess = new RFQI_Process__c( RFQI_FCM__c=itemFcm.id, Process__c=vRow.id, Sequence__c=vRow.Sequence__c);
								processCalc.add(itemProcess, vRow);
								processItemList.add(itemProcess);
							}
						}
						fcmBridge.selectedWire = null;
						
						//---Process the Dies
						fcmBridge.selectedDiePosition = 0;
						for(SObject dRow : fcmBridge.wrapper.dieConfigurations)
						{
							fcmBridge.selectedDiePosition++;
							fcmBridge.selectedDie = dRow;
							
							if (shouldAutoAddProcess(vRow, matchList, 'D'))
							{
								RFQI_Process__c itemProcess = new RFQI_Process__c( RFQI_FCM__c=itemFcm.id, Process__c=vRow.id, Sequence__c=vRow.Sequence__c);
								processCalc.add(itemProcess, vRow);
								processItemList.add(itemProcess);
							}
						}
						fcmBridge.selectedDie = null;	
						fcmBridge.selectedDiePosition = 0;
					}
				}
				else
				{
					//---Process the item
					if (shouldAutoAddProcess(processItemSelected.proc, matchList, 'I')) 
					{
						RFQI_Process__c itemProcess = new RFQI_Process__c( RFQI_FCM__c=itemFcm.id, Process__c=processItemSelected.proc.id, Sequence__c=processItemSelected.proc.Sequence__c);
						processCalc.add(itemProcess, processItemSelected.proc);
						processItemList.add(itemProcess);
					}
					
					//---Process the Wires
					for(SObject wRow : fcmBridge.wrapper.wireConfigurations)
					{
						fcmBridge.selectedWire = wRow;
							
						if (shouldAutoAddProcess(processItemSelected.proc, matchList, 'W'))
						{
							RFQI_Process__c itemProcess = new RFQI_Process__c( RFQI_FCM__c=itemFcm.id, Process__c=processItemSelected.proc.id, Sequence__c=processItemSelected.proc.Sequence__c);
							processCalc.add(itemProcess, processItemSelected.proc);
							processItemList.add(itemProcess);
						}
					}
					fcmBridge.selectedWire = null;
						
					//---Process the Dies
					for(SObject dRow : fcmBridge.wrapper.dieConfigurations)
					{
						fcmBridge.selectedDie = dRow;
							
						if (shouldAutoAddProcess(processItemSelected.proc, matchList, 'D'))
						{
							RFQI_Process__c itemProcess = new RFQI_Process__c( RFQI_FCM__c=itemFcm.id, Process__c=processItemSelected.proc.id, Sequence__c=processItemSelected.proc.Sequence__c);
							processCalc.add(itemProcess, processItemSelected.proc);
							processItemList.add(itemProcess);
						}
					}
					fcmBridge.selectedDie = null;	
				}
			}
		}
	}
	
	//---Sbould the Process be added automatically
	private Boolean shouldAutoAddProcess(FCM_Process__c proc, List<FCM_Match_Condition__c> matchList, String matchType)
	{
		List<FCM_Match_Condition__c> procMatch = new List<FCM_Match_Condition__c>();
		List<FCM_Match_Condition__c> parentProcMatch = new List<FCM_Match_Condition__c>();
		//---Load current and Parent Match Conditions
		for(FCM_Match_Condition__c row : matchList) 
		{
			if (row.FCM_Process__c == proc.id) procMatch.add(row);
			if (proc.Parent_Process__c != null && row.FCM_Process__c == proc.Parent_Process__c) parentProcMatch.add(row);
		}
		return shouldAddMatchCheck(procMatch, parentProcMatch, proc.name, matchType);
	}
	
	//---Clear the calculations 
	public void clearCalc()
	{
		buildNewFcm();	
		calcAndWriteResults();
	}
	
	private void warn(String message)
	{
		debug.log(message);
	}	

	public virtual override void onAttributeChange(RFQItemWrapper itemWrapper, String attributeName)
	{
        DebugUtils.write('attributeName', attributeName);
		if(attributeName == 'BU_Price__c') 
		{
		    onBUPriceChanged(itemWrapper);
		} 
		else if(attributeName == 'BU_Price_Perc_Delta_To_Target__c') 
		{
		   onBUPricePercDeltaToTargetChanged(itemWrapper);
		}
		else if (attributeName == 'BU_Price_Perc_GM__c')
		{
		    onBUPricePercGMChanged(itemWrapper);
		}                      
		else if (attributeName == 'Total_Cost__c')
        {
            onTotalCostChanged(itemWrapper);
        }
	}

    public virtual void onTotalCostChanged(RFQItemWrapper itemWrapper)
    {
        Decimal totalCost = getDecimal(itemWrapper.specificRfqItem, 'Total_Cost__c', 0.0);

        if(totalCost <= 0.0)
        {
            String err = 'Total Cost is less than or equal to 0. <br /> Please make sure total cost is greater than 0.';
            addError(err);
        }
        else
        {
            Decimal buPrice = getDecimal(itemWrapper.specificRfqItem, 'BU_Price__c', 0.0);
            Decimal marginPercent = getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Perc_GM__c', 0.0);
            Decimal newBuPrice = 0.0;
            Decimal newMarginPercent = 0.0;

            if (marginPercent == 0.0 && buPrice == 0.0)
            {
                // Do Nothing
                DebugUtils.write('Margin and BU Price not set, doing nothing');
                return;
            }
            else if (marginPercent > 0.0 && buPrice == 0.0)
            {
                DebugUtils.write('Margin is greater than 0, updating BU Price');
                newBuPrice = totalCost * 100.0 / (100.0 - marginPercent);
            }
            else if (marginPercent == 0.0 && buPrice > 0.0)
            {
                DebugUtils.write('BU Price is greater than 0, updating Margin');
                newMarginPercent = (buPrice - totalCost) * 100 / buPrice;
            }          // if we get here just update the bu
            else if (marginPercent > 0.0 && buPrice > 0.0)
            {
                DebugUtils.write('Updating BU Price');
                newBuPrice = totalCost * 100.0 / (100.0 - marginPercent);
            }

            if (newBuPrice > 0.0)
            {
                DebugUtils.write('newBuPrice', newBuPrice);
                itemWrapper.specificRfqItem.put('BU_Price__c',newBuPrice);
                Decimal salesTargetPrice = getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0) == 0.0 ? getDecimal(itemWrapper.specificRfqItem, 'Customer_Target_Price__c', 0.0) : getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0);
                Decimal delta = (salesTargetPrice != 0.0) ? (newBuPrice - salesTargetPrice)/salesTargetPrice : 0.0;
                itemWrapper.specificRfqItem.put('BU_Price_Perc_Delta_To_Target__c', delta * 100.0);
            }
            if (newMarginPercent > 0.0)
            {
                DebugUtils.write('newMarginPercent', newMarginPercent);
                itemWrapper.specificRfqItem.put('BU_Price_Perc_GM__c', newMarginPercent);
            }
            fcmBridge.calculatePackageItemValue(itemWrapper, buPrice);
        }
    }

	public virtual void onBUPriceChanged(RFQItemWrapper itemWrapper)
	{
		Decimal buPrice = getDecimal(itemWrapper.specificRfqItem, 'BU_Price__c', 0.0);

        if(buPrice <= 0.0)
        {
            String err = 'BU Price must be greater than 0. <br /> Please re-enter BU price. ';
            addError(err);
        }
        else
        {
            Decimal salesTargetPrice = getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0) == 0.0 ? getDecimal(itemWrapper.specificRfqItem, 'Customer_Target_Price__c', 0.0) : getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0);
            Decimal delta = (salesTargetPrice != 0.0) ? (buPrice - salesTargetPrice)/salesTargetPrice : 0.0;
            itemWrapper.specificRfqItem.put('BU_Price_Perc_Delta_To_Target__c', delta * 100.0);

            Decimal totalCost = getDecimal(itemWrapper.specificRfqItem, 'Total_Cost__c', 0.0);
            Decimal marginPercent = getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Perc_GM__c', 0.0);
            Decimal newTotalCost = 0.0;
            Decimal newMarginPercent = 0.0;
            if (totalCost == 0.0 && marginPercent == 0.0)
            {
                // Do Nothing
                DebugUtils.write('Total Cost and BU Price not set, doing nothing');
                return;
            }
            else if (totalCost > 0.0 && marginPercent == 0.0)
            {
                DebugUtils.write('Total Cost is greater than 0, updating Margin');
                newMarginPercent = (buPrice - totalCost) * 100.0 / buPrice;

                DebugUtils.write('newMarginPercent', newMarginPercent);
            }
            else if (totalCost == 0.0 && marginPercent > 0.0)
            {
                DebugUtils.write('BU Price is greater than 0, updating Margin');
                newTotalCost = buPrice - (marginPercent + buPrice)/100.0;
            }
            else if (totalCost > 0.0 && marginPercent > 0.0)
            {
                DebugUtils.write('Updating Margin');
                newMarginPercent = (buPrice - totalCost) * 100.0 / buPrice;
            }

            if (newTotalCost > 0.0)
            {
                DebugUtils.write('newTotalCost', newTotalCost);
                itemWrapper.specificRfqItem.put('Total_Cost__c', newTotalCost);
            }
            if (newMarginPercent > 0.0)
            {
                DebugUtils.write('newMarginPercent', newMarginPercent);
                itemWrapper.specificRfqItem.put('BU_Price_Perc_GM__c', newMarginPercent);
            }
            fcmBridge.calculatePackageItemValue(itemWrapper, buPrice);
        }
	}

	public virtual void onBUPricePercDeltaToTargetChanged(RFQItemWrapper itemWrapper){
        Decimal delta = getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Perc_Delta_To_Target__c',0.0) / 100.0;
        if(delta <= -1.0)
        {
        	String err = 'BU Price % Delta To Target is smaller than or equal to -100. <br /> Please make sure the value is greater than -100.';
    		addError(err);
        }

        Decimal targetSalesPrice =  getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0) == 0.0 ? getDecimal(itemWrapper.specificRfqItem,'Customer_Target_Price__c', 0.0) : getDecimal(itemWrapper.specificRfqItem,'Sales_Target_Price__c',0.0);        
        if(targetSalesPrice <= 0.0)
        {
        	String err = 'Sales target price is smaller than or equal to 0. <br /> Please make sure sales target price is greater than 0.';
    		addError(err);
        }
        
        Decimal buPrice = (delta + 1) * targetSalesPrice;        
        Decimal totalCost = getDecimal(itemWrapper.specificRfqItem,'Total_Cost__c', 0.0);
        Decimal marginPercent = (buPrice - totalCost) * 100 / buPrice ; 
        system.debug('marginPercent  : '+marginPercent);
        itemWrapper.specificRfqItem.put('BU_Price__c',buPrice);
        itemWrapper.specificRfqItem.put('BU_Price_Perc_GM__c', marginPercent);
        fcmBridge.calculatePackageItemValue(itemWrapper, buPrice);
	}

	public virtual void onBUPricePercGMChanged(RFQItemWrapper itemWrapper)
	{
	    system.debug('inside the CMFCMBuilderBase class onBUPricePercGMChanged ');
		Decimal marginPercent = getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Perc_GM__c', 0.0);
		if (marginPercent >= 100.0)
        {
            DebugUtils.write('Margin cannot be greater than or equal to 100, setting to 99.999 instead.');
            marginPercent = 99.999;
            itemWrapper.specificRfqItem.put('BU_Price_Perc_GM__c',marginPercent);
        }

        Decimal totalCost = getDecimal(itemWrapper.specificRfqItem, 'Total_Cost__c', 0.0);
        system.debug('CMFCMBuilderBase #1459 totalCost : '+totalCost);
        Decimal buPrice = getDecimal(itemWrapper.specificRfqItem, 'BU_Price__c', 0.0);
        system.debug('CMFCMBuilderBase #1459 buPrice : '+buPrice);

        Decimal newTotalCost = 0.0;
        Decimal newBuPrice = 0.0;


        if (totalCost == 0.0 && buPrice == 0.0)
        {
            // Do Nothing
            DebugUtils.write('Total Cost and BU Price not set, doing nothing');
            return;
        }
        else if (totalCost > 0.0 && buPrice == 0.0)
        {
            DebugUtils.write('Total Cost is greater than 0, updating BU Price');
            newBuPrice = totalCost * 100.0 / (100.0 - marginPercent);
        }
        else if (totalCost == 0.0 && buPrice > 0.0)
        {
            DebugUtils.write('BU Price is greater than 0, updating Total Cost');
            newTotalCost = buPrice - (marginPercent + buPrice) / 100.0;
        }
        else if (totalCost > 0.0 && buPrice > 0.0)
        {
            DebugUtils.write('Updating BU Price');
            newBuPrice = totalCost * 100.0 / (100.0 - marginPercent);
        }

        if (newTotalCost > 0.0)
        {
            DebugUtils.write('newTotalCost', newTotalCost);
            itemWrapper.specificRfqItem.put('Total_Cost__c', newTotalCost);
        }
        if (newBuPrice > 0.0)
        {
            DebugUtils.write('newBuPrice', newBuPrice);
            itemWrapper.specificRfqItem.put('BU_Price__c', newBuPrice);
            Decimal salesTargetPrice = getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0) == 0.0 ? getDecimal(itemWrapper.specificRfqItem, 'Customer_Target_Price__c', 0.0) : getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0);
            Decimal delta = (salesTargetPrice != 0.0) ? (newBuPrice - salesTargetPrice)/salesTargetPrice : 0.0;
            itemWrapper.specificRfqItem.put('BU_Price_Perc_Delta_To_Target__c', delta * 100.0);
        }
        fcmBridge.calculatePackageItemValue(itemWrapper, buPrice);
	}

	public virtual override void setEditabilityforNoCostModel(RFQILayout layout)
	{
        // Making all read only except for Total_Cost__c, BU_Price__c, BU_Price_Perc_GM__c, BU_Price_Perc_Delta_To_Target__c
		layout.changeEditability('Adder_Cost__c',false);
		layout.changeEditability('Additional_CAPEX__c',false);
		layout.changeEditability('Assembly_GM_wo_Substrate__c',false);
		layout.changeEditability('Au_Adder__c',false);
		layout.changeEditability('BU_Base_Price__c',false);
		layout.changeEditability('BU_Final_Test_Price_Unit__c',false);
		layout.changeEditability('BU_Margin__c',false);
		layout.changeEditability('BU_Post_Test_Price_Unit__c',false);
		layout.changeEditability('BU_Price_Monthly_Charge__c',false);
		layout.changeEditability('BU_Price_Per_Hour__c',false);
		layout.changeEditability('BU_Price_Per_Second__c',false);
		//layout.changeEditability('BU_Price_Perc_Delta_To_Target__c',false);
		//layout.changeEditability('BU_Price_Perc_GM__c',false);
		layout.changeEditability('BU_Price_Unit__c',false);
		//layout.changeEditability('BU_Price__c',false);
		layout.changeEditability('BU_Price_per_Minute__c',false);
		layout.changeEditability('CLAM_Depreciation__c',false);
		layout.changeEditability('CLAM_Direct_Labor__c',false);
		layout.changeEditability('CLAM_Facilities__c',false);
		layout.changeEditability('CLAM_Indirect_Labor__c',false);
		layout.changeEditability('CLAM_Labor__c',false);
		layout.changeEditability('CLAM_OCOGS__c',false);
		layout.changeEditability('CLAM_OH__c',false);
		layout.changeEditability('CLAM_Subtotal_New__c',false);
		layout.changeEditability('CLAM_Subtotal__c',false);
		layout.changeEditability('CLAM_Total__c',false);
		layout.changeEditability('Competitor_Au_Inclusive_Price__c',false);
		layout.changeEditability('Competitor_Price__c',false);
		layout.changeEditability('Competitor__c',false);
		layout.changeEditability('Contribution_Margin_Perc__c',false);
		layout.changeEditability('Cost_Data_Source__c',false);
		layout.changeEditability('Cost_Model_Filename__c',false);
		layout.changeEditability('Cost_Sec_CLAM__c',false);
		layout.changeEditability('Cost_Sec_Labor__c',false);
		layout.changeEditability('Cost_less_Substrate_New__c',false);
		layout.changeEditability('Cost_sec_Depreciation__c',false);
		layout.changeEditability('Cost_sec_Other__c',false);
		layout.changeEditability('Customer_Target_Price__c',false);
		layout.changeEditability('Depreciation__c',false);
		layout.changeEditability('Fixed_Costs__c',false);
		layout.changeEditability('Forecast__c',false);
		layout.changeEditability('Gross_Margin_Perc__c',false);
		layout.changeEditability('Guildlline_Price_1500__c',false);
		layout.changeEditability('Guildlline_Price_500__c',false);
		layout.changeEditability('Guildlline_Price_GT_1500__c',false);
		layout.changeEditability('Handler_Prober_Price__c',false);
		layout.changeEditability('Manufacturing_Overhead__c',false);
		layout.changeEditability('Material_Freight_Percent__c',false);
		layout.changeEditability('Material_Tooling_Percent__c',false);
		layout.changeEditability('Materials_As_Perc_Cost__c',false);
		layout.changeEditability('Materials_Laminate__c',false);
		layout.changeEditability('Materials_Leadframe__c',false);
		layout.changeEditability('Materials_ODM__c',false);
		layout.changeEditability('Materials_Substrate__c',false);
		layout.changeEditability('Materials_Subtotal__c',false);
		layout.changeEditability('Materials_Total_Wire__c',false);
		layout.changeEditability('Materials_Total__c',false);
		layout.changeEditability('Model_UE_Perc__c',false);
		layout.changeEditability('Monthly_Revenue_Setup__c',false);
		layout.changeEditability('Operating_Cash_u__c',false);
		layout.changeEditability('Other_Costs__c',false);
		layout.changeEditability('Other_Equipment_Cost__c',false);
		layout.changeEditability('Others_Cost__c',false);
		layout.changeEditability('Package_Item_Value__c',false);
		layout.changeEditability('Payback__c',false);
		layout.changeEditability('Perc_CM__c',false);
		layout.changeEditability('Perc_IRR_New__c',false);
		layout.changeEditability('Perc_VAM_New__c',false);
		layout.changeEditability('QA_Cost__c',false);
		layout.changeEditability('Quote_Type__c',false);
		layout.changeEditability('Sales_Target_Price__c',false);
		layout.changeEditability('Service_Group_Cost__c',false);
		layout.changeEditability('Subs_Markup_Perc__c',false);
		layout.changeEditability('Substrate_Business_Model__c',false);
		layout.changeEditability('Substrate_Freight__c',false);
		layout.changeEditability('Substrate_Markup_Margin__c',false);
		layout.changeEditability('Substrate_Tooling__c',false);
		layout.changeEditability('Substrate_Usage__c',false);
		layout.changeEditability('Target_IRR_at_GM__c',false);
		layout.changeEditability('Tax_and_Freight_Cost__c',false);
		layout.changeEditability('Tester_Price__c',false);
		//layout.changeEditability('Total_Cost__c',false);
		layout.changeEditability('Total_Cost_per_Hour__c',false);
		layout.changeEditability('Total_Cost_per_minute__c',false);
		layout.changeEditability('Total_Cost_with_Substrate_New__c',false);
		layout.changeEditability('Total_Fixed_Costs__c',false);
		layout.changeEditability('Total_GM_Perc__c',false);
		layout.changeEditability('Total_ODM__c',false);
		layout.changeEditability('Total_Perc_GM__c',false);
		layout.changeEditability('Total_Unit_Cost__c',false);
		layout.changeEditability('Unit_Cost_CLAM__c',false);
		layout.changeEditability('Unit_Cost_Depreciation__c',false);
		layout.changeEditability('Unit_Cost_Labor__c',false);
		layout.changeEditability('Unit_Cost_Material__c',false);
		layout.changeEditability('Unit_Cost_Other__c',false);
		layout.changeEditability('Value_Added_Margin_Perc__c',false);
		layout.changeEditability('Value_Added_Margin__c',false);
		layout.changeEditability('Value_Added_Revenue__c',false);
		layout.changeEditability('Variable_Costs_Total__c',false);
		layout.changeEditability('Variable_Costs__c',false);
		layout.changeEditability('Weekly_Revenue_Setup__c',false);
	}

	public virtual override Map<String, String> getFieldMap()
    {
    	Map<String, String> fieldMap = new Map<String, String>();

    	fieldMap.put('price', 'BU_Price__c');
    	fieldMap.put('margin', 'BU_Price_Perc_GM__c');
    	fieldMap.put('totalCost', 'Total_Cost__c');

		return fieldMap;
    }

	public override void calcMulti(RFQItemWrapper itemWrapper, Boolean hasSubstrate)
	{
		if (!itemWrapper.volumeList.isEmpty())
		{
			setup(itemWrapper);
			if (!(itemWrapper.packageFamily.No_Cost_Model__c || itemWrapper.rfqItem.Do_Not_Auto_Price__c))
				calcMultiCostModel(itemWrapper);
			else 
				super.calcMulti(itemWrapper, hasSubstrate);
		}
	}	

	public override void calcMulti(RFQItemWrapper itemWrapper, Integer index, Boolean hasSubstrate)
	{
		setup(itemWrapper);
		if (!(itemWrapper.packageFamily.No_Cost_Model__c || itemWrapper.rfqItem.Do_Not_Auto_Price__c))
			calcMultiCostModel(itemWrapper, index);
		else 
			super.calcMulti(itemWrapper, index, hasSubstrate);
	}

	public void calcMultiCostModel(RFQItemWrapper itemWrapper)
	{
		//AMK-2328 - Per peter, always make them type everything in. This came up because the rules for when to copy down 
		//total cost became too complex - is there a substrate, is materials substrate entered, is there a total cost field
		//when there is a substrate, do they enter total cost or (cost less subs AND materials substrate)
		if (!itemWrapper.packageFamily.Copy_Fields_To_multivolume__c || !itemWrapper.getAreMultivolumesEditableInEscalation()) return;

		multiVolumeBoms = new Map<String, List<RFQI_BOM__c>>();
		multiVolumeProcs = new Map<String, List<RFQI_Process__c>>();
		multiVolumeFcms = new Map<String, RFQI_FCM__c>();
		if (itemFcm == null) itemFcm = RFQIFCMDao.getInstance().getLatest(itemWrapper.rfqItem.id);
		
		//--- Clone the FCM for use with the new Volume
		RFQI_FCM__c multiFcm;
		for (RFQIVolume volume : itemWrapper.volumeList)
		{
			volume.needsRecalc = false;
			
			multiFcm = itemFcm.clone();
			multiVolumeFcms.put(String.valueOf(volume.index), multiFcm);
			multiFcm.Needs_Reparenting__c = true;
			multiFcm.RFQI_Volume_Key__c = String.valueOf(volume.index);
		}

		//--- Insert the FCMs to get Ids for the BOM/Process lookups
		insert multiVolumeFcms.values();

		//--- Copy the BOMs/Processes to the new FCM
		for (RFQIVolume volume : itemWrapper.volumeList)
		{
			multiFcm = multiVolumeFcms.get(String.valueOf(volume.index));
			copyBomsForVolume(volume, multiFcm.Id);
			copyProcsForVolume(volume, multiFcm.Id);
		}

		//---Insert the clones BOMs/Processes
		List<SObject> insertList = new List<SObject>();

		for (List<RFQI_Process__c> procList : multiVolumeProcs.values()) insertList.addAll((List<sObject>)procList);
		for (List<RFQI_BOM__c> bomList : multiVolumeBoms.values()) insertList.addAll((List<sObject>)bomList);

		insert insertList;

		//--- Reload FCMs with updated formula/roll-up summary fields
		Set<String> fcmIds = new Set<String>();
		for (RFQI_FCM__c fcm : multiVolumeFcms.values())
		{
			fcmIds.add(fcm.Id);
		} 

		List<RFQI_FCM__c> newFcms = RFQIFCMDao.getInstance().getByIds(fcmIds);

		//--- Recalculate values on the FCM, add to map
		for (RFQI_FCM__c fcm : newFcms) 
		{
			multiVolumeFcms.put(fcm.RFQI_Volume_Key__c, fcm);
		}

		RFQ_Item__c tempRFQI = (RFQ_Item__c)itemWrapper.specificRfqItem.getsObject('RFQ_Item__r');

		//--- Assign the values from the FCMs to the Volumes
		RFQI_FCM__c fcm;
		for (RFQIVolume volume : itemWrapper.volumeList)
		{
			fcm = multiVolumeFcms.get(String.valueOf(volume.index));
			fcm.Margin_Percent__c = fcmBridge.getMarginPercent(volume.volume);
			recalcSummaryValues(fcm);

			//AMK-1601
			volume.goldBillingFlag = (String)tempRFQI.RFQ__r.getsObject('SBU_Name__r').get('Gold_Billing_Flag__c');
			
			if (volume.goldBillingFlag == null || volume.goldBillingFlag == 'Transactionally' || volume.goldBillingFlag == '') 
				volume.auAdder = DataUtils.getString(itemWrapper.specificRfqItem, 'Au_Adder__c', '');
			else 
				volume.auAdder = 'Inclusive';

			Integer precision = 6;
			//only copy margin, price, etc if the margin is automatically calculated by the system.
			//Otherwise, make them enter values. Per Peter
			if (fcmBridge.hasAutomaticMargin)
			{
				volume.margin = DataUtils.getDecimal(fcm, 'Margin_Percent__c', 0).setScale(precision);
				volume.price = DataUtils.getDecimal(fcm, 'Total_Price__c', 0).setScale(precision);
				volume.marginNoSubstrate = DataUtils.getDecimal(fcm, 'Margin_Less_Substrate_Percent__c', 0).setScale(precision);

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

			volume.subsMarkup = DataUtils.getDecimal(fcm, 'Substrate_Markup_Percent__c', 0).setScale(precision);
			volume.costLessSubs = (DataUtils.getDecimal(fcm, 'Total_Cost_of_Goods__c', 0) - DataUtils.getDecimal(fcm, 'Total_BOM_Substrate__c', 0)).setScale(precision);
			volume.subsCost = DataUtils.getDecimal(fcm, 'Total_BOM_Substrate__c', 0).setScale(precision);


		}

		update multiVolumeFcms.values();
	}

	public void calcMultiCostModel(RFQItemWrapper itemWrapper, Integer index)
	{
		multiVolumeBoms = new Map<String, List<RFQI_BOM__c>>();
		multiVolumeProcs = new Map<String, List<RFQI_Process__c>>();
		multiVolumeFcms = new Map<String, RFQI_FCM__c>();
		RFQIVolume volume = itemWrapper.volumeList[index];
		if (!itemWrapper.packageFamily.Copy_Fields_To_multivolume__c || !itemWrapper.getAreMultivolumesEditableInEscalation()) return;
		volume.needsRecalc = false;

		if (itemFcm == null) itemFcm = RFQIFCMDao.getInstance().getLatest(itemWrapper.rfqItem.id);
		RFQI_FCM__c multiFcm;
		multiFcm = itemFcm.clone();
		multiFcm.Needs_Reparenting__c = true;
		multiFcm.RFQI_Volume_Key__c = String.valueOf(volume.index);

		insert multiFcm;
		
		copyBomsForVolume(volume, multiFcm.Id);
		copyProcsForVolume(volume, multiFcm.Id);

		List<SObject> insertList = new List<SObject>();

		for (List<RFQI_Process__c> procList : multiVolumeProcs.values()) insertList.addAll((List<sObject>)procList);
		for (List<RFQI_BOM__c> bomList : multiVolumeBoms.values()) insertList.addAll((List<sObject>)bomList);

		insert insertList;

		RFQI_FCM__c fcm = RFQIFCMDao.getInstance().getById(multiFcm.Id);

		RFQ_Item__c tempRFQI = (RFQ_Item__c)itemWrapper.specificRfqItem.getsObject('RFQ_Item__r');

		fcm.Margin_Percent__c = fcmBridge.getMarginPercent(volume.volume);
		recalcSummaryValues(fcm);

		//AMK-1601
		volume.goldBillingFlag = (String)tempRFQI.RFQ__r.getsObject('SBU_Name__r').get('Gold_Billing_Flag__c');
		
		if (volume.goldBillingFlag == null || volume.goldBillingFlag == 'Transactionally' || volume.goldBillingFlag == '') 
			volume.auAdder = DataUtils.getString(itemWrapper.specificRfqItem, 'Au_Adder__c', '');
		else 
			volume.auAdder = 'Inclusive';

		Integer precision = 6;
		//only copy margin, price, etc if the margin is automatically calculated by the system.
		//Otherwise, make them enter values. Per Peter
		volume.baseBUPrice = 0;
		if (fcmBridge.hasAutomaticMargin)
		{
			volume.margin = DataUtils.getDecimal(fcm, 'Margin_Percent__c', 0).setScale(precision);
			volume.price = DataUtils.getDecimal(fcm, 'Total_Price__c', 0).setScale(precision);
			volume.marginNoSubstrate = DataUtils.getDecimal(fcm, 'Margin_Less_Substrate_Percent__c', 0).setScale(precision);

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

		volume.subsMarkup = DataUtils.getDecimal(fcm, 'Substrate_Markup_Percent__c', 0).setScale(precision);
		volume.costLessSubs = (DataUtils.getDecimal(fcm, 'Total_Cost_of_Goods__c', 0) - DataUtils.getDecimal(fcm, 'Total_BOM_Substrate__c', 0)).setScale(precision);
		volume.subsCost = DataUtils.getDecimal(fcm, 'Total_BOM_Substrate__c', 0).setScale(precision);

		update fcm;
	}

	//---Directly copies the BOMs for an item to the new FCM
	private void copyBomsForVolume(RFQIVolume volume, Id fcmId)
	{
		if (bomItemList == null) bomItemList = RFQIBOMDao.getInstance().getByFcmId(itemFcm.id); 
		List<RFQI_BOM__c> volumeBomList = bomItemList.deepClone();
		for (RFQI_BOM__c bom : volumeBomList) bom.RFQI_FCM__c = fcmId;
		multiVolumeBoms.put(volume.index + volume.volume, volumeBomList);
	} 

	//--- Copy Processes to the new FCM, recalculate the fields on the process with the new volume
	private void copyProcsForVolume(RFQIVolume volume, Id fcmId)
	{
		if (processItemList == null) processItemList = RFQIProcessDao.getInstance().getByFcmId(itemFcm.id);
		if (processCalc.fcmBridge == null) loadProcessSettings();
		List<RFQI_Process__c> volumeProcList = processItemList.deepClone();
		Decimal totalCostOld = 0;
		for (RFQI_Process__c process : processItemList) totalCostOld += process.Total_Cost_Per_Unit__c;
		Decimal newForecast;
		Decimal totalCostNew = 0;
		//for (RFQI_Process__c proc : volumeProcList)
		RFQI_Process__c proc;
		String error = '';
		volume.debug = '';
		for (Integer i = 0; i < volumeProcList.size(); i++)
		{
			proc = volumeProcList[i];
			
			proc.RFQI_FCM__c = fcmId;
			volume.debug += processCalc.updateProcFieldsForVolume(proc, volume.volume);

			totalCostNew += proc.Total_Cost_Per_Unit__c;
		}
		multiVolumeProcs.put(volume.index + volume.volume, volumeProcList);
	}

}