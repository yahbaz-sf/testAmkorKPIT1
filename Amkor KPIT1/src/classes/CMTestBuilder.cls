/*************************************************************************
*
* PURPOSE: 
*
* CLASS:  
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMTestBuilder extends CMBuilder
{
    private RFQIWC_PBGA__c wireConfig;
    private Map<String, Decimal> costModelResults;
    private List<sObject> updateList;

    private Double totalPrice = 0;

    private Decimal totalTesterValue = 0;
    private Decimal totalHandlerValue = 0;
    private Decimal totalBUCost = 0;
    private Decimal totalBUPriceHour = 0;
    private Decimal totalBuPriceUnit = 0;
    private Decimal totalBUPriceMonth = 0;

    private Integer count = 0;

    private Boolean isStripTest;
    private Boolean isWaferProbe;
    private Decimal GDPW;

    public CMTestBuilder()
    {
        bridge = new CMTestBridge();
    }

    //To Do:
    public override void loadSettings(RFQItemWrapper itemWrapper, Boolean isReloaded)
    {
        //setup(pWrapper);

    }


    //Need to Check update part
    public override void calculateNew(RFQItemWrapper itemWrapper, CMSettings pSettings)
    {

        settings = pSettings;
        setup(itemWrapper);
        calcResults(itemWrapper, true);
        try
        {
            
            calcMulti(itemWrapper, getHasSubstrate(itemWrapper));
            
        }
        catch(Exception e) 
        {
            debugList.add( new CMDebug('Error: ' + e));
            debug.log('debugList', debugList);
        }

    }

    public override void calculateAll(RFQItemWrapper itemWrapper, Boolean isUpdate, CMSettings pSettings)
    {

        settings = pSettings;
        setup(itemWrapper);
        calcResults(itemWrapper, true);
        try
        {
            
            calcMulti(itemWrapper, getHasSubstrate(itemWrapper));
        }
        catch(Exception e) 
        {
            debugList.add( new CMDebug('Error: ' + e));
            debug.log('debugList', debugList);
        }
        
    }
        
    public override void displayResults(RFQItemWrapper itemWrapper, Boolean isUpdate)
    {
        
        if (settings == null) settings = new CMSettings();

        setup(itemWrapper);
        
        try 
        {   
            calcResults(itemWrapper, true);
        }
        catch(Exception e) 
        {
            debugList.add( new CMDebug('Error: ' + e));
        }
    }


    public void costModelTestMapInstall()
    {
        costModelResults = new Map<String, Decimal>();
    }
    
    private void calcMain(RFQItemWrapper itemWrapper)
    {}


    //To Do:
    protected override void calcCostModel(RFQItemWrapper itemWrapper)
    {}

    //To Do:
    @TestVisible protected override void calcResults(RFQItemWrapper itemWrapper, Boolean runCostModel)
    {
        totalTesterValue = 0;
        totalHandlerValue = 0;
        totalBUCost = 0;
        totalBUPriceHour = 0;
        totalBuPriceUnit = 0;
        totalBUPriceMonth = 0;

        isStripTest = itemWrapper.specificRfqItem.get('Test_Type__c') == AMKVARS.TT_STRIP;
        isWaferProbe = itemWrapper.specificRfqItem.get('Test_Type__c') == AMKVARS.TT_PROBE;
        //---Adder Section
        Decimal adderTotal = 0;

        if(!isWaferProbe){

            Decimal adderLeadScan      = (!(Boolean)(itemWrapper.specificRfqItem.get('Scan__c'))) ? 0 : getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Lead_Scan__c', 0);
            Decimal adderTapeReel      = (!(Boolean)(itemWrapper.specificRfqItem.get('Tape_and_Reel__c'))) ? 0 : getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Tape_and_Reel__c', 0);
            Decimal adderInkMark       = (!(Boolean)(itemWrapper.specificRfqItem.get('Ink_Mark__c'))) ? 0 : getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Ink_Mark__c', 0);
            Decimal adderLaserMark     = (!(Boolean)(itemWrapper.specificRfqItem.get('Laser_Mark__c'))) ? 0 : getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Laser_Mark__c', 0);
            Decimal adderOther         = ((itemWrapper.specificRfqItem.get('Other__c') == null)) ? 0 : getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Other__c', 0);
            Decimal adderPack          = ((itemWrapper.specificRfqItem.get('Packing_Method__c') == null)) ? 0 : getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Pack__c', 0);
            Decimal adderBake          = (!(Boolean)(itemWrapper.specificRfqItem.get('Bake__c'))) ? 0 : getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Bake__c', 0);
            Decimal adderDropShip      = (!(Boolean)(itemWrapper.specificRfqItem.get('Drop_Ship__c'))) ? 0 : getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Drop_Ship__c', 0);
            Decimal adderDeTape        = (!(Boolean)(itemWrapper.specificRfqItem.get('De_Tape__c'))) ? 0 : getDecimal(itemWrapper.specificRfqItem, 'BU_Price_De_Tape__c', 0);
            Decimal adderBurnIn        = (!(Boolean)(itemWrapper.specificRfqItem.get('Burn_In__c'))) ? 0 : getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Burn_In__c', 0);
            Decimal adderDryPack        = (!(Boolean)(itemWrapper.specificRfqItem.get('Dry_Pack__c'))) ? 0 : getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Dry_Pack__c', 0);

            adderTotal = adderLeadScan + adderTapeReel + adderInkMark + adderLaserMark + adderOther + adderPack + adderBake + adderDropShip + adderDeTape + adderBurnIn + adderDryPack;

        }else{
            Decimal adderOfflineInkMark      = (!(Boolean)(itemWrapper.specificRfqItem.get('Offline_Ink_Mark__c'))) ? 0 : getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Offline_Ink_Mark__c', 0);            
            Decimal adderWaferBake           = (!(Boolean)(itemWrapper.specificRfqItem.get('Wafer_Bake__c'))) ? 0 : getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Wafer_Bake__c', 0);            
            Decimal adderWaferPacking        = (!(Boolean)(itemWrapper.specificRfqItem.get('Wafer_Packing__c'))) ? 0 : getDecimal(itemWrapper.specificRfqItem, 'BU_Price_Wafer_Packing__c', 0); 
            GDPW = ((itemWrapper.specificRfqItem.get('GDPW_PK__c') == null)) ? 0 : getDecimal(itemWrapper.specificRfqItem, 'GDPW_PK__c', 0);
            adderTotal = adderOfflineInkMark + adderWaferBake + adderWaferPacking;

        }

        for (sObject sobj : itemWrapper.insertionConfigurations)
        {
            calculate(sobj, runCostModel, isStripTest);
        }



        Decimal totalBuPriceMinute = totalBUPriceHour / 60;
        Decimal totalBuPriceSecond = totalBuPriceMinute / 60;





        

        

        //--- Write Post Service BU Price to field sales can see
        itemWrapper.specificRfqItem.put('BU_Post_Test_Price_Unit__c', adderTotal);

        //--- Write BU Price to field that sales can see
        Decimal salesBUPrice;
        String quoteUOM = (String)itemWrapper.specificRfqItem.get('Test_Quote_Unit_of_Measure__c');
        if (quoteUOM == '/Hr')
        {
            salesBUPrice = totalBUPriceHour;
        }
        else if (quoteUOM == '/Sec')
        {
            salesBUPrice = totalBuPriceSecond;
        }
        else if (quoteUOM == '/Min')
        {
            salesBUPrice = totalBuPriceMinute;
        }
        ////Lalit - 22-Feb-2017 : Salesforce-42 : Turnkey ATP with ultraFlex (TI)
        //Changed the condition for /Time and Unit, /Time and Wafer so that BU Test Price can be set there to 0 for Test Package Family.
        //else if (quoteUOM == '/Unit' || quoteUOM == '/Wafer')
        
        //Abhay SF-204 UAT 21 Date:19/4/17 //Commenting the changes of SF-42 as it is affecting UAT of 204 changing back to /unit and /Wafer
        //else if (quoteUOM == '/Time and Unit' || quoteUOM == '/Time and Wafer')
        else if (quoteUOM == '/Unit' || quoteUOM == '/Wafer'|| quoteUOM == '/Time and Unit')
        {
            salesBUPrice = totalBuPriceUnit;
        }
        else if (quoteUOM == '/Month')
        {
            salesBUPrice = totalBUPriceMonth;
        }


        //currently using formula fields and default drivers to calculate these, so don't need to write to object
        //@RAGHU: need a BU_Price_per_Second__c field so that the value is updated live as the cost model runs
        //so we can remove the price_per_second_fml
        itemWrapper.specificRfqItem.put('BU_Price_per_Minute__c', totalBuPriceMinute); 
        itemWrapper.specificRfqItem.put('BU_Price_per_Second__c', totalBuPriceSecond); 





        //do not overwrite prices on display results
        if (runCostModel)
        {
            itemWrapper.specificRfqItem.put('BU_Price_Per_Hour__c', totalBUPriceHour);
            itemWrapper.specificRfqItem.put('BU_Final_Test_Price_Unit__c', totalBuPriceUnit);

            itemWrapper.specificRfqItem.put('BU_Price__c', salesBUPrice);

            //Abhay N 02-May-2017 : Salesforce 204 -19F 1.1- Added below line to assign value to 'test price to customer' field on reprice item.
            itemWrapper.specificRfqItem.put('Price_To_Customer__c', salesBUPrice);
            //--- WRite other roll up summary fields to specific item
            itemWrapper.specificRfqItem.put('Tester_Value__c', totalTesterValue);
            itemWrapper.specificRfqItem.put('Handler_Value__c', totalHandlerValue);
            itemWrapper.specificRfqItem.put('BU_Cost__c', totalBUCost);
            itemWrapper.specificRfqItem.put('BU_Price_Monthly_Charge__c', totalBUPriceMonth);
        }
    }

    private void calculate(sObject sobj, Boolean overwrite, Boolean isStripTest)
    {

        Decimal buPriceUnit;
        Decimal buPriceHour = getDecimal(sobj, 'Insertion_BU_Price_Per_Hour__c', 0);

        if (overwrite)
        {
            //--- BU Price Unit calculation
            Decimal indexTime = getDecimal(sobj, 'Insertion_Index_Time__c', 0);
            Decimal sitesInParallel = getDecimal(sobj, 'Number_of_Sites_in_Parallel__c', 0);
            Decimal testTime = getDecimal(sobj, 'Insertion_Test_Time__c', 0);

            Decimal buPriceSecond = buPriceHour / 3600;

            if(isWaferProbe){
                buPriceUnit = (sitesInParallel == 0) ? 0 :  (((testTime + indexTime) / sitesInParallel) * buPriceSecond * GDPW);
            }
            else if (isStripTest) buPriceUnit = getDecimal(sobj, 'BU_Price_Per_Unit_Final__c', 0);
            else buPriceUnit = (sitesInParallel == 0) ? 0 :  ((testTime + indexTime) / sitesInParallel) * buPriceSecond;
            //--- Write back to insertion
            sobj.put('BU_Price_Per_Unit_Final__c', buPriceUnit);
            sobj.put('Insertion_BU_Price_Per_Second__c', buPriceSecond);
        }
        else
        {
            buPriceUnit = getDecimal(sobj, 'BU_Price_Per_Unit_Final__c', 0);
        }

        //--- Roll up summary fields
        totalTesterValue += getDecimal(sobj, 'Insertion_Tester_Value__c', 0);
        totalHandlerValue += getDecimal(sobj, 'Insertion_Handler_Value__c', 0);
        totalBUCost += getDecimal(sobj, 'Insertion_BU_Cost__c', 0);
        totalBUPriceHour += buPriceHour;
        totalBuPriceUnit += buPriceUnit;
        totalBUPriceMonth += getDecimal(sobj, 'Insertion_BU_Price_Monthly_Charge__c', 0);


    }

    public override void onAttributeChange(RFQItemWrapper itemWrapper, String attributeName){}
    

    public override void setEditabilityforNoCostModel(RFQILayout layout) {}

    public override Boolean isBUPriceNull(RFQItemWrapper itemWrapper)
    {
        debug.log('isBUPriceNull');
        return  itemWrapper.specificRfqItem.get('BU_Price__c') == null &&
                itemWrapper.specificRfqItem.get('BU_Price_Per_Hour__c') == null &&
                itemWrapper.specificRfqItem.get('BU_Price_per_Minute__c') == null;
    }
}