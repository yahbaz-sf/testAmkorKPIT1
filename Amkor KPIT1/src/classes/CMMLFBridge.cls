/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com 
* AUTHOR: Steve Simpson
***************************************************************************/
public virtual with sharing class CMMLFBridge extends CMFCMBridgeBase
{
    List<CM_PF_Value__c> cmPfList;

    public override void loadFcmAssumption()
    {
        
        if (fcmA == null)
        {
            
            List<FCM_Assumption__c> assumptionList = FCMAssumptionDao.getInstance().getByPFAndVersion(wrapper.packageFamily.id, ver.id);
            String factoryName = String.valueOf(wrapper.specificRfqItem.get('Factory__c'));
            for(FCM_Assumption__c factoryAssumption : assumptionList){
        
                if(factoryAssumption.Factory__c == factoryName){
                    fcmA = factoryAssumption;
                    return;
                }
            }            
            fcmA = new FCM_Assumption__c();            
        }
    }
    
    public Decimal getUtilizationCompoundEfficiency()
    {   
        //Lalit SF-85.
        if(hasWireMaterial('AuPCC', 'Au', 'AND'))
            return getDecimal(fcmA, 'Utilization_Efficiency_Compound_Percent__c', 0.0);
        return getDecimal(fcmA, 'Utilization_Efficiency_Percent__c', 0.0); 
    }

    public boolean hasWireMaterial(String wireMaterial){        
        return hasWireMaterial(wireMaterial, '', 'OR');
    }

    public boolean hasWireMaterial(String wireMaterial1, String wireMaterial2, String operand){        
        Boolean hasFirst = false;
        Boolean hasSecond = false;
        for(SObject row : wrapper.wireConfigurations){                   
            if (row.get('Wire_Material__c') == wireMaterial1)
                hasFirst = true;
            if (row.get('Wire_Material__c') == wireMaterial2)
                hasSecond = true;
            if(operand == 'AND' && (hasFirst & hasSecond))
                return true;            
            if(operand == 'OR' && (hasFirst | hasSecond))
                return true;
        }
        return false;
    }

    protected override void  loadcmPFList(){

         cmPfList = CMPFValueDao.getInstance().getBySubPFAndVersion(ver.Id, getPF_Sub_Class_1());
    }


    //Based on AMK-922, there are no RuCU and PFF for PMLF. Only Ag Plate 
    //(No HDLF, and OMLF, only VHDLF)
    //Changed from lookup to calculation in AMK-2064
    public virtual Decimal getUnitsPerStrip()
    {
        Decimal bodySizeX = getBodySizeX();
        Decimal bodySizeY = getBodySizeY();

        Decimal moldCapsPerStrip = 2;
        Decimal sawStreetWidth = 0.325;
        Decimal stripLengthX = 250;
        Decimal stripWidthY = 70;
        Decimal moldCapX = 118.325;
        Decimal moldCapY = 63.4;
        Decimal moldDraftAngle = 20;
        Decimal moldCapThickness = 0.65;
        Decimal pi = 2 * Math.asin(1);
        Decimal draftLength = moldCapThickness*Math.tan(moldDraftAngle*pi/180);
        Decimal lockingFeatureMinSize = 1.5;
        
        Decimal minMoldCapBodyEdge;          
        if (lockingFeatureMinSize >= (draftLength + sawStreetWidth))
            minMoldCapBodyEdge = lockingFeatureMinSize;
        else 
            minMoldCapBodyEdge = draftLength + sawStreetWidth;
        Decimal totalUsableArea = (moldCapX - 2 * minMoldCapBodyEdge) * (moldCapY - 2 * minMoldCapBodyEdge);
        Decimal colX = ((moldCapX - (2 * minMoldCapBodyEdge) + sawStreetWidth) / (bodySizeX + sawStreetWidth)).round(System.RoundingMode.DOWN);
        Decimal colY = ((moldCapY - (2 * minMoldCapBodyEdge) + sawStreetWidth) / (bodySizeY + sawStreetWidth)).round(System.RoundingMode.DOWN);

        Decimal unitsPerStrip = 2 * colX * colY;

        return unitsPerStrip;
    }


    //Based on AMK-922, there are no RuCU and PFF for PMLF. Only Ag Plate 
    //(No HDLF, and OMLF, only VHDLF)
    public virtual Decimal getSubstrateCostPerStrip()
    {
        if(getPF_Sub_Class_1() == 'PMLF'){
            Decimal bodySize = getBodySize();
            for(CM_PF_Value__c pfVal : cmPfList){
                if(pfVal.Body_Size__c == bodySize){
                    return getDecimal(pfVal, 'Subs_Cost_Per_Strip__c', 0.0);                    
                    break;
                }
            }
            return 0.0;      
        }
        else if(getPF_Sub_Class_1() == 'SMLF'){
            String frameFinish = getFrameFinish();
            for(CM_PF_Value__c pfVal : cmPfList){
                if(pfVal.Frame_Finish__c == frameFinish){
                    return getDecimal(pfVal, 'Subs_Cost_Per_Strip__c', 0.0);
                    break;
                }
            }
            return 0.0;   
        }
        else{
            return 0.0;
        }

        
    }
    
    //Based on AMK-922, there are no RuCU and PFF for PMLF. Only Ag Plate 
    //(No HDLF, and OMLF, only VHDLF)
    public virtual Decimal getSubstrateNumberPerColumn()
    {
        Decimal bodySize = getBodySize();
        for(CM_PF_Value__c pfVal : cmPfList){
            if(pfVal.Body_Size__c == bodySize){
                return getDecimal(pfVal, 'Subs_Number_Per_Column__c', 0.0);                
                break;
            }
        }
        return 0.0;    
    }
    
    //To Do -- check here
    public virtual Decimal getDieNumDPW()
    {
        
        Decimal dieX = getDieX();
        Decimal dieY = getDieY();
        Decimal waferSize = getDieWaferSize();
        if(dieX  <= 0.0 || dieY <= 0.0 ) return 0.0;
        
        //note that waferSize is converted to mm for comparison
        if (waferSize == 150)
        {
            return ( 3.14 / (4.00 * ( dieX * dieY ))) * (146.4 - Math.sqrt(dieX * dieY)) * (146.4 - Math.sqrt(dieX * dieY)) ;
        }
        else if (waferSize == 200)
        {
            return (3.14 / (4.00 * (dieX * dieY))) * (195.2 - Math.sqrt(dieX * dieY))*(195.2 - Math.sqrt(dieX * dieY));
        }
        else if (waferSize == 300)
        {
            return (3.14 / (4.00 * (dieX * dieY))) * (292.8 - Math.sqrt(dieX * dieY) ) * (292.8 - Math.sqrt(dieX * dieY) );
        }
        else{
        	//default value should be 0??
        	return 0;
        }
    }
    
    //To Do : change it
    public virtual Decimal getDieWaferYield()
    {
        if(getPF_Sub_Class_1() == 'PMLF')
        {
            return 0.9; 
        }
        else if(getPF_Sub_Class_1() == 'SMLF')
        {
            return 0.8; 
        }
        else
            return 0.0;     
    }
    
    
    public virtual Decimal getDieNumGDPW()
    {
        return Math.floor(getDieNumDPW() * getDieWaferYield());
    }
    
    // TO Do -- it should be an user input but no field show up
    // public virtual Decimal getTrayPrice()
    // {
        
    //     wrapper.get
    //     // if(getPF_Sub_Class_1() == 'PMLF')
    //     // {
    //     //     return 1.4875; 
    //     // }
    //     // else if(getPF_Sub_Class_1() == 'SMLF')
    //     // {
    //     //     return 1.27; 
    //     // }
    //     // else
    //     //     return 0.0;     
    // }
    

    //Based on AMK-922, there are no RuCU and PFF for PMLF. Only Ag Plate 
    //(No HDLF, and OMLF, only VHDLF)
    public virtual Decimal getEMCShot()
    {        
        Decimal bodySize = getBodySize();
        for(CM_PF_Value__c pfVal : cmPfList){
            if(pfVal.Body_Size__c == bodySize){
                return getDecimal(pfVal, 'EMC_Shot__c', 0.0);                
                break;
            }
        }
        return 0.0;                
    }
      
    public virtual Decimal getTotalNumWiresByConfig(String configType)
    {
        Decimal numWires = 0;
    
        for(SObject row : wrapper.wireConfigurations)
        {
            if (row.get('Wire_Configuration__c') == configType)
            {
                Decimal currWireCount = (Decimal)row.get('Number_Of_Wires__c');
                if (currWireCount != null) numWires += currWireCount;
            }
        }
        
        return numWires;
    }
    //To Do: change it
    public virtual Decimal getNumStandardWires()
    {
        return getTotalNumWiresByConfig('Forward Bonding');
    }
    //To Do: change it
    public virtual Decimal getRSSBWires()
    {
        return getTotalNumWiresByConfig('Reverse Stand off Stitch Bond (RSSB)');
    }
    //To Do: change it
    public virtual Decimal getNumSSBWires()
    {
        return getTotalNumWiresByConfig('Stand off Stitch Bond (SSB)');
    }
    
    public virtual String getPF_Sub_Class_1(){
        return (String)wrapper.specificRfqItem.get('PF_Sub_Class_1__c');
    }

    public virtual String getFrameFinish(){

       return (String)wrapper.specificRfqItem.get('Frame_Finish__c');
    } 

    public virtual Decimal getBodySize()
    {   

        if(getPF_Sub_Class_1() == 'PMLF')
        {

            String bodySize = String.valueOf(wrapper.getAttribute('Body_Size__c', 'Package', 0));
            Integer endIndex = bodySize.indexOf('x'); 	        
            return Decimal.valueOf(bodySize.substring(0, endIndex));
        }

        else if(getPF_Sub_Class_1() == 'SMLF')
        {
            Decimal bodyX = getDecimal(wrapper.specificRfqItem, 'Body_Size_X__c', 0);
            Decimal bodyY = getDecimal(wrapper.specificRfqItem, 'Body_Size_Y__c', 0);
            return Math.sqrt(bodyX * bodyY);
        }

        return 0;

    }

    public virtual Decimal getBodySizeX()
    {   

        if(getPF_Sub_Class_1() == 'PMLF')
        {

            String bodySize = String.valueOf(wrapper.getAttribute('Body_Size__c', 'Package', 0));
            Integer endIndex = bodySize.indexOf('x');           
            return Decimal.valueOf(bodySize.substring(0, endIndex));
        }

        else if(getPF_Sub_Class_1() == 'SMLF')
        {
            return getDecimal(wrapper.specificRfqItem, 'Body_Size_X__c', 0);
        }

        return 0;
    }

    public virtual Decimal getBodySizeY()
    {   

        if(getPF_Sub_Class_1() == 'PMLF')
        {

            String bodySize = String.valueOf(wrapper.getAttribute('Body_Size__c', 'Package', 0));
            Integer startIndex = bodySize.indexOf('x') + 1;           
            return Decimal.valueOf(bodySize.substring(startIndex, bodySize.length()));
        }

        else if(getPF_Sub_Class_1() == 'SMLF')
        {
            return getDecimal(wrapper.specificRfqItem, 'Body_Size_Y__c', 0);
        }

        return 0;
    }

    public override Decimal getForecastVolumePerWeek(String forecast)
    {
        return getForecastFloor(forecast);
    }

    public override Decimal getMarginPercent(String forecastVal)
    {
        Decimal retVal = 0;

        Decimal foreCastFloor = getForecastFloor(forecastVal);
        List<CM_Margin__c> marginList = CMMarginDao.getInstance().getByVersion(mVer.id);
        for(CM_Margin__c mg : marginList){            
            if(mg.Volume_Floor__c == foreCastFloor){
                retVal = getDecimal(mg, 'Margin__c', 0.0);
                break;
            }
        }

        hasAutomaticMargin = retVal > 0;
        return retVal;

        
    }

    private Decimal getForecastFloor(String forecastVal){

        if      (forecastVal == '1 - 199')      return 100;
        else if (forecastVal == '200 - 499')    return 350;
        else if (forecastVal == '500 - 749')    return 625;
        else if (forecastVal == '750 - 1000')   return 875;
        else if (forecastVal == '> 1000')       return 1001;
        else return 0;

    }


    private Decimal getAnnualVolume(){
        return Decimal.valueOf((String)wrapper.specificRfqItem.get('Annual_Volume__c'));        
    }
}