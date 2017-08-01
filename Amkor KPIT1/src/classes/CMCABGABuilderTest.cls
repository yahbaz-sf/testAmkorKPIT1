/*************************************************************************
*
* PURPOSE: Test for CABGA Builder
*
* CLASS: CMCABGABuilderTest
* CREATED: 8/13/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
@isTest
public with sharing class CMCABGABuilderTest {

	public static testMethod void testBuilder()
	{
		//nothing is calculated, so just call the methods for code coverage
		Product_Group__c pg = SharedUnitTestUtils.createProductGroupFromName('CABGA', false);
		insert pg;
		Package_Family__c pf = SharedUnitTestUtils.createPackageFamilyFromName('CABGA', pg, 'RFQI_CABGA__c');
		insert pf;

		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem(pf.Name);
		CMCABGABuilder builder = new CMCABGABuilder();

		builder.loadSettings(wrapper, false);
		builder.calculateNew(wrapper, new CMSettings());
		builder.calculateAll(wrapper, false, new CMSettings());

		builder.onAttributeChange(wrapper, 'BU_Price__c');
		builder.onAttributeChange(wrapper, 'BU_Price_Perc_Delta_To_Target__c');
		builder.onAttributeChange(wrapper, 'BU_Price_Perc_GM__c');

		Map<String, String> fieldMap = builder.getFieldMap();
		System.assert(fieldMap.get('price') != null);

		RFQILayout layout = PFFieldDefDao.getInstance().getPackageFamilyLayout(pf.Id, 1, 1, 'Sales');

		builder.setEditabilityforNoCostModel(layout);

	}


    /*
	DebugUtils debug {get {return DebugUtils.getInstance();} }

	public static testMethod void testPrices1()
	{
		RFQItemWrapper wrapper = setUpTest();

		Type t = Type.forName(wrapper.productGroup.Cost_Model_Implementation__c);				
    	CMCABGABuilder CabgaCM = (CMCABGABuilder)t.newInstance(); 

		setupWrapper(wrapper, 'C3', 3.0, 4.0, 6, 10, 3.0, 4.0);

		setupCostFields(wrapper, 0.000001, 0.00001, 0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000, 40, 1500);

		CabgaCM.calculateNew(wrapper, new CMSettings());

		Decimal buPrice = (Decimal)wrapper.specificRfqItem.get('BU_Price__c');
		Decimal clamTotal = (Decimal)wrapper.specificRfqItem.get('CLAM_Total__c');
		Decimal varCost = (Decimal)wrapper.specificRfqItem.get('Variable_Costs__c');
		Decimal fixedCost = (Decimal)wrapper.specificRfqItem.get('Fixed_Costs__c');
		Decimal totalMaterials = (Decimal)wrapper.specificRfqItem.get('Materials_Subtotal__c');
		Decimal matPctCost = (Decimal)wrapper.specificRfqItem.get('Materials_As_Perc_Cost__c');
		Decimal totalCost = (Decimal)wrapper.specificRfqItem.get('Total_Cost__c');
		Decimal delta = (Decimal)wrapper.specificRfqItem.get('BU_Price_Perc_Delta_To_Target__c');

		Decimal clamTotalExpected = 1100.011111;
		Decimal varCostExpected = 1011.100001;
		Decimal fixedCostExpected = 100.011110;
		Decimal totalMaterialsExpected = 11.100000;
		Decimal matPctCostExpected = 0.999000;
		Decimal totalCostExpected = 1111.111111;
		Decimal buPriceExpected = 1851.85185167;
		Decimal deltaExpected = 23.45679011111;

		System.assert(Math.abs(clamTotal - clamTotalExpected) < 0.000001, clamTotal);
		System.assert(Math.abs(varCost - varCostExpected) < 0.000001, varCost);
		System.assert(Math.abs(fixedCost - fixedCostExpected) < 0.000001, fixedCost);
		System.assert(Math.abs(totalMaterials - totalMaterialsExpected) < 0.000001, totalMaterials);
		System.assert(Math.abs(matPctCost - matPctCostExpected) < 0.000001, matPctCost);
		System.assert(Math.abs(totalCost - totalCostExpected) < 0.000001, totalCost);
		System.assert(Math.abs(buPrice - buPriceExpected) < 0.000001, buPrice);
		System.assert(Math.abs(delta - deltaExpected) < 0.000001, delta);

	}

	public static testMethod void testPrices2()
	{
		RFQItemWrapper wrapper = setUpTest();

		Type t = Type.forName(wrapper.productGroup.Cost_Model_Implementation__c);				
    	CMCABGABuilder CabgaCM = (CMCABGABuilder)t.newInstance(); 

		setupWrapper(wrapper, 'C3', 3.0, 4.0, 6, 10, 3.0, 4.0);

		setupCostFields(wrapper, 0.000001, 0.00001, 0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000, 40, 1500);

		CabgaCM.displayResults(wrapper, false);

		Decimal buPrice = (Decimal)wrapper.specificRfqItem.get('BU_Price__c');
		Decimal clamTotal = (Decimal)wrapper.specificRfqItem.get('CLAM_Total__c');
		Decimal varCost = (Decimal)wrapper.specificRfqItem.get('Variable_Costs__c');
		Decimal fixedCost = (Decimal)wrapper.specificRfqItem.get('Fixed_Costs__c');
		Decimal totalMaterials = (Decimal)wrapper.specificRfqItem.get('Materials_Subtotal__c');
		Decimal matPctCost = (Decimal)wrapper.specificRfqItem.get('Materials_As_Perc_Cost__c');
		Decimal totalCost = (Decimal)wrapper.specificRfqItem.get('Total_Cost__c');
		Decimal delta = (Decimal)wrapper.specificRfqItem.get('BU_Price_Perc_Delta_To_Target__c');

		Decimal clamTotalExpected = 1100.011111;
		Decimal varCostExpected = 1011.100001;
		Decimal fixedCostExpected = 100.011110;
		Decimal totalMaterialsExpected = 11.100000;
		Decimal matPctCostExpected = 0.999000;
		Decimal totalCostExpected = 1111.111111;
		Decimal buPriceExpected = 1851.85185167;
		Decimal deltaExpected = 23.45679011111;

		System.assert(Math.abs(clamTotal - clamTotalExpected) < 0.000001, clamTotal);
		System.assert(Math.abs(varCost - varCostExpected) < 0.000001, varCost);
		System.assert(Math.abs(fixedCost - fixedCostExpected) < 0.000001, fixedCost);
		System.assert(Math.abs(totalMaterials - totalMaterialsExpected) < 0.000001, totalMaterials);
		System.assert(Math.abs(matPctCost - matPctCostExpected) < 0.000001, matPctCost);
		System.assert(Math.abs(totalCost - totalCostExpected) < 0.000001, totalCost);
		System.assert(Math.abs(buPrice - buPriceExpected) < 0.000001, buPrice);
		System.assert(Math.abs(delta - deltaExpected) < 0.000001, delta);

	}

	public static testMethod void testPrices3()
	{
		RFQItemWrapper wrapper = setUpTest();

		Type t = Type.forName(wrapper.productGroup.Cost_Model_Implementation__c);				
    	CMCABGABuilder CabgaCM = (CMCABGABuilder)t.newInstance(); 

		setupWrapper(wrapper, 'C3', 3.0, 4.0, 6, 10, 3.0, 4.0);

		setupCostFields(wrapper, 0.000001, 0.00001, 0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000, 40, 1500);

		CabgaCM.calculateNew(wrapper, new CMSettings());

		wrapper.specificRfqItem.put('BU_Price__c', 1700);
		CabgaCM.onBUPriceChanged(wrapper);

		Decimal margin = (Decimal)wrapper.specificRfqItem.get('BU_Price_Perc_GM__c');
		Decimal delta = (Decimal)wrapper.specificRfqItem.get('BU_Price_Perc_Delta_To_Target__c');

		Decimal marginExpected = 34.640522882;
		Decimal deltaExpected = 13.33333333;
		System.assert(Math.abs(delta - deltaExpected) < 0.000001, delta);
		System.assert(Math.abs(margin - marginExpected) < 0.000001, margin);

	}

	public static testMethod void testPrices4()
	{
		RFQItemWrapper wrapper = setUpTest();

		Type t = Type.forName(wrapper.productGroup.Cost_Model_Implementation__c);				
    	CMCABGABuilder CabgaCM = (CMCABGABuilder)t.newInstance(); 

		setupWrapper(wrapper, 'C3', 3.0, 4.0, 6, 10, 3.0, 4.0);

		setupCostFields(wrapper, 0.000001, 0.00001, 0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000, 40, 1500);

		CabgaCM.calculateNew(wrapper, new CMSettings());

		wrapper.specificRfqItem.put('BU_Price_Perc_GM__c', 34.640522882);
		CabgaCM.onBUPricePercGMChanged(wrapper);

		Decimal buPrice = (Decimal)wrapper.specificRfqItem.get('BU_Price__c');
		Decimal delta = (Decimal)wrapper.specificRfqItem.get('BU_Price_Perc_Delta_To_Target__c');

		Decimal buPriceExpected = 1700;
		Decimal deltaExpected = 13.33333333;
		System.assert(Math.abs(buPrice - buPriceExpected) < 0.000001, buPrice);
		System.assert(Math.abs(delta - deltaExpected) < 0.000001, delta);

	}

	public static testMethod void testPrices5()
	{
		RFQItemWrapper wrapper = setUpTest();

		Type t = Type.forName(wrapper.productGroup.Cost_Model_Implementation__c);				
    	CMCABGABuilder CabgaCM = (CMCABGABuilder)t.newInstance(); 

		setupWrapper(wrapper, 'C3', 3.0, 4.0, 6, 10, 3.0, 4.0);

		setupCostFields(wrapper, 0.000001, 0.00001, 0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000, 40, 1500);

		CabgaCM.calculateNew(wrapper, new CMSettings());

		wrapper.specificRfqItem.put('BU_Price_Perc_Delta_To_Target__c', 13.33333333);
		CabgaCM.onBUPricePercDeltaToTargetChanged(wrapper);

		Decimal buPrice = (Decimal)wrapper.specificRfqItem.get('BU_Price__c');
		Decimal margin = (Decimal)wrapper.specificRfqItem.get('BU_Price_Perc_GM__c');

		Decimal buPriceExpected = 1700;
		Decimal marginExpected = 34.640522882; 
		System.assert(Math.abs(buPrice - buPriceExpected) < 0.000001, buPrice);
		System.assert(Math.abs(margin - marginExpected) < 0.000001, margin);

	}

	public static testMethod void testCatches1()
	{
		RFQItemWrapper wrapper = setUpTest();
        RFQILayout layout = setupLayout(wrapper);

		Type t = Type.forName(wrapper.productGroup.Cost_Model_Implementation__c);				
    	CMCABGABuilder CabgaCM = (CMCABGABuilder)t.newInstance(); 

		setupWrapper(wrapper, 'C3', 3.0, 4.0, 6, 10, 3.0, 4.0);

		setupCostFields(wrapper, null, null, null, null, null, null, null, null, null, null, null, null);

		CabgaCM.calculateNew(wrapper, new CMSettings());
		CabgaCM.setEditabilityforNoCostModel(layout);
		
		Decimal buPrice = (Decimal)wrapper.specificRfqItem.get('BU_Price__c');
		System.assert(buPrice == 0);

	}

	public static testMethod void testCatches2()
	{
		RFQItemWrapper wrapper = setUpTest();

		Type t = Type.forName(wrapper.productGroup.Cost_Model_Implementation__c);				
    	CMCABGABuilder CabgaCM = (CMCABGABuilder)t.newInstance(); 

		setupWrapper(wrapper, 'C3', 3.0, 4.0, 6, 10, 3.0, 4.0);

		setupCostFields(wrapper, null, null, null, null, null, null, null, null, null, null, null, null);

		CabgaCM.displayResults(wrapper, true);

		Decimal buPrice = (Decimal)wrapper.specificRfqItem.get('BU_Price__c');
		System.assert(buPrice == 0);

	}

	static private void setupWrapper(RFQItemWrapper wrapper, String factory, Decimal bodyX, Decimal bodyY, Decimal ballCount, Decimal numWires, Decimal dieX, Decimal dieY)
	{
		Factory__c fact = [select id from Factory__c where name=:factory];
		wrapper.setAttribute('Factory__c', RFQItemWrapper.PACKAGE_OBJECT, fact.Id);
		wrapper.setAttribute('Body_X__c', RFQItemWrapper.PACKAGE_OBJECT, bodyX);
		wrapper.setAttribute('Body_Y__c', RFQItemWrapper.PACKAGE_OBJECT, bodyY);
		wrapper.setAttribute('Number_of_BGA_Balls__c', RFQItemWrapper.PACKAGE_OBJECT, ballCount);
		wrapper.setAttribute('Number_of_Wires__c', RFQItemWrapper.WIRE_OBJECT, numWires);
		wrapper.setAttribute('Die_Size_X__c', RFQItemWrapper.DIE_OBJECT, dieX);
		wrapper.setAttribute('Die_Size_Y__c', RFQItemWrapper.DIE_OBJECT, dieY);				
	}

	static private void setupCostFields(RFQItemWrapper wrapper, Decimal directLabor, Decimal indirectLabor, Decimal depreciation, Decimal facilities, Decimal service,
											Decimal substrate, Decimal wire, Decimal odm, Decimal qa, Decimal overhead, Decimal margin, Decimal salesTarget)
	{
		wrapper.specificRfqItem.put('CLAM_Direct_Labor__c', directLabor);
		wrapper.specificRfqItem.put('CLAM_Indirect_Labor__c', indirectLabor);
		wrapper.specificRfqItem.put('CLAM_Facilities__c', facilities);
		wrapper.specificRfqItem.put('CLAM_Depreciation__c', depreciation); 
		wrapper.specificRfqItem.put('Service_Group_Cost__c', service);
		wrapper.specificRfqItem.put('Materials_Substrate__c', substrate);
		wrapper.specificRfqItem.put('Materials_Total_Wire__c', wire);
		wrapper.specificRfqItem.put('Materials_ODM__c', odm);
		wrapper.specificRfqItem.put('QA_Cost__c', qa);
		wrapper.specificRfqItem.put('Manufacturing_Overhead__c', overhead);
		wrapper.specificRfqItem.put('BU_Price_Perc_GM__c', margin);
		wrapper.specificRfqItem.put('Sales_Target_Price__c', salesTarget);
	}

	static private RFQItemWrapper setUpTest()
	{
		
		RFQAdminInstaller.install();
		RFQAdminInstaller.installFactories();
		RFQAdminInstaller.installAccounts();
		
		CABGAInstaller.install();
		
		//get wrapper
		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('CABGA');

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
    }*/
}