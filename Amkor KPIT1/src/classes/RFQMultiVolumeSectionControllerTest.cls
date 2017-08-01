@isTest
public class RFQMultiVolumeSectionControllerTest {
    public static testMethod void testGetOptions()
    {
        RFQMultiVolumeSectionController cont = setupControllers();

        System.assert(cont.getShowForecastAsPicklist(), 'PBGA should have a picklist for forecast');

        List<SelectOption> options = cont.getOptions();

        System.assert(options.size() > 0, 'SelectOption list should have at least one options');

        Boolean hasCorrectValue = false;
        for (SelectOption option : options)
        {
            if (option.getValue() == '<5') hasCorrectValue = true;
        }

        System.assert(hasCorrectValue, 'PBGA should have a forecast of <5');
    }

    public static testMethod void testRepriceItems()
    {
        RFQMultiVolumeSectionController volCont = setupControllers();
        RFQItemWrapper wrapper = volCont.cWrapper;
        System.assert((Decimal)wrapper.specificRfqItem.get('Total_Cost_With_Substrate_New__c') > 0, 'Cost Model should have ran and generated a Total Cost for PBGA');
        
        volCont.addVolume();
        volCont.addVolume();
        volCont.addVolume();
        volCont.addVolume();

        System.assert(wrapper.volumeList.size() == 4, 'A multi volume config should have been added');

        Integer index = 1;
        for (RFQIVolume vol : wrapper.volumeList)
        {
            System.assert(vol.index == index, 'Volume\'s index should be ' + index);
            index++;
        }

        for (RFQIVolume vol : wrapper.volumeList)
        {
            vol.price = 0;
            vol.costLessSubs = 0;
        }

        volCont.repriceVolumes();

    }

    public static testMethod void testGetters()
    {
        RFQItemEditController rfqItemCont = setupItemCont();
        RFQMultiVolumeSectionController volCont = setupVolCont(rfqItemCont);
        RFQItemWrapper wrapper = volCont.cWrapper;
        wrapper.packageFamily.Copy_Fields_To_Multivolume__c = true;

        //add a wire to be safe
        rfqItemCont.addWireConfiguration();

        for (sObject wire : wrapper.wireConfigurations)
        {
            wire.put('Wire_Material__c', 'Au');
        }

        System.assert(volCont.getSubsCostDisabled(), 'PBGA does not have materials substrate in multi volume');
        System.assert(volCont.getCostLessSubsDisabled(), 'Total Cost is calculated for PBGA');

        volCont.editMode = false;
        System.assert(!volCont.getCanEdit(), 'Cannot edit on view pages');
        volCont.editMode = true;
        System.assert(volCont.getCanEdit(), 'Should edit on view pages');
        wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_COMPLETE;
        System.assert(!volCont.getCanEdit(), 'Cannot edit after approved');

        System.assert(volCont.getHasGoldWires(), 'A gold wire was added above - should be true');
        System.assert(!volCont.getLoadMap(), 'There should be no errors in creating map');
        System.assert(!volCont.getIsAddedService(), 'This item is an assembly');
        System.assert(!volCont.getIsTest(), 'This is not a Test item');
        System.assert(!volCont.getShowSubstrateFields(), 'PBGA was requested to not show substrate in multi volume');
        System.assert(!volCont.getIsPerMonth(), 'Item is not test');

        System.assert(!volCont.getCanDeleteOneVolume(), 'Cannot delete any if there are no volume configs');
        volCont.addVolume();
        System.assert(volCont.getCanDeleteOneVolume(), 'This is a simulation of non-bu page, so user can delete sales-added volumes');

    }


    private static RFQMultiVolumeSectionController setupControllers()
    {
        return setupVolCont(setupItemCont());       
    }

    private static RFQItemEditController setupItemCont()
    {
        setupPBGA();
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA', 1, 1);

        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(wrapper.rfqItem);
        RFQItemEditController rfqItemCont = new RFQItemEditController(sc);
        //set status so that setupCostModel will calculate parent item
        rfqItemCont.wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_PENDING_BU;
        rfqItemCont.setupCostModel();
        rfqItemCont.builder = CMBuilder.getCMBuilderByWrapper(rfqItemCont.wrapper);

        return rfqItemCont;
    }

    private static RFQMultiVolumeSectionController setupVolCont(RFQItemEditController rfqItemCont)
    {
        RFQMultiVolumeSectionController volCont = new RFQMultiVolumeSectionController();
        volCont.cWrapper = rfqItemCont.wrapper;
        volCont.cBuilder = rfqItemCont.builder;
        volCont.cLayout = rfqItemCont.layout;
        return volCont;
    }
    
    

    private static void setupPBGA()
    {
        Product_Group__c pg = new Product_Group__c(Name='PBGA');
        pg.Cost_Model_Implementation__c = 'CMPBGABuilder';
        pg.Wire_Calculation_Implementation__c = 'CMWireCalcBase';
        pg.Generated_Price_Requires_BU_Review__c = true;
        insert pg;

        List<Package_Family__c> families = new List<Package_Family__c>();
        FieldBuilderHelper.addPf('PBGA', pg, 'RFQI_PBGA__c', 'RFQIWC_PBGA__c', 'RFQIDC_PBGA__c', families, true);
        insert families;

        insert new RFQI_Section__c(Name = 'Cost and Price',Sequence__c = 4000);

        List<RFQI_Field_Def__c> defs = new List<RFQI_Field_Def__c>();
        defs.add(new RFQI_Field_Def__c(Name='Materials_Substrate__c'));
        defs.add(new RFQI_Field_Def__c(Name='CLAM_WB__c'));
        defs.add(new RFQI_Field_Def__c(Name='Customer_Target_Price__c'));
        defs.add(new RFQI_Field_Def__c(Name='BU_Price_Perc_GM__c'));
        defs.add(new RFQI_Field_Def__c(Name='Materials_Wire__c'));
        defs.add(new RFQI_Field_Def__c(Name='CLAM_Others__c'));
        defs.add(new RFQI_Field_Def__c(Name='Sales_Target_Price__c'));
        defs.add(new RFQI_Field_Def__c(Name='BU_Price__c'));
        defs.add(new RFQI_Field_Def__c(Name='Materials_ODM_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name='CLAM_Total__c'));
        defs.add(new RFQI_Field_Def__c(Name='Competitor__c'));
        defs.add(new RFQI_Field_Def__c(Name='Perc_IRR_New__c'));
        defs.add(new RFQI_Field_Def__c(Name='Materials_ODM_Mold__c'));
        defs.add(new RFQI_Field_Def__c(Name='Substrate_Perc_Markup__c'));
        defs.add(new RFQI_Field_Def__c(Name='Heatspreader__c'));
        defs.add(new RFQI_Field_Def__c(Name='Perc_CM__c'));
        defs.add(new RFQI_Field_Def__c(Name='Total_Materials__c'));
        defs.add(new RFQI_Field_Def__c(Name='Substrate_Unit__c'));
        defs.add(new RFQI_Field_Def__c(Name='Complex_Adder__c'));
        defs.add(new RFQI_Field_Def__c(Name='Apply_3D_Factor__c'));
        defs.add(new RFQI_Field_Def__c(Name='Assembly__c'));
        defs.add(new RFQI_Field_Def__c(Name='Substrate_Waste__c'));
        defs.add(new RFQI_Field_Def__c(Name='Mold_Wastage__c'));
        defs.add(new RFQI_Field_Def__c(Name='LGP_Market_Price__c'));
        defs.add(new RFQI_Field_Def__c(Name='Capacity_UE_Rate__c'));
        defs.add(new RFQI_Field_Def__c(Name='Operating_Cash_u__c'));

        insert defs;

        FieldBuilderHelper helper = new FieldBuilderHelper(families[0].Name);
        helper.add('Cost and Price', 'Materials_Substrate__c', 2000, false, true);
        helper.add('Cost and Price', 'CLAM_WB__c', 2010, false, true);
        helper.add('Cost and Price', 'Customer_Target_Price__c', 2020);
        helper.add('Cost and Price', 'BU_Price_Perc_GM__c', 2030, false, true);
        helper.add('Cost and Price', 'Materials_Wire__c', 2040, false, true);
        helper.add('Cost and Price', 'CLAM_Others__c', 2050, false, true);
        helper.add('Cost and Price', 'Sales_Target_Price__c', 2060, false, true);
        helper.add('Cost and Price', 'BU_Price__c', 2070, false, true);
        helper.add('Cost and Price', 'Materials_ODM_Other__c', 2080, false, true);
        helper.add('Cost and Price', 'CLAM_Total__c', 2140, false, true);
        helper.add('Cost and Price', 'Competitor__c', 2150, false, true);
        helper.add('Cost and Price', 'Perc_IRR_New__c', 2160, false, true);
        helper.add('Cost and Price', 'Materials_ODM_Mold__c', 2170, false, true);
        helper.add('Cost and Price', 'Substrate_Perc_Markup__c', 2180, false, false);
        helper.add('Cost and Price', 'Heatspreader__c', 2190, false, true);
        helper.add('Cost and Price', 'Perc_CM__c', 2200, false, true);
        helper.add('Cost and Price', 'Total_Materials__c', 2210, false, true);
        helper.add('Cost and Price', 'Substrate_Unit__c', 2220, false, false, false, false, '', true);
        helper.add('Cost and Price', 'Complex_Adder__c', 2230, false, true);
        helper.add('Cost and Price', 'Apply_3D_Factor__c', 2290, false, true);
        helper.add('Cost and Price', 'Assembly__c', 2300, false, false);
        helper.add('Cost and Price', 'Substrate_Waste__c', 2310, false, true);
        helper.add('Cost and Price', 'Mold_Wastage__c', 2320, false, true);
        helper.add('Cost and Price', 'LGP_Market_Price__c', 2340, false, true);
        helper.add('Cost and Price', 'Capacity_UE_Rate__c', 2350, false, true);
        helper.add('Cost and Price', 'Operating_Cash_u__c', 2380, false, true);
                                                    
        helper.insertFields();
    }
}