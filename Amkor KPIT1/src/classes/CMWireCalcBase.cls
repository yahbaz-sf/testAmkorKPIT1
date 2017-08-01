/*************************************************************************
*
* PURPOSE: Interface for Wire Calcs for each PG to have its own wire calc
*
* CLASS: CMWireCalcInterface
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/

public abstract class CMWireCalcBase
{

    
    protected CM_Version__c ver;
    protected UnitUtils converter = UnitUtils.getInstance(); 
    public DebugUtils debug {get {return DebugUtils.getInstance();} }
    
    //---Perform wire calculations
    public void calculate(RFQItemWrapper pWrapper) 
    {
        setupCmVersionObject(pWrapper);
        for(SObject row : pWrapper.wireConfigurations) {
            row.put('Do_Not_Validate__c', false);
            calcLength(row);
        } 
    }

    public void calculate(RFQItemWrapper pWrapper, String wireConfigId)
    {
        setupCmVersionObject(pWrapper);
        for(SObject row : pWrapper.wireConfigurations)  {
            if (row.Id == wireConfigId) calcLength(row);
            else row.put('Do_Not_Validate__c', true);

        }
    }

    private void setupCmVersionObject(RFQItemWrapper pWrapper) {
        ver = null;
        List<CM_Version__c> verList = null;
        
        //---Look for Active version first
        verList = CMVersionDao.getInstance().getByPGAndStatus(pWrapper.packageFamily.Product_Group__c, 'Active');
        if (verList != null && verList.size() > 0) ver = verList[0];
        
        if (ver == null)
        {
            //---If no ver, look for a pending
            verList = CMVersionDao.getInstance().getByPGAndStatus(pWrapper.packageFamily.Product_Group__c, 'Pending');
            if (verList != null && verList.size() > 0) ver = verList[0];
        }
        
        if (ver == null)
        {
            //---If no version, create a blank one to prevent errors
            ver = new CM_Version__c(Product_Group__c=pWrapper.packageFamily.Product_Group__c, Status__c='Pending');
        }
    }

    private void calcLength(sObject wireConfig)
    {
        calcLength(wireConfig, ver);
    }

    //---Calc Length
    public void calcLength(SObject wireConfig, CM_Version__c version)
    {
        
        if (version == null)
        {
            wireConfig.put('Total_2D_Wire_Length__c',0);
            wireConfig.put('Average_2D_Wire_Length__c',0); 
            wireConfig.put('Total_3D_Wire_Length__c',0);
        }
        else
        {
            //if wiresize == 'Other', use Other wire diameter field
            Decimal wireSize;
            if (wireConfig != null && wireConfig.get('Wire_Diameter__c') != null)                
                    if ((String)(wireConfig.get('Wire_Diameter__c')) == 'Other') wireSize = (Double)wireConfig.get('Wire_Diameter_Other__c');
                    else wireSize = Double.valueOf((String)wireConfig.get('Wire_Diameter__c'));


            Decimal numberOfWires = DataUtils.getDecimal(wireConfig,'Number_Of_Wires__c',0);
            Decimal average2DLength = DataUtils.getDecimal(wireConfig,'Average_2D_Wire_Length__c',0);
            Decimal total2DLength = DataUtils.getDecimal(wireConfig,'Total_2D_Wire_Length__c',0);
            Decimal total3DLength = DataUtils.getDecimal(wireConfig, 'Total_3D_Wire_Length__c', 0);
            //average2DLength.setScale(5);
            //total2DLength.setScale(5);

            Decimal loopHeight = version.Wire_Loop_Height__c == null ? 5 : version.Wire_Loop_Height__c;
            Decimal paddleDown = version.Wire_Paddle_Down__c == null ? 0 : version.Wire_Paddle_Down__c;
            Decimal dAThickness = version.Wire_DA_Thickness__c == null ? 1 : version.Wire_DA_Thickness__c;
            Decimal dieThickness = version.Wire_Die_Thickness__c == null ? 200 : version.Wire_Die_Thickness__c;

            Decimal YEff = (dieThickness + (loopHeight + dAThickness - paddleDown)*25.4)/1000;

            recalculateWireTotals(wireConfig);
           
            if(average2DLength > 0 || total2DLength > 0) {
            

                if(average2DLength > 0) {
                    total2DLength = average2DLength * numberOfWires;
                }   
                if(total2DLength > 0 && average2DLength == 0) {
                    average2DLength = (numberOfWires == 0) ? 0 : total2DLength / numberOfWires;
                }
                
                //---TODO Check line below - there was an extra '-wireSize' that shouldn't have been there (for Dual). Make sure it doesn't break anything in any other PG
                //--TODO the wire calculation will be different in fabMM for PBGA and others
                
                total3DLength = convert2DTo3DLength(average2DLength, wireSize, numberOfWires, loopHeight, YEff, version);
                

            }
            else if (total3DLength > 0)
            {
                average2DLength = convert3DTo2DLength(total3DLength, wireSize, numberOfWires, loopHeight, YEff, version);
                total2DLength = average2DLength * numberOfWires;
            }

            if (getString(wireConfig, 'Wire_Material__c') == 'Au') 
            {
                Decimal auFactor = converter.convert(total3DLength, UnitUtils.UNIT_MM, UnitUtils.UNIT_FT) * getTroyOzPerKft(wireSize);
                wireConfig.put('Au_Factor__c', auFactor);
            }
            else
            {
                wireConfig.put('Au_Factor__c', null);
            }

            wireConfig.put('Total_2D_Wire_Length__c',total2DLength);
            wireConfig.put('Average_2D_Wire_Length__c',average2DLength); 
            wireConfig.put('Total_3D_Wire_Length__c',total3DLength);

            
        }
    }

    //used by MLF, Quad, Dual. PBGA is different
    protected virtual  Decimal convert2DTo3DLength(Decimal average2DLength, Decimal wireSize, Decimal numberOfWires, Decimal loopHeight, Decimal YEff, CM_Version__c version)
    {
        Decimal tmp3DLength = (Math.sqrt(average2DLength*average2DLength+YEff*YEff) + converter.convert(loopHeight, UnitUtils.UNIT_MIL, UnitUtils.UNIT_MM))*numberOfWires;
        Decimal ballRatio = (version == null || version.Wire_Ball_Ratio__c == null) ? 1.8 : version.Wire_Ball_Ratio__c;
        Decimal convertedWireSize = converter.convert(wireSize, UnitUtils.UNIT_MIL, UnitUtils.UNIT_MM);
        Decimal fabMM =  (((4/3.0)*(ballRatio*ballRatio*ballRatio)*(convertedWireSize/2.0)))*numberOfWires; 
        return tmp3DLength + fabMM; 
    }

    //used by MLF, Quad, Dual. PBGA is different
    protected virtual Decimal convert3DTo2DLength(Decimal total3DwireLength,  Decimal wireSize, Decimal numberOfWires, Decimal loopHeight, Decimal YEff, CM_Version__c version)
    {
        Decimal ballRatio = (version == null || version.Wire_Ball_Ratio__c == null) ? 1.8 : version.Wire_Ball_Ratio__c;
        Decimal constant = converter.convert(loopHeight, UnitUtils.UNIT_MIL, UnitUtils.UNIT_MM); 
        Decimal convertedWireSize = converter.convert(wireSize, UnitUtils.UNIT_MIL, UnitUtils.UNIT_MM);
        Decimal fabMM = (((4/3.0)*(ballRatio*ballRatio*ballRatio)*(convertedWireSize/2.0)))*numberOfWires;

        return (numberOfWires == 0) ? 0 : Math.sqrt((((total3DwireLength - fabMM )/ numberOfWires - constant ) *((total3DwireLength - fabMM)/ numberOfWires - constant ) - YEff * YEff));
    }

    //this method is added because the Quad wire calc has extra fields (# SSB and # FWD wires) that must be re-calculated based on each other
    protected virtual void recalculateWireTotals(SObject wireConfig)
    {}

    //---Get decimal value from attribute
    protected Decimal getDecimal(sObject obj, String fieldName, Decimal defVal) 
    {
        if(obj == null) return defVal;
        if(obj.get(fieldName) == null) return defVal;
        return Decimal.valueOf(String.valueOf(obj.get(fieldName)));
    }

    private String getString (sObject obj, String fieldName)
    {
        if(obj.get(fieldName) == null) return '';
        return String.valueOf(obj.get(fieldName));
    }

    
    private virtual Decimal getTroyOzPerKft(Decimal diameter)
    {
        if      (diameter == 0.5) return 0.023985;
        else if (diameter == 0.6) return 0.0345399054397398;
        else if (diameter == 0.7) return 0.0470126490707569;
        else if (diameter == 0.8) return 0.0614042763373152;
        else if (diameter == 0.9) return 0.0777147872394145;
        else if (diameter == 1.0) return 0.095944181777055;
        else if (diameter == 1.1) return 0.116092459950237;
        else if (diameter == 1.2) return 0.138159621758959;
        else if (diameter == 1.3) return 0.162145667203223;
        else if (diameter == 1.5) return 0.215874408998374;
        else if (diameter == 2.0) return 0.38377672710822;
        return 0;
    }
}