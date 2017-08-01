public with sharing class RFQIVolume {
	
	public Integer index {get; set;}
    public String volume {get; set;}
    public String requestedBy {get; set;}
    public Decimal price {get; set;}
    public Decimal margin {get; set;}
    public Decimal subsMarkup {get; set;}
    public Decimal marginNoSubstrate {get; set;}
    public Decimal costLessSubs {get; set;}
    public Decimal subsCost {get; set;}
    public Decimal othersCost {get; set;} //AMK-2263, PBGA only
    public String debug {get; set;}
    public Id rfqItemId {get; set;}
    public String auAdder {get; set;}
    public Decimal baseBUPrice {get; set;}
    public String goldBillingFlag {get; set;}
    public String createdRFQIId {get; set;}
    public String createdRFQIName {get; set;}
    public List<Decimal> subTotals {get;set;}
    public List<Integer> subTotalInd {get;set;}
    public RFQITestInsertion testInsertionsTotals {get; set;}
    public List<RFQITestInsertion> testInsertions {get; set;}
    public Boolean needsRecalc {get; set;}
    public String parentVolumeKey {get; set;}

    //---Any values that will be directly copied to a field must be in this map
    //---Implemented for BU Export
    public transient Map<String, String> fieldMap;

	public RFQIVolume(Boolean isBUPage) {
		debug = '';
		if(isBUPage) {
            requestedBy = 'BU';
		}
		else {
			requestedBy = 'Sales';
		}
        needsRecalc = false;
        subTotals = new List<Decimal>();
        testInsertionsTotals = new RFQITestInsertion();
        testInsertions = new List<RFQITestInsertion>();
	}

    public Decimal getNumericValue()
    {
        return volume == null ? 0 : Decimal.valueOf(volume);
    }

    public void setNumericValue(Decimal value)
    {
        volume = String.valueOf(value);
    }

    public List<Decimal> getSubtotal() {
        subTotalInd = new List<Integer>();
        Integer count = 0;
        for(Decimal s : subTotals) {
            subTotalInd.add(count++);
        }
        return subTotals;

    }

    public List<Integer> getTestInsertionIndexes()
    {
        List<Integer> indexList = new List<Integer>();
        Integer count = 0;
        if (testInsertions != null)
        {
            for (RFQITestInsertion t : testInsertions)
            {
                indexList.add(count++);
            }
        }

        return indexList;
    }

    public void totalTestInsertions()
    {
        
        testInsertionsTotals.buPriceMonthly = 0;
        testInsertionsTotals.buPriceHour = 0;
        testInsertionsTotals.buPriceSecond = 0;
        testInsertionsTotals.buPriceUnit = 0;
        testInsertionsTotals.buPriceMinute = 0;
        for (RFQITestInsertion ins : testInsertions)
        {
            testInsertionsTotals.buPriceMonthly += ins.buPriceMonthly;
            testInsertionsTotals.buPriceHour += ins.buPriceHour;
            testInsertionsTotals.buPriceSecond += ins.buPriceSecond;
            testInsertionsTotals.buPriceUnit += ins.buPriceUnit;
            testInsertionsTotals.buPriceMinute += ins.buPriceMinute;
        }
    }

    public String getDynamicValue(String key)
    {
        if (fieldMap == null)
        {
            fieldMap = new Map<String, String>
            {
                'price' => (String.valueOf(this.price)),
                'margin' => (String.valueOf(this.margin)),
                'subsMarkup' => (String.valueOf(this.subsMarkup)),
                'marginNoSubstrate' => (String.valueOf(this.marginNoSubstrate)),
                'totalCost' => (String.valueOf((this.costLessSubs == null ? 0 : this.costLessSubs) + (this.subsCost == null ? 0 : this.subsCost))),
                'subsCost' => (String.valueOf(this.subsCost)),
                'othersCost' => (String.valueOf(this.othersCost))
                //TODO - engineering services and test values - find way to display on bu export
            };
        }
        return fieldMap.get(key);
    }

    public void setDynamicValue(String key, String value)
    {
        setDynamicValue(key, value, null);
    }

    public void setDynamicValue(String key, String value, Integer index)
    {
        if (index != null)
        {
            if      (key == 'buPriceHour') testInsertions[index].buPriceHour = Decimal.valueOf(value);
            else if (key == 'buPriceSecond') testInsertions[index].buPriceSecond = Decimal.valueOf(value);
            else if (key == 'buPriceUnit') testInsertions[index].buPriceUnit = Decimal.valueOf(value);
            else if (key == 'buPriceMonthly') testInsertions[index].buPriceMonthly = Decimal.valueOf(value);
        }
        else
        {
            if      (key == 'price') price = Decimal.valueOf(value);
            else if (key == 'margin') margin = Decimal.valueOf(value);
            else if (key == 'subsMarkup') subsMarkup = Decimal.valueOf(value);
            else if (key == 'marginNoSubstrate') marginNoSubstrate = Decimal.valueOf(value);
            else if (key == 'totalCost') costLessSubs = Decimal.valueOf(value);
            else if (key == 'costLessSubs') costLessSubs = Decimal.valueOf(value);
            else if (key == 'subsCost') subsCost = Decimal.valueOf(value);
            else if (key == 'othersCost') othersCost = Decimal.valueOf(value);
            else if (key == 'buPriceHour') testInsertionsTotals.buPriceHour = Decimal.valueOf(value);
            else if (key == 'buPriceSecond') testInsertionsTotals.buPriceSecond = Decimal.valueOf(value);
            else if (key == 'buPriceUnit') testInsertionsTotals.buPriceUnit = Decimal.valueOf(value);
            else if (key == 'buPriceMonthly') testInsertionsTotals.buPriceMonthly = Decimal.valueOf(value);
        }
        system.debug('RFQIVolume margin value  : '+margin);
    }

    public class RFQITestInsertion
    {
        public Decimal testTime {get; set;}
        public Decimal sitesInParallel {get; set;}
        public Decimal indexTime {get; set;}
        public Decimal testerValue {get; set;}
        public Decimal handlerValue {get; set;}
        public Decimal buCostHour {get; set;}
        public Decimal buPriceMonthly {get; set;}
        public Decimal buPriceHour {get; set;}
        public Decimal buPriceMinute {get; set;}
        public Decimal buPriceSecond {get; set;}
        public Decimal buPriceUnit {get; set;}
    }
}