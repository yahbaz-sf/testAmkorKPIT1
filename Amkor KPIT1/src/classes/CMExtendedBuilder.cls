/*************************************************************************
*
* PURPOSE: Cost Model Engine for extended Product Groups 
*
* CLASS: CMExtendedBuilder
* CREATED: 8/5/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
public virtual with sharing class CMExtendedBuilder extends CMBuilder
{
    public CMExtendedBuilder()
    {
        bridge = new CMOthersBridge();
    }



    //To Do:
    public override void loadSettings(RFQItemWrapper itemWrapper, Boolean isReloaded){
        //setup(pWrapper);

    }

    public override void onAttributeChange(RFQItemWrapper itemWrapper, String attributeName){
        calcResults(itemWrapper, false);
    }
    
    public override void setEditabilityforNoCostModel(RFQILayout layout)
    {
        layout.changeEditability('Competitor__c',false);
        layout.changeEditability('Competitor_Au_Inclusive_Price__c',false);
        layout.changeEditability('CLAM_Subtotal__c',false);
        layout.changeEditability('Customer_Target_Price__c',false);
        layout.changeEditability('Sales_Target_Price__c',false);
        layout.changeEditability('Materials_Subtotal__c',false);

        layout.changeEditability('BU_Price__c',false);
        layout.changeEditability('Total_Cost__c',false);
        layout.changeEditability('Total_Perc_GM__c',false);
        layout.changeEditability('Perc_IRR_New__c',false);
        layout.changeEditability('Perc_VAM_New__c',false);
        
        
    
    }

    //To Do:
    protected override void calcCostModel(RFQItemWrapper itemWrapper){}



    protected override void calcResults(RFQItemWrapper itemWrapper, Boolean runCostModel)
    {
    
        // Ashish:SF-139: Need to simplify the %GM calculation on BU Screen.
        // %GM calculation is based upon total cost and BU price only. Other fields are commented.
        /*Decimal clamOverhead = getDecimal(itemWrapper.specificRfqItem, 'CLAM_OH__c', 0.0);
        Decimal clamDepreciation = getDecimal(itemWrapper.specificRfqItem, 'CLAM_Depreciation__c', 0.0);
        Decimal clamOCOGS = getDecimal(itemWrapper.specificRfqItem, 'CLAM_OCOGS__c', 0.0);
        Decimal clamLabor = getDecimal(itemWrapper.specificRfqItem, 'CLAM_Direct_Labor__c', 0.0);
        
        Decimal clamSubtotal = clamDepreciation + clamLabor + clamOCOGS + clamOverhead;


        Decimal materialWire = getDecimal(itemWrapper.specificRfqItem, 'Materials_Total_Wire__c', 0.0);

        Decimal materialSubstrate = getDecimal(itemWrapper.specificRfqItem, 'Materials_Substrate__c', 0.0);
        Decimal materialODM = getDecimal(itemWrapper.specificRfqItem, 'Materials_ODM__c', 0.0);
        Decimal materialSubtotal = materialSubstrate + materialODM + materialWire;*/
        
        Decimal totalCost = getDecimal(itemWrapper.specificRfqItem, 'Total_Cost__c', 0.0);
       // Decimal costLessSubstrate = totalCost - materialSubstrate;

        //not all PFs have substrate markup
        /* Decimal substrateMarkup = getDecimal(itemWrapper.specificRfqItem, 'Subs_Markup_Perc__c', 0.0) / 100;        
        Decimal assemblyGM = getDecimal(itemWrapper.specificRfqItem, 'Assembly_GM_wo_Substrate__c', 0.0) / 100; */
        Decimal buPrice = getDecimal(itemWrapper.specificRfqItem, 'BU_Price__c', 0.0);
        Decimal totalGM = buPrice == 0 ? 0 : (buPrice - totalCost) / (buPrice);
        totalGM *= 100.0;
            
       /* Decimal percVAM = buPrice - materialSubtotal  == 0 ? 0 : (buPrice - totalCost) / (buPrice - materialSubtotal) * 100.0; 
        
        

         itemWrapper.specificRfqItem.put('Materials_Subtotal__c', materialSubtotal);
        itemWrapper.specificRfqItem.put('BU_Price__c', buPrice);
        itemWrapper.specificRfqItem.put('CLAM_Subtotal__c', clamSubtotal);
        itemWrapper.specificRfqItem.put('Total_Cost__c', totalCost); */
        itemWrapper.specificRfqItem.put('Total_Perc_GM__c', totalGM);
        //itemWrapper.specificRfqItem.put('Perc_VAM_New__c', percVAM);

        

        itemWrapper.clearPriceToCustomerIfRequired();

    }

    public override Map<String, String> getFieldMap()
    {
        Map<String, String> fieldMap = new Map<String, String>();

        fieldMap.put('price', 'BU_Price__c');
        fieldMap.put('margin', 'Total_Perc_GM__c');
        fieldMap.put('subsMarkup', 'Subs_Markup_Perc__c');
        fieldMap.put('marginNoSubstrate', 'Assembly_GM_wo_Substrate__c');
        fieldMap.put('subsCost', 'Materials_Substrate__c');
        fieldMap.put('totalCost', 'Total_Cost__c');

        return fieldMap;
    }
    

    
}