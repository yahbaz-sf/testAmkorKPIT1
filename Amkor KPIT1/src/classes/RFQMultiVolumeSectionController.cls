public with sharing class RFQMultiVolumeSectionController {
	 
	public RFQItemWrapper cWrapper {get; set;}
	public RFQILayout cLayout {get; set;}
	public Boolean editMode {get; set;}
    private List<SelectOption> mOptions;
    public Boolean fieldsChecked = false;
    private Boolean disableSubsCost;
    private Boolean disableCostLessSubs;
    public CMBuilder cBuilder {get; set;}
    public Boolean buPage {get; set;}
    public Decimal auFactor {get; set;}
    public Boolean engineeringService {get;set;}
    public Map<Integer, Map<String, Boolean>> renderedMap {get;set;}
    
    private transient Schema.DescribeFieldResult fr;
    
	public RFQMultiVolumeSectionController() {
		buPage = false;
		auFactor = 0;
		engineeringService = false;
        /*String rfqItemId = PageUtil.param('Id');
        String multiVolumeJson = [select Multi_Volume__c from RFQ_Item__c where Id =: rfqItemId].Multi_Volume__c;
        
        if(multiVolumeJson == 'null' || StringUtils.isBlank(multiVolumeJson)) {
            volumeList = new List<RFQIVolume>();
        }
        else {
        	volumeList =  (List<RFQIVolume>)JSON.deserialize(multiVolumeJson, List<RFQIVolume>.class);
        }*/
		
	}

	public Boolean getShowPriceEntry() {
		Boolean isBU = RFQ_System_Settings__c.getInstance(UserInfo.getProfileId()).Is_BU_Profile__c;
		Boolean isHybrid = RFQ_System_Settings__c.getInstance(UserInfo.getProfileId()).Is_Hybrid_Profile__c;
		return (isBU || isHybrid);
	}

	public List<SelectOption> getOptions() {

        if(mOptions == null) {

	        
	        List<Schema.PicklistEntry> pickListValues = fr.getPicklistValues();

	        mOptions = new List<SelectOption>();
	        for(Schema.PicklistEntry p : pickListValues) {
	            mOptions.add(new SelectOption(p.getValue(),p.getLabel()));
	        }
        }

        return mOptions;
	}

	private void reIndex() {
		RFQ_Item__c tempRFQI = (RFQ_Item__c)cWrapper.specificRfqItem.getsObject('RFQ_Item__r');

		for(Integer i = 0; i < cWrapper.volumeList.size(); i++) {
			cWrapper.volumeList[i].goldBillingFlag = (String)tempRFQI.RFQ__r.getsObject('SBU_Name__r').get('Gold_Billing_Flag__c');

			if (cWrapper.volumeList[i].goldBillingFlag == null || cWrapper.volumeList[i].goldBillingFlag == 'Transactionally' || cWrapper.volumeList[i].goldBillingFlag == '') 
				cWrapper.volumeList[i].auAdder = DataUtils.getString(cWrapper.specificRfqItem, 'Au_Adder__c', '');
			else 
				cWrapper.volumeList[i].auAdder = 'Inclusive';

			cWrapper.volumeList[i].index = i + 1;
		}
	}

	public PageReference addVolume() {
        
        RFQIVolume newVol = new RFQIVolume(buPage);
        //default to first value in picklist
        if (getShowForecastAsPicklist())
        {
        	newVol.volume = fr.getPicklistValues()[0].getValue();
        }
        //engineering services do not have forecast
        else if (!engineeringService)
        {
        	newVol.volume = String.valueOf(cWrapper.specificRfqItem.get('Forecast__c'));
        }
        cWrapper.volumeList.add(newVol);
        reIndex();
        if (cBuilder != null) cBuilder.calcMulti(cWrapper, cWrapper.volumeList.size() - 1, getShowSubstrateFields());
        return null;
	}

	public PageReference addAllVolumes()
	{
		//adds a volume config for each volume in the picklist that has not yet been created
		Integer index = 0;
		List<Schema.PicklistEntry> picklistValues = fr.getPicklistValues();
		String forecast = DataUtils.getString(cWrapper.specificRfqItem, 'Forecast__c', '');
		if (!String.isBlank(forecast))
		{
			for (Schema.PicklistEntry picklistValue : picklistValues)
			{
				index++;
				if (picklistValue.getValue() == forecast)
				{
					break;
				}
			}
		}

		if (index == 0 || index == 1 && picklistValues.size() > 0)
		{
			//selected is lowest, get next highest forecast
			//or selected forecast is --None--, get lowest forecast
			addVolumeWithForecast(picklistValues.get(index).getValue());
		}
		else if (index == pickListValues.size())
		{
			//selected is highest, get next lowest
			addVolumeWithForecast(picklistValues.get(pickListValues.size() - 2).getValue());
		}
		else
		{
			addVolumeWithForecast(picklistValues.get(index - 2).getValue());
			addVolumeWithForecast(picklistValues.get(index).getValue());
		}



		return null;
	}

	public void addVolumeWithForecast(String forecast)
	{
		Boolean shouldAdd = true;
		for (RFQIVolume existingVolume : cWrapper.volumeList)
		{
			//do not add volumes that already have been created
			if (existingVolume.volume == forecast)
			{
				shouldAdd = false;
				break;
			}
		}
		if (shouldAdd)
		{
			RFQIVolume newVolume = new RFQIVolume(buPage);
			newVolume.volume = forecast;
			cWrapper.volumeList.add(newVolume);
			reIndex();
    		if (cBuilder != null) cBuilder.calcMulti(cWrapper, cWrapper.volumeList.size() - 1, getShowSubstrateFields());
		}
	}

	public PageReference removeVolume() {
        String sIndex = PageUtil.param('index');
        Integer index = Integer.valueOf(sIndex) - 1;

        if(index >= 0 && index < cWrapper.volumeList.size()) {
        	cWrapper.volumeList.remove(index);
        }
		reIndex();
		return null;
	}

	public PageReference removeAllVolumes()
	{
		for (Integer i = 0; i < cWrapper.volumeList.size(); i++)
		{
			if (!(buPage && cWrapper.volumeList[i].requestedBy == 'Sales'))
			{
				//decrement i because the item was removed, so there is a new item 
				//at the same index
				cWrapper.volumeList.remove(i--);
			}
		}
		return null;
	}

	public PageReference resetPrice() {
        String sIndex = PageUtil.param('index');
        Integer index = Integer.valueOf(sIndex) - 1;

        if (cBuilder != null) cBuilder.calcMulti(cWrapper, index, getShowSubstrateFields());
		return null;
	}

	public PageReference repriceVolumes() {
        
        if (cBuilder != null) cBuilder.calcMulti(cWrapper, getShowSubstrateFields());
		return null;
	}

	public Boolean getSubsCostDisabled()
	{
		if (!fieldsChecked) disableFields();
		return disableSubsCost;
	}

	public Boolean getCostLessSubsDisabled()
	{
		if (!fieldsChecked) disableFields();
		return disableCostLessSubs;
	}

	private void disableFields()
	{
		disableSubsCost = true;

		//if fields are not copied to multiV section, then fields cannot be readonly
		//if there is a cost model, then it will generate total cost, so disable the field
		//if cannot auto price, then user needs to be able to enter
		//Test has a strange C/P section, so enable total cost
		system.debug('cWrapper.packageFamily.Copy_Fields_To_Multivolume__c : '+cWrapper.packageFamily.Copy_Fields_To_Multivolume__c);
		system.debug('cWrapper.packageFamily.No_Cost_Model__c : '+cWrapper.packageFamily.No_Cost_Model__c);
		system.debug('cWrapper.rfqItem.Do_Not_Auto_Price__c) : '+cWrapper.rfqItem.Do_Not_Auto_Price__c);
		disableCostLessSubs = cWrapper.packageFamily.Copy_Fields_To_Multivolume__c && !(cWrapper.packageFamily.No_Cost_Model__c || cWrapper.rfqItem.Do_Not_Auto_Price__c) && cWrapper.packageFamily.Name != 'Test';
		system.debug('disableCostLessSubs : '+disableCostLessSubs);
		if (cLayout.enabledSections.get('Cost and Price') != null && cLayout.enabledSections.get('Cost and Price'))
		{
	        for (RFQISectionAttribute attrib : cLayout.sectionMap.get('Cost and Price').attributes)
	        {
	        	if (attrib.fieldAPIName == 'Materials_Substrate__c')
	        		disableSubsCost = !attrib.isEditable;
	        }
		}
		
        //do not run again
		fieldsChecked = true;
	}

	public Boolean getShowForecastAsPicklist()
	{
		//do getDescribes first in order to decide if it's a picklist or not
		SObjectType objToken = Schema.getGlobalDescribe().get(cWrapper.packageFamily.Specific_RFQ_Item_Object__c);
    	DescribeSObjectResult objDef = objToken.getDescribe();
    	//do not check for egr services (even though they dont have forecast) because
    	//egr services should never have add multivolume button
    	fr = objDef.fields.getMap().get('Forecast__c').getDescribe();
		//TSV package family is not a picklist
		return (fr != null && fr.getType() == Schema.DisplayType.Picklist);
	}

	public Boolean getCanEdit()
	{
		return editMode && (cWrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_ESCALATION || !RFQItemDao.getInstance().statusGreaterOrEqual(cWrapper.rfqItem, RFQItemDao.STATUS_PRICE_COMPLETE));
	}

	public Boolean getHasGoldWires()
	{
		Boolean hasGold = false;
		for (sObject wireConfig : cWrapper.wireConfigurations)
		{
			if (((String)wireConfig.get('Wire_Material__c')).toLowerCase().contains('au'))
			{
				hasGold = true;
				Object wireAu = wireConfig.get('Au_Factor__c');
				auFactor += wireAU == null ? 0 : (Decimal)wireAu;
			}
		}

		return hasGold;
	}

	public Boolean getLoadMap() {
		Boolean isEscalationEditable = getIsEscalationEditable();
		Boolean edit = getCanEdit() && isEscalationEditable;
		Boolean forcastPick = (engineeringService) ? false : getShowForecastAsPicklist();
		Boolean isAddedService = getIsAddedService();
		Boolean isTest = getIsTest();
		Boolean isTestAddedService = isTest && isAddedService;
		Boolean showPriceEntry = getShowPriceEntry();
		Boolean showSubstrateFields = getShowSubstrateFields();
		Boolean isPerMonth = getIsPerMonth();
		Boolean isBump = getIsBumpOrWLCSP();
		Boolean isWaferProbe = cWrapper.rfqItem.Test_Type__c == AMKVARS.TT_PROBE;
		//test volume shows up if it is test
		//assy volume shows up if it is test added service only (test standalone, it does not show up at all) 
		//assy volume is never editable for test

		renderedMap = new Map<Integer, Map<String, Boolean>>();
		for(RFQIVolume v : cWrapper.volumeList) {
			Boolean requestedBySales = v.requestedBy == 'Sales';
			renderedMap.put(v.index , new Map<String, Boolean> {
				'volPBSI' =>  (edit && !engineeringService  && forcastPick && !(buPage && requestedBySales)  && (!isAddedService || isBump || isWaferProbe)),
				'volPBSIEntry' =>  (edit && !engineeringService && !forcastPick && !(buPage && requestedBySales) && (!isAddedService || isBump || isWaferProbe)),
				//do not show for test unless it is added service
				'volPBSIOutput' =>  (!engineeringService && !edit || (buPage && requestedBySales) || (isAddedService && !isBump && !isWaferProbe)),
				'subsMarkupPBSI' =>  (edit && showPriceEntry && showSubstrateFields),
				'subsMarkupPBSO' =>  (!edit && showPriceEntry && showSubstrateFields),
				'margNoSubstratePBSI' =>  (edit && showPriceEntry && showSubstrateFields),
				'margNoSubstratePBSO' =>  (!edit && showPriceEntry && showSubstrateFields),
				'marginPBSI' =>  (edit && showPriceEntry && !engineeringService && !isTest),
				'marginPBSO' =>  (!edit && showPriceEntry && !engineeringService && !isTest),
				'pricePBSI' =>  (edit && showPriceEntry && !isPerMonth),
				'pricePBSO' =>  (!edit && showPriceEntry || isPerMonth),
				'costLessSubsPBSI' =>  (edit && showPriceEntry && !engineeringService && !isTest),
				'costLessSubsPBSO' =>  (!edit && showPriceEntry && !engineeringService && !isTest),
				'subsCostPBSI' =>  (edit && showPriceEntry && showSubstrateFields),
				'subsCostPBSO' =>  (!edit && showPriceEntry && showSubstrateFields),
				'resetV' =>  (edit && showPriceEntry),
				'remV' =>  (edit && !(buPage && requestedBySales) && !engineeringService && (!isAddedService || isBump || isWaferProbe)),
				'linkRFQ' =>  (v.createdRFQIId != '' && v.createdRFQIId != null),
				//check if the subtotals list is empty because the subtotal index list is also used for test
				'engineeringServiceSubTotal' =>  (engineeringService && !v.subTotals.isEmpty()),
				'buPriceHourPBSI' => (edit && showPriceEntry && isTest && !isPerMonth), 
				'buPriceHourPBSO' => (!edit && showPriceEntry && isTest || isPerMonth), 
				//'buPriceSecondPBSI' => (edit && showPriceEntry && isTest && !isPerMonth), 
				//'buPriceSecondPBSO' => (!edit && showPriceEntry && isTest || isPerMonth), 
				//'buPriceMinutePBSI' => (edit && showPriceEntry && isTest && !isPerMonth), 
				//'buPriceMinutePBSO' => (!edit && showPriceEntry && isTest || isPerMonth), 
				'buPriceUnitPBSI' => (edit && showPriceEntry && isTest && !isPerMonth), 
				'buPriceUnitPBSO' => (!edit && showPriceEntry && isTest || isPerMonth), 
				'buPriceMonthlyPBSI' => (edit && showPriceEntry && isTest && !isPerMonth), 
				'buPriceMonthlyPBSO' => (!edit && showPriceEntry && isTest || isPerMonth)
				}
			);
		}
		
		return false;	
	}

	public Boolean getIsAddedService()
	{
		return cWrapper.rfqItem.Service__c != 'Assembly';
	}

	public Boolean getIsTest()
	{
		return cwrapper.packageFamily.Name == AMKVARS.PF_TEST;
 	}

	public Boolean getShowSubstrateFields()
	{
	    //Lalit: display the fields from packageFamily objects based upon the Has_Substrate__c and !Hide_Substrate_Multivolume__c from cmbuilder class.
		return CMBuilder.getHasSubstrate(cWrapper);
	}

	public Boolean getIsPerMonth()
	{
		return getIsTest() && (String)cWrapper.specificRfqItem.get('Test_Quote_Unit_of_Measure__c') == '/Month';
	}

	public Boolean getCanDeleteOneVolume()
	{
		Boolean canDelete = false;
		for (Integer i = 0; i < cWrapper.volumeList.size(); i++)
		{
			if (!(buPage && cWrapper.volumeList[i].requestedBy == 'Sales'))
			{
				canDelete = true;
				break;
			}
		}
		return canDelete;
	}

	public Boolean getIsBumpOrWLCSP()
	{
		return cWrapper.packageFamily.Name == AMKVARS.PF_BUMP || cWrapper.packageFamily.Name == AMKVARS.PF_WLCSP || cWrapper.packageFamily.Name == 'Die Processing Service (WLCSP)' || cWrapper.packageFamily.Name == 'WLCSP' || cWrapper.packageFamily.Name == 'Die Processing Service';
	}

	public Boolean getIsEscalationEditable()
	{
		return cWrapper.getAreMultivolumesEditableInEscalation();
	}
}