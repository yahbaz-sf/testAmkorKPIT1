/*************************************************************************
* 
* PURPOSE:  this class seeds fresh RFQ Item Field Definition specifically
*           for the Advanced Product package families (cloned from SOIC150Installer
*           for the purposes of generalization)
*         
* CLASS: AdvancedProductInstaller
* CREATED: 05/08/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
global class AdvancedProductInstaller {

    private static Product_Group__c prodGroup {get; set;}
    private static List<Package_Family__c> families {get; set;}
    private static List<RFQI_Default_Driver__c> drivers {get; set;}

    global static void install() {
        FieldBuilderHelper.clean('Advanced Product Development');
        prodGroup = FieldBuilderHelper.installProductGroup('Advanced Product Development', true, false, 'CMOthersBuilder');
        installAdvancedProductPackageFamilies();
        installVersion();
        installMEPFields();
        installEmergingFields();
        installTSVFields();
        //installWLFOFields();
        installOtherFields();
        //installCoCFields();
        installDefaultDrivers();
        FieldBuilderHelper.markNoCostModels('Advanced Product Development');
        
    }
    
    public static void updateSapFields() {
    	RFQAdminInstaller.updateSapFieldsForProductGroup('Advanced Product Development');  
    }
    	
        private static List<Package_Family__c> installAdvancedProductPackageFamilies() {
        
        families = new List<Package_Family__c>();
        FieldBuilderHelper.addPf('MEP', prodGroup, 'RFQI_MEP__c', 'RFQIWC_MEP__c', 'RFQIDC_MEP__c', families);
        FieldBuilderHelper.addPf('Emerging', prodGroup, 'RFQI_Emerging__c', null, null, families);
        FieldBuilderHelper.addPf('TSV', prodGroup, 'RFQI_TSV__c', null, 'RFQIDC_TSV__c', families, true);
        //FieldBuilderHelper.addPf('WLFO', prodGroup, 'RFQI_WLFO__c', 'RFQIWC_WLFO__c', 'RFQIDC_WLFO__c', families, true);
        /*FieldBuilderHelper.addPf('CoC', prodGroup, 'RFQI_CoC__c', 'RFQIWC_CoC__c', 'RFQIDC_CoC__c', families);*/
        FieldBuilderHelper.addPf('Other', prodGroup, 'RFQI_Other__c', 'RFQIWC_Other__c', 'RFQIDC_Other__c', families);
        
        try {
            insert families;
        }catch(Exception e) {
            system.debug('Could not install Advanced Product Package Families: ' + e);
        }
        return families;
    }

    private static void installVersion()
    {
        CM_Version__c cmVersion = new CM_Version__c(Product_Group__c=prodGroup.Id, Status__c='Active', Version__c=1);
        cmVersion.Wire_Die_Thickness__c = 200;
        cmVersion.Wire_Loop_Height__c = 5;
        cmVersion.Wire_DA_Thickness__c = 1;
        cmVersion.Wire_Paddle_Down__c = 0;
        cmVersion.Wire_Ball_Ratio__c = 1.8;
        insert cmVersion;

        CM_PF_Value__c pfValue;
        List<CM_PF_Value__c> pfValueList = new List<CM_PF_Value__c>();
        for (Package_Family__c family : families)
        {
            pfValue = new CM_PF_Value__c(CM_Version__C=cmVersion.Id, Package_Family__c=family.Id, Subs_Markup_Perc__c=5);
            pfValueList.add(pfValue);
        }
        insert pfValueList;
    }

    private static void installDefaultDrivers()
    {
        List<Package_Family__c> pf = [select Name, Id from Package_Family__c where Product_Group__r.Name =: 'Advanced Product Development'];
        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 

        for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
        }

        drivers = new List<RFQI_Default_Driver__c>();

        for (Package_Family__c packageFamily : pf)
        {
            FieldBuilderHelper.installDefaultDriversMath(packageFamily, fieldDefs.get('Ball_Lead_Count__c'), 'Ball_Lead_Count__c', fieldDefs.get('Number_Of_Wires__c'), drivers);
        }

        insert drivers;
    }

    private static List<RFQI_PF_Field_Def__c> installMEPFields(){
        FieldBuilderHelper helper = new FieldBuilderHelper('MEP');
        
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
        helper.add('BU Header', 'Device_Project_Name__c', 1070);
        helper.add('BU Header', 'New_Business__c', 1080);
        helper.add('BU Header', 'Forecast__c', 1090);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__r.SBU_Name__r.Customer_AU_Base_fml__c', 1100);
        helper.add('BU Header', 'RGQ_Projected_Annual_Revenue__c', 1120);
        helper.add('BU Header', 'End_Market_Segment__c', 1150);
        helper.add('BU Header', 'Automotive__c', 1160);
        helper.add('BU Header', 'ITAR__c', 1170);
        helper.add('BU Header', 'EAR__c', 1180);
        helper.add('BU Header', 'RFQ_Item__r.Customer_Tier__c', 1190);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__c', 1200);
        //End Header section for BU

        helper.add('Cost and Price','CLAM_Labor__c',1000,false,true);
        helper.add('Cost and Price','Materials_Substrate__c',1010,false,true);
        helper.add('Cost and Price','Customer_Target_Price__c',1020,false,true);
        helper.add('Cost and Price','Assembly_GM_wo_Substrate__c',1030,false,true);
        helper.add('Cost and Price','CLAM_Depreciation__c',1040,false,true);        
        helper.add('Cost and Price','Materials_ODM__c',1050,false,true);
        helper.add('Cost and Price','Competitor__c',1060,false,true);
        helper.add('Cost and Price','Total_Perc_GM__c',1070,false,true);
        helper.add('Cost and Price','CLAM_OCOGS__c',1080,false,true);
        helper.add('Cost and Price','Materials_Subtotal__c',1090,false,true);
        helper.add('Cost and Price','Competitor_Price__c',1100,false,false);
        helper.add('Cost and Price','Perc_IRR_New__c',1110,false,false);
        helper.add('Cost and Price','CLAM_OH__c', 1120,false,false);
        helper.add('Cost and Price','Cost_less_Substrate_New__c',1130,false,true);
        helper.add('Cost and Price','Model_UE_Perc__c',1140,false,false);
        helper.add('Cost and Price','Perc_VAM_New__c',1150,false,false);
        helper.add('Cost and Price','CLAM_Subtotal_New__c',1160,false,false);
        helper.add('Cost and Price','Total_Cost_with_Substrate_New__c',1170,false,true);
        helper.add('Cost and Price','Subs_Markup_Perc__c',1180,false,true);
        helper.add('Cost and Price','BU_Price__c',1190,false,false); 
        
        helper.add('Quote Information', 'Package__c', 1000);
        helper.add('Quote Information', 'Device_Project_Name__c', 1010);
        helper.add('Quote Information', 'New_Business__c', 1020);
        helper.add('Quote Information', 'Forecast__c', 1030);
        helper.add('Quote Information', 'End_Market_Segment__c', 1050);
        helper.add('Quote Information', 'HVP_Anticipated_Start_Date__c', 1060);
        
        helper.add('Package Description', 'Body_Size_X__c', 2000, true);
        helper.add('Package Description', 'Body_Size_Y__c', 2010, true);
        helper.add('Package Description', 'Leadframe_Finish__c', 2040, true);
        helper.add('Package Description', 'Body_Thickness__c', 2060, true);
        helper.add('Package Description', 'Ball_Lead_Count__c', 2070, true, false, false, true);
        helper.add('Package Description', 'Other_Components__c', 2080, true);
        //helper.add('Package Description', 'Factory__c', 2090, true);
        helper.add('Package Description', 'Number_of_Chips_per_Package__c', 2100, true);
        helper.add('Package Description', 'Mold_Type__c', 2110, true);
        helper.add('Package Description', 'Base_Customer_Au_Price__c', 2120, true);
        helper.add('Package Description', 'LGP_Market_Price__c', 2130, true);
        helper.add('Package Description', 'Capacity_UE_Rate__c', 2140, true);
        helper.add('Package Description', 'Packing_Method__c', 2160, true);
        
        helper.add('Wire Description', 'Wire_Configuration__c', 3010, true);
        helper.add('Wire Description', 'Wire_Material__c', 3010, true, false, true);
        helper.add('Wire Description', 'Wire_Diameter__c', 3020, true, false, true);
        helper.add('Wire Description', 'Number_Of_Wires__c', 3030, true, false, true);
        helper.add('Wire Description', 'Average_2D_Wire_Length__c', 3040);
        helper.add('Wire Description', 'Total_2D_Wire_Length__c', 3050);
        helper.add('Wire Description', 'Total_3D_Wire_Length__c', 3060, true);
        helper.add('Wire Description', 'Au_Factor__c', 3070);
        
        helper.add('Die Description', 'Die_Attach__c', 3000, true);
        helper.add('Die Description', 'Wafer_Material__c', 3010, true);
        helper.add('Die Description', 'Wafer_Size__c', 3020, true);
        helper.add('Die Description', 'Wafer_Technology__c', 3030, true);   
        helper.add('Die Description', 'Wafer_Thickness__c', 3040, true);
        helper.add('Die Description', 'Chip_Size_X__c', 3050, true);
        helper.add('Die Description', 'Chip_Size_Y__c', 3060, true);
        helper.add('Die Description', 'Laser_Groove__c', 3070, true);
        helper.add('Die Description', 'WBG_Final_Thickness__c', 3080, true);
        helper.add('Die Description', 'WBG_Required__c', 3090, true);  

        helper.add('Substrate Description', 'OS_Sampling_Perc__c', 3020, true);
        helper.add('Substrate Description', 'Amkor_Purchased_Substrate__c', 3030, true);        
        helper.add('Substrate Description', 'Number_of_Layers_Core__c', 3040, true);
        helper.add('Substrate Description', 'Number_of_Layers_Buildup__c', 3050, true);
        helper.add('Substrate Description', 'Line_and_Space_Core__c', 3060, true);  
        helper.add('Substrate Description', 'Line_and_Space_Buildup__c', 3070, true);
        helper.add('Substrate Description', 'Via_and_Pad_Size_Core__c', 3080, true);    
        helper.add('Substrate Description', 'Via_and_Pad_Size_Buildup__c', 3090, true);
        helper.add('Substrate Description', 'Number_of_Stacked_Via__c', 3100, true);
        helper.add('Substrate Description', 'Other_Options__c', 3110, true);
        
        helper.add('Adders', 'Extra_Plasma__c', 5000, true);
        helper.add('Adders', 'Plasma_Before_Wire_Bond__c', 5010, true);
        helper.add('Adders', 'Plasma_Before_Die_Attach__c', 5020, true);
        helper.add('Adders', 'Optical_Inspections__c', 5030, true);    
        helper.add('Adders', 'Plasma_Before_Mold__c', 5040, true);
        helper.add('Adders', 'Optical_Inspection_1__c', 5050, true);
        helper.add('Adders', 'Optical_Inspection_2__c', 5060, true);
        helper.add('Adders', 'Optical_Inspection_3__c', 5070, true);
        helper.add('Adders', 'Bake_Dry_Pack__c', 5080, true);
        helper.add('Adders', 'Temperature_Cycle__c', 5090, true);
        helper.add('Adders', 'Bake__c', 5100, true);
        helper.add('Adders', 'Heatspreader__c', 5110, true);
        
        
        helper.add('NRE', 'Art_Work__c', 4000, true);
        helper.add('NRE', 'Electrical_Simulation__c', 4010, true);
        helper.add('NRE', 'Stencil_for_SMT__c', 4020, true);
        helper.add('NRE', 'X3D_Wire_Bond_Simulation__c', 4030, true);
        helper.add('NRE', 'Substrate_Design__c', 4040, true);
        helper.add('NRE', 'Substrate_Artwork_per_Supplier__c', 4050, true);
        helper.add('NRE', 'Package_Singulation_Tool__c', 4060, true);
        helper.add('NRE', 'Reliability_Testing__c', 4070, true);
        helper.add('NRE', 'Heater_Spreader_Design__c', 4080, true);
        helper.add('NRE', 'Substrate_ET_Checker__c', 4090, true);
        helper.add('NRE', 'Tray__c', 4100, true);
        helper.add('NRE', 'MRT_TC_HAST_HTS__c', 4110, true);
        helper.add('NRE', 'Package_Substrate_Co_Design__c', 4120, true);
        helper.add('NRE', 'Auto_BAT__c', 4140, true);
        helper.add('NRE', 'Custom_Mold_Chase__c', 4150, true);
        helper.add('NRE', 'bHast__c', 4160, true);
        helper.add('NRE', 'Thermal_Simualtion__c', 4170, true);
        helper.add('NRE', 'Manual_BAT__c', 4180, true);
        helper.add('NRE', 'Modeling_Charges__c', 4190, true);
        helper.add('NRE', 'Custom_Lid_Tooling__c', 4200, true);
        helper.add('NRE', 'BLR_Simulation__c', 4210, true);
        helper.add('NRE', 'Other__c', 4220, true);
            
        
        helper.insertFields();
        
        return helper.getPfFieldDefs();
    }
    
    private static List<RFQI_PF_Field_Def__c> installEmergingFields(){
        FieldBuilderHelper helper = new FieldBuilderHelper('Emerging');
        
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
        helper.add('BU Header', 'Device_Project_Name__c', 1070);
        helper.add('BU Header', 'Forecast__c', 1090);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__r.SBU_Name__r.Customer_AU_Base_fml__c', 1100);
        helper.add('BU Header', 'RGQ_Projected_Annual_Revenue__c', 1120);
        helper.add('BU Header', 'End_Market_Segment__c', 1150);
        helper.add('BU Header', 'Automotive__c', 1160);
        helper.add('BU Header', 'ITAR__c', 1170);
        helper.add('BU Header', 'EAR__c', 1180);
        helper.add('BU Header', 'RFQ_Item__r.Customer_Tier__c', 1190);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__c', 1200);
        //End Header section for BU
        
        helper.add('Cost and Price','CLAM_Labor__c',1000,false,true);
        helper.add('Cost and Price','Materials_Substrate__c',1010,false,true);
        helper.add('Cost and Price','Customer_Target_Price__c',1020,false,true);
        helper.add('Cost and Price','Assembly_GM_wo_Substrate__c',1030,false,true);
        helper.add('Cost and Price','CLAM_Depreciation__c',1040,false,true);        
        helper.add('Cost and Price','Materials_ODM__c',1050,false,true);
        helper.add('Cost and Price','Competitor__c',1060,false,true);
        helper.add('Cost and Price','Total_Perc_GM__c',1070,false,true);
        helper.add('Cost and Price','CLAM_OCOGS__c',1080,false,true);
        helper.add('Cost and Price','Materials_Subtotal__c',1090,false,true);
        helper.add('Cost and Price','Competitor_Price__c',1100,false,false);
        helper.add('Cost and Price','Perc_IRR_New__c',1110,false,false);
        helper.add('Cost and Price','CLAM_OH__c', 1120,false,false);
        helper.add('Cost and Price','Cost_less_Substrate_New__c',1130,false,true);
        helper.add('Cost and Price','Model_UE_Perc__c',1140,false,false);
        helper.add('Cost and Price','Perc_VAM_New__c',1150,false,false);
        helper.add('Cost and Price','CLAM_Subtotal_New__c',1160,false,false);
        helper.add('Cost and Price','Total_Cost_with_Substrate_New__c',1170,false,true);
        helper.add('Cost and Price','Subs_Markup_Perc__c',1180,false,true);
        helper.add('Cost and Price','BU_Price__c',1190,false,false); 
        
        helper.add('Quote Information', 'Package__c', 1000);
        helper.add('Quote Information', 'Device_Project_Name__c', 1010);
        helper.add('Quote Information', 'Forecast__c', 1030);
        helper.add('Quote Information', 'End_Market_Segment__c', 1050);
        helper.add('Quote Information', 'HVP_Anticipated_Start_Date__c', 1060);
        
        helper.add('Package Description', 'Body_Size_X__c', 2000, true);
        helper.add('Package Description', 'Body_Size_Y__c', 2010, true);
        helper.add('Package Description', 'Body_Thickness__c', 2060, true);
        helper.add('Package Description', 'Ball_Lead_Count__c', 2070, true, false, false, true);
        //helper.add('Package Description', 'Factory__c', 2090, true);
        helper.add('Package Description', 'Number_of_Chips_per_Package__c', 2100, true);
        
        helper.add('NRE', 'Art_Work__c', 4000, true);
        helper.add('NRE', 'Electrical_Simulation__c', 4010, true);
        helper.add('NRE', 'Stencil_for_SMT__c', 4020, true);
        helper.add('NRE', 'X3D_Wire_Bond_Simulation__c', 4030, true);
        helper.add('NRE', 'Substrate_Design__c', 4040, true);
        helper.add('NRE', 'Substrate_Artwork_per_Supplier__c', 4050, true);
        helper.add('NRE', 'Package_Singulation_Tool__c', 4060, true);
        helper.add('NRE', 'Reliability_Testing__c', 4070, true);
        helper.add('NRE', 'Heater_Spreader_Design__c', 4080, true);
        helper.add('NRE', 'Substrate_ET_Checker__c', 4090, true);
        helper.add('NRE', 'Tray__c', 4100, true);
        helper.add('NRE', 'MRT_TC_HAST_HTS__c', 4110, true);
        helper.add('NRE', 'Package_Substrate_Co_Design__c', 4120, true);
        helper.add('NRE', 'Auto_BAT__c', 4140, true);
        helper.add('NRE', 'Custom_Mold_Chase__c', 4150, true);
        helper.add('NRE', 'bHast__c', 4160, true);
        helper.add('NRE', 'Thermal_Simualtion__c', 4170, true);
        helper.add('NRE', 'Manual_BAT__c', 4180, true);
        helper.add('NRE', 'Modeling_Charges__c', 4190, true);
        helper.add('NRE', 'Custom_Lid_Tooling__c', 4200, true);
        helper.add('NRE', 'BLR_Simulation__c', 4210, true);
        helper.add('NRE', 'Other__c', 4220, true);
        
        helper.insertFields();
        
        return helper.getPfFieldDefs();
    }
    
    private static List<RFQI_PF_Field_Def__c> installTSVFields(){
        FieldBuilderHelper helper = new FieldBuilderHelper('TSV');
        
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
        helper.add('BU Header', 'Device_Project_Name__c', 1070);
        helper.add('BU Header', 'New_Business__c', 1080);
        helper.add('BU Header', 'Forecast__c', 1090);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__r.SBU_Name__r.Customer_AU_Base_fml__c', 1100);
        helper.add('BU Header', 'RGQ_Projected_Annual_Revenue__c', 1120);
        helper.add('BU Header', 'End_Market_Segment__c', 1150);
        helper.add('BU Header', 'Automotive__c', 1160);
        helper.add('BU Header', 'ITAR__c', 1170);
        helper.add('BU Header', 'EAR__c', 1180);
        helper.add('BU Header', 'RFQ_Item__r.Customer_Tier__c', 1190);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__c', 1200);
        //End Header section for BU
        
        helper.add('Cost and Price','CLAM_Labor__c',1000,false,true);
        helper.add('Cost and Price','Materials_Substrate__c',1010,false,true);
        helper.add('Cost and Price','Customer_Target_Price__c',1020,false,true);
        helper.add('Cost and Price','Assembly_GM_wo_Substrate__c',1030,false,true);
        helper.add('Cost and Price','CLAM_Depreciation__c',1040,false,true);        
        helper.add('Cost and Price','Materials_ODM__c',1050,false,true);
        helper.add('Cost and Price','Competitor__c',1060,false,true);
        helper.add('Cost and Price','Total_Perc_GM__c',1070,false,true);
        helper.add('Cost and Price','CLAM_OCOGS__c',1080,false,true);
        helper.add('Cost and Price','Materials_Subtotal__c',1090,false,true);
        helper.add('Cost and Price','Competitor_Price__c',1100,false,false);
        helper.add('Cost and Price','Perc_IRR_New__c',1110,false,false);
        helper.add('Cost and Price','CLAM_OH__c', 1120,false,false);
        helper.add('Cost and Price','Cost_less_Substrate_New__c',1130,false,true);
        helper.add('Cost and Price','Model_UE_Perc__c',1140,false,false);
        helper.add('Cost and Price','Perc_VAM_New__c',1150,false,false);
        helper.add('Cost and Price','CLAM_Subtotal_New__c',1160,false,false);
        helper.add('Cost and Price','Total_Cost_with_Substrate_New__c',1170,false,true);
        helper.add('Cost and Price','Subs_Markup_Perc__c',1180,false,true);
        helper.add('Cost and Price','BU_Price__c',1190,false,false); 
        
        helper.add('Quote Information', 'Package__c', 1000);
        helper.add('Quote Information', 'Device_Project_Name__c', 1010);
        helper.add('Quote Information', 'New_Business__c', 1020);
        helper.add('Quote Information', 'Forecast__c', 1030);
        helper.add('Quote Information', 'End_Market_Segment__c', 1050);
        helper.add('Quote Information', 'HVP_Anticipated_Start_Date__c', 1060);
        
        helper.add('Package Description', 'Body_Size_X__c', 2000, true);
        helper.add('Package Description', 'Body_Size_Y__c', 2010, true);
        helper.add('Package Description', 'Body_Thickness__c', 2060, true);
        helper.add('Package Description', 'Ball_Lead_Count__c', 2070, true, false, false, true);
        //helper.add('Package Description', 'Factory__c', 2090, true);
        helper.add('Package Description', 'Interposer_Or_Active_TSV_Wafer__c', 2120, true);
        helper.add('Package Description', 'Interposer_Size_X__c', 2130, true);
        helper.add('Package Description', 'Interposer_Size_Y__c', 2140, true);
        helper.add('Package Description', 'Interposer_Wafer_Size__c', 2150, true);
        helper.add('Package Description', 'Interposer_TSV_Diameter__c', 2160, true);
        helper.add('Package Description', 'Interposer_TSV_Depth__c', 2170, true);
        helper.add('Package Description', 'Interposer_TSV_Material__c', 2180, true);
        helper.add('Package Description', 'Interposer_Bump_Count__c', 2190, true);
        helper.add('Package Description', 'Interposer_Bump_Pitch__c', 2200, true);
        helper.add('Package Description', 'Interposer_Supplier__c', 2210, true);
        helper.add('Package Description', 'Interposer_BS_Bump_Comp__c', 2220, true);
        helper.add('Package Description', 'Amkor_Standard_BS_Interposer_Processing__c', 2230, true);
        helper.add('Package Description', 'RDL_Required_On_Interposer_BS__c', 2240, true);
        helper.add('Package Description', 'Chips_per_Package__c', 2250, true);
        helper.add('Package Description', 'Package_Assembly_per_Amkor_Rec__c', 2260, true);
        helper.add('Package Description', 'Heatspreader__c', 2270, true);
        helper.add('Package Description', 'Packing_Method__c', 2280, true);
        
        helper.add('Die Description', 'Die_Size_X__c', 3000, true, false, false, false, '', true);
        helper.add('Die Description', 'Die_Size_Y__c', 3010, true, false, false, false, '', true);
        helper.add('Die Description', 'Die_Pitch__c', 3020, true);
        helper.add('Die Description', 'Die_Bump_Comp__c', 3030, true);
        helper.add('Die Description', 'Amkor_Bumped__c', 3040, true);
        helper.add('Die Description', 'Die_Bump_Count__c', 3050, true);
        helper.add('Die Description', 'WBG_Final_Thickness__c', 3060, true);
        helper.add('Die Description', 'Technology_Node__c', 3070, true);
        helper.add('Die Description', 'Chip_is_Memory__c', 3080, true);
        helper.add('Die Description', 'Chip_Power_Dissipation__c', 3090, true);
        helper.add('Die Description', 'Closest_Die_to_Die_Spacing__c', 3100, true); 
        
        helper.add('Substrate Description', 'Number_of_SMDs_On_Substrate__c', 3000, true);
        //# of SMDs on ___? Spreadsheet not clear on next item
        helper.add('Substrate Description', 'Substrate_Core__c', 3010, true);
        helper.add('Substrate Description', 'Substrate_Layer_Count_Stack_Up__c', 3020, true);
        helper.add('Substrate Description', 'Amkor_Purchased_Substrate__c', 3030, true);
        
        helper.add('NRE', 'Art_Work__c', 4000, true);
        helper.add('NRE', 'Electrical_Simulation__c', 4010, true);
        helper.add('NRE', 'Stencil_for_SMT__c', 4020, true);
        helper.add('NRE', 'X3D_Wire_Bond_Simulation__c', 4030, true);
        helper.add('NRE', 'Substrate_Design__c', 4040, true);
        helper.add('NRE', 'Substrate_Artwork_per_Supplier__c', 4050, true);
        helper.add('NRE', 'Package_Singulation_Tool__c', 4060, true);
        helper.add('NRE', 'Reliability_Testing__c', 4070, true);
        helper.add('NRE', 'Heater_Spreader_Design__c', 4080, true);
        helper.add('NRE', 'Substrate_ET_Checker__c', 4090, true);
        helper.add('NRE', 'Tray__c', 4100, true);
        helper.add('NRE', 'MRT_TC_HAST_HTS__c', 4110, true);
        helper.add('NRE', 'Package_Substrate_Co_Design__c', 4120, true);
        helper.add('NRE', 'Auto_BAT__c', 4140, true);
        helper.add('NRE', 'Custom_Mold_Chase__c', 4150, true);
        helper.add('NRE', 'bHast__c', 4160, true);
        helper.add('NRE', 'Thermal_Simualtion__c', 4170, true);
        helper.add('NRE', 'Manual_BAT__c', 4180, true);
        helper.add('NRE', 'Modeling_Charges__c', 4190, true);
        helper.add('NRE', 'Custom_Lid_Tooling__c', 4200, true);
        helper.add('NRE', 'Interposer_Masks__c', 4210, true);
        helper.add('NRE', 'BLR_Simulation__c', 4220, true);
        helper.add('NRE', 'Other__c', 4230, true);
        helper.add('NRE','TC_Bond_Head_Tooling_per_Die__c', 4240, true);
        helper.addLotChargeField('NRE','Interposer_Lot_Charge__c', 4250, true);
        helper.add('NRE','TC_Bond_Head_Tooling_Interposer__c', 4270, true);
        helper.addLotChargeField('NRE','Assembly_Lot_Charge__c', 4290, true);
        helper.add('NRE','UF_Boat_Tooling__c', 4300, true);
        
        helper.insertFields();
        
        return helper.getPfFieldDefs();
        
    }
    
    /*private static List<RFQI_PF_Field_Def__c> installWLFOFields(){
        FieldBuilderHelper helper = new FieldBuilderHelper('WLFO');
        
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
        helper.add('BU Header', 'Device_Project_Name__c', 1070);
        helper.add('BU Header', 'New_Business__c', 1080);
        helper.add('BU Header', 'Forecast__c', 1090);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__r.SBU_Name__r.Customer_AU_Base_fml__c', 1100);
        helper.add('BU Header', 'RGQ_Projected_Annual_Revenue__c', 1120);
        helper.add('BU Header', 'End_Market_Segment__c', 1150);
        helper.add('BU Header', 'Automotive__c', 1160);
        helper.add('BU Header', 'ITAR__c', 1170);
        helper.add('BU Header', 'EAR__c', 1180);
        helper.add('BU Header', 'RFQ_Item__r.Customer_Tier__c', 1190);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__c', 1200);
        //End Header section for BU
        
        helper.add('Cost and Price','CLAM_Labor__c',1000,false,true);
        helper.add('Cost and Price','CLAM_Depreciation__c',1010,false,true);
        helper.add('Cost and Price','CLAM_OCOGS__c',1020,false,true);
        helper.add('Cost and Price','CLAM_OH__c',1030,false,true);
        helper.add('Cost and Price','CLAM_Subtotal_New__c',1040,false,true);
        helper.add('Cost and Price','Materials_Bumping__c',1050,false,true);
        helper.add('Cost and Price','Materials_Assembly__c',1060,false,true);
        helper.add('Cost and Price','Materials_Subtotal__c',1070,false,true);
        helper.add('Cost and Price','Total_Cost__c',1080,false,true);
        helper.add('Cost and Price','Customer_Target_Price__c',1090,false,false);
        helper.add('Cost and Price','Competitor__c', 1100,false,false);
        helper.add('Cost and Price','Competitor_Price__c', 1110,false,false);
        helper.add('Cost and Price','Model_UE_Perc__c',1120,false,true);
        helper.add('Cost and Price','Total_Perc_GM__c',1130,false,false);
        helper.add('Cost and Price','Perc_IRR_New__c',1140,false,true);
        helper.add('Cost and Price','Perc_VAM_New__c',1150,false,true);
        helper.add('Cost and Price','BU_Price__c',1160,false,true); 
        
        helper.add('Quote Information', 'Package__c', 1000);
        helper.add('Quote Information', 'Device_Project_Name__c', 1010);
        helper.add('Quote Information', 'New_Business__c', 1020);
        helper.add('Quote Information', 'Forecast__c', 1030);
        helper.add('Quote Information', 'End_Market_Segment__c', 1050);
        helper.add('Quote Information', 'HVP_Anticipated_Start_Date__c', 1060);
        
        helper.add('Package Description', 'Body_Size_X__c', 2000, true);
        helper.add('Package Description', 'Body_Size_Y__c', 2010, true);
        helper.add('Package Description', 'Body_Thickness__c', 2020, true);
        //helper.add('Package Description', 'Factory__c', 2030, true);
        helper.add('Package Description', 'Package_Thickness__c', 2040, true);
        helper.add('Package Description', 'Number_Of_Die__c', 2050, true);
        helper.add('Package Description', 'X2D_Or_3D_Structure__c', 2060, true);
        helper.add('Package Description', 'Bond_Pad_Opening__c', 2070, true);
        helper.add('Package Description', 'Bond_Pad_Pitch__c', 2080, true);
        helper.add('Package Description', 'BGA_Count__c', 2090, true);
        helper.add('Package Description', 'BGA_Pitch__c', 2100, true);
        helper.add('Package Description', 'Min_MSL_Requirement__c', 2110, true);
        helper.add('Package Description', 'Packing_Method__c', 2160, true);
        helper.add('Package Description', 'Bake_Dry_Pack__c', 2170, true);
        
        helper.add('Die Description', 'Die_Size_X__c', 3000, true, false, false, false, '', true);
        helper.add('Die Description', 'Die_Size_Y__c', 3010, true, false, false, false, '', true);
        helper.add('Die Description', 'Wafer_Size__c', 3020, true);
        helper.add('Die Description', 'Wafer_Material__c', 3030, true);
        helper.add('Die Description', 'Wafer_Thickness__c', 3040, true);
        helper.add('Die Description', 'Wafer_Technology__c', 3050, true);
        helper.add('Die Description', 'Wafer_Yield__c', 3060, true);
        helper.add('Die Description', 'Die_Thickness__c', 3070, true);
        
        helper.add('Substrate Description', 'Number_Of_RDL_Layers__c', 3000, true);
        helper.add('Substrate Description', 'Min_RDL_Line_and_Space__c', 3010, true);
        helper.add('Substrate Description', 'Number_of_TMVs__c', 3020, true);
        helper.add('Substrate Description', 'Raw_Solder_Ball_Diameter__c', 3030, true);
        helper.add('Substrate Description', 'OS_Sampling_Perc__c', 3040, true);
        
        helper.add('NRE', 'Photo_Masks__c', 4000, true);
        helper.add('NRE', 'Laser_Masks__c', 4010, true);
        helper.add('NRE', 'Flux_Stencil__c', 4020, true);
        helper.add('NRE', 'Ball_Attach_Stencil__c', 4030, true);
        helper.add('NRE', 'Custom_Pocket_Tape__c', 4040, true);
        helper.add('NRE', 'Design_Fee__c', 4050, true);
        helper.add('NRE', 'Modeling_Charges__c', 4060, true);
        helper.add('NRE', 'Thermal_Simualtion__c', 4070, true);
        helper.add('NRE', 'Electrical_Simulation__c', 4080, true);
        helper.add('NRE', 'BLR_Simulation__c', 4090, true);
        helper.addLotChargeField('NRE', 'Engineering_Lot_Charge__c', 4100, true);
        helper.addLotChargeField('NRE', 'Small_Lot_Charge__c', 4110, true);
        helper.add('NRE', 'Reliability_Testing__c', 4120, true);
        helper.add('NRE', 'MRT_TC_HAST_HTS__c', 4130, true);
        helper.add('NRE', 'bHast__c', 4140, true);
        helper.add('NRE', 'Other__c', 4150, true);
        
        helper.insertFields();
        
        return helper.getPfFieldDefs();
    }*/
    
    
    
    private static List<RFQI_PF_Field_Def__c> installOtherFields(){
        FieldBuilderHelper helper = new FieldBuilderHelper('Other');
        
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
        helper.add('BU Header', 'Device_Project_Name__c', 1070);
        helper.add('BU Header', 'New_Business__c', 1080);
        helper.add('BU Header', 'Forecast__c', 1090);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__r.SBU_Name__r.Customer_AU_Base_fml__c', 1100);
        helper.add('BU Header', 'RGQ_Projected_Annual_Revenue__c', 1120);
        helper.add('BU Header', 'End_Market_Segment__c', 1150);
        helper.add('BU Header', 'Automotive__c', 1160);
        helper.add('BU Header', 'ITAR__c', 1170);
        helper.add('BU Header', 'EAR__c', 1180);
        helper.add('BU Header', 'RFQ_Item__r.Customer_Tier__c', 1190);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__c', 1200);
        //End Header section for BU
        
        helper.add('Cost and Price','CLAM_Labor__c',1000,false,true);
        helper.add('Cost and Price','Materials_Substrate__c',1010,false,true);
        helper.add('Cost and Price','Customer_Target_Price__c',1020,false,true);
        helper.add('Cost and Price','Assembly_GM_wo_Substrate__c',1030,false,true);
        helper.add('Cost and Price','CLAM_Depreciation__c',1040,false,true);        
        helper.add('Cost and Price','Materials_ODM__c',1050,false,true);
        helper.add('Cost and Price','Competitor__c',1060,false,true);
        helper.add('Cost and Price','Total_Perc_GM__c',1070,false,true);
        helper.add('Cost and Price','CLAM_OCOGS__c',1080,false,true);
        helper.add('Cost and Price','Materials_Subtotal__c',1090,false,true);
        helper.add('Cost and Price','Competitor_Price__c',1100,false,false);
        helper.add('Cost and Price','Perc_IRR_New__c',1110,false,false);
        helper.add('Cost and Price','CLAM_OH__c', 1120,false,false);
        helper.add('Cost and Price','Cost_less_Substrate_New__c',1130,false,true);
        helper.add('Cost and Price','Model_UE_Perc__c',1140,false,false);
        helper.add('Cost and Price','Perc_VAM_New__c',1150,false,false);
        helper.add('Cost and Price','CLAM_Subtotal_New__c',1160,false,false);
        helper.add('Cost and Price','Total_Cost_with_Substrate_New__c',1170,false,true);
        helper.add('Cost and Price','Subs_Markup_Perc__c',1180,false,true);
        helper.add('Cost and Price','BU_Price__c',1190,false,false); 
        
        helper.add('Quote Information', 'Package__c', 1000);
        helper.add('Quote Information', 'Device_Project_Name__c', 1010);
        helper.add('Quote Information', 'New_Business__c', 1020);
        helper.add('Quote Information', 'Forecast__c', 1030);
        helper.add('Quote Information', 'End_Market_Segment__c', 1050);
        helper.add('Quote Information', 'HVP_Anticipated_Start_Date__c', 1060);
        
        helper.add('Package Description', 'Body_Size_X__c', 2000, true);
        helper.add('Package Description', 'Body_Size_Y__c', 2010, true);
        helper.add('Package Description', 'Leadframe_Finish__c', 2040, true);
        helper.add('Package Description', 'Body_Thickness__c', 2060, true);
        helper.add('Package Description', 'Ball_Lead_Count__c', 2070, true, false, false, true);
        helper.add('Package Description', 'Other_Components__c', 2080, true);
        //helper.add('Package Description', 'Factory__c', 2090, true);
        helper.add('Package Description', 'Number_of_Chips_per_Package__c', 2100, true);
        helper.add('Package Description', 'Mold_Type__c', 2110, true);
        helper.add('Package Description', 'Base_Customer_Au_Price__c', 2070, true);
        helper.add('Package Description', 'LGP_Market_Price__c', 2080, true);
        helper.add('Package Description', 'Capacity_UE_Rate__c', 2090, true);
        helper.add('Package Description', 'Packing_Method__c', 2110, true);
        
        helper.add('Wire Description', 'Wire_Configuration__c', 3000, true);
        helper.add('Wire Description', 'Wire_Material__c', 3010, true, false, true);
        helper.add('Wire Description', 'Wire_Diameter__c', 3020, true, false, true);
        helper.add('Wire Description', 'Number_Of_Wires__c', 3030, true, false, true);
        helper.add('Wire Description', 'Average_2D_Wire_Length__c', 3040);
        helper.add('Wire Description', 'Total_2D_Wire_Length__c', 3050);
        helper.add('Wire Description', 'Total_3D_Wire_Length__c', 3060, true);
        helper.add('Wire Description', 'Au_Factor__c', 3070);
        
        helper.add('Die Description', 'Die_Attach__c', 3000, true);
        helper.add('Die Description', 'Wafer_Material__c', 3010, true);
        helper.add('Die Description', 'Wafer_Size__c', 3020, true);
        helper.add('Die Description', 'Wafer_Technology__c', 3030, true);   
        helper.add('Die Description', 'Wafer_Thickness__c', 3040, true);
        helper.add('Die Description', 'Chip_Size_X__c', 3050, true);
        helper.add('Die Description', 'Chip_Size_Y__c', 3060, true);
        helper.add('Die Description', 'Laser_Groove__c', 3070, true);
        helper.add('Die Description', 'WBG_Final_Thickness__c', 3080, true);
        helper.add('Die Description', 'WBG_Required__c', 3090, true);
        
        helper.add('Substrate Description', 'OS_Sampling_Perc__c', 3020, true);
        helper.add('Substrate Description', 'Amkor_Purchased_Substrate__c', 3030, true);        
        helper.add('Substrate Description', 'Number_of_Layers_Core__c', 3040, true);
        helper.add('Substrate Description', 'Number_of_Layers_Buildup__c', 3050, true);
        helper.add('Substrate Description', 'Line_and_Space_Core__c', 3060, true);  
        helper.add('Substrate Description', 'Line_and_Space_Buildup__c', 3070, true);
        helper.add('Substrate Description', 'Via_and_Pad_Size_Core__c', 3080, true);    
        helper.add('Substrate Description', 'Via_and_Pad_Size_Buildup__c', 3090, true);
        helper.add('Substrate Description', 'Number_of_Stacked_Via__c', 3100, true);
        helper.add('Substrate Description', 'Other_Options__c', 3110, true);
        
        helper.add('Adders', 'Plasma_Before_Die_Attach__c', 5000, true);
        helper.add('Adders', 'Plasma_Before_Wire_Bond__c', 5010, true);
        helper.add('Adders', 'Plasma_Before_Mold__c', 5020, true);
        helper.add('Adders', 'Optical_Inspection_1__c', 5030, true);
        helper.add('Adders', 'Optical_Inspection_2__c', 5040, true);
        helper.add('Adders', 'Optical_Inspection_3__c', 5050, true);
        helper.add('Adders', 'Bake_Dry_Pack__c', 5060, true);
        helper.add('Adders', 'Temperature_Cycle__c', 5070, true);
        helper.add('Adders', 'Bake__c', 5080, true);
        helper.add('Adders', 'Heatspreader__c', 5090, true);
        helper.add('Adders', 'Extra_Plasma__c', 5100, true);
        
        helper.add('NRE', 'Art_Work__c', 4000, true);
        helper.add('NRE', 'Electrical_Simulation__c', 4010, true);
        helper.add('NRE', 'Stencil_for_SMT__c', 4020, true);
        helper.add('NRE', 'X3D_Wire_Bond_Simulation__c', 4030, true);
        helper.add('NRE', 'Substrate_Design__c', 4040, true);
        helper.add('NRE', 'Substrate_Artwork_per_Supplier__c', 4050, true);
        helper.add('NRE', 'Package_Singulation_Tool__c', 4060, true);
        helper.add('NRE', 'Reliability_Testing__c', 4070, true);
        helper.add('NRE', 'Heater_Spreader_Design__c', 4080, true);
        helper.add('NRE', 'Substrate_ET_Checker__c', 4090, true);
        helper.add('NRE', 'Tray__c', 4100, true);
        helper.add('NRE', 'MRT_TC_HAST_HTS__c', 4110, true);
        helper.add('NRE', 'Package_Substrate_Co_Design__c', 4120, true);
        helper.add('NRE', 'Auto_BAT__c', 4140, true);
        helper.add('NRE', 'Custom_Mold_Chase__c', 4150, true);
        helper.add('NRE', 'bHast__c', 4160, true);
        helper.add('NRE', 'Thermal_Simualtion__c', 4170, true);
        helper.add('NRE', 'Manual_BAT__c', 4180, true);
        helper.add('NRE', 'Modeling_Charges__c', 4190, true);
        helper.add('NRE', 'Custom_Lid_Tooling__c', 4200, true);
        helper.add('NRE', 'BLR_Simulation__c', 4210, true);
        helper.add('NRE', 'Other__c', 4220, true);
        
        helper.insertFields();
        
        return helper.getPfFieldDefs();
    }

    /*private static List<RFQI_PF_Field_Def__c> installCoCFields(){
        FieldBuilderHelper helper = new FieldBuilderHelper('CoC');
    
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
        helper.add('BU Header', 'Device_Project_Name__c', 1070);
        helper.add('BU Header', 'New_Business__c', 1080);
        helper.add('BU Header', 'Forecast__c', 1090);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__r.SBU_Name__r.Customer_AU_Base_fml__c', 1100);
        helper.add('BU Header', 'RGQ_Projected_Annual_Revenue__c', 1120);
        helper.add('BU Header', 'End_Market_Segment__c', 1150);
        helper.add('BU Header', 'Automotive__c', 1160);
        helper.add('BU Header', 'ITAR__c', 1170);
        helper.add('BU Header', 'EAR__c', 1180);
        helper.add('BU Header', 'RFQ_Item__r.Customer_Tier__c', 1190);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__c', 1200);
        //End Header section for BU
        
        helper.add('Cost and Price','CLAM_Labor__c',1000,false,true);
        helper.add('Cost and Price','CLAM_Depreciation__c',1010,false,true);
        helper.add('Cost and Price','CLAM_OCOGS__c',1020,false,true);
        helper.add('Cost and Price','CLAM_OH__c',1030,false,true);
        helper.add('Cost and Price','CLAM_Subtotal_New__c',1040,false,true);        
        helper.add('Cost and Price','Materials_Substrate__c',1050,false,true);
        helper.add('Cost and Price','Materials_ODM__c',1060,false,true);
        helper.add('Cost and Price','Materials_Subtotal__c',1070,false,true);
        helper.add('Cost and Price','Cost_less_Substrate_New__c',1080,false,true);
        helper.add('Cost and Price','Total_Cost_with_Substrate_New__c',1090,false,true);
        helper.add('Cost and Price','Customer_Target_Price__c',1100,false,false);
        helper.add('Cost and Price','Competitor__c',1110,false,false);
        helper.add('Cost and Price','Competitor_Price__c', 1120,false,false);
        helper.add('Cost and Price','Model_UE_Perc__c',1130,false,true);
        helper.add('Cost and Price','Subs_Markup_Perc__c',1140,false,false);
        helper.add('Cost and Price','Assembly_GM_wo_Substrate__c',1150,false,false);
        helper.add('Cost and Price','Total_Perc_GM__c',1160,false,false);
        helper.add('Cost and Price','Perc_IRR_New__c',1170,false,true);
        helper.add('Cost and Price','Perc_VAM_New__c',1180,false,true);
        helper.add('Cost and Price','BU_Price__c',1190,false,true); 
            
        
        helper.add('Quote Information', 'Package__c', 1000);
        helper.add('Quote Information', 'Device_Project_Name__c', 1010);
        helper.add('Quote Information', 'New_Business__c', 1020);
        helper.add('Quote Information', 'Forecast__c', 1030);
        helper.add('Quote Information', 'End_Market_Segment__c', 1050);
        helper.add('Quote Information', 'HVP_Anticipated_Start_Date__c', 1060);
        
        helper.add('Package Description', 'Body_Size_X__c', 2000, true);
        helper.add('Package Description', 'Body_Size_Y__c', 2010, true);
        helper.add('Package Description', 'Body_Thickness__c', 2020, true);
        helper.add('Package Description', 'Ball_Lead_Count__c', 2030, true, false, false, true);
        //helper.add('Package Description', 'Factory__c', 2040, true);
        helper.add('Package Description', 'Number_of_Chips_per_Package__c', 2050, true);
        
        helper.add('Die Description', 'Wafer_Thickness_Post_Backgrind__c', 3010, true); 
        helper.add('Die Description', 'Wafer_Size__c', 3020, true);
        helper.add('Die Description', 'Incoming_Wafer_Yield__c', 3030, true);
        helper.add('Die Description', 'Die_Wafer__c', 3040, true);
        helper.add('Die Description', 'Chip_Size_X__c', 3050, true);
        helper.add('Die Description', 'Chip_Size_Y__c', 3060, true);
        helper.add('Die Description', 'Chip_Bump_Pitch__c', 3070, true);
        helper.add('Die Description', 'Expected_Lot_Size__c', 3080, true);
        helper.add('Die Description', 'Die_to_Die_Standoff__c', 3090, true);
        helper.add('Die Description', 'Die_to_Die_Capillary_Underfill__c', 3100, true);
        helper.add('Die Description', 'Die_to_Die_NCP_Underfill__c', 3110, true);
        helper.add('Die Description', 'Die_to_Die_Bump_Count__c', 3120, true);
        helper.add('Die Description', 'Chip_On_Chip_Process__c', 3150, true);
        helper.add('Die Description', 'Chip_On_Wafer_Process__c', 3160, true);
        helper.add('Die Description', 'Dual_Bumping__c', 3170, true);
        helper.add('Die Description', 'WLCSP_CoC__c', 3180, true);
        helper.add('Die Description', 'Die_Spacing__c', 3190, true);
        
        helper.add('NRE', 'NRE_per_Jig__c', 4000, true);
        helper.add('NRE', 'Number_Of_Jigs__c', 4010, true);
        helper.add('NRE', 'Total_NRE__c', 4020, true);
        helper.addLotChargeField('NRE', 'Engineering_Lot_Charge__c', 4030, true);
        
        helper.insertFields();
        
        return helper.getPfFieldDefs();
    }*/
	global static void installAMK1427()
	{
		List<Product_Group__c> pgs = [select Id, Name from Product_Group__c];
		for(Product_Group__c pg : pgs)
		{
			if(pg.Name == 'Advanced Products')
			{
				pg.Name = 'Advanced Product Development';
			}
		}
		update pgs;
	}

    public static void AMK1735() {
        List<RFQI_PF_Field_Def__c> pfFieldDefs = new List<RFQI_PF_Field_Def__c>();
        Map<String, RFQI_Section__c> sections = FieldBuilderHelper.getSectionMap();
        Map<string, RFQI_Field_Def__c> fieldDefs = FieldBuilderHelper.getFieldDefs();
        families = [select Id from Package_Family__c where Product_Group__r.Name =: 'Advanced Product Development'];

        for(Package_Family__c family : families) {
            pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Sales_BU_Price__c').Id, Sequence__c = 1020, Package_Family__c = family.Id, RFQI_Section__c = sections.get('Quote Information').Id));
            pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Customer_Target_Price__c').Id, Sequence__c = 1034, Package_Family__c = family.Id, RFQI_Section__c = sections.get('Quote Information').Id));
            pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Sales_Target_Price__c').Id, Sequence__c = 1037, Package_Family__c = family.Id, RFQI_Section__c = sections.get('Quote Information').Id));
            pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Competitor__c').Id, Sequence__c = 1055, Package_Family__c = family.Id, RFQI_Section__c = sections.get('Quote Information').Id));
            pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Competitor_Price__c').Id, Sequence__c = 1056, Package_Family__c = family.Id, RFQI_Section__c = sections.get('Quote Information').Id));
            pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Price_To_Customer__c').Id, Sequence__c = 1030, Package_Family__c = family.Id, RFQI_Section__c = sections.get('Quote Information').Id));

            pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('BLANK').Id, Sequence__c = 1200, Package_Family__c = family.Id, RFQI_Section__c = sections.get('Cost and Price').Id));
            pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('BLANK').Id, Sequence__c = 1210, Package_Family__c = family.Id, RFQI_Section__c = sections.get('Cost and Price').Id));
            pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Sales_Target_Price__c').Id, Sequence__c = 1220, Package_Family__c = family.Id, RFQI_Section__c = sections.get('Cost and Price').Id));
        }

        insert pfFieldDefs;

    }
}