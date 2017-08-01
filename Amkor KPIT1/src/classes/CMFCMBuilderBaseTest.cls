/*************************************************************************
* 
* PURPOSE:  This is a Test Class for the CMPBGABUilder class
            
*         
* CLASS: CMPBGABuilderTest
* CREATED: 06/05/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Chia Yuan Chuang
* 
**************************************************************************/

@isTest

private class CMFCMBuilderBaseTest {
    
    //test Bomcalc, and ProcessCalc
    //To Do: markup or margin

    private static  testmethod void testDualLeadframe1(){       
        RFQItemWrapper wrapper = setupTest1();

        //instantiate a cost model
        Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Cost_Model_Implementation__c);             
        CMFCMBuilderBase DualLeadframeCM = (CMFCMBuilderBase)t.newInstance();       
        
        
        Test.startTest();
        DualLeadframeCM.calculateNew(wrapper, new CMSettings());

        //Test CLAM detail
        Decimal Total_Cost_Per_Unit_Expected    = 0.00427;
        Decimal Manufacturing_Overhead_Expected = 0.00238;
        Decimal QA_Cost_Expected                = 0.00024;  
        Decimal Service_Group_Cost_Expected     = 0.00028;   
    
        Decimal Total_Cost_Per_Unit    = DualLeadframeCM.itemFcm.Total_Cost_Per_Unit__c;   
        Decimal Manufacturing_Overhead = DualLeadframeCM.itemFcm.Manufacturing_Overhead__c;  
        Decimal QA_Cost                = DualLeadframeCM.itemFcm.QA_Cost__c;   
        Decimal Service_Group_Cost     = DualLeadframeCM.itemFcm.Service_Group_Cost__c;
        
        System.assert(Manufacturing_Overhead.setScale(5)== Manufacturing_Overhead_Expected, 'Manufacturing_Overhead failed! '   + 'calculated value is ' + Manufacturing_Overhead.setScale(5));
        System.assert(QA_Cost.setScale(5)               == QA_Cost_Expected,                'QA_Cost failed! '                  + 'calculated value is ' + QA_Cost.setScale(5));
        System.assert(Service_Group_Cost.setScale(5)    == Service_Group_Cost_Expected,     'Service_Group_Cost failed! '       + 'calculated value is ' + Service_Group_Cost.setScale(5));  

        Decimal Total_Material_Cost_Expected = 0.01053;
        Total_Cost_Per_Unit_Expected = 0.00427;
        Decimal Total_Cost_of_Goods_Expected = 0.01771;

        //prcess calc
        Total_Cost_Per_Unit = DualLeadframeCM.itemFcm.Total_Cost_Per_Unit__c;
        System.assert(Math.abs(Total_Cost_Per_Unit - Total_Cost_Per_Unit_Expected) < 0.00001,   'Total_Cost_Per_Unit failed! '      + 'calculated value is ' + Total_Cost_Per_Unit.setScale(5));
        
        //Bom calc

        Decimal Total_Material_Cost = DualLeadframeCM.itemFcm.Total_Material_Cost__c;
        System.assert(Math.abs(Total_Material_Cost - Total_Material_Cost_Expected) < 0.00001, 'Total Material failed! ' + 'calculated value is ' + Total_Material_Cost.setScale(5));
                
        
        //test total cost of goods
        Decimal Total_Cost_of_Goods = DualLeadframeCM.itemFcm.Total_Cost_of_Goods__c;       
        System.assert(Math.abs(Total_Cost_of_Goods - Total_Cost_of_Goods_Expected) < 0.00001, 'Total Cost of Goods failed! ' + ' calulated value is ' + Total_Cost_of_Goods.setScale(5));
        Test.stopTest();        
    }   
    
    
    
    private static  testmethod void testDualLeadframe4(){
        
        Decimal Total_Material_Cost_Expected = 0.02030;
        Decimal Total_Cost_Per_Unit_Expected = 0.00530;
        Decimal Total_Cost_of_Goods_Expected = 0.02920;
         
        
        RFQItemWrapper wrapper = setUpDualLeadframe();
        
        //To Do: Check Customer Name. In Excel Sheet, cost of dual leaf frame depends on customers
        
        //setup Quote information
        setupQuoteInoformation(wrapper, '1,000 - 5,000');
        //Setup Package description
        setupPackage(wrapper, null, 'TL-PPF', '8ld', 'Stamped', 'Standard', null);
        //Setup wire
        setupWire(wrapper, 'Au', '1.0', 16.0, 18, 0.0);
        //Setup die
    
        //Die_Attach, List<String> Wafer_Singulation, List<Boolean> Wafer_Backgrind){   
        List<String> Die_Attach = new List<String>();
        List<String> Wafer_Singulation = new List<String>();
        List<Boolean> Wafer_Backgrind = new List<Boolean>();
        
        Die_Attach.add('Silver Filled Epoxy');
        Wafer_Singulation.add('Saw');
        Wafer_Backgrind.add(false);
        setupDie(wrapper, 1, Die_Attach, Wafer_Singulation, Wafer_Backgrind);
        
        //instantiate a wire calculator
        Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Wire_Calculation_Implementation__c);       
        CMWireCalcBase wireCalculator = (CMWireCalcBase)t.newInstance();
        wireCalculator.calculate(wrapper);
        
        //instantiate a cost model
        t = Type.forName(wrapper.packageFamily.Product_Group__r.Cost_Model_Implementation__c);              
        CMFCMBuilderBase DualLeadframeCM = (CMFCMBuilderBase)t.newInstance();       
                
        Test.startTest();
        DualLeadframeCM.calculateNew(wrapper, new CMSettings());                
        //prcess calc
        Decimal Total_Cost_Per_Unit = DualLeadframeCM.itemFcm.Total_Cost_Per_Unit__c;
        System.assert(Math.abs(Total_Cost_Per_Unit - Total_Cost_Per_Unit_Expected) < 0.00001,   'Total_Cost_Per_Unit failed! '      + 'calculated value is ' + Total_Cost_Per_Unit.setScale(5));
        
        //Bom calc
        Decimal Total_Material_Cost = DualLeadframeCM.itemFcm.Total_Material_Cost__c;       
        System.assert(Math.abs(Total_Material_Cost - Total_Material_Cost_Expected) < 0.00001, 'Total Material failed! ' + 'calculated value is ' + Total_Material_Cost.setScale(5));
                
        
        //test total cost
        Decimal Total_Cost_of_Goods = DualLeadframeCM.itemFcm.Total_Cost_of_Goods__c;       
        System.assert(Math.abs(Total_Cost_of_Goods - Total_Cost_of_Goods_Expected) < 0.00001, 'Total Cost of Goods failed! ' + ' calulated value is ' + Total_Cost_of_Goods.setScale(5));
        System.assert(true);
        Test.stopTest();        
    }
    
    
    private static  testmethod void testDualLeadframe5(){
        
        Decimal Total_Material_Cost_Expected = 0.00858;
        Decimal Total_Cost_Per_Unit_Expected = 0.00545;
        Decimal Total_Cost_of_Goods_Expected = 0.01774;
         
        
        RFQItemWrapper wrapper = setUpDualLeadframe();
        
        //To Do: Check Customer Name. In Excel Sheet, cost of dual leaf frame depends on customers
        
        //setup Quote information
        setupQuoteInoformation(wrapper, '1,000 - 5,000');
        //Setup Package description
        setupPackage(wrapper, null, 'TL-PPF', '8ld', 'Stamped', 'Standard', null);
        //Setup wire
        setupWire(wrapper, 'Cu', '1.0', 16.0, 18, 0.0);
        //Setup die
    
        //Die_Attach, List<String> Wafer_Singulation, List<Boolean> Wafer_Backgrind){   
        List<String> Die_Attach = new List<String>();
        List<String> Wafer_Singulation = new List<String>();
        List<Boolean> Wafer_Backgrind = new List<Boolean>();
        
        Die_Attach.add('Silver Filled Epoxy');
        Wafer_Singulation.add('Saw');
        Wafer_Backgrind.add(false);
        setupDie(wrapper, 1, Die_Attach, Wafer_Singulation, Wafer_Backgrind);
        
        //instantiate a wire calculator
        Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Wire_Calculation_Implementation__c);       
        CMWireCalcBase wireCalculator = (CMWireCalcBase)t.newInstance();
        wireCalculator.calculate(wrapper);
        
        //instantiate a cost model
        t = Type.forName(wrapper.packageFamily.Product_Group__r.Cost_Model_Implementation__c);              
        CMFCMBuilderBase DualLeadframeCM = (CMFCMBuilderBase)t.newInstance();       
        
        
        Test.startTest();
        DualLeadframeCM.calculateNew(wrapper, new CMSettings());                
        //prcess calc
        Decimal Total_Cost_Per_Unit = DualLeadframeCM.itemFcm.Total_Cost_Per_Unit__c;
        System.assert(Math.abs(Total_Cost_Per_Unit - Total_Cost_Per_Unit_Expected) < 0.00001,   'Total_Cost_Per_Unit failed! '      + 'calculated value is ' + Total_Cost_Per_Unit.setScale(5));
        
        //Bom calc
        Decimal Total_Material_Cost = DualLeadframeCM.itemFcm.Total_Material_Cost__c;       
        System.assert(Math.abs(Total_Material_Cost - Total_Material_Cost_Expected) < 0.00001, 'Total Material failed! ' + 'calculated value is ' + Total_Material_Cost.setScale(5));
                
        
        //test total cost
        Decimal Total_Cost_of_Goods = DualLeadframeCM.itemFcm.Total_Cost_of_Goods__c;       
        System.assert(Math.abs(Total_Cost_of_Goods - Total_Cost_of_Goods_Expected) < 0.00001, 'Total Cost of Goods failed! ' + ' calulated value is ' + Total_Cost_of_Goods.setScale(5));
        System.assert(true);
        Test.stopTest();        
    }
    
    
    private static  testmethod void testDualLeadframe6(){
        
        Decimal Total_Material_Cost_Expected = 0.00948;
        Decimal Total_Cost_Per_Unit_Expected = 0.00545;
        Decimal Total_Cost_of_Goods_Expected = 0.01865;
         
        
        RFQItemWrapper wrapper = setUpDualLeadframe();
        
        //To Do: Check Customer Name. In Excel Sheet, cost of dual leaf frame depends on customers
        
        //setup Quote information
        setupQuoteInoformation(wrapper, '1,000 - 5,000');
        //Setup Package description
        setupPackage(wrapper, null, 'TL-PPF', '8ld', 'Stamped', 'Standard', null);
        //Setup wire
        //Lalit SF-85.
        setupWire(wrapper, 'AuPCC', '1.0', 16.0, 18, 0.0);
        //Setup die
    
        //Die_Attach, List<String> Wafer_Singulation, List<Boolean> Wafer_Backgrind){   
        List<String> Die_Attach = new List<String>();
        List<String> Wafer_Singulation = new List<String>();
        List<Boolean> Wafer_Backgrind = new List<Boolean>();
        
        Die_Attach.add('Silver Filled Epoxy');
        Wafer_Singulation.add('Saw');
        Wafer_Backgrind.add(false);
        setupDie(wrapper, 1, Die_Attach, Wafer_Singulation, Wafer_Backgrind);
        
        //instantiate a wire calculator
        Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Wire_Calculation_Implementation__c);       
        CMWireCalcBase wireCalculator = (CMWireCalcBase)t.newInstance();
        wireCalculator.calculate(wrapper);
        
        //instantiate a cost model
        t = Type.forName(wrapper.packageFamily.Product_Group__r.Cost_Model_Implementation__c);              
        CMFCMBuilderBase DualLeadframeCM = (CMFCMBuilderBase)t.newInstance();       
        
        
        Test.startTest();
        DualLeadframeCM.calculateNew(wrapper, new CMSettings());                
        //prcess calc
        Decimal Total_Cost_Per_Unit = DualLeadframeCM.itemFcm.Total_Cost_Per_Unit__c;
        System.assert(Math.abs(Total_Cost_Per_Unit - Total_Cost_Per_Unit_Expected) < 0.00001,   'Total_Cost_Per_Unit failed! '      + 'calculated value is ' + Total_Cost_Per_Unit.setScale(5));
        
        //Bom calc
        Decimal Total_Material_Cost = DualLeadframeCM.itemFcm.Total_Material_Cost__c;       
        System.assert(Math.abs(Total_Material_Cost - Total_Material_Cost_Expected) < 0.00001, 'Total Material failed! ' + 'calculated value is ' + Total_Material_Cost.setScale(5));
                
        
        //test total cost
        Decimal Total_Cost_of_Goods = DualLeadframeCM.itemFcm.Total_Cost_of_Goods__c;       
        System.assert(Math.abs(Total_Cost_of_Goods - Total_Cost_of_Goods_Expected) < 0.00001, 'Total Cost of Goods failed! ' + ' calulated value is ' + Total_Cost_of_Goods.setScale(5));
        System.assert(true);
        Test.stopTest();        
    }
    private static  testmethod void testDualLeadframe1Edit(){
         
        RFQItemWrapper wrapper = setupTest1();  
        //instantiate a cost model
        Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Cost_Model_Implementation__c);             
        CMFCMBuilderBase DualLeadframeCM = (CMFCMBuilderBase)t.newInstance();
        
        Test.startTest();
        //Run the calcualtions to get numbers in the fields
        DualLeadframeCM.calculateNew(wrapper, new CMSettings());

        //This should not change the values in the fields
        wrapper.packageFamily.No_Cost_Model__c = true;
        DualLeadframeCM.calculateNew(wrapper, new CMSettings());

        Decimal Total_Material_Cost_Expected = 0.01053;
        Decimal Total_Cost_Per_Unit_Expected = 0.00427;
        Decimal Total_Cost_of_Goods_Expected = 0.01771;

        //prcess calc
        Decimal Total_Cost_Per_Unit = DualLeadframeCM.itemFcm.Total_Cost_Per_Unit__c;
        System.assert(Math.abs(Total_Cost_Per_Unit - Total_Cost_Per_Unit_Expected) < 0.00001,   'Total_Cost_Per_Unit failed! '      + 'calculated value is ' + Total_Cost_Per_Unit.setScale(5));
        
        //Bom calc

        Decimal Total_Material_Cost = DualLeadframeCM.itemFcm.Total_Material_Cost__c;
        System.assert(Math.abs(Total_Material_Cost - Total_Material_Cost_Expected) < 0.00001, 'Total Material failed! ' + 'calculated value is ' + Total_Material_Cost.setScale(5));
                
        
        //test total cost of goods
        Decimal Total_Cost_of_Goods = DualLeadframeCM.itemFcm.Total_Cost_of_Goods__c;       
        System.assert(Math.abs(Total_Cost_of_Goods - Total_Cost_of_Goods_Expected) < 0.00001, 'Total Cost of Goods failed! ' + ' calulated value is ' + Total_Cost_of_Goods.setScale(5));
        Test.stopTest();

    }

    private static  testmethod void testDualLeadframe1Recalc(){
         
        RFQItemWrapper wrapper = setupTest1();  
        //instantiate a cost model
        Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Cost_Model_Implementation__c);             
        CMFCMBuilderBase DualLeadframeCM = (CMFCMBuilderBase)t.newInstance();
        
        Test.startTest();
        //Run the calcualtions to get numbers in the fields
        DualLeadframeCM.calculateNew(wrapper, new CMSettings());

        //This should not change the values in the fields
        wrapper.packageFamily.No_Cost_Model__c = true;
        DualLeadframeCM.calculateAll(wrapper, true, new CMSettings());

        Decimal Total_Material_Cost_Expected = 0.01053;
        Decimal Total_Cost_Per_Unit_Expected = 0.00427;
        Decimal Total_Cost_of_Goods_Expected = 0.01771;

        //prcess calc
        Decimal Total_Cost_Per_Unit = DualLeadframeCM.itemFcm.Total_Cost_Per_Unit__c;
        System.assert(Math.abs(Total_Cost_Per_Unit - Total_Cost_Per_Unit_Expected) < 0.00001,   'Total_Cost_Per_Unit failed! '      + 'calculated value is ' + Total_Cost_Per_Unit.setScale(5));
        
        //Bom calc

        Decimal Total_Material_Cost = DualLeadframeCM.itemFcm.Total_Material_Cost__c;
        System.assert(Math.abs(Total_Material_Cost - Total_Material_Cost_Expected) < 0.00001, 'Total Material failed! ' + 'calculated value is ' + Total_Material_Cost.setScale(5));
                
        
        //test total cost of goods
        Decimal Total_Cost_of_Goods = DualLeadframeCM.itemFcm.Total_Cost_of_Goods__c;       
        System.assert(Math.abs(Total_Cost_of_Goods - Total_Cost_of_Goods_Expected) < 0.00001, 'Total Cost of Goods failed! ' + ' calulated value is ' + Total_Cost_of_Goods.setScale(5));
        Test.stopTest();

    }
    private static  testmethod void testDualLeadframe1RecalcCostModel(){
         
        RFQItemWrapper wrapper = setupTest1();  
        //instantiate a cost model
        Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Cost_Model_Implementation__c);             
        CMFCMBuilderBase DualLeadframeCM = (CMFCMBuilderBase)t.newInstance();
        
        Test.startTest();
        //Run the calcualtions to get numbers in the fields
        DualLeadframeCM.calculateNew(wrapper, new CMSettings());

        //This should not change the values in the fields
        DualLeadframeCM.calculateAll(wrapper, true, new CMSettings());

        Decimal Total_Material_Cost_Expected = 0.01053;
        Decimal Total_Cost_Per_Unit_Expected = 0.00427;
        Decimal Total_Cost_of_Goods_Expected = 0.01771;

        //prcess calc
        Decimal Total_Cost_Per_Unit = DualLeadframeCM.itemFcm.Total_Cost_Per_Unit__c;
        System.assert(Math.abs(Total_Cost_Per_Unit - Total_Cost_Per_Unit_Expected) < 0.00001,   'Total_Cost_Per_Unit failed! '      + 'calculated value is ' + Total_Cost_Per_Unit.setScale(5));
        
        //Bom calc

        Decimal Total_Material_Cost = DualLeadframeCM.itemFcm.Total_Material_Cost__c;
        System.assert(Math.abs(Total_Material_Cost - Total_Material_Cost_Expected) < 0.00001, 'Total Material failed! ' + 'calculated value is ' + Total_Material_Cost.setScale(5));
                
        
        //test total cost of goods
        Decimal Total_Cost_of_Goods = DualLeadframeCM.itemFcm.Total_Cost_of_Goods__c;       
        System.assert(Math.abs(Total_Cost_of_Goods - Total_Cost_of_Goods_Expected) < 0.00001, 'Total Cost of Goods failed! ' + ' calulated value is ' + Total_Cost_of_Goods.setScale(5));
        Test.stopTest();

    }

    private static  testmethod void testDualLeadframe1Display(){
         
        RFQItemWrapper wrapper = setupTest1();  
        //instantiate a cost model
        Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Cost_Model_Implementation__c);             
        CMFCMBuilderBase DualLeadframeCM = (CMFCMBuilderBase)t.newInstance();
        
        Test.startTest();
        //Run the calcualtions to get numbers in the fields
        DualLeadframeCM.calculateNew(wrapper, new CMSettings());

        //This should not change the values in the fields
        DualLeadframeCM.displayResults(wrapper, true);

        Decimal Total_Material_Cost_Expected = 0.01053;
        Decimal Total_Cost_Per_Unit_Expected = 0.00427;
        Decimal Total_Cost_of_Goods_Expected = 0.01771;

        //prcess calc
        Decimal Total_Cost_Per_Unit = DualLeadframeCM.itemFcm.Total_Cost_Per_Unit__c;
        System.assert(Math.abs(Total_Cost_Per_Unit - Total_Cost_Per_Unit_Expected) < 0.00001,   'Total_Cost_Per_Unit failed! '      + 'calculated value is ' + Total_Cost_Per_Unit.setScale(5));
        
        //Bom calc

        Decimal Total_Material_Cost = DualLeadframeCM.itemFcm.Total_Material_Cost__c;
        System.assert(Math.abs(Total_Material_Cost - Total_Material_Cost_Expected) < 0.00001, 'Total Material failed! ' + 'calculated value is ' + Total_Material_Cost.setScale(5));
                
        
        //test total cost of goods
        Decimal Total_Cost_of_Goods = DualLeadframeCM.itemFcm.Total_Cost_of_Goods__c;       
        System.assert(Math.abs(Total_Cost_of_Goods - Total_Cost_of_Goods_Expected) < 0.00001, 'Total Cost of Goods failed! ' + ' calulated value is ' + Total_Cost_of_Goods.setScale(5));
        Test.stopTest();

    }

    private static  testmethod void testDualLeadframe1BUChange(){
         
        RFQItemWrapper wrapper = setupTest1();  
        //instantiate a cost model
        Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Cost_Model_Implementation__c);             
        CMFCMBuilderBase DualLeadframeCM = (CMFCMBuilderBase)t.newInstance();
        
        wrapper.setAttribute('Sales_Target_Price__c', RFQItemWrapper.PACKAGE_OBJECT, 0.018);
        wrapper.setAttribute('BU_Price_Perc_GM__c', RFQItemWrapper.PACKAGE_OBJECT, 40);
        Test.startTest();
        //Run the calcualtions to get numbers in the fields
        DualLeadframeCM.calculateNew(wrapper, new CMSettings());

        Decimal Total_Material_Cost_Expected = 0.01053;
        Decimal Total_Cost_Per_Unit_Expected = 0.00427;
        Decimal Total_Cost_of_Goods_Expected = 0.01771;
        Decimal buPriceExpected = 0.01771;

        //prcess calc
        Decimal Total_Cost_Per_Unit = DualLeadframeCM.itemFcm.Total_Cost_Per_Unit__c;
        System.assert(Math.abs(Total_Cost_Per_Unit - Total_Cost_Per_Unit_Expected) < 0.00001,   'Total_Cost_Per_Unit failed! '      + 'calculated value is ' + Total_Cost_Per_Unit.setScale(5));
        
        //Bom calc
        Decimal Total_Material_Cost = DualLeadframeCM.itemFcm.Total_Material_Cost__c;
        System.assert(Math.abs(Total_Material_Cost - Total_Material_Cost_Expected) < 0.00001, 'Total Material failed! ' + 'calculated value is ' + Total_Material_Cost.setScale(5));
                
        //test total cost of goods
        Decimal Total_Cost_of_Goods = DualLeadframeCM.itemFcm.Total_Cost_of_Goods__c;       
        System.assert(Math.abs(Total_Cost_of_Goods - Total_Cost_of_Goods_Expected) < 0.00001, 'Total Cost of Goods failed! ' + ' calulated value is ' + Total_Cost_of_Goods.setScale(5));

        Decimal buPrice = (Decimal) wrapper.specificRfqItem.get('BU_Price__c');
        System.assert(Math.abs(buPrice - buPriceExpected) < 0.00001, 'BU Price failed! ' + ' calulated value is ' + buPrice.setScale(5));

        wrapper.setAttribute('BU_Price__c', RFQItemWrapper.PACKAGE_OBJECT, 0.02);
        DualLeadframeCM.onBUPriceChanged(wrapper);

        Decimal marginExpected = 11.46296331;
        Decimal deltaExpected = 11.111111;

        Decimal margin = (Decimal)wrapper.specificRfqItem.get('BU_Price_Perc_GM__c');
        Decimal delta = (Decimal) wrapper.specificRfqItem.get('BU_Price_Perc_Delta_To_Target__c');

        System.assert(Math.abs(margin - marginExpected) < 0.00001, 'Margin failed! ' + ' calulated value is ' + margin.setScale(5));
        System.assert(Math.abs(delta - deltaExpected) < 0.00001, 'Delta failed! ' + ' calulated value is ' + delta.setScale(5));

        Test.stopTest();

    }

    private static  testmethod void testDualLeadframe1DeltaChange(){
         
        RFQItemWrapper wrapper = setupTest1();  
        //instantiate a cost model
        Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Cost_Model_Implementation__c);             
        CMFCMBuilderBase DualLeadframeCM = (CMFCMBuilderBase)t.newInstance();
        
        wrapper.setAttribute('Sales_Target_Price__c', RFQItemWrapper.PACKAGE_OBJECT, 0.018);
        wrapper.setAttribute('BU_Price_Perc_GM__c', RFQItemWrapper.PACKAGE_OBJECT, 40);
        Test.startTest();
        //Run the calcualtions to get numbers in the fields
        DualLeadframeCM.calculateNew(wrapper, new CMSettings());

        wrapper.setAttribute('BU_Price_Perc_Delta_To_Target__c', RFQItemWrapper.PACKAGE_OBJECT, 11.11111);
        DualLeadframeCM.onBUPricePercDeltaToTargetChanged(wrapper);

        Decimal marginExpected = 11.46296331;
        Decimal buPriceExpected = 0.02;

        Decimal buPrice = (Decimal)wrapper.specificRfqItem.get('BU_Price__c');
        Decimal margin = (Decimal) wrapper.specificRfqItem.get('BU_Price_Perc_GM__c');

        System.assert(Math.abs(margin - marginExpected) < 0.00001, 'Margin failed! ' + ' calulated value is ' + margin.setScale(5));
        System.assert(Math.abs(buPrice - buPriceExpected) < 0.00001, 'Delta failed! ' + ' calulated value is ' + buPrice.setScale(5));

        Test.stopTest();

    }

    private static  testmethod void testDualLeadframe1MarrginChange(){
         
        RFQItemWrapper wrapper = setupTest1();  
        //instantiate a cost model
        Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Cost_Model_Implementation__c);             
        CMFCMBuilderBase DualLeadframeCM = (CMFCMBuilderBase)t.newInstance();
        
        wrapper.setAttribute('Sales_Target_Price__c', RFQItemWrapper.PACKAGE_OBJECT, 0.018);
        wrapper.setAttribute('BU_Price_Perc_GM__c', RFQItemWrapper.PACKAGE_OBJECT, 40);
        Test.startTest();
        //Run the calcualtions to get numbers in the fields
        DualLeadframeCM.calculateNew(wrapper, new CMSettings());

        wrapper.setAttribute('BU_Price_Perc_GM__c', RFQItemWrapper.PACKAGE_OBJECT, 11.46296331);
        DualLeadframeCM.onBUPricePercGMChanged(wrapper);

        Decimal deltaExpected = 11.11111;
        Decimal buPriceExpected = 0.02;

        Decimal buPrice = (Decimal)wrapper.specificRfqItem.get('BU_Price__c');
        Decimal delta = (Decimal) wrapper.specificRfqItem.get('BU_Price_Perc_Delta_To_Target__c');

        System.assert(Math.abs(delta - deltaExpected) < 0.00001, 'Margin failed! ' + ' calulated value is ' + delta.setScale(5));
        System.assert(Math.abs(buPrice - buPriceExpected) < 0.00001, 'Delta failed! ' + ' calulated value is ' + buPrice.setScale(5));

        Test.stopTest();

    }


    private static testMethod void testFields()
    {
        RFQItemWrapper wrapper = setupTest1();  
        RFQILayout layout = setupLayout(wrapper);
        //instantiate a cost model
        Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Cost_Model_Implementation__c);             
        CMFCMBuilderBase DualLeadframeCM = (CMFCMBuilderBase)t.newInstance();
        
        DualLeadframeCM.setEditabilityforNoCostModel(layout);

        List<RFQISectionAttribute>  attributes = layout.sectionMap.get('Cost and Price').attributes;
        for(RFQISectionAttribute attribute : attributes){            
            //wrapper.layout.changeIsGenerated(attribute.fieldAPIName,false);
            if(attribute.fieldAPIName == 'Customer_Target_Price__c')
                 System.assert(attribute.isEditable == false);
             if(attribute.fieldAPIName == 'Sales_Target_Price__c')
                 System.assert(attribute.isEditable == false);
             if(attribute.fieldAPIName == 'Materials_Subtotal__c')
                 System.assert(attribute.isEditable == false);
             if(attribute.fieldAPIName == 'Fixed_Costs__c')
                 System.assert(attribute.isEditable == false);
             if(attribute.fieldAPIName == 'Variable_Costs__c')
                 System.assert(attribute.isEditable == false);             
             if(attribute.fieldAPIName == 'Materials_As_Perc_Cost__c')
                 System.assert(attribute.isEditable == false);             
             if(attribute.fieldAPIName == 'Package_Item_Value__c')
                 System.assert(attribute.isEditable == false);                        
        }
  
    }
    static private RFQItemWrapper setUpDualLeadframe(){
        

        RFQAdminInstaller.install();
        DualLeadFrameInstaller.installTest();
        DualLeadframeInstaller.installDLFDefaultDriversTest();
        CMDualInstaller.install();

        
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('SOIC 150mil Body', 1, 1);
        
                
        return wrapper;
        
    }


    static private void setupQuoteInoformation(RFQItemWrapper wrapper, String Forecast){
        wrapper.setAttribute('Forecast__c', 'Package', Forecast);   
    }

    
    
    static private void setupPackage(RFQItemWrapper wrapper, String location, String Leadframe_Finish, String Lead_Count, String Stamped_Etched_Leadframe, String Standard_Rough_Leadframe, String Additional_Components_In_Package){
        
        if(location != null){
            Factory__c factory = [Select Name, id From Factory__c where Name =: location];
            wrapper.setAttribute('Factory__c', 'Package', factory.Id);
        }
        
        wrapper.setAttribute('Lead_Count__c', 'Package', Lead_Count);               
        wrapper.setAttribute('Stamped_Etched_Leadframe__c', 'Package', Stamped_Etched_Leadframe);       
        wrapper.setAttribute('Leadframe_Finish__c', 'Package', Leadframe_Finish);       
        wrapper.setAttribute('Standard_Rough_Leadframe__c', 'Package', Standard_Rough_Leadframe);       
        wrapper.setAttribute('Additional_Components_In_Package__c', 'Package', Additional_Components_In_Package);                   
        
    }
    
    static private void setupDie(RFQItemWrapper wrapper, Integer Num_of_Die, List<String> Die_Attach, List<String> Wafer_Singulation, List<Boolean> Wafer_Backgrind){
        for(Integer i = 0; i < Num_of_Die; i++){
            String dieAttach = Die_Attach[i];
            wrapper.dieConfigurations[i].put('Die_Attach__c', Die_Attach[i]);
            wrapper.dieConfigurations[i].put('Wafer_Singulation__c', Wafer_Singulation[i]);
            wrapper.dieConfigurations[i].put('Wafer_Backgrind__c', Wafer_Backgrind[i]);
        }
    }
    
    static private void setupWire(RFQItemWrapper wrapper, String Wire_Material, String Wire_Diameter, Decimal Number_Of_Wires, Decimal Total_2D_Wire_Length, Decimal Average_2D_Wire_Length){
        
                                            
        wrapper.wireConfigurations[0].put('Wire_Material__c',Wire_Material);
        wrapper.wireConfigurations[0].put('Wire_Diameter__c',  Wire_Diameter);
        wrapper.wireConfigurations[0].put('Number_Of_Wires__c',Number_Of_Wires);
        wrapper.wireConfigurations[0].put('Total_2D_Wire_Length__c',Total_2D_Wire_Length);
        wrapper.wireConfigurations[0].put('Average_2D_Wire_Length__c',Average_2D_Wire_Length);
    }

    //Specs for test 1 get used to test various methods in CMFCMBuilderBase
    private static RFQItemWrapper setupTest1()
    {
        RFQItemWrapper wrapper = setUpDualLeadframe();
        
        //To Do: Check Customer Name. In Excel Sheet, cost of dual leaf frame depends on customers
        
        //setup Quote information
        setupQuoteInoformation(wrapper, '1,000 - 5,000');
        //Setup Package description
        setupPackage(wrapper, null, 'TL-PPF', '8ld', 'Stamped', 'Standard', null);
        //Setup wire
        setupWire(wrapper, 'Au', '0.6', 8.0, 12.2, 0.0);
        //Setup die
    
        //Die_Attach, List<String> Wafer_Singulation, List<Boolean> Wafer_Backgrind){   
        List<String> Die_Attach = new List<String>();
        List<String> Wafer_Singulation = new List<String>();
        List<Boolean> Wafer_Backgrind = new List<Boolean>();
        
        Die_Attach.add('Silver Filled Epoxy');
        Wafer_Singulation.add('Saw');
        Wafer_Backgrind.add(false);
        setupDie(wrapper, 1, Die_Attach, Wafer_Singulation, Wafer_Backgrind);
        
        //instantiate a wire calculator
        Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Wire_Calculation_Implementation__c);       
        CMWireCalcBase wireCalculator = (CMWireCalcBase)t.newInstance();
        wireCalculator.calculate(wrapper);

        return wrapper;
        
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
    private static List<RFQI_PF_Field_Def__c> installFieldDefs(string pf) {
        FieldBuilderHelper helper = new FieldBuilderHelper(pf);
        
        //Adding Header section for Sales Header
        helper.add('Sales Header', 'RFQ_Item__r.RFQ__c', 1000);
        helper.add('Sales Header', 'RFQ_Item__r.RFQ__r.RFQ_Name__c', 1010);
        helper.add('Sales Header', 'RFQ_Item__r.Package_Family__r.Name', 1020);
        helper.add('Sales Header', 'RFQ_Item__r.Status__c', 1030);
        helper.add('Sales Header', 'RFQ_Item__r.RFQ__r.SBU_Name__c', 1040);
        helper.add('Sales Header', 'RFQ_Item__r.CreatedById', 1040);
        //End Sales Header
        
        //Adding Header section for BU
        helper.add('BU Header', 'RFQ_Item__r.RFQ__r.RFQ_Name__c', 1000);
        helper.add('BU Header', 'RFQ_Item__r.Package_Family__r.Name', 1010);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__r.SBU_Name__c', 1020);
        helper.add('BU Header', 'RFQ_Item__r.OwnerId', 1030);
        helper.add('BU Header', 'RFQ_Item__r.Status__c', 1040);
        helper.add('BU Header', 'RFQ_Item__r.Service__c', 1050);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__r.SBU_Name__r.AccountNumber', 1060);
        helper.add('BU Header', 'Customer_Project_Name__c', 1070);
        helper.add('BU Header', 'New_Business__c', 1080);
        helper.add('BU Header', 'Forecast__c', 1090);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__r.SBU_Name__r.Customer_AU_Base_fml__c', 1100);
        helper.add('BU Header', 'Customer_Device_Name__c', 1110);
        helper.add('BU Header', 'RGQ_Projected_Annual_Revenue__c', 1120);
        helper.add('BU Header', 'Au_Inclusive__c', 1140);
        helper.add('BU Header', 'End_Market_Segment__c', 1150);
        helper.add('BU Header', 'Automotive__c', 1160);
        helper.add('BU Header', 'ITAR__c', 1170);
        helper.add('BU Header', 'EAR__c', 1180);
        helper.add('BU Header', 'RFQ_Item__r.Customer_Tier__c', 1190);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__c', 1200);
        //End Header section for BU
        
        //Adding Cost and Price section for BUs
        helper.add('Cost and Price','CLAM_Direct_Labor__c',1000,false,true);
        helper.add('Cost and Price','Materials_Leadframe__c',1010,false,true);
        helper.add('Cost and Price','Customer_Target_Price__c',1020,false,false);
        helper.add('Cost and Price','BU_Price_Perc_GM__c',1030,false,false);
        helper.add('Cost and Price','CLAM_Indirect_Labor__c',1040,false,true);
        helper.add('Cost and Price','Materials_Total_Wire__c',1050,false,true);
        helper.add('Cost and Price','Sales_Target_Price__c',1060,false,false);
        helper.add('Cost and Price','BU_Price__c',1070,false,false);
        helper.add('Cost and Price','CLAM_Depreciation__c',1080,false,true);
        helper.add('Cost and Price','Materials_ODM__c',1090,false,true);
        helper.add('Cost and Price','Competitor__c', 1100,false,true);
        helper.add('Cost and Price','BU_Price_Perc_Delta_To_Target__c',1110,false,false);
        helper.add('Cost and Price','CLAM_Facilities__c',1120,false,true);
        helper.add('Cost and Price','Materials_Subtotal__c',1130,false,true);
        helper.add('Cost and Price','Competitor_Au_Inclusive_Price__c',1140,false,true);
        helper.add('Cost and Price','Manufacturing_Overhead__c',1150,false,true);
        helper.add('Cost and Price','Materials_As_Perc_Cost__c',1160,false,true);
        helper.add('Cost and Price','QA_Cost__c',1170,false,true);
        helper.add('Cost and Price','Total_Cost__c',1180,false,true);
        helper.add('Cost and Price','Variable_Costs__c',1190,false,true);
        helper.add('Cost and Price','Service_Group_Cost__c',1200,false,true);
        helper.add('Cost and Price','Adder_Cost__c',1210,false,true);
        helper.add('Cost and Price','Fixed_Costs__c',1220,false,true);    
        //End Adding Cost and Price section for BUs

        helper.add('Quote Information', 'New_Business__c', 1000);
        helper.add('Quote Information', 'Sales_BU_Price__c', 1010);
        helper.add('Quote Information', 'Price_To_Customer__c', 1020);
        helper.add('Quote Information', 'Automotive__c', 1030);
        helper.add('Quote Information', 'ITAR__c', 1040);
        helper.add('Quote Information', 'EAR__c', 1050);
        helper.add('Quote Information', 'Customer_Project_Name__c', 1060);
        helper.add('Quote Information', 'Customer_Device_Name__c', 1070);
        helper.add('Quote Information', 'Forecast__c', 1080);
        helper.add('Quote Information', 'Prototype__c', 1090, false, false, false, true);
        helper.add('Quote Information', 'Customer_Target_Price__c', 1100);
        helper.add('Quote Information', 'Sales_Target_Price__c', 1110);
        helper.add('Quote Information', 'End_Market_Segment__c', 1120);
        helper.add('Quote Information', 'Competitor__c', 1130);
        helper.add('Quote Information', 'Competitor_Au_Inclusive_Price__c', 1140);
        helper.add('Quote Information', 'HVP_Anticipated_Start_Date__c', 1150);
        helper.add('Quote Information', 'Has_Been_Quoted_Before__c', 1160);
        
        //helper.add('Package Description', 'Factory__c', 2000, true, false, true);
        helper.add('Package Description', 'Lead_Count__c', 2010, true, false, false, true);
        helper.add('Package Description', 'Stamped_Etched_Leadframe__c', 2020, true);
        helper.add('Package Description', 'Leadframe_Finish__c', 2030, true);
        helper.add('Package Description', 'Standard_Rough_Leadframe__c', 2040, true);
        helper.add('Package Description', 'Additional_Components_In_Package__c', 2090, true);
        helper.add('Package Description', 'Packing_Method__c', 2100, true);
        helper.add('Package Description', 'Zero_Delam_Required__c', 2110, true);
            
        helper.add('Wire Description', 'Wire_Configuration__c', 3000, false, false, true);
        helper.add('Wire Description', 'Wire_Material__c', 3010, true, false, true);
        helper.add('Wire Description', 'Wire_Diameter__c', 3020, true, false, true);
        helper.add('Wire Description', 'Number_Of_Wires__c', 3030, true, false, true);
        helper.add('Wire Description', 'Average_2D_Wire_Length__c', 3040);
        helper.add('Wire Description', 'Total_2D_Wire_Length__c', 3050);
        helper.add('Wire Description', 'Total_3D_Wire_Length__c', 3060, true);
        helper.add('Wire Description', 'Au_Factor__c', 3070);
        
        helper.add('Die Description', 'Die_Attach__c', 3000, true);
        helper.add('Die Description', 'Die_1_Size_Dim_X__c', 3010, true);
        helper.add('Die Description', 'Die_1_Size_Dim_Y__c', 3020, true);
        helper.add('Die Description', 'Die_1_Thickness__c', 3030, true);    
        helper.add('Die Description', 'Wafer_Number_of_DPW__c', 3040, true, false, false, true);
        helper.add('Die Description', 'Wafer_Yield__c', 3050, true, false, false, true);
        helper.add('Die Description', 'GDPW__c', 3060, true);
        helper.add('Die Description', 'Wafer_Size__c', 3070, true);
        helper.add('Die Description', 'Wafer_Backgrind__c', 3080, true);
        helper.add('Die Description', 'Wafer_Singulation__c', 3090, true);
        
        
        helper.add('Adders', 'Plasma_Before_Die_Attach__c', 4000, true);
        helper.add('Adders', 'Plasma_Before_Wire_Bond__c', 4010, true);
        helper.add('Adders', 'Plasma_Before_Mold__c', 4020, true);
        helper.add('Adders', 'Die_Coat__c', 4030, true);
        helper.add('Adders', 'Wafer_Inspection__c', 4040, true);
        helper.add('Adders', 'X2_OPT_INSP_100__c', 4050, true);
        helper.add('Adders', 'X3RD_OPT_100__c', 4060, true);
        helper.add('Adders', 'FVI_100__c', 4070, true);
        helper.add('Adders', 'Bake_Dry_Pack__c', 4080, true);
        helper.add('Adders', 'Temperature_Cycle__c', 4090, true);
        helper.add('Adders', 'Bake__c', 4100, true);
        
        helper.add('NRE', 'Stamped_Leadframe_Tooling__c', 5000);
        helper.add('NRE', 'Etched_Leadframe_Tooling__c', 5010);
        helper.add('NRE', 'Other__c', 5020);
                                                    
        helper.insertFields();
        
        return helper.getPfFieldDefs();                             
                                                 
    }
    //Bhanu-L Code Coverage change
    private static testMethod void testBomAndOtherMethods()
    {
        Test.StartTest();
        RFQItemWrapper wrapper = setupTest1();
        CMFCMBuilderBase objBase =  new CMFCMBuilderBase();
        objBase.bomAdded();
        //objBase.bomDeleted();
        objBase.processAdded();
        //objBase.processDeleted();
        //objBase.clearCalc();
        objBase.onAttributeChange(wrapper,'BU_Price__c');
        //objBase.onAttributeChange(wrapper,'BU_Price_Perc_Delta_To_Target__c');
        objBase.onAttributeChange(wrapper,'BU_Price_Perc_GM__c');
        objBase.onAttributeChange(wrapper,'Total_Cost__c');
        objBase.getFieldMap();
        objBase.calcMultiCostModel(wrapper);
        //objBase.calcMultiCostModel(wrapper,0);
        Test.StopTest();
    }

}