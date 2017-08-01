/*************************************************************************
* 
* PURPOSE:  This class seeds fresh RFQ Item Field Definition specifically
*           for the PBGA package families (cloned from SOIC150Installer
*           for the purposes of generalization)
*         
* CLASS: PBGAInstaller
* CREATED: 03/28/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
global class PBGAInstaller {
    
    /**
    * This method houses all of the install methods further defined later in code
    */
    global static void install() {
        CMPBGAInstaller.clean();
        FieldBuilderHelper.clean('PBGA');
        installPBGAProductGroup();
        installPBGAPackageFamilies();
        installFieldDefs('PBGA');
        FieldBuilderHelper.deleteProductgroupDefaultDriver('PBGA');    
        installPBGADefaultDrivers();
        installExtended('DLP');
        installExtended('AREA SENSOR');
        installExtended('SBGA');
        installExtended('TA/FLEX BGA');
        installExtended('TABGA');
        installExtended('CDD-IMAGE');
        RFQAdminInstaller.AMK1237();
        AMK1658();

    }

    global static void installTest() {
        installPBGAProductGroup();
        installPBGAPackageFamilies();
        installFieldDefs('PBGA');
        installPBGADefaultDrivers();
    }
    
    /**
    * This method installs PBGA Product group
    *
    * @returns a the installed Product Group
    * TODO - Will refactor this when Cost Model for other package families are done 
    */
    private static Product_Group__c installPBGAProductGroup() {
        
        Product_Group__c PBGAGroup = new Product_Group__c(Name ='PBGA');
        try {
            PBGAGroup.Cost_Model_Implementation__c = 'CMPBGABuilder';
            //PBGAGroup.Wire_Calculation_Implementation__c = 'CMPBGAWireCalc';
            PBGAGroup.Wire_Calculation_Implementation__c = 'CMWireCalcBase';
            PBGAGroup.Generated_Price_Requires_BU_Review__c = true;
            insert PBGAGroup;
        }catch(Exception e) {
            system.debug('Could not install PBGA Group: ' + e);
        }
        return PBGAGroup;
    }
    
    public static void updateSapFields() {
        RFQAdminInstaller.updateSapFieldsForProductGroup('PBGA');  
    }

    private static void installPBGADefaultDrivers() {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'PBGA'];
        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
            }
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Prototype__c'), 'true', fieldDefs.get('Forecast__c'), '<5'); 

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '15', fieldDefs.get('Substrate_Thickness__c'), '320');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '17', fieldDefs.get('Substrate_Thickness__c'), '320');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '19', fieldDefs.get('Substrate_Thickness__c'), '320'); 
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '23', fieldDefs.get('Substrate_Thickness__c'), '320'); 
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '25', fieldDefs.get('Substrate_Thickness__c'), '520');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '27', fieldDefs.get('Substrate_Thickness__c'), '520');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '29', fieldDefs.get('Substrate_Thickness__c'), '520');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '31', fieldDefs.get('Substrate_Thickness__c'), '520'); 
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '35', fieldDefs.get('Substrate_Thickness__c'), '520'); 
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '37.5', fieldDefs.get('Substrate_Thickness__c'), '520');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '40', fieldDefs.get('Substrate_Thickness__c'), '520');

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Total_Layer_Count__c'), '4', fieldDefs.get('Substrate_Thickness__c'), '560');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Total_Layer_Count__c'), '6', fieldDefs.get('Substrate_Thickness__c'), '560');

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '15', fieldDefs.get('Core_Thickness__c'), '200');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '17', fieldDefs.get('Core_Thickness__c'), '200');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '19', fieldDefs.get('Core_Thickness__c'), '200'); 
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '23', fieldDefs.get('Core_Thickness__c'), '200'); 
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '25', fieldDefs.get('Core_Thickness__c'), '400');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '27', fieldDefs.get('Core_Thickness__c'), '400');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '29', fieldDefs.get('Core_Thickness__c'), '400');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '31', fieldDefs.get('Core_Thickness__c'), '400'); 
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '35', fieldDefs.get('Core_Thickness__c'), '400'); 
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '37.5', fieldDefs.get('Core_Thickness__c'), '400');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '40', fieldDefs.get('Core_Thickness__c'), '400');

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Total_Layer_Count__c'), '2', fieldDefs.get('Core_Thickness__c'), '200');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Total_Layer_Count__c'), '4', fieldDefs.get('Core_Thickness__c'), '200');


        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Layer_Configuration__c'), 'Total_Via_Formula__c', fieldDefs.get('Total_Number_of_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Layer_Configuration__c'), 'Laser_Via_Formula__c', fieldDefs.get('Number_of_Laser_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Layer_Configuration__c'), 'Mech_Via_Formula__c', fieldDefs.get('Number_of_Mech_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size__c'), 'Ball_Count_Formula__c', fieldDefs.get('Number_of_BGA_Balls__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size__c'), 'Ball_Count_Formula__c', fieldDefs.get('Ball_Count__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Number_of_BGA_Balls__c'), 'Number_of_BGA_Balls__c', fieldDefs.get('Ball_Count__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Number_of_BGA_Balls__c'), 'Wire_Count_Formula__c', fieldDefs.get('Number_Of_Wires__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size__c'), 'Wire_Count_Formula__c', fieldDefs.get('Number_Of_Wires__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size__c'), 'Total_Via_Formula__c', fieldDefs.get('Total_Number_of_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size__c'), 'Laser_Via_Formula__c', fieldDefs.get('Number_of_Laser_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size__c'), 'Mech_Via_Formula__c', fieldDefs.get('Number_of_Mech_Vias__c'));

        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Number_of_BGA_Balls__c'), 'Total_Via_Formula__c', fieldDefs.get('Total_Number_of_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Number_of_BGA_Balls__c'), 'Laser_Via_Formula__c', fieldDefs.get('Number_of_Laser_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Number_of_BGA_Balls__c'), 'Mech_Via_Formula__c', fieldDefs.get('Number_of_Mech_Vias__c'));



    }
    
    /**
    * This method installs PBGA Package Families
    *
    * @returns a list of package families
    */
    private static List<Package_Family__c> installPBGAPackageFamilies() {
        
        Product_Group__c prodGroup = [select Id from Product_Group__c where Name =: 'PBGA'];
        
        List<Package_Family__c> families = new List<Package_Family__c>();
        
        FieldBuilderHelper.addPf('PBGA', prodGroup, 'RFQI_PBGA__c', 'RFQIWC_PBGA__c', 'RFQIDC_PBGA__c', families, true);
        FieldBuilderHelper.addPf('DLP', prodGroup, 'RFQI_DLP__c', null, null,null, null, families, false, 'CMExtendedBuilder');
        FieldBuilderHelper.addPf('AREA SENSOR', prodGroup, 'RFQI_AREA_SENSOR__c', null, null,null, null, families, false, 'CMExtendedBuilder');
        FieldBuilderHelper.addPf('SBGA', prodGroup, 'RFQI_SBGA__c', null, null,null, null, families, false, 'CMExtendedBuilder');
        FieldBuilderHelper.addPf('TA/FLEX BGA', prodGroup, 'RFQI_TA_FLEX_BGA__c', null, null,null, null, families, false, 'CMExtendedBuilder');
        FieldBuilderHelper.addPf('TABGA', prodGroup, 'RFQI_TABGA__c', null, null,null, null, families, false, 'CMExtendedBuilder');
        FieldBuilderHelper.addPf('CDD-IMAGE', prodGroup, 'RFQI_CCD_IMAGE__c', null, null,null, null, families, false, 'CMExtendedBuilder');
        for(Integer i=1; i < families.size(); i++){
            families[i].No_Cost_Model__c = true;
            families[i].Has_Manual_Entry_Fields__c = true;
        }
        try {
            insert families;
        }catch(Exception e) {
            system.debug('Could not install PBGA Package Families: ' + e);
        }
        return families;
    }
    
    /**
    * This method installs the field defs for the package families
    * 
    * @param pf name of the package family
    *
    * @return the list of field definitions for a specific package family
    */
    private static List<RFQI_PF_Field_Def__c> installFieldDefs(String pf) {
        FieldBuilderHelper helper = new FieldBuilderHelper(pf);
        
        //Adding Header section for BU
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
        //TODO - RGQ Projected Annual Revenue
        helper.add('BU Header', 'Au_Inclusive__c', 1140);
        helper.add('BU Header', 'End_Market_Segment__c', 1150);
        helper.add('BU Header', 'Automotive__c', 1160);
        helper.add('BU Header', 'ITAR__c', 1170);
        helper.add('BU Header', 'EAR__c', 1180);
        helper.add('BU Header', 'RFQ_Item__r.Customer_Tier__c', 1190);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__c', 1200);
        //End Header section for BU
        
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
            
        helper.add('Package Description', 'Body_Size__c', 2000, true, false, true, true);
        helper.add('Package Description', 'Number_of_BGA_Balls__c', 2010, true, false, false, true);
        helper.add('Package Description', 'Mold_Process_Type__c', 2010, true);
        helper.add('Package Description', 'Mold_Type__c', 2050, true);
        helper.add('Package Description', 'Heatspreader__c', 2070, true);
        helper.add('Package Description', 'MCM_or_Stacked__c', 2110, true);
        helper.add('Package Description', 'Backgrinding_Required__c', 2140, true);

        //helper.add('Cost and Price', 'Materials_Subs__c', 2000, false, true);
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
        //helper.add('Cost and Price', 'Base_Customer_Au_Price__c', 2360, false, true);
        //helper.add('Cost and Price', 'LGP_Market_Price__c', 2370);
        helper.add('Cost and Price', 'Operating_Cash_u__c', 2380, false, true);
        
        //helper.add('Substrate Description', 'Substrate_Body_Size__c', 3020, true);
        helper.add('Substrate Description', 'Total_Layer_Count__c', 3030, true, false, false, true);    
        helper.add('Substrate Description', 'Layer_Configuration__c', 3040, true, false, false, true);
        helper.add('Substrate Description', 'Ball_Count__c', 3050, true);
        helper.add('Substrate Description', 'Ball_Pitch__c', 3060, true);
        helper.add('Substrate Description', 'Minimum_Line_Outer__c', 3070, true);
        helper.add('Substrate Description', 'Minimum_Space_Outer__c', 3080, true);
        helper.add('Substrate Description', 'Minimum_Line_Inner__c', 3090, true);
        helper.add('Substrate Description', 'Minimum_Space_Inner__c', 3100, true);
        helper.add('Substrate Description', 'Minimum_Bond_Finger_Pitch__c', 3100, true);
        helper.add('Substrate Description', 'Total_Number_of_Vias__c', 3110, true);
        helper.add('Substrate Description', 'Mech_Via_Capture_Pad_Diam__c', 3120, true);
        helper.add('Substrate Description', 'Number_of_Mech_Vias__c', 3130, true);  
        helper.add('Substrate Description', 'Laser_Via_Capture_Pad_Diam__c', 3140, true);
        helper.add('Substrate Description', 'Number_of_Laser_Vias__c', 3150, true);
        helper.add('Substrate Description', 'Via_Fill__c', 3160, true);
        helper.add('Substrate Description', 'Soldermask_Registration__c', 3170, true);
        helper.add('Substrate Description', 'Soldermask_Material__c', 3180, true);
        helper.add('Substrate Description', 'Core_Material__c', 3190, true);
        helper.add('Substrate Description', 'Core_Thickness__c', 3200, true);
        helper.add('Substrate Description', 'Substrate_Thickness__c', 3200, true);
        helper.add('Substrate Description', 'Plating__c', 3210, true);
        helper.add('Substrate Description', 'Metal_Finish__c', 3220, true);
        helper.add('Substrate Description', 'Substrate_Supplier__c', 3230, true);   
        helper.add('Substrate Description', 'Restricted_Substrate_Supplier__c', 3240, true);
        helper.add('Substrate Description', 'Special_Options__c', 3250, true);
        
        helper.add('Wire Description', 'Wire_Configuration__c', 3000, true, false, true);
        helper.add('Wire Description', 'Wire_Material__c',   3010, true, false, true);
        helper.add('Wire Description', 'Wire_Diameter__c',   3020, true, false, true);
        helper.add('Wire Description', 'Number_Of_Wires__c', 3030, true, false, true);   
        helper.add('Wire Description', 'Average_2D_Wire_Length__c', 3040);
        helper.add('Wire Description', 'Total_2D_Wire_Length__c', 3050);
        helper.add('Wire Description', 'Total_3D_Wire_Length__c', 3060, true);
        helper.add('Wire Description', 'Au_Factor__c', 3070, true);
        
        helper.add('Die Description', 'Die_Attach__c', 3000, true);
        helper.add('Die Description', 'Die_Size_X__c', 3010, true);
        helper.add('Die Description', 'Die_Size_Y__c', 3020, true);
        helper.add('Die Description', 'Wafer_Size__c', 3040, true);
                
        helper.add('Adders', 'Plasma_Before_Die_Attach__c', 5000, true);
        helper.add('Adders', 'Inline_OS_Test__c', 5010, true);
        helper.add('Adders', 'Endline_OS_Test__c', 5020, true);
        helper.add('Adders', 'X2_OPT_INSP_100__c', 5030, true);
        helper.add('Adders', 'X3RD_OPT_100__c', 5040, true);
        helper.add('Adders', 'FVI_100__c', 5050, true);
        helper.add('Adders', 'Bake_Dry_Pack__c', 5060, true);
        helper.add('Adders', 'Temperature_Cycle__c', 5070, true);
        helper.add('Adders', 'Bake__c', 5080, true);
        helper.add('Adders', 'Passives__c', 5090, true);
        
        helper.add('NRE', 'Substrate_Design__c', 6000);
        helper.add('NRE', 'Custom_B_A_Tooling__c', 6010);
        helper.add('NRE', 'Custom_Tray_Tooling__c', 6020);
        helper.add('NRE', 'Substrate_Tooling__c', 6030);
        helper.add('NRE', 'Custom_Heatspreader_Tooling__c', 6040);
        helper.add('NRE', 'Substrate_ET_Checker__c', 6050);
        helper.add('NRE', 'Assembly_OS_Test__c', 6060);
        helper.add('NRE', 'Other__c', 6070);
                                                    
        helper.insertFields();
        
        return helper.getPfFieldDefs();                   
    }

    private static List<RFQI_PF_Field_Def__c> installExtended(string pf) {
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
        //helper.add('BU Header', 'RGQ_Projected_Annual_Revenue__c', 1120);
        helper.add('BU Header', 'Au_Inclusive__c', 1140);
        helper.add('BU Header', 'End_Market_Segment__c', 1150);
        helper.add('BU Header', 'Automotive__c', 1160);
        helper.add('BU Header', 'ITAR__c', 1170);
        helper.add('BU Header', 'EAR__c', 1180);
        helper.add('BU Header', 'RFQ_Item__r.Customer_Tier__c', 1190);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__c', 1200);
        //End Header section for BU

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

        //Adding Cost and Price section for BUs
        helper.add('Cost and Price','CLAM_Direct_Labor__c',1000,false,true);
        helper.add('Cost and Price','Materials_Total_Wire__c',1010,false,true);
        helper.add('Cost and Price','Customer_Target_Price__c',1020,false,false);
        helper.add('Cost and Price','Assembly_GM_wo_Substrate__c',1030,false,false);
        helper.add('Cost and Price','CLAM_Depreciation__c',1040,false,true);
        helper.add('Cost and Price','Materials_Substrate__c',1050,false,true);
        helper.add('Cost and Price','Sales_Target_Price__c',1060,false,false);
        helper.add('Cost and Price','Total_Perc_GM__c',1070,false,false);
        helper.add('Cost and Price','CLAM_OCOGS__c',1080,false,true);
        helper.add('Cost and Price','Materials_ODM__c',1090,false,true);
        helper.add('Cost and Price','Competitor__c', 1100,false,true);
        helper.add('Cost and Price','Perc_VAM_New__c',1110,false,false);
        helper.add('Cost and Price','CLAM_OH__c',1120,false,true);
        helper.add('Cost and Price','Materials_Subtotal__c',1130,false,true);
        helper.add('Cost and Price','Competitor_Au_Inclusive_Price__c',1140,false,true);
        helper.add('Cost and Price','BU_Price__c',1150,false,true);
        helper.add('Cost and Price','CLAM_Subtotal__c',1160,false,true);
        helper.add('Cost and Price','Subs_Markup_Perc__c',1170,false,false);
        helper.add('Cost and Price','Total_Cost__c',1180,false,true);  
        //End Adding Cost and Price section for BUs

        helper.add('Package Description', 'Package_Description_Extended__c', 2020, true, false, true);

        helper.add('NRE', 'Substrate_Design__c', 6000);
        helper.add('NRE', 'Custom_B_A_Tooling__c', 6010);
        helper.add('NRE', 'Custom_Tray_Tooling__c', 6020);
        helper.add('NRE', 'Substrate_Tooling__c', 6030);
        helper.add('NRE', 'Custom_Heatspreader_Tooling__c', 6040);
        helper.add('NRE', 'Substrate_ET_Checker__c', 6050);
        helper.add('NRE', 'Assembly_OS_Test__c', 6060);
        helper.add('NRE', 'Other__c', 6070);

        helper.insertFields();
        
        return helper.getPfFieldDefs(); 

    }

    public static void AMK1658()
    {
        delete [select Id from RFQI_PF_Field_Def__c where RFQI_Field_Def__r.Name='Base_Customer_Au_Price__c' and Package_Family__r.Name='PBGA'];
    }

    public static void AMK1797()
    {
        RFQI_PF_Field_Def__c def = [select id, name, package_family__r.name, rfqi_field_def__r.name, generated__c from rfqi_pf_field_def__c where package_family__r.name='PBGA' and rfqi_field_def__r.name='Capacity_UE_Rate__c'];
        def.Generated__c = false;
        update def;
    }
}