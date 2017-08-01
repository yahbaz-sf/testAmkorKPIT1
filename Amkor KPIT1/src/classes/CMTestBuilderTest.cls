/*************************************************************************
*
* PURPOSE: Test for Test Builder
*
* CLASS: CMTestBuilderTest
* CREATED: 8/7/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
@isTest
public with sharing class CMTestBuilderTest {

    //private static  testmethod void test1(){
    //  RFQItemWrapper wrapper = setUpTest(2);
        
    //  //Setup Package description
    //  setupPackage(wrapper, '/Hr');

    //  List<Map<String, Decimal>> insertionPrices = new List<Map<String, Decimal>>
    //  {
    //      new Map<String,Decimal>
    //      { 
    //          'Insertion_BU_Price_Per_Hour__c' => 1000, 
    //          'Insertion_Index_Time__c' => 3, 
    //          'Number_of_Sites_in_Parallel__c' => 4, 
    //          'Insertion_Test_Time__c' => 5, 
    //          'BU_Price_Per_Unit_Final__c' => 6, 
    //          'Insertion_Tester_Value__c' => 7, 
    //          'Insertion_Handler_Value__c' => 8, 
    //          'Insertion_BU_Cost__c' => 9
    //      },
    //      new Map<String,Decimal>
    //      { 
    //          'Insertion_BU_Price_Per_Hour__c' => 2000, 
    //          'Insertion_Index_Time__c' => 2, 
    //          'Number_of_Sites_in_Parallel__c' => 8, 
    //          'Insertion_Test_Time__c' => 8, 
    //          'BU_Price_Per_Unit_Final__c' => 9, 
    //          'Insertion_Tester_Value__c' => 10, 
    //          'Insertion_Handler_Value__c' => 11, 
    //          'Insertion_BU_Cost__c' => 12
    //      }
    //  };
        
    //  setupInsertions(wrapper, insertionPrices);

    //  DebugUtils.write('wrapper.insertionConfigurations[0].Insertion_BU_Price_Per_Hour__c', wrapper.insertionConfigurations[0].get('Insertion_BU_Price_Per_Hour__c'));
    //  DebugUtils.write('wrapper.insertionConfigurations[0].Insertion_Index_Time__c', wrapper.insertionConfigurations[0].get('Insertion_Index_Time__c'));
    //  DebugUtils.write('wrapper.insertionConfigurations[0].Number_of_Sites_in_Parallel__c', wrapper.insertionConfigurations[0].get('Number_of_Sites_in_Parallel__c'));
    //  DebugUtils.write('wrapper.insertionConfigurations[0].Insertion_Test_Time__c', wrapper.insertionConfigurations[0].get('Insertion_Test_Time__c'));
    //  DebugUtils.write('wrapper.insertionConfigurations[0].BU_Price_Per_Unit_Final__c', wrapper.insertionConfigurations[0].get('BU_Price_Per_Unit_Final__c'));
    //  DebugUtils.write('wrapper.insertionConfigurations[0].Insertion_Tester_Value__c', wrapper.insertionConfigurations[0].get('Insertion_Tester_Value__c'));
    //  DebugUtils.write('wrapper.insertionConfigurations[0].Insertion_Handler_Value__c', wrapper.insertionConfigurations[0].get('Insertion_Handler_Value__c'));
    //  DebugUtils.write('wrapper.insertionConfigurations[0].Insertion_BU_Cost__c', wrapper.insertionConfigurations[0].get('Insertion_BU_Cost__c'));

    //  //instantiate a cost model
    //  Type t = Type.forName(wrapper.productGroup.Cost_Model_Implementation__c);               
 //     CMTestBuilder TestCM = (CMTestBuilder)t.newInstance();      
 //     String rfqId = (String)wrapper.specificRfqItem.get('RFQ_Item__c');
 //     RFQItemDao.getInstance().saveLineItem(wrapper);

    //  wrapper = RFQItemDao.getInstance().getWrapperById(rfqId);
 //     Test.startTest();
 //     TestCM.calculateNew(wrapper, new CMSettings());             

 //     Decimal insertionUnit1 = DataUtils.getDecimal(wrapper.insertionConfigurations[0],'BU_Price_Per_Unit_Final__c',0);
 //     Decimal insertionUnit2 = DataUtils.getDecimal(wrapper.insertionConfigurations[1],'BU_Price_Per_Unit_Final__c',0);

    //  Decimal totalTesterValue = DataUtils.getdecimal(wrapper.specificRfqItem, 'Tester_Value__c', 0);
    //  Decimal totalHandlerValue = DataUtils.getdecimal(wrapper.specificRfqItem, 'Handler_Value__c', 0);
    //  Decimal totalBUCost = DataUtils.getdecimal(wrapper.specificRfqItem, 'BU_Cost__c', 0);
    //  Decimal totalBUPriceHour = DataUtils.getdecimal(wrapper.specificRfqItem, 'BU_Price_Per_Hour__c', 0);
    //  Decimal totalBuPriceUnit = DataUtils.getdecimal(wrapper.specificRfqItem, 'BU_Final_Test_Price_Unit__c', 0);

    //  Decimal insertionUnit1Expected = 0.5555555555;
    //  Decimal insertionUnit2Expected = 0.694444444;
    //  Decimal totalTesterValueExpected = 17;
    //  Decimal totalHandlerValueExpected = 19;
    //  Decimal totalBUCostExpected = 21;
    //  Decimal totalBUPriceHourExpected = 3000;
    //  Decimal totalBuPriceUnitExpected = 1.25;


 //     System.assert(Math.abs(insertionUnit1 - insertionUnit1Expected) < 0.00000001, 'BU Price Unit - Insertion 1: Expected ' + insertionUnit1Expected + ', recieved ' + insertionUnit1 );
 //     System.assert(Math.abs(insertionUnit2 - insertionUnit2Expected) < 0.00000001, 'BU Price Unit - Insertion 2: Expected ' + insertionUnit2Expected + ', recieved ' + insertionUnit2 );
    //  System.assert(Math.abs(totalTesterValue - totalTesterValueExpected) < 0.00000001, 'totalTesterValue - Expected ' + totalTesterValueExpected + ', recieved ' + totalTesterValue);
    //  System.assert(Math.abs(totalHandlerValue - totalHandlerValueExpected) < 0.00000001, 'totalHandlerValue - Expected ' + totalHandlerValueExpected + ', recieved ' + totalHandlerValue);
    //  System.assert(Math.abs(totalBUCost - totalBUCostExpected) < 0.00000001, 'totalBUCost - Expected ' + totalBUCostExpected + ', recieved ' + totalBUCost);
    //  System.assert(Math.abs(totalBUPriceHour - totalBUPriceHourExpected) < 0.00000001, 'totalBUPriceHour - Expected ' + totalBUPriceHourExpected + ', recieved ' + totalBUPriceHour);
    //  System.assert(Math.abs(totalBuPriceUnit - totalBuPriceUnitExpected) < 0.00000001, 'totalBuPriceUnit - Expected ' + totalBuPriceUnitExpected + ', recieved ' + totalBuPriceUnit);
    //  Test.stopTest();        
    //}

    //private static  testmethod void test2(){
    //  RFQItemWrapper wrapper = setUpTest(0);
        
    //  //Setup Package description
    //  setupPackage(wrapper, '/Hr');

    //  setupAdders(wrapper);

    //  //instantiate a cost model
    //  Type t = Type.forName(wrapper.productGroup.Cost_Model_Implementation__c);               
 //     CMTestBuilder TestCM = (CMTestBuilder)t.newInstance();      
 //     String rfqId = (String)wrapper.specificRfqItem.get('RFQ_Item__c');
 //     RFQItemDao.getInstance().saveLineItem(wrapper);

    //  wrapper = RFQItemDao.getInstance().getWrapperById(rfqId);
 //     Test.startTest();
 //     TestCM.calculateNew(wrapper, new CMSettings());             

 //     Decimal adderTotal = DataUtils.getDecimal(wrapper.specificRfqItem, 'BU_Post_Test_Price_Unit__c', 0);
 //     Decimal adderTotalExpected = 2500;

 //     System.assert(adderTotal == adderTotalExpected, 'adderTotal - Expected ' + adderTotalExpected + ', recieved ' + adderTotal);
    //  Test.stopTest();        
    //}

    public static testmethod void testVolume()
    {
        RFQItemWrapper wrapper = setupTestNew();
        wrapper.insertionConfigurations.addAll(RFQItemDao.createInsertionObject(wrapper.packageFamily, wrapper.specificRfqItem.Id, 2));
        System.assertEquals(wrapper.insertionConfigurations.size(), 2);
        Integer count = 1;
        for (sObject ins : wrapper.insertionConfigurations)
        {
            ins.put('Insertion_Test_Time__c',               1  * count);
            ins.put('Number_of_Sites_in_Parallel__c',       2  * count);
            ins.put('Insertion_Index_Time__c',              3  * count);
            ins.put('Insertion_Tester_Value__c',            4  * count);
            ins.put('Insertion_Handler_Value__c',           5  * count);
            ins.put('Insertion_BU_Cost__c',                 6  * count);
            ins.put('Insertion_BU_Price_Per_Hour__c',       7  * count);
            ins.put('Insertion_BU_Price_Per_Second__c',     8  * count);
            ins.put('BU_Price_Per_Unit_Final__c',           9  * count);
            ins.put('Insertion_BU_Price_Monthly_Charge__c', 10 * count);
            count++;
        }
        System.assertEquals(3, count);

        wrapper.volumeList.add(new RFQIVolume(false));
        wrapper.volumeList[0].index = 1;

        wrapper.packageFamily.Copy_Fields_To_multivolume__c = true;

        CMTestBuilder builder = new CMTestBuilder();
        builder.calcMulti(wrapper, CMBuilder.getHasSubstrate(wrapper));

        count = 1;
        for (RFQIVolume.RFQITestInsertion volIns : wrapper.volumeList[0].testInsertions)
        {
            System.assertEquals(volIns.buPriceHour,     7  * count);
            System.assertEquals(volIns.buPriceSecond,   8  * count);
            System.assertEquals(volIns.buPriceUnit,     9  * count);
            System.assertEquals(volIns.buPriceMonthly,  10 * count);
            count++;
        }
        System.assertEquals(3, count);

        RFQIVolume.RFQITestInsertion testTotal = wrapper.volumeList[0].testInsertionsTotals;
        System.assertEquals(testTotal.buPriceHour,      21);
        System.assertEquals(testTotal.buPriceSecond,    24);
        System.assertEquals(testTotal.buPriceUnit,      27);
        System.assertEquals(testTotal.buPriceMonthly,   30);

        wrapper.specificRfqItem.put('Test_Quote_Unit_of_Measure__c', '/Hr');
        builder.calcMulti(wrapper, CMBuilder.getHasSubstrate(wrapper));
        System.assert(wrapper.volumeList[0].price == wrapper.volumeList[0].testInsertionsTotals.buPriceHour);

        wrapper.specificRfqItem.put('Test_Quote_Unit_of_Measure__c', '/Sec');
        builder.calcMulti(wrapper, CMBuilder.getHasSubstrate(wrapper));
        System.assert(wrapper.volumeList[0].price == wrapper.volumeList[0].testInsertionsTotals.buPriceSecond);

        wrapper.specificRfqItem.put('Test_Quote_Unit_of_Measure__c', '/Min');
        builder.calcMulti(wrapper, CMBuilder.getHasSubstrate(wrapper));
        System.assert(wrapper.volumeList[0].price == wrapper.volumeList[0].testInsertionsTotals.buPriceMinute);

        wrapper.specificRfqItem.put('Test_Quote_Unit_of_Measure__c', '/Unit');
        builder.calcMulti(wrapper, CMBuilder.getHasSubstrate(wrapper));
        System.assert(wrapper.volumeList[0].price == wrapper.volumeList[0].testInsertionsTotals.buPriceUnit);

        wrapper.specificRfqItem.put('Test_Quote_Unit_of_Measure__c', '/Month');
        builder.calcMulti(wrapper, CMBuilder.getHasSubstrate(wrapper));
        System.assert(wrapper.volumeList[0].price == wrapper.volumeList[0].testInsertionsTotals.buPriceMonthly);
        
        
        //18/July/2016 Increasing Code Coverage
        builder.loadSettings(wrapper, True);
        builder.calculateNew(wrapper, new CMSettings());// need to pass CMSettings pSettings
        builder.calculateAll(wrapper, True, new CMSettings());// need to pass CMSettings pSettings
        builder.displayResults(wrapper, True);
        builder.costModelTestMapInstall();
        builder.calcResults(wrapper, True);
        builder.isBUPriceNull(wrapper);
        //Bhanu 18/July/2016 Increasing Code Coverage ends
    }

    static private RFQItemWrapper setUpTest(Integer numInsertions){
        
        RFQAdminInstaller.install();
        RFQAdminInstaller.installFactories();
        RFQAdminInstaller.installAccounts();
        
        ServiceInstaller.install();
        ServiceInstaller.incrementalInstall1();

        Product_Group__c pg = [select Id from Product_Group__c where Name =:'Standalone Services'];
        insert  new Package_Family__c(Name = 'Final Test2', Default_Number_Of_Insertions__c = 1, Product_Group__c = pg.Id, Specific_Insertion_Configuration_Object__c = 'RFQIIC_TESTS__c', Specific_RFQ_Item_Object__c = 'RFQI_TESTS__c', Cost_Model_Implementation__c = 'CMTestBuilder');
        //get wrapper
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('Final Test2', 0, 0, numInsertions, 0);

        //RFQItemDao.createInsertionObject(wrapper.packageFamily, wrapper.specificRfqItem.Id,1);
  //      BaseDao packageFamilyWireDao = new BaseDao(wrapper.packageFamily.Specific_Insertion_Configuration_Object__c);
  //      wrapper.insertionConfigurations = packageFamilyWireDao.getSObjects('Parent__c = ' + BaseDao.quote(wrapper.specificRfqItem.Id), 'CreatedDate');
        
                
        return wrapper;
    }

    private static RFQItemWrapper setupTestNew()
    {
        Product_Group__c pg = SharedUnitTestUtils.createProductGroupFromName('Standalone Services', false);
        insert pg;

        Package_Family__c pf = SharedUnitTestUtils.createPackageFamilyFromName('Test', pg, 'RFQI_TESTS__c');
        pf.Specific_Insertion_Configuration_Object__c = 'RFQIIC_TESTS__c';
        pf.Has_Substrate__c = false;

        insert pf;

        return SharedUnitTestUtils.createLineItem(pf.Name);
    }

    static private void setupQuoteInformation(RFQItemWrapper wrapper, String Forecast){
        wrapper.setAttribute('Forecast__c', 'Package', Forecast);
    }

    static private void setupPackage(RFQItemWrapper wrapper, String quoteUOM){
        
            
    }

    static private void setupInsertions(RFQItemWrapper wrapper, List<Map<String, Decimal>> insertionPrices)
    {
        DebugUtils.write('wrapper.insertionConfigurations.size()', wrapper.insertionConfigurations.size());
        DebugUtils.write('insertionPrices.size()', insertionPrices.size());
        for (Integer i = 0; i < wrapper.insertionConfigurations.size(); i++)
        {
            DebugUtils.write('i', i);
            for (String key : insertionPrices[i].keySet())
            {
                wrapper.insertionConfigurations[i].put(key, insertionPrices[i].get(key));
            }
        }
    }

    private static void setupAdders(RFQItemWrapper wrapper)
    {
        wrapper.specificRfqItem.put('Scan__c', true);
        wrapper.specificRfqItem.put('Tape_and_Reel__c', false);
        wrapper.specificRfqItem.put('Ink_Mark__c', true);
        wrapper.specificRfqItem.put('Laser_Mark__c', false);
        wrapper.specificRfqItem.put('Other__c', true);
        wrapper.specificRfqItem.put('Packing_Method__c', null);
        wrapper.specificRfqItem.put('Bake__c', true);
        wrapper.specificRfqItem.put('Drop_Ship__c', false);
        wrapper.specificRfqItem.put('De_Tape__c', true);
        wrapper.specificRfqItem.put('Burn_In__c', false);

        wrapper.specificRfqItem.put('BU_Price_Lead_Scan__c', 100);
        wrapper.specificRfqItem.put('BU_Price_Tape_and_Reel__c', 200);
        wrapper.specificRfqItem.put('BU_Price_Ink_Mark__c', 300);
        wrapper.specificRfqItem.put('BU_Price_Laser_Mark__c', 400);
        wrapper.specificRfqItem.put('BU_Price_Other__c', 500);
        wrapper.specificRfqItem.put('BU_Price_Pack__c', 600);
        wrapper.specificRfqItem.put('BU_Price_Bake__c', 700);
        wrapper.specificRfqItem.put('BU_Price_Drop_Ship__c', 800);
        wrapper.specificRfqItem.put('BU_Price_De_Tape__c', 900);
        wrapper.specificRfqItem.put('BU_Price_Burn_In__c', 1000);
        
    }

    private static RFQILayout setupLayout(RFQItemWrapper wrapper)
    {
        RFQILayout layout = PFFieldDefDao.getInstance().getPackageFamilyLayout(wrapper.packageFamily.Id, wrapper.packageFamily.Layout_Version__c, (Decimal)wrapper.rfqItem.get('Layout_Version__c'));

        //Loop over OtherAttributes, check if they contain other
        //if they do, add attribute 
        for(String fieldName : layout.getOtherFieldApiNames()) { 
            String fieldValue = String.valueOf(wrapper.getAttribute(fieldName, RFQItemWrapper.PACKAGE_OBJECT, 0));
            if(fieldValue != null && fieldValue.toLowerCase() == 'other') {
                layout.addAttributeForOtherField(fieldName);
            }
        }

        Decimal salesScreenColumns = wrapper.packageFamily.Product_Group__r.Sales_Screen_Columns__c;
        Decimal buScreenColumns = wrapper.packageFamily.Product_Group__r.BU_Screen_Columns__c;
        layout.setBUColumns(Integer.valueOf(bUScreenColumns));
        layout.setSalesColumns(Integer.valueOf(salesScreenColumns));

        wrapper.calculateAttributeVisibility(layout);
        return layout;
    }


}