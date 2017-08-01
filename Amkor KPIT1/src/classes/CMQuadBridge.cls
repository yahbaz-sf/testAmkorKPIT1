/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMQuadBridge extends CMFCMBridgeBase
{
	//---Find by PF
	public override void loadFcmAssumption()
	{
		if (fcmA == null)
		{
			List<FCM_Assumption__c> assumptionList = FCMAssumptionDao.getInstance().getByPFAndVersion(wrapper.packageFamily.id, ver.Id);
			if (assumptionList.size() > 0)
			{
				fcmA = assumptionList[0];
			}
			else
			{
				fcmA = new FCM_Assumption__c();
			}
		}
	}
	
	//---TODO, how much will this logic change?
	public override List<CM_Margin__c> getMarginList()
	{
		return CMMarginDao.getInstance().getByQuadCriteria(mVer.id);
	}
	
	public override Decimal getForecastVolumePerWeek( String forecast)
	{

        if (forecast == '< 50') return 49;
        else if (forecast == '< 250') return 249;
        else if (forecast == '< 500') return 499;
        else return 501;
    }
	public virtual Decimal getDieNumGDPW()
	{
        selectedDie = wrapper.dieConfigurations.get(0);
		Decimal dieX = getDieX();
		Decimal dieY = getDieY();
		Decimal dieTest = dieX * dieY;
		Decimal dieWaferSize = getDieWaferSize();
		Decimal exclusionWafer1 = 2*Math.sqrt(dieX * dieX + dieY * dieY);
		exclusionWafer1 = exclusionWafer1.setScale(1);
		return (dieTest == null || dieTest == 0) ? 0 : Math.round(0.8 * 3.14159 * 0.25 * (( dieWaferSize - exclusionWafer1) * (dieWaferSize - exclusionWafer1)) / (dieX*dieY));
	}

	public virtual Integer getTotalNumWiresByConfig(String configType, String wireMaterial)
    {
        Integer numWires = 0;
    
        for(SObject row : wrapper.wireConfigurations)
        {
            if (row.get('Wire_Configuration__c') == configType && row.get('Wire_Material__c') == wireMaterial)
            {
                Integer currWireCount = (Integer)row.get('Number_Of_Wires__c');
                if (currWireCount != null) numWires += currWireCount;
            }
        }
        
        return numWires;
    }
	public virtual Decimal getWireBondUPH()
	{

        //TODO - Get these rates from CM_PF_Values (per AMK-811)
        //currently valid for TQFP package family
        List<CM_PF_Value__c> cmPfList = CMPFValueDao.getInstance().getByPFAndVersion(ver.Id, wrapper.packageFamily.id);
        CM_PF_Value__c cmPf = (cmPfList == null || cmPfList.size() == 0 ) ? new CM_PF_Value__c() : cmPfList.get(0);

		Decimal fwdRate = (cmPf.FPP_Rate__c == null) ? 0 : cmPf.FPP_Rate__c;
        Decimal ssbRate = (cmPf.RSSB__c == null) ? 0 : cmPf.RSSB__c;

        if(!StringUtils.isMatch(getWireMaterial(), 'Au'))
        {
        	fwdRate *= 0.85;
        	ssbRate *= 0.85;
        }

        Decimal fwdWires = getNumberOfForwardWires();
        Decimal ssbWires = getNumberOfSSBWires();

		Decimal uphFwd = (fwdWires == 0 || fwdRate == 0) ? 0 : Math.round(3600/fwdRate/fwdWires);
		Decimal hpkFwd = (uphFwd == 0) ? 0 : 1000 / uphFwd;	

		Decimal uphSSB = (ssbWires == 0 || ssbRate == 0) ? 0 : Math.round(3600/ssbRate/ssbWires);
		Decimal hpkSSB = (uphSSB == 0) ? 0 : 1000/uphSSB;

		return (hpkFwd + hpkSSB == 0) ? 0 : Math.round(1000/(hpkFwd + hpkSSB));

	}

	public virtual Decimal getNumberOfForwardWires()
	{
		return getDecimal(selectedWire, 'Number_of_FWD_Wires__c', 0);
	}

	public virtual Decimal  getNumberOfSSBWires()
	{
		return getDecimal(selectedWire, 'Number_of_SSB_Wires__c', 0);
	}

	public virtual Integer getTotalAuForwardWires()
	{
		return getTotalNumWiresByConfig('Forward Bonding', 'Au');
	}

	public virtual Integer getTotalCuForwardWires()
	{
		return getTotalNumWiresByConfig('Forward Bonding', 'Cu');
	}

	public virtual Integer getTotalAuSSBWires()
	{
		return getTotalNumWiresByConfig('Stich on solder ball (SSB)', 'Au');
	}

	public virtual Integer getTotalCuSSBWires()
	{
		return getTotalNumWiresByConfig('Stich on solder ball (SSB)', 'Cu');
	}

	public override void calculatePackageItemValue(RFQItemWrapper itemWrapper, Decimal buPrice)
    {
    	Decimal packageValue = buPrice * getMeanForecast(getString(itemWrapper.specificRfqItem, 'Forecast__c'));
		itemWrapper.specificRfqItem.put( 'Package_Item_Value__c', packageValue);
    }

    private Decimal getMeanForecast(String forecast)
	{
		if (forecast == null) return 0;
		else if (forecast == '< 50') return 25; 
		else if (forecast == '< 100') return 75; 
		else if (forecast == '< 250') return 175; 
		else if (forecast == '< 500') return 375; 
		else if (forecast == '< 1,000') return 750; 
		else if (forecast == '> 1,000') return 1000; 
		return 0;
	}
}