/*************************************************************************
*
* PURPOSE: Cost Model Engine for substrate Product Groups 
* (CABGA, SCSP)
*
* CLASS: CMCABGABuilder
* CREATED: 7/17/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
public virtual with sharing class CMCABGABuilder extends CMBuilder
{
    public CMCABGABuilder()
    {
        bridge = new CMOthersBridge();
    }



    

    //To Do:
    public override void loadSettings(RFQItemWrapper itemWrapper, Boolean isReloaded){
        //setup(pWrapper);

    }
    
    //Bharat - 22-June-2017 : Salesforce-81 : JDevice Plant Quoting capability in SFDC.Chaning onAttributeChange method to virtual.
    public virtual override void onAttributeChange(RFQItemWrapper itemWrapper, String attributeName)
    {
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
        
    }
    
    /*
    public void onBUPriceChanged(RFQItemWrapper itemWrapper)
    {
        Decimal buPrice = getDecimal(itemWrapper.specificRfqItem, 'BU_Price__c', 0.0);

        if(buPrice > 0.0)
        {
            Decimal salesTargetPrice = getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0) == 0.0 ? getDecimal(itemWrapper.specificRfqItem, 'Customer_Target_Price__c', 0.0) : getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0);
            Decimal totalCost = getDecimal(itemWrapper.specificRfqItem, 'Total_Cost__c', 0.0);
            Decimal delta = (salesTargetPrice != 0.0) ? (buPrice - salesTargetPrice)/salesTargetPrice : 0.0;            
            itemWrapper.specificRfqItem.put('BU_Price_Perc_Delta_To_Target__c', delta * 100.0);                           
            Decimal margin = (buPrice - totalCost)/buPrice ; 
            itemWrapper.specificRfqItem.put('BU_Price_Perc_GM__c', margin * 100.0);        
        }
        else
        {
            String err = 'BU Price must be greater than 0. <br /> Please re-enter BU price. ';
            addError(err);

        }
    }
    

    public void onBUPricePercDeltaToTargetChanged(RFQItemWrapper itemWrapper)
    {
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
        Decimal margin = (buPrice - totalCost)/buPrice ; 
        itemWrapper.specificRfqItem.put('BU_Price__c',buPrice);
        itemWrapper.specificRfqItem.put('BU_Price_Perc_GM__c', margin * 100.0);
    }

    public void onBUPricePercGMChanged(RFQItemWrapper itemWrapper)
    {
        Decimal margin = getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Perc_GM__c', 0.0)/100.0;
        if(1-margin > 0.0)
        {        
            Decimal salesTargetPrice = getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0) == 0.0 ? getDecimal(itemWrapper.specificRfqItem, 'Customer_Target_Price__c', 0.0) : getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0);        
            Decimal totalCost = getDecimal(itemWrapper.specificRfqItem, 'Total_Cost__c', 0.0);
            Decimal buPrice = totalCost / (1 - margin);            
            Decimal delta = (salesTargetPrice != 0.0) ? (buPrice - salesTargetPrice)/salesTargetPrice : 0.0;         
            itemWrapper.specificRfqItem.put('BU_Price_Perc_Delta_To_Target__c',delta * 100.0);        
            itemWrapper.specificRfqItem.put('BU_Price__c',buPrice);
        }
        else
        {
            String err = 'Margin cannot be greater than or equal to 100. <br /> Please re-enter margin.';
            addError(err);
        }
    }

    
    public override void setEditabilityforNoCostModel(RFQILayout layout)
    {
        layout.changeEditability('Competitor__c',false);
        layout.changeEditability('Competitor_Price__c',false);
        layout.changeEditability('Fixed_Costs__c',false);
        layout.changeEditability('Variable_Costs__c',false);
        layout.changeEditability('Materials_As_Perc_Cost__c',false);
        layout.changeEditability('CLAM_Total__c',false);
        layout.changeEditability('Package_Item_Value__c',false);
        layout.changeEditability('Total_Cost__c',false);
        layout.changeEditability('Customer_Target_Price__c',false);
        layout.changeEditability('Sales_Target_Price__c',false);
        layout.changeEditability('Materials_Subtotal__c',false);
        
    
    }

    protected override void calcCostModel(RFQItemWrapper itemWrapper){}
    

    protected override void calcResults(RFQItemWrapper itemWrapper, Boolean runCostModel)
    {
        Decimal overhead = getDecimal(itemWrapper.specificRfqItem, 'Manufacturing_Overhead__c', 0.0);
        Decimal qaCost = getDecimal(itemWrapper.specificRfqItem, 'QA_Cost__c', 0.0);
        Decimal serviceGroup = getDecimal(itemWrapper.specificRfqItem, 'Service_Group_Cost__c', 0.0);

        Decimal clamDepreciation = getDecimal(itemWrapper.specificRfqItem, 'CLAM_Depreciation__c', 0.0);
        Decimal clamFacilities = getDecimal(itemWrapper.specificRfqItem, 'CLAM_Facilities__c', 0.0);
        Decimal clamDirectLabor = getDecimal(itemWrapper.specificRfqItem, 'CLAM_Direct_Labor__c', 0.0);
        Decimal clamIndirectLabor = getDecimal(itemWrapper.specificRfqItem, 'CLAM_Indirect_Labor__c', 0.0);
        Decimal clamLabor = clamDirectLabor + clamIndirectLabor;
        
        Decimal clamSubtotal = clamDepreciation + clamLabor + clamFacilities + overhead + qaCost + serviceGroup;
        
        Decimal materialSubtotal = getMaterialTotal(itemWrapper);
        
        Decimal totalCost = materialSubtotal + clamSubtotal;

        Decimal totalGM = getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Perc_GM__c', 0.0) / 100;
        Decimal buPrice = (totalGM == 1) ? 0 : totalCost / (1 - totalGM);

        Decimal targetPrice = getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0) == 0.0 ? getDecimal(itemWrapper.specificRfqItem, 'Customer_Target_Price__c', 0.0) : getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0);
        Decimal percDelta = (targetPrice == 0) ? 0 : (buPrice - targetPrice) / targetPrice * 100;
        

        Decimal varCost = clamDirectLabor + overhead + materialSubtotal;                        
        Decimal fixedCost = clamIndirectLabor + clamDepreciation + clamFacilities + qaCost + serviceGroup; 

        Decimal materialPct = (totalCost > 0) ? 100 * materialSubtotal / totalCost : 0;

        Decimal packageItemValue = buPrice * getMeanForecast((String)itemWrapper.specificRfqItem.get('Forecast__c'));

        itemWrapper.specificRfqItem.put( 'Materials_As_Perc_Cost__c', materialPct);

        itemWrapper.specificRfqItem.put( 'Fixed_Costs__c', fixedCost);
        itemWrapper.specificRfqItem.put( 'Variable_Costs__c', varCost); 

        itemWrapper.specificRfqItem.put('Materials_Subtotal__c', materialSubtotal);
        itemWrapper.specificRfqItem.put('BU_Price__c', buPrice);
        itemWrapper.specificRfqItem.put('BU_Price_Perc_Delta_To_Target__c', percDelta);
        itemWrapper.specificRfqItem.put('Package_Item_Value__c', packageItemValue);

        //SCSP does not have this field
        try
        {
            itemWrapper.specificRfqItem.put('CLAM_Total__c', clamSubtotal);
        }
        catch (Exception e) { DebugUtils.getInstance().log('Error', e); }

        itemWrapper.specificRfqItem.put('Total_Cost__c', totalCost);

        Decimal customerPrice = getDecimal(itemWrapper.specificRfqItem, 'Price_To_Customer__c', 0.0);
        if(customerPrice < buPrice)
            itemWrapper.specificRfqItem.put('Price_To_Customer__c', buPrice);
        else
            itemWrapper.specificRfqItem.put('Price_To_Customer__c', customerPrice);

        itemWrapper.clearPriceToCustomerIfRequired();
        
        //update itemWrapper.specificRfqItem;
    }

    public virtual Decimal getMeanForecast(String forecast)
    {
        if (forecast == null) return 0;

        //CABGA
        Pattern betweenTwoNumbers = Pattern.compile('(\\s*\\d+)(\\s*-\\s*)(\\d+\\s*)');
        Pattern greaterOrEqaul = Pattern.compile('(\\s*>\\s*=*)\\s*(\\d+)');
        Matcher betweenMatcher = betweenTwoNumbers.matcher(forecast);                        
        Matcher greaterMatcher = greaterOrEqaul.matcher(forecast);
        
        try{
            //check greater first       
            Decimal value;
            if(greaterMatcher.matches()){               
                    value = Decimal.valueOf(greaterMatcher.group(2));
            }
            else if(betweenMatcher.matches()){                
                    value = (Decimal.valueOf(betweenMatcher.group(1)) +  Decimal.valueOf(betweenMatcher.group(3)) ) /2.0;
            }
            else value = 0.0;            
            return value;
        }
        catch(Exception e){
            System.debug(LoggingLevel.ERROR, '##### getForecast ERROR: ' + e);
            return 0.0;   

        }       
    }

    protected virtual Decimal getMaterialTotal(RFQItemWrapper itemWrapper)
    {
        Decimal materialSubstrate = getDecimal(itemWrapper.specificRfqItem, 'Materials_Substrate__c', 0.0);
        Decimal materialODM = getDecimal(itemWrapper.specificRfqItem, 'Materials_ODM__c', 0.0);
        Decimal materialWire = getDecimal(itemWrapper.specificRfqItem, 'Materials_Total_Wire__c', 0.0);
        return materialSubstrate + materialODM + materialWire;
    }
    */

    public virtual override Map<String, String> getFieldMap()
    {
        Map<String, String> fieldMap = new Map<String, String>();

        fieldMap.put('price', 'BU_Price__c');
        fieldMap.put('margin', 'BU_Price_Perc_GM__c');
        fieldMap.put('subsCost', 'Materials_Substrate__c');
        fieldMap.put('totalCost', 'Total_Cost__c');
        fieldMap.put('subsMarkup', 'Subs_Markup_Perc__c');

        return fieldMap;
    }

    protected override void calcCostModel(RFQItemWrapper itemWrapper) {}
    protected override void calcResults(RFQItemWrapper itemWrapper, Boolean runCostModel) {}
    //Bharat - 22-June-2017 : Salesforce-81 : JDevice Plant Quoting capability in SFDC.Chaning onBUPriceChanged method to virtual.
    public virtual void onBUPriceChanged(RFQItemWrapper itemWrapper) {}
    public void onBUPricePercDeltaToTargetChanged(RFQItemWrapper itemWrapper) {}
    public void onBUPricePercGMChanged(RFQItemWrapper itemWrapper) {}
    public override void setEditabilityforNoCostModel(RFQILayout layout) {}

    
}