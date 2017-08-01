/*************************************************************************
*
* PURPOSE: Unit Tests for FactoryHelper
*
* CLASS: FactoryHelperTest
* CREATED: 08/10/13 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
***************************************************************************/
@isTest
public class FactoryHelperTest {

	private static testMethod void testGetFactoryMapStringForField() {
		String jsonString = FactoryHelper.getFactoryMapStringForField('RFQI_Die_Sales__c', 'Inspect_2__c');
		system.assert(jsonString.contains('AOI'));

		jsonString = FactoryHelper.getFactoryMapStringForField('something fake', 'also something fake');
		system.assert(jsonString == null);
	}

	private static testMethod void testGetAllowedFactories () {
		string allowedFactories = FactoryHelper.getAllowedFactories('RFQI_CABGA__C');
		system.assert(allowedFactories.contains('J1'));

		allowedFactories = FactoryHelper.getAllowedFactories('something fake');
		system.assert(allowedFactories == null);
	}

	private static testMethod void testAMK1400() {
		RFQAdminInstaller.install();
		RFQAdminInstaller.installFactories();
		PBGAInstaller.install();

		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');
		FactoryHelper.amk1400();

		RFQI_PF_Field_Def__c pfFieldDef = [select Id, Factory_Values__c from RFQI_PF_Field_Def__c where Package_Family__r.Name =: 'PBGA' and RFQI_Field_Def__r.Name =: 'Mold_Process_Type__c'];
		system.assert(pfFieldDef.Factory_Values__c.contains('CGM'));


		wrapper.packageFamily.Allowed_factories__c = FactoryHelper.getAllowedFactories('RFQI_PBGA__C');
		RFQILayout layout = setupLayout(wrapper);
		List<Factory__c> factories = FactoryHelper.getAllowedFactoryList(wrapper, layout);
		system.assert(factories != null);
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