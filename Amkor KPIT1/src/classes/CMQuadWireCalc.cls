/*************************************************************************
*
* PURPOSE: Calculate 3D wire length or 2D wire length based on 
* wireSize, numberOfWires, CM Version and wire length.
*
* CLASS: CMQuadWireCalc
* CREATED: 6/28/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Chia Yuan Chuang
***************************************************************************/

public class CMQuadWireCalc extends CMWireCalcBase
{

    protected override void recalculateWireTotals(SObject wireConfig)
    {
        Decimal totalWires = getDecimal(wireConfig,'Number_of_Wires__c',0);
        Decimal fwdWires = getDecimal(wireConfig,'Number_of_FWD_Wires__c',0);
        Decimal ssbWires = getDecimal(wireConfig, 'Number_of_SSB_Wires__c', 0);

        if (totalWires > 0)
        {
            if (fwdWires > 0 && fwdWires < totalWires) ssbWires = totalWires - fwdWires;
            else fwdWires = totalWires - ssbWires;
        }
        
        totalWires = fwdWires + ssbWires;

        wireConfig.put('Number_of_Wires__c',totalWires);
        wireConfig.put('Number_of_FWD_Wires__c',fwdWires); 
        wireConfig.put('Number_of_SSB_Wires__c',ssbWires);
        
    }
}