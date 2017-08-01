/*************************************************************************
*
* PURPOSE: Calculate 3D wire length or 2D wire length based on 
* wireSize, numberOfWires, CM Version and wire length.

* CLASS: CMPBGAWireCalc
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/

public class CMPBGAWireCalc extends CMWireCalcBase
{
    

    protected override Decimal convert2DTo3Dlength(Decimal average2DLength, Decimal wireSize, Decimal numberOfWires, Decimal loopHeight, Decimal YEff, CM_Version__c version){

    	Decimal tmp3DLength = (Math.sqrt(average2DLength*average2DLength+YEff*YEff) + converter.convert(loopHeight, UnitUtils.UNIT_MIL, UnitUtils.UNIT_MM))*numberOfWires;

    	Decimal ballRatio = version.Wire_Ball_Ratio__c == null ? 1.8 : version.Wire_Ball_Ratio__c;
        Decimal convertedWireSize = converter.convert(wireSize, UnitUtils.UNIT_MIL, UnitUtils.UNIT_MM);
        Decimal fabMM =  (((4/3.0)*(ballRatio*ballRatio*ballRatio)*(convertedWireSize/2.0) - convertedWireSize))*numberOfWires;	
        
        return tmp3DLength + fabMM;

    }
    protected override Decimal convert3DTo2DLength(Decimal total3DwireLength, Decimal wireSize, Decimal numberOfWires, Decimal loopHeight, Decimal YEff, CM_Version__c version ){
      
    	Decimal ballRatio = version.Wire_Ball_Ratio__c == null ? 1.8 : version.Wire_Ball_Ratio__c;
    	Decimal constant = converter.convert(loopHeight, UnitUtils.UNIT_MIL, UnitUtils.UNIT_MM); 
    	Decimal convertedWireSize = converter.convert(wireSize, UnitUtils.UNIT_MIL, UnitUtils.UNIT_MM);
		Decimal fabMM = (((4/3.0)*(ballRatio*ballRatio*ballRatio)*(convertedWireSize/2.0) - convertedWireSize))*numberOfWires;	
      
        return (numberOfWires == 0) ? 0 : Math.sqrt((((total3DwireLength - fabMM)/ numberOfWires - constant ) *((total3DwireLength - fabMM)/ numberOfWires - constant ) - YEff * YEff));




    }
}