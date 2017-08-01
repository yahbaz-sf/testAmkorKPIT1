@isTest
public with sharing class CMBumpBuilderTest {

	public static testMethod void testPrices1()
	{
		RFQItemWrapper wrapper = setUpTest();

		Type t = Type.forName(wrapper.packageFamily.Cost_Model_Implementation__c);
		DebugUtils.getInstance().log('Cost_Model_Implementation__c', wrapper.packageFamily.Cost_Model_Implementation__c);			
    	CMBumpBuilder bumpCM = (CMBumpBuilder)t.newInstance(); 

		setupWrapper(wrapper, 'C3', 'Plated', 'BOP = Bump only (no repass, no RDL)');

		setupCostFields(wrapper, 0.01, 0.1, 1, 10, 40, 19);

		bumpCM.calculateNew(wrapper, new CMSettings());

		Decimal varCost = (Decimal)wrapper.specificRfqItem.get('Variable_Costs_Total__c');
		Decimal fixedCost = (Decimal)wrapper.specificRfqItem.get('Total_Fixed_Costs__c');
		Decimal totalCost = (Decimal)wrapper.specificRfqItem.get('Total_Cost__c');
		Decimal buPrice = (Decimal)wrapper.specificRfqItem.get('BU_Price__c');


		Decimal varCostExpected = 0.11;
		Decimal fixedCostExpected = 11;
		Decimal totalCostExpected = 11.11;
		Decimal buPriceExpected = 18.51666666;


		System.assert(Math.abs(varCost - varCostExpected) < 0.000001, varCost);
		System.assert(Math.abs(fixedCost - fixedCostExpected) < 0.000001, fixedCost);
		System.assert(Math.abs(totalCost - totalCostExpected) < 0.000001, totalCost);
		System.assert(Math.abs(buPrice - buPriceExpected) < 0.000001, buPrice);

	}

	public static testMethod void testBUPriceChange()
	{
		RFQItemWrapper wrapper = setUpTest();

		Type t = Type.forName(wrapper.packageFamily.Cost_Model_Implementation__c);				
    	CMBumpBuilder bumpCM = (CMBumpBuilder)t.newInstance(); 

		setupWrapper(wrapper, 'C3', 'Plated', 'BOP = Bump only (no repass, no RDL)');
		setupCostFields(wrapper, 0.01, 0.1, 1, 10, 40, 19);

		bumpCM.calculateNew(wrapper, new CMSettings());

		wrapper.specificRfqItem.put('BU_Price__c', 20);
		bumpCM.onBUPriceChanged(wrapper);

		Decimal varCost = (Decimal)wrapper.specificRfqItem.get('Variable_Costs_Total__c');
		Decimal fixedCost = (Decimal)wrapper.specificRfqItem.get('Total_Fixed_Costs__c');
		Decimal totalCost = (Decimal)wrapper.specificRfqItem.get('Total_Cost__c');
		Decimal buPrice = (Decimal)wrapper.specificRfqItem.get('BU_Price__c');
		Decimal margin = (Decimal)wrapper.specificRfqItem.get('BU_Margin__c');
		Decimal contMargin = (Decimal)wrapper.specificRfqItem.get('Contribution_Margin_Perc__c');

		Decimal varCostExpected = 0.11;
		Decimal fixedCostExpected = 11;
		Decimal totalCostExpected = 11.11;
		Decimal buPriceExpected = 20;
		Decimal marginExpected = 44.45;
		Decimal contMarginExpected = 99.45;

		System.assert(Math.abs(varCost - varCostExpected) < 0.000001, varCost);
		System.assert(Math.abs(fixedCost - fixedCostExpected) < 0.000001, fixedCost);
		System.assert(Math.abs(totalCost - totalCostExpected) < 0.000001, totalCost);
		System.assert(Math.abs(buPrice - buPriceExpected) < 0.000001, buPrice);
		System.assert(Math.abs(margin - marginExpected) < 0.000001, margin);
		System.assert(Math.abs(contMargin - contMarginExpected) < 0.000001, contMargin);

	}

	public static testMethod void testBUMarginChange()
	{
		RFQItemWrapper wrapper = setUpTest();

		Type t = Type.forName(wrapper.packageFamily.Cost_Model_Implementation__c);				
    	CMBumpBuilder bumpCM = (CMBumpBuilder)t.newInstance(); 

		setupWrapper(wrapper, 'C3', 'Plated', 'BOP = Bump only (no repass, no RDL)');
		setupCostFields(wrapper, 0.01, 0.1, 1, 10, 40, 19);

		bumpCM.calculateNew(wrapper, new CMSettings());

		wrapper.specificRfqItem.put('BU_Margin__c', 44.45);
		bumpCM.onBUPricePercGMChanged(wrapper);

		Decimal varCost = (Decimal)wrapper.specificRfqItem.get('Variable_Costs_Total__c');
		Decimal fixedCost = (Decimal)wrapper.specificRfqItem.get('Total_Fixed_Costs__c');
		Decimal totalCost = (Decimal)wrapper.specificRfqItem.get('Total_Cost__c');
		Decimal buPrice = (Decimal)wrapper.specificRfqItem.get('BU_Price__c');
		Decimal margin = (Decimal)wrapper.specificRfqItem.get('BU_Margin__c');
		Decimal contMargin = (Decimal)wrapper.specificRfqItem.get('Contribution_Margin_Perc__c');

		Decimal varCostExpected = 0.11;
		Decimal fixedCostExpected = 11;
		Decimal totalCostExpected = 11.11;
		Decimal buPriceExpected = 20;
		Decimal marginExpected = 44.45;
		Decimal contMarginExpected = 99.45;

		System.assert(Math.abs(varCost - varCostExpected) < 0.000001, varCost);
		System.assert(Math.abs(fixedCost - fixedCostExpected) < 0.000001, fixedCost);
		System.assert(Math.abs(totalCost - totalCostExpected) < 0.000001, totalCost);
		System.assert(Math.abs(buPrice - buPriceExpected) < 0.000001, buPrice);
		System.assert(Math.abs(margin - marginExpected) < 0.000001, margin);
		System.assert(Math.abs(contMargin - contMarginExpected) < 0.000001, contMargin);

	}

	private static testMethod void testFields()
    {
        RFQItemWrapper wrapper = setUpTest();
        RFQILayout layout = setupLayout(wrapper);
        String cmModel;
        if (!StringUtils.isBlank(wrapper.packageFamily.Cost_Model_Implementation__c)) cmModel = wrapper.packageFamily.Cost_Model_Implementation__c;
        else cmModel = wrapper.productGroup.Cost_Model_Implementation__c;
        Type t = Type.forName(cmModel);

    	CMBumpBuilder bumpCM = (CMBumpBuilder)t.newInstance();
        bumpCM.setEditabilityforNoCostModel(layout);



        List<RFQISectionAttribute>  attributes = layout.sectionMap.get('Cost and Price').attributes;
        for(RFQISectionAttribute attribute : attributes){            
            //wrapper.layout.changeIsGenerated(attribute.fieldAPIName,false);
            if(attribute.fieldAPIName == 'Variable_Costs_Total__c')
                 System.assert(attribute.isEditable == false);
             if(attribute.fieldAPIName == 'Total_Fixed_Costs__c')
                 System.assert(attribute.isEditable == false);
             if(attribute.fieldAPIName == 'Total_Cost__c')
                 System.assert(attribute.isEditable == false);
             if(attribute.fieldAPIName == 'Customer_Target_Price__c')
                 System.assert(attribute.isEditable == false);
             if(attribute.fieldAPIName == 'Contribution_Margin_Perc__c')
                 System.assert(attribute.isEditable == false);
             if(attribute.fieldAPIName == 'Sales_Target_Price__c')
                 System.assert(attribute.isEditable == false);                         
        }
    }

    private static testMethod void testOtherMethods()
    {
    	RFQItemWrapper wrapper = setUpTest();
        String cmModel;
        if (!StringUtils.isBlank(wrapper.packageFamily.Cost_Model_Implementation__c)) cmModel = wrapper.packageFamily.Cost_Model_Implementation__c;
        else cmModel = wrapper.productGroup.Cost_Model_Implementation__c;
        Type t = Type.forName(cmModel);
        CMBumpBuilder bumpCM = (CMBumpBuilder)t.newInstance();

        bumpCm.loadSettings(wrapper, false);
        bumpCm.getMeanForecast('');

        //nothing in this methods now, so just make sure it didn't explode
        System.assert(true);
    }

	static private void setupWrapper(RFQItemWrapper wrapper, String factory, String type, String structure)
	{
		Factory__c fact = [select id from Factory__c where name=:factory];
		wrapper.setAttribute('Factory__c', RFQItemWrapper.PACKAGE_OBJECT, fact.Id);
		wrapper.setAttribute('Type_of_Bump__c', RFQItemWrapper.PACKAGE_OBJECT, type);
		wrapper.setAttribute('Structure__c', RFQItemWrapper.PACKAGE_OBJECT, structure);
	}

	static private void setupCostFields(RFQItemWrapper wrapper, Decimal matTotal, Decimal otherMat, Decimal depreciation, Decimal otherFixed, Decimal margin, Decimal salesTarget)
	{
		wrapper.specificRfqItem.put('Materials_Total__c', matTotal);
		wrapper.specificRfqItem.put('Variable_Costs__c', otherMat);
		wrapper.specificRfqItem.put('Depreciation__c', depreciation);
		wrapper.specificRfqItem.put('Fixed_Costs__c', otherFixed); 
		wrapper.specificRfqItem.put('BU_Margin__c', margin);
		wrapper.specificRfqItem.put('Sales_Target_Price__c', salesTarget);
	}

	static private RFQItemWrapper setUpTest()
	{
		
		RFQAdminInstaller.install();
		RFQAdminInstaller.installFactories();
		
		ServiceInstaller.install();
		ServiceInstaller.incrementalInstallAMK1383();
		
		//get wrapper
		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('Bump');
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
}