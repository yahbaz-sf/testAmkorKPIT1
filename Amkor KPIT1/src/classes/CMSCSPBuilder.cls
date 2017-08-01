/*************************************************************************
*
* PURPOSE: Cost Model Engine for SCSP Product Group
*
* CLASS: CMSCSPBuilder
* CREATED: 7/30/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
public with sharing class CMSCSPBuilder extends CMCABGABuilder
{
    //protected override Decimal getMaterialTotal(RFQItemWrapper itemWrapper)
    //{
    //  Decimal materialLaminate = getDecimal(itemWrapper.specificRfqItem, 'Materials_Laminate__c', 0.0);
    //  Decimal materialODM = getDecimal(itemWrapper.specificRfqItem, 'Materials_ODM__c', 0.0);
    //  Decimal materialWire = getDecimal(itemWrapper.specificRfqItem, 'Materials_Total_Wire__c', 0.0);
    //  return materialLaminate + materialODM + materialWire;
    //}

    //public override Decimal getMeanForecast(String forecast)
    //{
    //  if (forecast == null) return 0;
    //  else if (forecast == '50-100') return 75;
    //  else if (forecast == '100') return 150;
    //  else if (forecast == '200') return 250;
    //  else if (forecast == '300') return 350;
    //  else if (forecast == '400') return 450;
    //  else if (forecast == '500') return 750;
    //  else if (forecast == '1000') return 1500;
    //  else if (forecast == '2000') return 2500;
    //  else if (forecast == '3000') return 3500;
    //  else if (forecast == '4000') return 4500;
    //  else if (forecast == '5000') return 5500;
    //  else if (forecast == '6000') return 6500;
    //  else if (forecast == '7000') return 7500;
    //  else if (forecast == '8000') return 8500;
    //  else if (forecast == '9000') return 9500;
    //  else if (forecast == '10000') return 10000;

    //  else return 0;
    //}
    
    //Bharat - 22-June-2017 : Salesforce-81 : JDevice Plant Quoting capability in SFDC.
    public override void onAttributeChange(RFQItemWrapper itemWrapper, String attributeName)
    {
        if(attributeName == 'BU_Price__c' || attributeName == 'Total_Cost__c' ) 
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
        
    }
    
    //Bharat - 22-June-2017 : Salesforce-81 : JDevice Plant Quoting capability in SFDC.
    // %GM calculation based on bu price and total cost.
    public override void onBUPriceChanged(RFQItemWrapper itemWrapper)
    {
        Decimal buPrice = getDecimal(itemWrapper.specificRfqItem, 'BU_Price__c', 0.0);

        if(buPrice > 0.0)
        {
            // Decimal salesTargetPrice = getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0) == 0.0 ? getDecimal(itemWrapper.specificRfqItem, 'Customer_Target_Price__c', 0.0) : getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0);
            // Decimal delta = (salesTargetPrice != 0.0) ? (buPrice - salesTargetPrice)/salesTargetPrice : 0.0;            
            // itemWrapper.specificRfqItem.put('BU_Price_Perc_Delta_To_Target__c', delta * 100.0); 
            Decimal totalCost = getDecimal(itemWrapper.specificRfqItem, 'Total_Cost__c', 0.0);                          
            Decimal margin = (buPrice - totalCost)/buPrice ; 
            itemWrapper.specificRfqItem.put('Total_Perc_GM__c', margin * 100.0);        
        }
        else
        {
            String err = 'BU Price must be greater than 0. <br /> Please re-enter BU price. ';
            addError(err);

        }
        
    }
    
    public override Map<String, String> getFieldMap()
    {
        Map<String, String> fieldMap = new Map<String, String>();

        fieldMap.put('price', 'BU_Price__c');
        fieldMap.put('margin', 'Total_Perc_GM__c');
        fieldMap.put('totalCost', 'Total_Cost__c');

        return fieldMap;
    }
    
}