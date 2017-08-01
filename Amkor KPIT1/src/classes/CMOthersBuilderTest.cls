@isTest
private class CMOthersBuilderTest {

	private static CMOthersBuilder OthersCostModelCalculator;

	private static testMethod void test1()
	{
		RFQAdminInstaller.install();
		//RFQAdminInstaller.installAccounts();
		RFQAdminInstaller.installFactories();
		//RFQAdminInstaller.installRFQSystemSettings();
		AdvancedProductInstaller.install();


        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('Emerging');
    	String cmModel;
        if (!StringUtils.isBlank(wrapper.packageFamily.Cost_Model_Implementation__c)) cmModel = wrapper.packageFamily.Cost_Model_Implementation__c;
        else cmModel = wrapper.productGroup.Cost_Model_Implementation__c;
        Type t = Type.forName(cmModel);
        OthersCostModelCalculator = (CMOthersBuilder)t.newInstance();

        wrapper.setAttribute('CLAM_OH__c', 'Package', 1.0);
        wrapper.setAttribute('CLAM_Depreciation__c', 'Package', 2.0);
        wrapper.setAttribute('CLAM_OCOGS__c', 'Package', 3.0);
        wrapper.setAttribute('CLAM_Labor__c', 'Package', 4.0);

        wrapper.setAttribute('Materials_Substrate__c', 'Package', 1.0);
        wrapper.setAttribute('Materials_ODM__c', 'Package', 2.0);

        wrapper.setAttribute('Subs_Markup_Perc__c', 'Package', 5.0);
        wrapper.setAttribute('Assembly_GM_wo_Substrate__c', 'Package', 40.0);

        OthersCostModelCalculator.calculateAll(wrapper, true, new CMSettings());

        Decimal clamSubtotal = (Decimal)wrapper.specificRfqItem.get('CLAM_Subtotal_New__c');
        Decimal materialsSubtotal = (Decimal)wrapper.specificRfqItem.get('Materials_Subtotal__c');
        Decimal buPrice = (Decimal)wrapper.specificRfqItem.get('BU_Price__c');
        Decimal percGM = (Decimal)wrapper.specificRfqItem.get('Total_Perc_GM__c');
        Decimal costLessSubstrate = (Decimal)wrapper.specificRfqItem.get('Cost_less_Substrate_New__c');
        Decimal costWithSubstrate = (Decimal)wrapper.specificRfqItem.get('Total_Cost_with_Substrate_New__c');

        System.assert(clamSubtotal == 10);
        System.assert(materialsSubtotal == 3);
        System.assert(costLessSubstrate == 12);
        System.assert(costWithSubstrate == 13);
        System.assert(Math.abs(buPrice - 21.05) < 0.0000001, buPrice);
        System.assert(Math.abs(percGM - 38.242280285) < 0.0000001, percGM);
	}

    private static testMethod void test2()
    {
        RFQAdminInstaller.install();
        //RFQAdminInstaller.installAccounts();
        RFQAdminInstaller.installFactories();
        //RFQAdminInstaller.installRFQSystemSettings();
        AdvancedProductInstaller.install();


        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('Emerging');
        String cmModel;
        if (!StringUtils.isBlank(wrapper.packageFamily.Cost_Model_Implementation__c)) cmModel = wrapper.packageFamily.Cost_Model_Implementation__c;
        else cmModel = wrapper.productGroup.Cost_Model_Implementation__c;
        Type t = Type.forName(cmModel);
        OthersCostModelCalculator = (CMOthersBuilder)t.newInstance();

        wrapper.setAttribute('CLAM_OH__c', 'Package', 1.0);
        wrapper.setAttribute('CLAM_Depreciation__c', 'Package', 2.0);
        wrapper.setAttribute('CLAM_OCOGS__c', 'Package', 3.0);
        wrapper.setAttribute('CLAM_Labor__c', 'Package', 4.0);

        wrapper.setAttribute('Materials_Substrate__c', 'Package', 1.0);
        wrapper.setAttribute('Materials_ODM__c', 'Package', 2.0);

        wrapper.setAttribute('Subs_Markup_Perc__c', 'Package', 5.0);
        wrapper.setAttribute('Assembly_GM_wo_Substrate__c', 'Package', 40.0);

        OthersCostModelCalculator.calculateNew(wrapper, new CMSettings());

        Decimal clamSubtotal = (Decimal)wrapper.specificRfqItem.get('CLAM_Subtotal_New__c');
        Decimal materialsSubtotal = (Decimal)wrapper.specificRfqItem.get('Materials_Subtotal__c');
        Decimal buPrice = (Decimal)wrapper.specificRfqItem.get('BU_Price__c');
        Decimal percGM = (Decimal)wrapper.specificRfqItem.get('Total_Perc_GM__c');
        Decimal costLessSubstrate = (Decimal)wrapper.specificRfqItem.get('Cost_less_Substrate_New__c');
        Decimal costWithSubstrate = (Decimal)wrapper.specificRfqItem.get('Total_Cost_with_Substrate_New__c');

        System.assert(clamSubtotal == 10);
        System.assert(materialsSubtotal == 3);
        System.assert(costLessSubstrate == 12);
        System.assert(costWithSubstrate == 13);
        System.assert(Math.abs(buPrice - 21.05) < 0.0000001, buPrice);
        System.assert(Math.abs(percGM - 38.242280285) < 0.0000001, percGM);
    }

    private static testMethod void test3()
    {
        RFQAdminInstaller.install();
        //RFQAdminInstaller.installAccounts();
        RFQAdminInstaller.installFactories();
        //RFQAdminInstaller.installRFQSystemSettings();
        AdvancedProductInstaller.install();


        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('Emerging');
        String cmModel;
        if (!StringUtils.isBlank(wrapper.packageFamily.Cost_Model_Implementation__c)) cmModel = wrapper.packageFamily.Cost_Model_Implementation__c;
        else cmModel = wrapper.productGroup.Cost_Model_Implementation__c;
        Type t = Type.forName(cmModel);
        OthersCostModelCalculator = (CMOthersBuilder)t.newInstance();

        wrapper.setAttribute('CLAM_OH__c', 'Package', 1.0);
        wrapper.setAttribute('CLAM_Depreciation__c', 'Package', 2.0);
        wrapper.setAttribute('CLAM_OCOGS__c', 'Package', 3.0);
        wrapper.setAttribute('CLAM_Labor__c', 'Package', 4.0);

        wrapper.setAttribute('Materials_Substrate__c', 'Package', 1.0);
        wrapper.setAttribute('Materials_ODM__c', 'Package', 2.0);

        wrapper.setAttribute('Subs_Markup_Perc__c', 'Package', 5.0);
        wrapper.setAttribute('Assembly_GM_wo_Substrate__c', 'Package', 40.0);

        OthersCostModelCalculator.displayResults(wrapper, true);

        Decimal clamSubtotal = (Decimal)wrapper.specificRfqItem.get('CLAM_Subtotal_New__c');
        Decimal materialsSubtotal = (Decimal)wrapper.specificRfqItem.get('Materials_Subtotal__c');
        Decimal buPrice = (Decimal)wrapper.specificRfqItem.get('BU_Price__c');
        Decimal percGM = (Decimal)wrapper.specificRfqItem.get('Total_Perc_GM__c');
        Decimal costLessSubstrate = (Decimal)wrapper.specificRfqItem.get('Cost_less_Substrate_New__c');
        Decimal costWithSubstrate = (Decimal)wrapper.specificRfqItem.get('Total_Cost_with_Substrate_New__c');

        System.assert(clamSubtotal == 10);
        System.assert(materialsSubtotal == 3);
        System.assert(costLessSubstrate == 12);
        System.assert(costWithSubstrate == 13);
        System.assert(Math.abs(buPrice - 21.05) < 0.0000001, buPrice);
        System.assert(Math.abs(percGM - 38.242280285) < 0.0000001, percGM);
    }


    private static testMethod void test4()
    {
        

        RFQAdminInstaller.install();
        //RFQAdminInstaller.installAccounts();
        RFQAdminInstaller.installFactories();
        //RFQAdminInstaller.installRFQSystemSettings();
        AdvancedProductInstaller.install();

        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('Emerging');
        RFQILayout layout = setupLayout(wrapper);
        String cmModel;
        if (!StringUtils.isBlank(wrapper.packageFamily.Cost_Model_Implementation__c)) cmModel = wrapper.packageFamily.Cost_Model_Implementation__c;
        else cmModel = wrapper.productGroup.Cost_Model_Implementation__c;
        Type t = Type.forName(cmModel);
        OthersCostModelCalculator = (CMOthersBuilder)t.newInstance();
        OthersCostModelCalculator.setEditabilityforNoCostModel(layout);



        List<RFQISectionAttribute>  attributes = layout.sectionMap.get('Cost and Price').attributes;
        for(RFQISectionAttribute attribute : attributes){            
            //wrapper.layout.changeIsGenerated(attribute.fieldAPIName,false);
            if(attribute.fieldAPIName == 'Competitor__c')
                 System.assert(attribute.isEditable == false);
             if(attribute.fieldAPIName == 'Competitor_Price__c')
                 System.assert(attribute.isEditable == false);
             if(attribute.fieldAPIName == 'CLAM_Subtotal_New__c')
                 System.assert(attribute.isEditable == false);
             if(attribute.fieldAPIName == 'Customer_Target_Price__c')
                 System.assert(attribute.isEditable == false);
             if(attribute.fieldAPIName == 'Materials_Subtotal__c')
                 System.assert(attribute.isEditable == false);
             if(attribute.fieldAPIName == 'BU_Price__c')
                 System.assert(attribute.isEditable == false);             
             if(attribute.fieldAPIName == 'Total_Cost_with_Substrate_New__c')
                 System.assert(attribute.isEditable == false);             
             if(attribute.fieldAPIName == 'Cost_less_Substrate_New__c')
                 System.assert(attribute.isEditable == false);             
             if(attribute.fieldAPIName == 'Total_Perc_GM__c')
                 System.assert(attribute.isEditable == false);             
             if(attribute.fieldAPIName == 'Perc_IRR_New__c')
                 System.assert(attribute.isEditable == false);             
             if(attribute.fieldAPIName == 'Perc_VAM_New__c')
                 System.assert(attribute.isEditable == false);             
        }

  
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