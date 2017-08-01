/*************************************************************************
* 
* PURPOSE:  this class seeds fresh RFQ Item Field Definition specifically
*           for the FCCSP package families (cloned from SOIC150Installer
*           for the purposes of generalization)
*         
* CLASS: FCCSPInstaller
* CREATED: 05/06/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
global class FCCSPInstaller {

    private static Product_Group__c prodGroup {get; set;}
    private static List<Package_Family__c> families {get; set;}

    // @future
    global static void install(){
        CMFCbgaInstaller.clean();
        FieldBuilderHelper.clean('Flip Chip');  
        prodGroup = FieldBuilderHelper.installProductGroup('Flip Chip', 'CMFCBuilder');
        installFCCSPPackageFamilies();        
        installFCCSPDefaultDrivers('FC CSP');
        installFCCSPDefaultDrivers('FC SCSP');
        installFCBGADefaultDrivers();
        installFCBGAFields();
        installFields('FC CSP');
        installFields('FC SCSP');
        FieldBuilderHelper.markNoCostModels('Flip Chip');
        amk1249();
        RFQAdminInstaller.AMK1432();
        
    }

    global static void install2() {
        amk1248();
        amk1164();
        amk1037();
        AMK1432();
        updateOtherFields();
    }

    global static void install3() {
        AMK1503();
        RFQAdminInstaller.AMK1237();
        AMK1493();
    }

    global static void install4() {
        AMK1496();
        RFQAdminInstaller.AMK1222();
        amk1222();
    }
    
    public static void updateSapFields() {
    	RFQAdminInstaller.updateSapFieldsForProductGroup('Flip Chip');  
    }
    
    private static List<Package_Family__c> installFCCSPPackageFamilies(){
        
        families = new List<Package_Family__c>();
        
        FieldBuilderHelper.addPf('FC CSP', prodGroup, 'RFQI_fcCSP__c', null, 'RFQIDC_fcCSP__c', 'RFQIPC_fcCSP__c', null, families, true);
        FieldBuilderHelper.addPf('FC SCSP', prodGroup, 'RFQI_FCSCSP__c', 'RFQIWC_FCSCSP__c', 'RFQIDC_FCSCSP__c', 'RFQIPC_FCSCSP__c', null, families, true);
        FieldBuilderHelper.addPf('FC BGA', prodGroup, 'RFQI_fcBGA__c', null, 'RFQIDC_fcBGA__c', 'RFQIPC_fcBGA__c', null, families, true);
        try {
            insert families;
        }catch(Exception e) {
            system.debug('Could not install Flip Chip Package Families: ' + e);
        }return families;
    }
    

    private static void installFCCSPDefaultDrivers(string packageFamily) {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: packageFamily];

        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
            }

        if (packageFamily != 'FC CSP') {
            FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Number_of_BGA_Balls__c'), 'Wire_Count_Formula__c', fieldDefs.get('Number_Of_Wires__c'));
            /*FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size_X__c'), 'Wire_Count_Formula__c', fieldDefs.get('Number_of_Wires__c'));
            FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size_Y__c'), 'Wire_Count_Formula__c', fieldDefs.get('Number_of_Wires__c'));*/
        }  

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Prototype__c'), 'true', fieldDefs.get('Forecast__c'), '<25'); 

        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Layer_Configuration__c'), 'Total_Via_Formula__c', fieldDefs.get('Total_Number_of_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Layer_Configuration__c'), 'Laser_Via_Formula__c', fieldDefs.get('Number_of_Laser_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Layer_Configuration__c'), 'Mech_Via_Formula__c', fieldDefs.get('Number_of_Mech_Vias__c'));

        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Number_of_BGA_Balls__c'), 'Number_of_BGA_Balls__c', fieldDefs.get('Ball_Count__c'));

        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('BGA__c'), 'BGA__c', fieldDefs.get('Ball_Pitch__c'));
        

        //FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size_X__c'), 'Ball_Count_Formula__c', fieldDefs.get('Ball_Count__c'));
        //FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size_Y__c'), 'Ball_Count_Formula__c', fieldDefs.get('Ball_Count__c'));
        //FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size_X__c'), 'Ball_Count_Formula__c', fieldDefs.get('Number_of_BGA_Balls__c'));
        //FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size_Y__c'), 'Ball_Count_Formula__c', fieldDefs.get('Number_of_BGA_Balls__c'));

        /*FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size_X__c'), 'Total_Via_Formula__c', fieldDefs.get('Total_Number_of_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size_X__c'), 'Laser_Via_Formula__c', fieldDefs.get('Number_of_Laser_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size_X__c'), 'Mech_Via_Formula__c', fieldDefs.get('Number_of_Mech_Vias__c'));

        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size_Y__c'), 'Total_Via_Formula__c', fieldDefs.get('Total_Number_of_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size_Y__c'), 'Laser_Via_Formula__c', fieldDefs.get('Number_of_Laser_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size_Y__c'), 'Mech_Via_Formula__c', fieldDefs.get('Number_of_Mech_Vias__c'));*/

        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Number_of_BGA_Balls__c'), 'Total_Via_Formula__c', fieldDefs.get('Total_Number_of_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Number_of_BGA_Balls__c'), 'Laser_Via_Formula__c', fieldDefs.get('Number_of_Laser_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Number_of_BGA_Balls__c'), 'Mech_Via_Formula__c', fieldDefs.get('Number_of_Mech_Vias__c'));
        }


    private static void installFCBGADefaultDrivers() {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'FC BGA'];
        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
            }


        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Number_of_BGA_Balls__c'), 'Number_of_BGA_Balls__c', fieldDefs.get('Ball_Count__c')); 
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Number_of_BGA_Balls__c'), 'Number_of_BGA_Balls__c', fieldDefs.get('Number_Of_Wires__c'));  
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Package_Structure__c'), 'Lid_Formula__c', fieldDefs.get('Lid__c')); 

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Prototype__c'), 'true', fieldDefs.get('Forecast__c'), '<01');   

        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_X__c'), 'Die_Size_fml__c', fieldDefs.get('Die_Size_X__c')); 
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_X__c'), 'Die_Size_fml__c', fieldDefs.get('Die_Size_Y__c')); 
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Ball_Pitch__c'), 'Ball_Count_fml__c', fieldDefs.get('Number_of_BGA_Balls__c')); 
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_X__c'), 'Ball_Count_fml__c', fieldDefs.get('Number_of_BGA_Balls__c')); 


        /*FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Layer_Configuration__c'), 'Total_Via_Formula__c', fieldDefs.get('Total_Number_of_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Layer_Configuration__c'), 'Laser_Via_Formula__c', fieldDefs.get('Number_of_Laser_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Layer_Configuration__c'), 'Mech_Via_Formula__c', fieldDefs.get('Number_of_Mech_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size__c'), 'Ball_Count_Formula__c', fieldDefs.get('Ball_Count__c'));*/
        }
    
    
    private static List<RFQI_PF_Field_Def__c> installFields(string pf){
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
        
        helper.add('Cost and Price','CLAM_Labor__c',1000,false,true);
        helper.add('Cost and Price','Materials_Substrate__c',1010,false,true);
        helper.add('Cost and Price','Customer_Target_Price__c',1020,false,false);
        helper.add('Cost and Price','BU_Price__c',1030,false,true);
        helper.add('Cost and Price','CLAM_Depreciation__c',1040,false,true);
        helper.add('Cost and Price','Materials_ODM__c',1050,false,true);
        helper.add('Cost and Price','Sales_Target_Price__c',1060,false,false);
        helper.add('Cost and Price','Total_Perc_GM__c',1070,false,true);
        helper.add('Cost and Price','CLAM_OCOGS__c',1080,false,true);
        helper.add('Cost and Price','Materials_Subtotal__c',1090,false,true);
        helper.add('Cost and Price','Competitor__c', 1100,false,false);
        helper.add('Cost and Price','Perc_VAM_New__c',1110,false,false);
        helper.add('Cost and Price','CLAM_OH__c',1120,false,true);
        helper.add('Cost and Price','Cost_less_Substrate_New__c',1130,false,true);
        helper.add('Cost and Price','Competitor_Au_Inclusive_Price__c',1140,false,true);
        //helper.add('Cost and Price','Perc_IRR_New__c',1150,false,true);
        helper.add('Cost and Price','CLAM_Subtotal_New__c',1160,false,true);
        helper.add('Cost and Price','Total_Cost_with_Substrate_New__c',1170,false, true);
        //helper.add('Cost and Price','Model_UE_Perc__c',1180,false,true);
        helper.add('Cost and Price','BU_Price_Perc_Delta_To_Target__c',1190,false,true);
        helper.add('Cost and Price','Assembly_GM_wo_Substrate__c',1200,false,false);
        helper.add('Cost and Price','Subs_Markup_Perc__c',1210,false,false);    

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
        
        helper.add('Package Description', 'Strip_Width__c', 2000, true, false, false, false, 'Strip_Width_Other__c');
        //helper.add('Package Description', 'Strip_Width_Other__c', 2010, true);
        helper.add('Package Description', 'Body_Size_X__c', 2020, true, false, true, true);
        helper.add('Package Description', 'Body_Size_Y__c', 2030, true, false, true, true);
        helper.add('Package Description', 'Number_of_Units_Strip__c', 2040, true);
        helper.add('Package Description', 'BGA__c', 2050, true);
        helper.add('Package Description', 'Number_of_BGA_Balls__c', 2060, true, false, false, true);
        helper.add('Package Description', 'BGA_Ball_Composition__c', 2070, true, false, false, false, 'BGA_Ball_Composition_Other__c');
        //helper.add('Package Description', 'BGA_Ball_Composition_Other__c', 2080, true);
        helper.add('Package Description', 'Ball_Size__c', 2090, true);
        helper.add('Package Description', 'Si_Node__c', 2100, true);
        helper.add('Package Description', 'Side_Spacer__c', 2110, true);
        helper.add('Package Description', 'Mold_Process_Type__c', 2120, true);
        helper.add('Package Description', 'Target_Mold_Cap_Thickness__c', 2130, true);
        helper.add('Package Description', 'Lid__c', 2140, true);
        helper.add('Package Description', 'Lid_Attach_Type__c', 2150, true, false, false, false, 'Lid_Attach_Type_Other__c');
        //helper.add('Package Description', 'Lid_Attach_Type_Other__c', 2160, true);
        helper.add('Package Description', 'Lid_Material__c', 2170, true, false, false, false, 'Lid_Material_Other__c');
        //helper.add('Package Description', 'Lid_Material_Other__c', 2180, true);
        helper.add('Package Description', 'Lid_Finish__c', 2190, true, false, false, false, 'Lid_Finish_Other__c');
        //helper.add('Package Description', 'Lid_Finish_Other__c', 2200, true);
        helper.add('Package Description', 'Lid_TIM__c', 2210, true, false, false, false, 'Lid_TIM_Other__c');
        //helper.add('Package Description', 'Lid_TIM_Other__c', 2220, true);
        helper.add('Package Description', 'Lid_Adhesive__c', 2230, true, false, false, false, 'Lid_Adhesive_Other__c');
        //helper.add('Package Description', 'Lid_Adhesive_Other__c', 2240, true);
        helper.add('Package Description', 'Lid_Size_X__c', 2250, true);
        helper.add('Package Description', 'Lid_Size_Y__c', 2260, true);
        helper.add('Package Description', 'Prestacking__c', 2270, true);
        helper.add('Package Description', 'Include_TMV__c', 2280, true);
        helper.add('Package Description', 'Number_of_TMV_Balls__c', 2290, true);
        helper.add('Package Description', 'TMV_Pitch__c', 2300, true);
        helper.add('Package Description', 'TMV_Ball_Composition__c', 2310, true, false, false, false, 'TMV_Ball_Composition_Other__c');
        //helper.add('Package Description', 'TMV_Ball_Composition_Other__c', 2320, true);

        
        helper.add('Die Description', 'Die_Bump_Type__c', 3000, true);
        helper.add('Die Description', 'Die_Size_X__c', 3010, true);
        helper.add('Die Description', 'Die_Size_Y__c', 3020, true);
        helper.add('Die Description', 'Die_Bump_Pitch__c', 3030, true);
        helper.add('Die Description', 'Wafer_Size__c', 3040, true);  
        helper.add('Die Description', 'Wafer_Number_of_DPW__c', 3050, true);
        helper.add('Die Description', 'Wafer_Probe_Yield__c', 3060, true);
        helper.add('Die Description', 'GDPW__c', 3070, true);
        helper.add('Die Description', 'Wafer_Yield__c', 3080, true);
        helper.add('Die Description', 'wafer_thickness__c', 3090, true);
        helper.add('Die Description', 'Wafer_Stealth_Dicing__c', 3100, true);
        helper.add('Die Description', 'Laser_Groove__c', 3110, true);
        helper.add('Die Description', 'Die_Attach__c', 3120, true);
        helper.add('Die Description', 'UF__c', 3130, true);
        helper.add('Die Description', 'Passivation_Type__c', 3140, true); 
        helper.add('Die Description', 'Technology_Node__c', 3150, true);   
        helper.add('Die Description', 'Bump_Pad_Opening_Size__c', 3160, true);
        helper.add('Die Description', 'Bump_Pad_Metal_Size__c', 3170, true);
        helper.add('Die Description', 'Number_of_Bumps__c', 3180, true);
        helper.add('Die Description', 'UBM_Dia__c', 3190, true); 
        helper.add('Die Description', 'Bump_Height__c', 3200, true);        

        if (pf != 'FC CSP') {
        helper.add('Wire Description', 'Wire_Configuration__c', 3000, false, false, true);
        helper.add('Wire Description', 'Wire_Material__c', 3010, true, false, true);
        helper.add('Wire Description', 'Wire_Diameter__c', 3020, true, false, true);
        helper.add('Wire Description', 'Wire_Diameter_Other__c', 3030, true);
        helper.add('Wire Description', 'Number_Of_Wires__c', 3040, true, false, true); 
        helper.add('Wire Description', 'Average_2D_Wire_Length__c', 3050);
        helper.add('Wire Description', 'Total_2D_Wire_Length__c', 3060);
        helper.add('Wire Description', 'Total_3D_Wire_Length__c', 3070, true);
        helper.add('Wire Description', 'Au_Factor__c', 3080, true);
        }


        //helper.add('Substrate Description', 'Substrate_Body_Size__c', 3020, true);
        helper.add('Substrate Description', 'Total_Layer_Count__c', 3030, true);    
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
        
        /*helper.add('Substrate Description', 'Substrate_Core_Type__c', 3000, true);
        helper.add('Substrate Description', 'Core_Thickness__c', 3010, true);
        helper.add('Substrate Description', 'Bond_Finger_Pitch__c', 3020, true);
        helper.add('Substrate Description', 'layer_count__c', 3030, true); 
        helper.add('Substrate Description', 'Max_package_Thickness__c', 3040, true);
        helper.add('Substrate Description', 'Substrate_thickness__c', 3050, true);
        helper.add('Substrate Description', 'Number_of_Stacked_Via__c', 3060, true);
        helper.add('Substrate Description', 'Restricted_Substrate_Supplier__c', 3070, true);
        helper.add('Substrate Description', 'Special_Options__c', 3080, true);
        helper.add('Substrate Description', 'Total_Layer_Count__c', 3090, true);
        helper.add('Substrate Description', 'Via_Size_Build_up__c', 3100, true);
        helper.add('Substrate Description', 'Via_Size_Core__c', 3110, true);
        helper.add('Substrate Description', 'Dielectric_Thickness__c', 3120, true);
        helper.add('Substrate Description', 'Dielectric_Type__c', 3130, true);
        helper.add('Substrate Description', 'Substrate_Dielectric_Buildup_Type__c', 3140, true);
        helper.add('Substrate Description', 'Copper_Thickness_Core__c', 3150, true);
        helper.add('Substrate Description', 'Copper_Thickness_External__c', 3160, true);
        helper.add('Substrate Description', 'Copper_Thickness_Internal__c', 3170, true);
        helper.add('Substrate Description', 'Line_Widths_External_Layers__c', 3180, true);
        helper.add('Substrate Description', 'Line_Widths_Internal_Layers__c', 3190, true);
        helper.add('Substrate Description', 'Line_Widths_Core_Layers__c', 3200, true);
        helper.add('Substrate Description', 'Line_Space_External_Layers__c', 3210, true);
        helper.add('Substrate Description', 'Line_Space_Internal_Layers__c', 3220, true);
        helper.add('Substrate Description', 'Line_Space_Core_Layers__c', 3230, true);
        helper.add('Substrate Description', 'Solder_mask_Registration__c', 3240, true);
        helper.add('Substrate Description', 'Soldermask_Type__c', 3250, true);
        helper.add('Substrate Description', 'Soldermask_Thickness__c', 3260, true);
        helper.add('Substrate Description', 'Bump_Pad_Plating_Surface_Finish__c', 3270, true);
        helper.add('Substrate Description', 'BGA_IGA_Top_Surface_Finish__c', 3280, true);
        helper.add('Substrate Description', 'BGA_IGA_Bottom_Surface_Finish__c', 3290, true);
        helper.add('Substrate Description', 'Bond_Finger_Surface_Finish__c', 3300, true);
        helper.add('Substrate Description', 'SMD_Top_Surface_Finish__c', 3310, true);
        helper.add('Substrate Description', 'SMD_Bottom_Surface_Finish__c', 3320, true);
        helper.add('Substrate Description', 'Fiducial_Top_Surface_Finish__c', 3330, true);
        helper.add('Substrate Description', 'Fiducial_Bottom_Surface_Finish__c', 3340, true);
        helper.add('Substrate Description', 'Strip_Surface_Finish__c', 3350, true);
        helper.add('Substrate Description', 'Solder_Mask_Dam__c', 3360, true);
        helper.add('Substrate Description', 'Dam_SM_Type__c', 3370, true);
        helper.add('Substrate Description', 'Dam_SM_Height__c', 3380, true);
        helper.add('Substrate Description', 'Dam_SM_Width__c', 3390, true);
        helper.add('Substrate Description', 'BGA_IGA_Pad_Opening__c', 3400, true);
        helper.add('Substrate Description', 'BGA_IGA_Pad_Metal_Size__c', 3410, true);*/


        helper.add('Passive Description', 'Passive_Type__c', 3000, true);
        helper.add('Passive Description', 'Number_of_Passives__c', 3010, true);
        helper.add('Passive Description', 'Specific_Passive__c', 3020, true);
        helper.add('Passive Description', 'Passive_Supplier__c', 3030, true);
        helper.add('Passive Description', 'Tolerance__c', 3040, true);
        helper.add('Passive Description', 'Resistance_Value__c', 3050, true);
        helper.add('Passive Description', 'Voltage__c', 3060, true);
    
        
        helper.add('Adders', 'Bake_Dry_Pack__c', 5000, true);
        helper.add('Adders', 'OS_Test__c', 5010, true);
        helper.add('Adders', 'OS_Test_Sample__c', 5020, true);
        helper.add('Adders', 'Dimension_Inspection__c', 5030, true);
        helper.add('Adders', 'Dimension_Inspection_Sample__c', 5040, true);

        
        helper.add('NRE', 'Substrate_Design__c', 4000, true);
        helper.add('NRE', 'Custom_BA_Tooling__c', 4010, true);
        helper.add('NRE', 'Custom_Tray_Tooling__c', 4020, true);
        helper.add('NRE', 'Package_Singulation_Tool__c', 4030, true);
        helper.add('NRE', 'Substrate_Tooling__c', 4040, true);
        helper.add('NRE', 'Custom_Lid_Tooling__c', 4050, true);
        helper.add('NRE', 'BGA_Attach_Manual_Tooling__c', 4060, true);
        helper.add('NRE', 'SIP_Solder_Stencil__c', 4070, true);
        helper.add('NRE', 'TMV_Ball_Attach_Tooling__c', 4080, true);
        helper.add('NRE', 'BGA_Ball_Attach_Tooling__c', 4090, true);
        helper.add('NRE', 'Other__c', 4100, true);
        
        helper.insertFields();
        
        return helper.getPfFieldDefs();
    }

    private static List<RFQI_PF_Field_Def__c> installFCBGAFields(){
        
        FieldBuilderHelper helper = new FieldBuilderHelper('FC BGA');
        
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
        helper.add('Cost and Price','Materials_Substrate__c',1010,false,true);
        helper.add('Cost and Price','Customer_Target_Price__c',1020,false,false);
        helper.add('Cost and Price','Subs_Markup_Perc__c',1030,false,false);
        helper.add('Cost and Price','CLAM_Depreciation__c',1040,false,true);
        helper.add('Cost and Price','Materials_ODM__c',1050,false,true);
        helper.add('Cost and Price','Competitor__c',1060,false,false);
        helper.add('Cost and Price','Assembly_GM_wo_Substrate__c',1070,false,false);
        helper.add('Cost and Price','CLAM_OCOGS__c',1080,false,true);
        helper.add('Cost and Price','Materials_Subtotal__c',1090,false,true);
        helper.add('Cost and Price','Competitor_Au_Inclusive_Price__c', 1100,false,false);
        helper.add('Cost and Price','Total_Perc_GM__c',1110,false,true);
        helper.add('Cost and Price','CLAM_OH__c',1120,false,true);
        helper.add('Cost and Price','Total_Cost_with_Substrate_New__c',1130,false,true);
        //helper.add('Cost and Price','Model_UE_Perc__c',1140,false,true);
        helper.add('Cost and Price','CLAM_Subtotal_New__c',1150,false,true);
        //helper.add('Cost and Price','Perc_IRR_New__c',1160,false,true);
        helper.add('Cost and Price','Perc_VAM_New__c',1170,false,true);
        helper.add('Cost and Price','BU_Price__c',1180,false,true);      
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
        helper.add('Package Description', 'Package_Structure__c', 2010, true, false, true, true);
        helper.add('Package Description', 'Body_X__c', 2040, true, false, true);
        helper.add('Package Description', 'Body_Y__c', 2050, true, false, true);
        helper.add('Package Description', 'Lid__c', 2050, true);
        helper.add('Package Description', 'Lid_Thickness__c', 2070, true);
        helper.add('Package Description', 'Lid_Attach_Type__c', 2080, true);
        helper.add('Package Description', 'TIM__c', 2090, true);
        helper.add('Package Description', 'Number_of_BGA_Balls__c', 2100, true, false, false, true);
        helper.add('Package Description', 'Ball_Type__c', 2170, true);
        helper.add('Package Description', 'Ball_Pitch__c', 2190, true, false, false, true);
        helper.add('Package Description', 'Bump_Type__c', 2200, true);
        helper.add('Package Description', 'Underfill_Type__c', 2210, true);
        helper.add('Package Description', 'Stiffener_Adhesive__c', 2220, true);
        helper.add('Package Description', 'HS_Adhesive__c', 2230, true);
        helper.add('Package Description', 'Process_Type__c', 2230, true);
        
        helper.add('Adders', 'OS_Sampling__c', 4130, true);

        helper.add('Die Description', 'Die_Size_X__c', 3030, true); 
        helper.add('Die Description', 'Die_Size_Y__c', 3040, true);
        helper.add('Die Description', 'Wafer_Size__c', 3050, true);
        helper.add('Die Description', 'WBG_Required__c', 3060, true);
        helper.add('Die Description', 'WBG_Final_Thickness__c', 3070, true);
        helper.add('Die Description', 'Bump_Pad_Pitch__c', 3080, true);
        helper.add('Die Description', 'Passivation_Type__c', 3090, true);
        helper.add('Die Description', 'Minimum_Saw_Street_100_Microns__c', 3100, true);
        
        helper.add('Substrate Description', 'Substrate_Ball_Pad_Pitch__c', 3000, true);
        helper.add('Substrate Description', 'Bond_Finger_Pitch__c', 3010, true);
        helper.add('Substrate Description', 'Ball_Count__c', 2100, true);
        helper.add('Substrate Description', 'Layer_Configuration__c', 3020, true);
        helper.add('Substrate Description', 'Line_and_Space_Inner__c', 3030, true); 
        helper.add('Substrate Description', 'Line_and_Space_Outer__c', 3040, true);
        helper.add('Substrate Description', 'Number_of_Stacked_Via__c', 3050, true);
        helper.add('Substrate Description', 'Restricted_Substrate_Supplier__c', 3060, true);
        helper.add('Substrate Description', 'Special_Options__c', 3070, true);
        helper.add('Substrate Description', 'Total_Layer_Count__c', 3080, true);
        helper.add('Substrate Description', 'Via_Size_Build_up__c', 3090, true);
        helper.add('Substrate Description', 'Via_Size_Core__c', 3100, true);
        helper.add('Substrate Description', 'Amkor_Purchased_Substrate__c', 3110);
        helper.add('Substrate Description', 'Amkor_Tooling__c', 3120);

        helper.add('Passive Description', 'Passive_Type__c', 3000, true);
        helper.add('Passive Description', 'Number_of_Passives__c', 3010, true);
        helper.add('Passive Description', 'Specific_Passive__c', 3020, true);
        helper.add('Passive Description', 'Passive_Supplier__c', 3030, true);
        helper.add('Passive Description', 'Tolerance__c', 3040, true);
        helper.add('Passive Description', 'Resistance_Value__c', 3050, true);
        helper.add('Passive Description', 'Voltage__c', 3060, true);

        /*helper.add('Passive Description', 'Passive_Type__c', 3000, true, false, false, false, 'Passive_Type_Other__c');
        helper.add('Passive Description', 'Number_of_Passives__c', 3010, true);
        helper.add('Passive Description', 'Specific_Passive__c', 3020, true, false, false, false, 'Passive_Size_Other__c');
        helper.add('Passive Description', 'Capacitance__c', 3030, true);
        helper.add('Passive Description', 'Resistance_Value__c', 3040, true);
        helper.add('Passive Description', 'Inductance__c', 3050, true);
        helper.add('Passive Description', 'Passive_Units__c', 3060, true);
        helper.add('Passive Description', 'Tolerance__c', 3070, true, false, false, false, 'Tolerance_Other__c');
        helper.add('Passive Description', 'Voltage_Power_Amperage__c', 3080, true, false, false, false, 'Voltage_Power_Amperage_Other__c');
        helper.add('Passive Description', 'Dielectric_Material__c', 3090, true, false, false, false, 'Dielectric_Material_Other__c');
        helper.add('Passive Description', 'Passive_Supplier__c', 3100, true, false, false, false, 'Passive_Supplier_Other__c');
        helper.add('Passive Description', 'Amkor_SID__c', 3110, true, false, false, false, 'Amkor_SID_Other__c');
        helper.add('Passive Description', 'Supplier_SID_Part_Number__c', 3110, true, false, false, false, 'Supplier_SID_Part_Number_Other__c');*/

        /*helper.add('Passive Description', 'Passive_Type__c', 3000, true);
        helper.add('Passive Description', 'Passive_Type_Other__c', 3010, true);
        helper.add('Passive Description', 'Number_of_Passives__c', 3020, true);
        helper.add('Passive Description', 'Specific_Passive__c', 3030, true);
        helper.add('Passive Description', 'Passive_Size_Other__c', 3040, true);
        helper.add('Passive Description', 'Capacitance__c', 3050, true);
        helper.add('Passive Description', 'Resistance_Value__c', 3060, true);
        helper.add('Passive Description', 'Inductance__c', 3070, true);
        helper.add('Passive Description', 'Passive_Units__c', 3080, true);
        helper.add('Passive Description', 'Tolerance__c', 3090, true);
        helper.add('Passive Description', 'Tolerance_Other__c', 3100, true);
        helper.add('Passive Description', 'Voltage_Power_Amperage__c', 3110, true);
        helper.add('Passive Description', 'Voltage_Power_Amperage_Other__c', 3120, true);
        helper.add('Passive Description', 'Dielectric_Material__c', 3130, true);
        helper.add('Passive Description', 'Dielectric_Material_Other__c', 3140, true);
        helper.add('Passive Description', 'Passive_Supplier__c', 3150, true);
        helper.add('Passive Description', 'Passive_Supplier_Other__c', 3060, true);
        helper.add('Passive Description', 'Amkor_SID__c', 3170, true);
        helper.add('Passive Description', 'Amkor_SID_Other__c', 3180, true);
        helper.add('Passive Description', 'Supplier_SID_Part_Number__c', 3190);
        helper.add('Passive Description', 'Supplier_SID_Part_Number_Other__c', 3200, true);*/
    
        
        helper.add('NRE', 'Substrate_Design__c', 4000, true);
        helper.add('NRE', 'Custom_BA_Tooling__c', 4010, true);
        helper.add('NRE', 'Custom_Tray_Tooling__c', 4020, true);
        helper.add('NRE', 'Substrate_Tooling__c', 4030, true);
        helper.add('NRE', 'Custom_Lid_Tooling__c', 4040, true);
        helper.add('NRE', 'Other__c', 4050, true); 
        
        helper.insertFields();
        
        return helper.getPfFieldDefs();
    }

    public static void amk1248() {
        installRFQFD();
        changeFD();
        deletePFFD('FC CSP');
        deletePFFD('FC SCSP');
        changePFFD('FC CSP');
        changePFFD('FC SCSP');
        installPFFD('FC CSP');
        installPFFD('FC SCSP');
        installDD('FC CSP');
        installDD('FC SCSP');
    }

    private static void changeFD(){
        List<RFQI_Field_Def__c> fieldDef = [select Id, Name from RFQI_Field_Def__c];

        for (RFQI_Field_Def__c fields : fieldDef) {
            if(fields.Name == 'Dielectric_Thickness__c')
                {fields.Object__c='Package';}
            if(fields.Name == 'Dielectric_Type__c')
                {fields.Object__c='Package';}
        }
        update fieldDef;

    }

    private static void installDD(string packageFamily) {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: packageFamily];

        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
            }

        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('BGA__c'), 'BGA__c', fieldDefs.get('Ball_Pitch__c'));
    }

    private static void installRFQFD() {
        List<RFQI_Field_Def__c> defs = new List<RFQI_Field_Def__c>();

        defs.add(new RFQI_Field_Def__c(Name = 'BGA_IGA_Top_Surface_Finish_Other__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Bond_Finger_Surface_Finish_Other__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Minimum_Line_Core__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Minimum_Space_Core__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'SideSpacer__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'SiNode__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'SMD_Top_Surface_Finish_Other__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'SMD_Bottom_Surface_Finish_Other__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Dam_Thickness__c', Object__c='Package', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Dam_Material__c', Object__c='Package', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Stackup__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BGA_IGA_Bottom_Surface_Finish_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Fiducial_Bottom_Surface_Finish_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Fiducial_Top_Surface_Finish_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Strip_Surface_Finish_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BGA_IGA_Pad_Metal_Size_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BGA_IGA_Pad_Opening_Other__c'));

        insert defs;


    }

    private static List<RFQI_PF_Field_Def__c> installPFFD(string pf) {
        FieldBuilderHelper helper = new FieldBuilderHelper(pf);

        helper.add('Package Description', 'SiNode__c', 2100, true);
        helper.add('Package Description', 'SideSpacer__c', 2110, true);
        helper.add('Package Description', 'Max_package_Thickness__c', 2140, true);

        helper.add('Substrate Description', 'Minimum_Line_Core__c', 3110, true);
        helper.add('Substrate Description', 'Minimum_Space_Core__c', 3120, true);
        helper.add('Substrate Description', 'Substrate_Stackup__c', 3300, true, false, false, false, 'Substrate_Stackup_Other__c');
        helper.add('Substrate Description', 'Dielectric_Thickness__c', 3310, true);
        helper.add('Substrate Description', 'Dielectric_Type__c', 3320, true);
        helper.add('Substrate Description', 'Copper_Thickness_Core__c', 3330, true);
        helper.add('Substrate Description', 'Copper_Thickness_External__c', 3340, true);
        helper.add('Substrate Description', 'Copper_Thickness_Internal__c', 3350, true);
        helper.add('Substrate Description', 'Solder_Mask_Dam__c', 3360, true);
        helper.add('Substrate Description', 'Substrate_Dam_Thickness__c', 3370, true);
        helper.add('Substrate Description', 'Substrate_Dam_Material__c', 3380, true);
        helper.add('Substrate Description', 'BGA_IGA_Top_Surface_Finish_Other__c', 3390, true, false, false, false, 'BGA_IGA_Top_Surface_Finish__c');
        helper.add('Substrate Description', 'Bond_Finger_Surface_Finish_Other__c', 3400, true, false, false, false, 'Bond_Finger_Surface_Finish__c');
        helper.add('Substrate Description', 'SMD_Top_Surface_Finish_Other__c', 3410, true, false, false, false, 'SMD_Top_Surface_Finish__c');
        helper.add('Substrate Description', 'SMD_Bottom_Surface_Finish_Other__c', 3420, true, false, false, false, 'SMD_Bottom_Surface_Finish__c');
        helper.add('Substrate Description', 'BGA_IGA_Bottom_Surface_Finish_Other__c', 3430, true, false, false, false, 'BGA_IGA_Bottom_Surface_Finish__c');
        helper.add('Substrate Description', 'Fiducial_Bottom_Surface_Finish_Other__c', 3440, true, false, false, false, 'Fiducial_Bottom_Surface_Finish__c');
        helper.add('Substrate Description', 'Strip_Surface_Finish_Other__c', 3450, true, false, false, false, 'Strip_Surface_Finish__c');
        helper.add('Substrate Description', 'BGA_IGA_Pad_Metal_Size_Other__c', 3460, true, false, false, false, 'BGA_IGA_Pad_Metal_Size__c');
        helper.add('Substrate Description', 'BGA_IGA_Pad_Opening_Other__c', 3470, true, false, false, false, 'BGA_IGA_Pad_Opening__c');
        helper.add('Substrate Description', 'Substrate_Stackup__c', 3480, true, false, false, false, 'Substrate_Stackup_Other__c');
        
        helper.add('Die Description', 'Wafer_Dicing__c', 3100, true);
        


        helper.insertFields();
        
        return helper.getPfFieldDefs();
    }

    private static void deletePFFD(string pf) {
        List<RFQI_PF_Field_Def__c> fields = [Select Id, RFQI_Field_Def__r.Name from RFQI_PF_Field_Def__c where RFQI_PF_Field_Def__c.Package_Family__r.Name =: pf];
        List<RFQI_PF_Field_Def__c> fieldsToDelete = new List<RFQI_PF_Field_Def__c>();

        for  (RFQI_PF_Field_Def__c field : fields) {
            string fieldName = field.RFQI_Field_Def__r.Name;

            if (fieldName == 'Si_Node__c' ||
                fieldName == 'Side_Spacer__c' ||
                fieldName == 'Wafer_Probe_Yield__c' ||
                fieldName == 'Wafer_Stealth_Dicing__c' ||
                fieldName == 'Laser_Groove__c' )
            {fieldsToDelete.add(field);}
        }

        delete fieldsToDelete;
    }

    private static void changePFFD(string pf) {
        List<RFQI_PF_Field_Def__c> fields = [Select Id, RFQI_Field_Def__r.Name, Sequence__c from RFQI_PF_Field_Def__c where RFQI_PF_Field_Def__c.Package_Family__r.Name =: pf];

        for  (RFQI_PF_Field_Def__c field : fields) {
        if(field.RFQI_Field_Def__r.Name == 'Body_Size_X__c')
            {field.Default_Driver__c = false;}
        if(field.RFQI_Field_Def__r.Name == 'Body_Size_Y__c')
            {field.Default_Driver__c = false;}
        if(field.RFQI_Field_Def__r.Name == 'Lid__c')
            {field.Sequence__c = 2150;}
        if(field.RFQI_Field_Def__r.Name == 'Lid_Attach_Type__c')
            {field.Sequence__c = 2160;}
        if(field.RFQI_Field_Def__r.Name == 'BGA__c')
            {field.Default_Driver__c = true;}
        if(field.RFQI_Field_Def__r.Name == 'Minimum_Bond_Finger_Pitch__c')
            {field.Sequence__c = 3130;}
        if(field.RFQI_Field_Def__r.Name == 'Total_Number_of_Vias__c')
            {field.Sequence__c = 3140;}
        if(field.RFQI_Field_Def__r.Name == 'Mech_Via_Capture_Pad_Diam__c')
            {field.Sequence__c = 3150;}
        if(field.RFQI_Field_Def__r.Name == 'Number_of_Mech_Vias__c')
            {field.Sequence__c = 3160;}
        if(field.RFQI_Field_Def__r.Name == 'Laser_Via_Capture_Pad_Diam__c')
            {field.Sequence__c = 3170; field.Other_Field__c = 'Laser_Via_Capture_Pad_Diam_Other__c';}
        if(field.RFQI_Field_Def__r.Name == 'Number_of_Laser_Vias__c')
            {field.Sequence__c = 3180;}
        if(field.RFQI_Field_Def__r.Name == 'Via_Fill__c')
            {field.Sequence__c = 3190;}
        if(field.RFQI_Field_Def__r.Name == 'Soldermask_Registration__c')
            {field.Sequence__c = 3200; field.Other_Field__c = 'Solder_mask_Registration__c';}
        if(field.RFQI_Field_Def__r.Name == 'Soldermask_Material__c')
            {field.Sequence__c = 3210;}
        if(field.RFQI_Field_Def__r.Name == 'Core_Material__c')
            {field.Sequence__c = 3220;}
        if(field.RFQI_Field_Def__r.Name == 'Core_Thickness__c')
            {field.Sequence__c = 3230;}
        if(field.RFQI_Field_Def__r.Name == 'Substrate_Thickness__c')
            {field.Sequence__c = 3240;}
        if(field.RFQI_Field_Def__r.Name == 'Plating__c')
            {field.Sequence__c = 3250;}
        if(field.RFQI_Field_Def__r.Name == 'Metal_Finish__c')
            {field.Sequence__c = 3260; field.Other_Field__c = 'Metal_Finish_Other__c';}
        if(field.RFQI_Field_Def__r.Name == 'Substrate_Supplier__c')
            {field.Sequence__c = 3270;}
        if(field.RFQI_Field_Def__r.Name == 'Restricted_Substrate_Supplier__c')
            {field.Sequence__c = 3280;}
        if(field.RFQI_Field_Def__r.Name == 'Special_Options__c')
            {field.Sequence__c = 3290;}
        }

        update fields;
    }

    public static void amk1249() {
        List<RFQI_Field_Def__c> defs = new List<RFQI_Field_Def__c>();

        defs.add(new RFQI_Field_Def__c(Name = 'Ground_Lid_Adhesive__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Markup_Margin__c'));

        insert defs;

        RFQI_PF_Field_Def__c processType = [select Id from RFQI_PF_Field_Def__c where RFQI_Field_Def__r.Name =: 'Process_Type__c' AND Package_Family__r.Name =: 'FC BGA' ];
        processType.Sequence__c = 2250;
        update processType;

        families = [select Id, Name from Package_Family__c where Product_Group__r.Name =: 'Flip Chip'];

        List<RFQI_PF_Field_Def__c> pfFields = new List<RFQI_PF_Field_Def__c>();

        RFQI_Section__c packageDesc = [select Id from RFQI_Section__c where Name =: 'Package Description'];
        RFQI_Section__c costPrice = [select Id from RFQI_Section__c where Name =: 'Cost and Price'];


        for (Package_Family__c pf :  families) {
            if (pf.Name == 'FC BGA') {
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = packageDesc.Id, RFQI_Field_Def__c = defs[0].Id, Sequence__c = 2240,Package_Family__c = pf.Id,CPN_Attribute__c = true));
            }
            else {
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = costPrice.Id, RFQI_Field_Def__c = defs[1].Id, Sequence__c = 1150,Package_Family__c = pf.Id,CPN_Attribute__c = false));
            }
        }

        insert pfFields;

    }
    public static void amk1222()
    {
        Package_Family__c pf = [select id, No_Cost_Model__c from Package_Family__c where Name='FC BGA' and Product_Group__r.Name='Flip Chip'];
        pf.No_Cost_Model__c = false;
        pf.Cost_Model_Implementation__c = 'CMFCBuilder';
        update pf;

        List<String> sectionNames = new List<String>
        {
            'BU Attributes',
            'Passive Description',
            'Cost and Price',
            'Package Description',
            'Substrate Description'
        };

        List<RFQI_Section__c> sections = [select Id, Name from RFQI_Section__c where Name in :sectionNames];

        Map<String, String> sectionMap = new Map<String, String>();

        for (RFQI_Section__c row : sections) sectionMap.put(row.name, row.Id);

        List<String> fieldNames = new List<String>
        {
            'Capacitor_Paste_Flux__c',
            'Flux__c',
            'Solder_Ball_Flux__c',
            'OM_Chase__c',
            'OM_Thickness__c',
            'LG_Pass__c',
            'Substrate_Purchase_Price__c',
            'Process_Include_LA_In_Line_Plasma__c',
            'Process_Include_Wafer_Mount_Stand_Alone__c',
            'Process_Include_Underfill_In_Line_Plasma__c',
            'Process_Include_Cap_Attached_on_BGA__c',
            'Process_Include_OS_Test__c', 
            'Purchase_Price__c', 
            'OS_Sampling_Perc__c',
            'Die_Yield__c', 
            'Perc_IRR_New__c',
            'Number_of_BGA_Balls__c'
        };

        List<RFQI_Field_Def__c> defs = [select Id, Name from RFQI_Field_Def__c where name in :fieldNames];

        Map<String, RFQI_Field_Def__c> defMap = new Map<String, RFQI_Field_Def__c>();
        for (RFQI_Field_Def__c row : defs) defMap.put(row.Name, row);

        List<RFQI_PF_Field_Def__c> pfDefs = new List<RFQI_PF_Field_Def__c>();
        Decimal seq = 1000;
        String sectionName;
        for (String fieldName : fieldNames)
        {
            if (fieldName == 'Purchase_Price__c')
                pfDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c=sectionMap.get('Passive Description'), RFQI_Field_Def__c=defMap.get(fieldName).Id, Sequence__c=3190, Is_Manual_Entry__c=true, Package_Family__c=pf.Id));
            else if (fieldName == 'Perc_IRR_New__c')
                pfDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c=sectionMap.get('Cost and Price'), RFQI_Field_Def__c=defMap.get(fieldName).Id, Sequence__c=1175, Generated__c=true, Package_Family__c=pf.Id));
            else if (fieldName != 'Number_of_BGA_Balls__c')
            {
                pfDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c=sectionMap.get('BU Attributes'), RFQI_Field_Def__c=defMap.get(fieldName).Id, Sequence__c=seq, Is_Manual_Entry__c=true, Package_Family__c=pf.Id));
                seq += 10;
            }
                

        }

        Set<String> pfDefNames = new Set<String>
        {
            'Underfill_Type__c',
            'Stiffener_Adhesive__c',
            'Ground_Lid_Adhesive__c',
            'HS_Adhesive__c',
            'Ball_Pitch__c'
        };

        Set<String> pfDefReqd = new Set<String>
        {
            'Die_Size_X__c',
            'Die_Size_Y__c',
            'Number_of_BGA_Balls__c',
            'Body_X__c',
            'Body_Y__c'
        };

        Set<String> pfDefsDD = new Set<String>
        {
            'Body_X__c'
        };

        Set<String> pfDefsMove = new Set<String>
        {
            'Ball_Count__c'
        };

        List<RFQI_PF_Field_Def__c> oldPfDefs = [select Id, Has_Amkor_Selected__c, Is_Manual_Entry__c, Default_Driver__c, RFQI_Field_Def__r.Name from RFQI_PF_Field_Def__c where (RFQI_Field_Def__r.Name in :pfDefNames or RFQI_Field_Def__r.Name in :pfDefsDD or RFQI_Field_Def__r.Name in :pfDefReqd or RFQI_Field_Def__r.Name in :pfDefsMove) and Package_Family__c=:pf.Id ];
        Boolean containsBGABalls = false;
        for (RFQI_PF_Field_Def__c row : oldPfDefs)
        {
            if (pfDefNames.contains(row.RFQI_Field_Def__r.Name))
            {
                if (row.RFQI_Field_Def__r.Name != 'Ball_Pitch__c') row.Has_Amkor_Selected__c = true;
                row.Is_Manual_Entry__c = true;
            }
            else if (pfDefsDD.contains(row.RFQI_Field_Def__r.Name))
            {
                row.Default_Driver__c = true;
            }
            else if (pfDefReqd.contains(row.RFQI_Field_Def__r.Name))
            {
                if (row.RFQI_Field_Def__r.Name == 'Number_of_BGA_Balls__c') containsBGABalls = true;
                row.Required__c = true;
            }
            else if (pfDefsMove.contains(row.RFQI_Field_Def__r.Name))
            {
                row.RFQI_Section__c = sectionMap.get('Substrate Description');
            }
        }

        if (!containsBGABalls) insert new RFQI_PF_Field_Def__c(Package_Family__c = pf.Id, RFQI_Field_Def__c=defMap.get('Number_of_BGA_Balls__c').Id, RFQI_Section__c=sectionMap.get('Package Description'), Required__c=true, Default_Driver__c=true, CPN_Attribute__c=true, Sequence__c=2100);

        List<SObject> updateList = new List<SObject>();
        List<SObject> insertList = new List<SObject>();

        updateList.addAll((List<SObject>)oldPfDefs);

        insertList.addAll((List<SObject>)pfDefs);
        insertList.add((Sobject)new RFQI_Field_Def__c(Name = 'Factory__r.Name'));

        
        update updateList;
        insert insertList;
    }


    //these were added to the installFCBGADefaultDrivers method, added here only for pushes to existing environments
    public static void AMK1222DefaultDrivers()
    {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'FC BGA'];
        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
            }

        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_X__c'), 'Die_Size_fml_2__c', fieldDefs.get('Die_Size_X__c')); 
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_X__c'), 'Die_Size_fml_2__c', fieldDefs.get('Die_Size_Y__c')); 
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Ball_Pitch__c'), 'Ball_Count_fml__c', fieldDefs.get('Number_of_BGA_Balls__c')); 
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_X__c'), 'Ball_Count_fml__c', fieldDefs.get('Number_of_BGA_Balls__c')); 

    }

    public static void AMK1222DefaultDrivers_2()
    {
        List<RFQI_Default_Driver__c> drivers = [select id, driver_value__c from rfqi_default_driver__c where package_family__r.name='FC BGA' and driver_value__c='Ball_Count_fml__c'];

        for (RFQI_Default_Driver__c driver : drivers)
        {
            driver.Driver_Value__c = 'Ball_Count_fml_2__c';
        }

        update drivers;
    }

    public static void amk1222_2()
    {
        Package_Family__c pf = [select id, No_Cost_Model__c from Package_Family__c where Name='FC BGA' and Product_Group__r.Name='Flip Chip'];
        RFQI_Section__c section = [select Id, Name from RFQI_Section__c where Name = 'Cost and Price'];
        RFQI_Field_Def__c def = [select Id, Name from RFQI_Field_Def__c where name = 'Perc_IRR_New__c'];
        insert new RFQI_PF_Field_Def__c(RFQI_Section__c=section.Id, RFQI_Field_Def__c=def.Id, Sequence__c=1175, Generated__c=true, Package_Family__c=pf.Id);
    }

    public static void AMK1222_3()
    {
        Package_Family__c pf = [select id, No_Cost_Model__c from Package_Family__c where Name='FC BGA' and Product_Group__r.Name='Flip Chip'];
        RFQI_Field_Def__c def = [select Id, Name from RFQI_Field_Def__c where name = 'Number_of_BGA_Balls__c'];
        Set<String> sectionNames = new Set<String>
        {
            'Package Description',
            'Substrate Description'
        };

        List<RFQI_Section__c> sections = [select Id, Name from RFQI_Section__c where Name in :sectionNames];

        Map<String, String> sectionMap = new Map<String, String>();

        for (RFQI_Section__c row : sections) sectionMap.put(row.name, row.Id);

        //move ball_count__c to new section
        RFQI_PF_Field_Def__c pfDef = [select id, RFQI_Section__c from RFQI_PF_Field_Def__c where Package_Family__c=:pf.Id and RFQI_Field_Def__r.Name='Ball_Count__c'];
        pfDef.RFQI_Section__c = sectionMap.get('Substrate Description');
        update pfDef;

        //add Number BGA Balls
        insert new RFQI_PF_Field_Def__c(Package_Family__c = pf.Id, RFQI_Field_Def__c=def.Id, RFQI_Section__c=sectionMap.get('Package Description'), Required__c=true, Default_Driver__c=true, CPN_Attribute__c=true, Sequence__c=2100);

        Set<String> reqFields = new Set<String>
        {
            'Body_X__c',
            'Body_Y__c',
            'Number_of_BGA_Balls__c'
        };

        List<RFQI_PF_Field_Def__c> pfDefList = [SELECT Id, Required__c from RFQI_PF_Field_Def__c where RFQI_Field_Def__r.Name in :reqFields];
        for (RFQI_PF_Field_Def__c row : pfDefList)
        {
            row.Required__c = true;
        }

        update pfDefList;

    }

    public static void AMK1432()
    {
        DebugUtils debug = DebugUtils.getInstance();
        Product_Group__c pGroup = [select Id, Name, Cost_Model_Implementation__c from Product_Group__c where Name='Flip Chip'];
        pGroup.Cost_Model_Implementation__c = null;
        update pGroup;


        List<RFQI_Field_Def__c> defs = new List<RFQI_Field_Def__c>();

        defs.add(new RFQI_Field_Def__c(Name = 'Material_Freight_Percent__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Material_Tooling_Percent__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Freight__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Usage__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Cost_Model_Filename__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Other_Costs__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Quote_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Business_Model__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Value_Added_Revenue__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Value_Added_Margin__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Value_Added_Margin_Perc__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BLANK'));

        insert defs;

        defs = [select Id, Name from RFQI_Field_Def__c];
        Map<String, String> defMap = new Map<String, String>();
        for (RFQI_Field_Def__c row : defs) defMap.put(row.Name, row.Id);
        debug.log('defMap total cost', defMap.get('Total_Cost_with_Substrate_New__c'));

        //get the current of fields defs for each family, to not overwrite/duplicate them
        List<RFQI_PF_Field_Def__c> pfDefs = [select Id, Name, RFQI_Field_Def__r.Name, Package_Family__r.Name from RFQI_PF_Field_Def__c where RFQI_Section__r.Name='Cost and Price' and Package_Family__r.Name in ('FC CSP', 'FC SCSP')];
        Map<String, RFQI_PF_Field_Def__c> cspFields = new Map<String, RFQI_PF_Field_Def__c>();
        Map<String, RFQI_PF_Field_Def__c> scspFields = new Map<String, RFQI_PF_Field_Def__c>();

        for (RFQI_PF_Field_Def__c row : pfDefs)
        {
            if (row.Package_Family__r.Name == 'FC CSP') cspFields.put(row.RFQI_Field_Def__r.Name, row);
            else if (row.Package_Family__r.Name == 'FC SCSP') scspFields.put(row.RFQI_Field_Def__r.Name, row);
        }

        families = [select Id, Name, Cost_Model_Implementation__c, Layout_Version__c from Package_Family__c where Product_Group__r.Name = 'Flip Chip'];
        Map<String, Map<String, RFQI_PF_Field_Def__c>> familyFields = new Map<String, Map<String, RFQI_PF_Field_Def__c>>();

        for (Package_Family__c row : families)
        {
            if (row.Name == 'FC CSP') familyFields.put(row.Name, cspFields);
            else if (row.Name == 'FC SCSP') familyFields.put(row.Name, scspFields);
        }

        RFQI_Section__c costPrice = [select Id from RFQI_Section__c where Name =: 'Cost and Price'];
        List<String> fieldNames = new List<String>
        {
            'CLAM_Labor__c',
            'Materials_Substrate__c',
            'BLANK',
            'BU_Price__c',
            'CLAM_Indirect_Labor__c',
            'Substrate_Freight__c',
            'Customer_Target_Price__c',
            'Total_Perc_GM__c',
            'CLAM_Depreciation__c',
            'Substrate_Tooling__c',
            'Competitor__c',
            'Contribution_Margin_Perc__c',
            'CLAM_Facilities__c',
            'Substrate_Usage__c',
            'Competitor_Au_Inclusive_Price__c',
            'Assembly_GM_wo_Substrate__c',
            'CLAM_OH__c',
            'Materials_ODM__c',
            'Model_UE_Perc__c',
            'Value_Added_Revenue__c',
            'QA_Cost__c',
            'Material_Freight_Percent__c',
            'Cost_Model_Filename__c',
            'Value_Added_Margin__c',
            'Service_Group_Cost__c',
            'Material_Tooling_Percent__c',
            'BLANK ',
            'Value_Added_Margin_Perc__c',
            'CLAM_Subtotal_New__c',
            'Materials_Subtotal__c',
            'Quote_Type__c',
            'BLANK  ',
            'Other_Costs__c',
            'Total_Cost_with_Substrate_New__c',
            'Substrate_Business_Model__c',
            'Subs_Markup_Perc__c' 
        };

        List<String> deprecatedNames = new List<String>
        {
            'Sales_Target_Price__c',
            'CLAM_OCOGS__c',
            'Perc_VAM_New__c',
            'Cost_less_Substrate_New__c',
            'Substrate_Markup_Margin__c',
            'BU_Price_Perc_Delta_To_Target__c'
        };

        Map<String, Double> fieldSequence = new Map<String, Double>
        {
            'CLAM_Labor__c' =>  1000,
            'Materials_Substrate__c' => 1010,
            'BLANK' =>  1020,
            'BU_Price__c' =>    1030,
            'CLAM_Indirect_Labor__c' => 1040,
            'Substrate_Freight__c' =>   1050,
            'Customer_Target_Price__c' =>   1060,
            'Total_Perc_GM__c' =>   1070,
            'CLAM_Depreciation__c' =>   1080,
            'Substrate_Tooling__c' =>   1090,
            'Competitor__c' =>  1100,
            'Contribution_Margin_Perc__c' =>    1110,
            'CLAM_Facilities__c' => 1120,
            'Substrate_Usage__c' => 1130,
            'Competitor_Au_Inclusive_Price__c' =>   1140,
            'Assembly_GM_wo_Substrate__c' =>    1150,
            'CLAM_OH__c' => 1160,
            'Materials_ODM__c' =>   1170,
            'Model_UE_Perc__c' =>   1180,
            'Value_Added_Revenue__c' => 1190,
            'QA_Cost__c' => 1200,
            'Material_Freight_Percent__c' =>    1210,
            'Cost_Model_Filename__c' => 1220,
            'Value_Added_Margin__c' =>  1230,
            'Service_Group_Cost__c' =>  1240,
            'Material_Tooling_Percent__c' =>    1250,
            'BLANK ' =>  1260,
            'Value_Added_Margin_Perc__c' => 1270,
            'CLAM_Subtotal_New__c' =>   1280,
            'Materials_Subtotal__c' =>  1290,
            'Quote_Type__c' =>  1300,
            'BLANK  ' =>  1310,
            'Other_Costs__c' => 1320,
            'Total_Cost_with_Substrate_New__c' =>   1330,
            'Substrate_Business_Model__c' =>    1340,
            'Subs_Markup_Perc__c' =>   1350
        };

        List<RFQI_PF_Field_Def__c> pfFields = new List<RFQI_PF_Field_Def__c>();
        Map<String, RFQI_PF_Field_Def__c> fields;
        for (Package_Family__c pf :  families) 
        {
            pf.Layout_Version__c = (pf.Layout_Version__c == null) ? 1 : pf.Layout_Version__c + 1;
            if (pf.Name == 'FC BGA') pf.Cost_Model_Implementation__c = 'CMFCBuilder';
            else
            {
                pf.Cost_Model_Implementation__c = null;
                fields = familyFields.get(pf.Name);

                for( String fieldName: fieldNames)
                {
                    if(fields.containsKey(fieldName)) 
                    {
                        fields.get(fieldName).Sequence__c = fieldSequence.get(fieldName);
                        pfFields.add(fields.get(fieldName));
                    }
                    else 
                    {                        
                        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = costPrice.Id, Sequence__c = fieldSequence.get(fieldName), RFQI_Field_Def__c = defMap.get(fieldName.trim()), Package_Family__c = pf.Id)); 
                    }
                }

                for (String deprecatedName : deprecatedNames)
                {
                    //system.debug(LoggingLevel.ERROR, 'Deprecated: ' + deprecatedName);
                    if(fields.get(deprecatedName)== null) {system.debug(LoggingLevel.ERROR, 'Deprecated: ' + deprecatedName);}
                    fields.get(deprecatedName).Deprecated__c = true;

                    pfFields.add(fields.get(deprecatedName));
                }

            }

        }

        update families;
        upsert pfFields;
    }


    public static void amk1164() {
        List<RFQI_Field_Def__c> defs = new List<RFQI_Field_Def__c>();

        defs.add(new RFQI_Field_Def__c(Name = 'Laminate__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Restricted_Supplier__c', Type__c = 'Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'Order_Size__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Buildup_Material__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'SOP_ALPHA_CPH__c'));
        insert defs;
        Map<String, RFQI_Field_Def__c> fieldDefs  = new Map<String, RFQI_Field_Def__c>(); 
        for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
        }

        List<RFQI_PF_Field_Def__c> pfFields = [select Id, Name, Sequence__c, Package_Family__c, CPN_Attribute__c, RFQI_Field_Def__r.Name, Required__c from RFQI_PF_Field_Def__c where Package_Family__r.Name =: 'FC BGA'  and RFQI_Section__r.Name =: 'Substrate Description'];

        List<RFQI_PF_Field_Def__c> fieldToRemove = new List<RFQI_PF_Field_Def__c>();

        for (RFQI_PF_Field_Def__c field : pfFields) {
            if (field.RFQI_Field_Def__r.Name == 'Amkor_Purchased_Substrate__c')
                {field.Sequence__c = 3030;}
            if (field.RFQI_Field_Def__r.Name == 'Amkor_Tooling__c')
                {field.Sequence__c = 3040;}
            if (field.RFQI_Field_Def__r.Name == 'Layer_Configuration__c')
                {field.Sequence__c = 3050;}
            if (field.RFQI_Field_Def__r.Name == 'Restricted_Substrate_Supplier__c')
                {field.Sequence__c = 3010;}
            if (field.RFQI_Field_Def__r.Name == 'Total_Layer_Count__c')
                {fieldToRemove.add(field);}
            if (field.RFQI_Field_Def__r.Name == 'Bond_Finger_Pitch__c')
                {fieldToRemove.add(field);}
            if (field.RFQI_Field_Def__r.Name == 'Number_of_Stacked_Via__c')
                {field.Sequence__c = 3070;}
            if (field.RFQI_Field_Def__r.Name == 'Substrate_Ball_Pad_Pitch__c')
                {field.Sequence__c = 3080;}
            if (field.RFQI_Field_Def__r.Name == 'Line_and_Space_Outer__c')
                {field.Sequence__c = 3120;}
            if (field.RFQI_Field_Def__r.Name == 'Line_and_Space_Inner__c')
                {field.Sequence__c = 3130;}
            if (field.RFQI_Field_Def__r.Name == 'Special_Options__c')
                {field.Sequence__c = 3140;}
            if (field.RFQI_Field_Def__r.Name == 'Via_Size_Build_up__c')
                {field.Sequence__c = 3190;}
            if (field.RFQI_Field_Def__r.Name == 'Via_Size_Core__c')
                {field.Sequence__c = 3200;}
        }

        RFQI_Section__c substrateDesc = [select Id from RFQI_Section__c where Name =: 'Substrate Description'];    
        Package_Family__c pf = [select Id from Package_Family__c where Name=: 'FC BGA'];

        

        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = substrateDesc.Id, RFQI_Field_Def__c = fieldDefs.get('Laminate__c').Id, Sequence__c = 3000,Package_Family__c = pf.Id,CPN_Attribute__c = true));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = substrateDesc.Id, RFQI_Field_Def__c = fieldDefs.get('Restricted_Supplier__c').Id, Sequence__c = 3020,Package_Family__c = pf.Id,CPN_Attribute__c = true));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = substrateDesc.Id, RFQI_Field_Def__c = fieldDefs.get('Order_Size__c').Id, Sequence__c = 3060,Package_Family__c = pf.Id,CPN_Attribute__c = true));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = substrateDesc.Id, RFQI_Field_Def__c = fieldDefs.get('Buildup_Material__c').Id, Sequence__c = 3090,Package_Family__c = pf.Id,CPN_Attribute__c = true));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = substrateDesc.Id, RFQI_Field_Def__c = fieldDefs.get('Bump_Pitch__c').Id, Sequence__c = 3100,Package_Family__c = pf.Id,CPN_Attribute__c = true));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = substrateDesc.Id, RFQI_Field_Def__c = fieldDefs.get('Core_Material__c').Id, Sequence__c = 3110,Package_Family__c = pf.Id,CPN_Attribute__c = true));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = substrateDesc.Id, RFQI_Field_Def__c = fieldDefs.get('Process_Finish__c').Id, Sequence__c = 3150,Package_Family__c = pf.Id,CPN_Attribute__c = true));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = substrateDesc.Id, RFQI_Field_Def__c = fieldDefs.get('Soldermask_Material__c').Id, Sequence__c = 3160,Package_Family__c = pf.Id,CPN_Attribute__c = true));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = substrateDesc.Id, RFQI_Field_Def__c = fieldDefs.get('Soldermask_Registration__c').Id, Sequence__c = 3170,Package_Family__c = pf.Id,CPN_Attribute__c = true));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = substrateDesc.Id, RFQI_Field_Def__c = fieldDefs.get('SOP_ALPHA_CPH__c').Id, Sequence__c = 3180,Package_Family__c = pf.Id,CPN_Attribute__c = true));

        upsert pfFields;

        delete fieldToRemove;
    }


    public static void amk1037() {
        List<RFQI_PF_Field_Def__c> pfFields = [select Id, Package_Family__r.Specific_RFQ_Item_Object__c,Package_Family__r.Name, Object_API_Name__c, RFQI_Field_Def__r.Name, Sequence__c from RFQI_PF_Field_Def__c];

        addFieldDefs1037();

        Map<String, RFQI_Field_Def__c> fieldDefs  = new Map<String, RFQI_Field_Def__c>(); 
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
                fieldDefs.put(fieldDef.Name, fieldDef);
            }

        
        
        otherFieldPFFieldChange('FC CSP', pfFields, fieldDefs);
        otherFieldPFFieldChange('FC SCSP', pfFields, fieldDefs);

        for (RFQI_PF_Field_Def__c def : pfFields) {
            if (def.Package_Family__r.Name == 'FC BGA') {
                if (def.RFQI_Field_Def__r.Name == 'Lid_Attach_Type__c')
                {def.RFQI_Section__c = null;def.Belongs_To_Section__c = 'Package Description';}
                if (def.RFQI_Field_Def__r.Name == 'Lid_Thickness__c')
                {def.RFQI_Section__c = null;def.Belongs_To_Section__c = 'Package Description';}
                if (def.RFQI_Field_Def__r.Name == 'TIM__c')
                {def.RFQI_Section__c = null;def.Belongs_To_Section__c = 'Package Description';}
            }
        }

        RFQI_Section__c passiveSection = [select Id from RFQI_Section__c where Name =: 'Passive Description'];
        addNewPassiveSection('FC CSP', pfFields, fieldDefs, passiveSection);
        addNewPassiveSection('FC SCSP', pfFields, fieldDefs, passiveSection);
        addNewPassiveSection('FC BGA', pfFields, fieldDefs, passiveSection);


        // for (RFQI_PF_Field_Def__c field : pfFields ) {
        //     string otherFields = OtherFieldHelper.getOtherMapStringForField(field.Object_API_Name__c, field.RFQI_Field_Def__r.Name);
        //     field.Other_Fields__c = otherFields;
        // }

        upsert pfFields;
    }

    public static void updateOtherFields() {
        List<RFQI_PF_Field_Def__c> pfFields = [select Id, Package_Family__r.Specific_RFQ_Item_Object__c,Package_Family__r.Name, Object_API_Name__c, RFQI_Field_Def__r.Name, Sequence__c from RFQI_PF_Field_Def__c];

        for (RFQI_PF_Field_Def__c field : pfFields ) {
            string otherFields = OtherFieldHelper.getOtherMapStringForField(field.Object_API_Name__c, field.RFQI_Field_Def__r.Name);
            field.Other_Fields__c = otherFields;
        }

        upsert pfFields;
    }

    private static void otherFieldPFFieldChange(String packageFamily, List<RFQI_PF_Field_Def__c> fields, Map<String, RFQI_Field_Def__c> fieldDefs) {
        Package_Family__c pf = [select Id, Name from Package_Family__c where Name =: packageFamily];

        for  (RFQI_PF_Field_Def__c field : fields) {
            if (field.Package_Family__c == pf.id){
                if(field.RFQI_Field_Def__r.Name == 'Lid_Attach_Type__c')
                    {field.RFQI_Section__c = null; field.Other_Field__c = null; field.Belongs_To_Section__c = 'Package Description';}
                if(field.RFQI_Field_Def__r.Name == 'Lid_Material__c')
                    {field.RFQI_Section__c = null; field.Other_Field__c = null; field.Sequence__c = 2180; field.Belongs_To_Section__c = 'Package Description';}
                if(field.RFQI_Field_Def__r.Name == 'Lid_Finish__c')
                    {field.RFQI_Section__c = null; field.Other_Field__c = null; field.Sequence__c = 2200; field.Belongs_To_Section__c = 'Package Description';}
                if(field.RFQI_Field_Def__r.Name == 'Lid_TIM__c')
                    {field.RFQI_Section__c = null; field.Other_Field__c = null; field.Sequence__c = 2220; field.Belongs_To_Section__c = 'Package Description';}
                if(field.RFQI_Field_Def__r.Name == 'Lid_Adhesive__c')
                    {field.RFQI_Section__c = null; field.Other_Field__c = null; field.Sequence__c = 2240; field.Belongs_To_Section__c = 'Package Description';}
                if(field.RFQI_Field_Def__r.Name == 'Lid_Size_X__c')
                    {field.RFQI_Section__c = null; field.Sequence__c = 2260; field.Belongs_To_Section__c = 'Package Description';}
                if(field.RFQI_Field_Def__r.Name == 'Lid_Size_Y__c')
                    {field.RFQI_Section__c = null; field.Sequence__c = 2270; field.Belongs_To_Section__c = 'Package Description';}
                if(field.RFQI_Field_Def__r.Name == 'Prestacking__c')
                    {field.RFQI_Section__c = null; field.Sequence__c = 2280; field.Belongs_To_Section__c = 'Package Description';}
                if(field.RFQI_Field_Def__r.Name == 'Include_TMV__c')
                    {field.Sequence__c = 2290;}
                if(field.RFQI_Field_Def__r.Name == 'Number_of_TMV_Balls__c')
                    {field.RFQI_Section__c = null; field.Sequence__c = 2300; field.Belongs_To_Section__c = 'Package Description';}
                if(field.RFQI_Field_Def__r.Name == 'TMV_Pitch__c')
                    {field.RFQI_Section__c = null; field.Sequence__c = 2310; field.Belongs_To_Section__c = 'Package Description';}
                if(field.RFQI_Field_Def__r.Name == 'TMV_Ball_Composition__c')
                    {field.RFQI_Section__c = null; field.Other_Field__c = null; field.Sequence__c = 2320; field.Belongs_To_Section__c = 'Package Description';}
                if(field.RFQI_Field_Def__r.Name == 'Strip_Width__c')
                    {field.Other_Field__c = null;}
                if(field.RFQI_Field_Def__r.Name == 'BGA_Ball_Composition__c')
                    {field.Other_Field__c = null;}
            }
        }

        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Lid_Attach_Type_Other__c').Id, Sequence__c = 2170, Package_Family__c = pf.Id, Belongs_To_Section__c = 'Package Description'));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Lid_Material_Other__c').Id, Sequence__c = 2190, Package_Family__c = pf.Id, Belongs_To_Section__c = 'Package Description'));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Lid_Finish_Other__c').Id, Sequence__c = 2210, Package_Family__c = pf.Id, Belongs_To_Section__c = 'Package Description'));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Lid_TIM_Other__c').Id, Sequence__c = 2230, Package_Family__c = pf.Id, Belongs_To_Section__c = 'Package Description'));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Lid_Adhesive_Other__c').Id, Sequence__c = 2250, Package_Family__c = pf.Id, Belongs_To_Section__c = 'Package Description'));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('TMV_Ball_Composition_Other__c').Id, Sequence__c = 2330, Package_Family__c = pf.Id, Belongs_To_Section__c = 'Package Description'));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Strip_Width_Other__c').Id, Sequence__c = 2010, Package_Family__c = pf.Id, Belongs_To_Section__c = 'Package Description'));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('BGA_Ball_Composition_Other__c').Id, Sequence__c = 2080, Package_Family__c = pf.Id, Belongs_To_Section__c = 'Package Description'));
    }

    private static void addFieldDefs1037() {
        List<RFQI_Field_Def__c> defs = new List<RFQI_Field_Def__c>();

        defs.add(new RFQI_Field_Def__c(Name = 'Amkor_SID__c', Object__c='Passive', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Amkor_SID_Other__c', Object__c='Passive', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Capacitance__c', Object__c='Passive', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Dielectric_Material__c', Object__c='Passive', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Dielectric_Material_Other__c', Object__c='Passive', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Inductance__c', Object__c='Passive', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Passive_Size_Other__c', Object__c='Passive', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Passive_Supplier_Other__c', Object__c='Passive', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Passive_Type_Other__c', Object__c='Passive', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Passive_Units__c', Object__c='Passive', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Supplier_SID_Part_Number__c', Object__c='Passive', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Supplier_SID_Part_Number_Other__c', Object__c='Passive', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Tolerance_Other__c', Object__c='Passive', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Voltage_Power_Amperage__c', Object__c='Passive', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Voltage_Power_Amperage_Other__c', Object__c='Passive', Type__c='Decimal'));

        insert defs;
    }

    private static void addNewPassiveSection(String packageFamily, List<RFQI_PF_Field_Def__c> fields, Map<String, RFQI_Field_Def__c> fieldDefs, RFQI_Section__c passiveSection) {
        Package_Family__c pf = [select Id, Name from Package_Family__c where Name =: packageFamily];

        for  (RFQI_PF_Field_Def__c field : fields) {
            if (field.Package_Family__c == pf.id){
                if(field.RFQI_Field_Def__r.Name == 'Number_of_Passives__c')
                    {field.Sequence__c = 3020;}
                if(field.RFQI_Field_Def__r.Name == 'Specific_Passive__c')
                    {field.Sequence__c = 3030;}
                if(field.RFQI_Field_Def__r.Name == 'Resistance_Value__c')
                    {field.Sequence__c = 3060; field.Belongs_To_Section__c = 'Passive Description';}
                if(field.RFQI_Field_Def__r.Name == 'Tolerance__c')
                    {field.Sequence__c = 3090;}
                if(field.RFQI_Field_Def__r.Name == 'Voltage__c')
                    {field.Sequence__c = 3120;}
                if(field.RFQI_Field_Def__r.Name == 'Passive_Supplier__c')
                    {field.Sequence__c = 3150;}

            }
        }

        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Passive_Type_Other__c').Id, Sequence__c = 3010, Package_Family__c = pf.Id, Belongs_To_Section__c = 'Passive Description', RFQI_Section__c = passiveSection.Id));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Passive_Size_Other__c').Id, Sequence__c = 3040, Package_Family__c = pf.Id, Belongs_To_Section__c = 'Passive Description', RFQI_Section__c = passiveSection.Id));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Capacitance__c').Id, Sequence__c = 3050, Package_Family__c = pf.Id, CPN_Attribute__c = true, Belongs_To_Section__c = 'Passive Description', RFQI_Section__c = passiveSection.Id));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Inductance__c').Id, Sequence__c = 3070, Package_Family__c = pf.Id, CPN_Attribute__c = true, Belongs_To_Section__c = 'Passive Description', RFQI_Section__c = passiveSection.Id));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Passive_Units__c').Id, Sequence__c = 3080, Package_Family__c = pf.Id, RFQI_Section__c = passiveSection.Id));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Tolerance_Other__c').Id, Sequence__c = 3100, Package_Family__c = pf.Id, Belongs_To_Section__c = 'Passive Description', RFQI_Section__c = passiveSection.Id));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Voltage_Power_Amperage__c').Id, Sequence__c = 3110, Package_Family__c = pf.Id, RFQI_Section__c = passiveSection.Id, CPN_Attribute__c = true));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Dielectric_Material__c').Id, Sequence__c = 3130, Package_Family__c = pf.Id, RFQI_Section__c = passiveSection.Id, CPN_Attribute__c = true));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Dielectric_Material_Other__c').Id, Sequence__c = 3140, Package_Family__c = pf.Id, Belongs_To_Section__c = 'Passive Description', RFQI_Section__c = passiveSection.Id));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Passive_Supplier_Other__c').Id, Sequence__c = 3160, Package_Family__c = pf.Id, Belongs_To_Section__c = 'Passive Description', RFQI_Section__c = passiveSection.Id));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Amkor_SID__c').Id, Sequence__c = 3170, Package_Family__c = pf.Id, RFQI_Section__c = passiveSection.Id, CPN_Attribute__c = true));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Amkor_SID_Other__c').Id, Sequence__c = 3180, Package_Family__c = pf.Id, Belongs_To_Section__c = 'Passive Description'));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Supplier_SID_Part_Number__c').Id, Sequence__c = 3170, Package_Family__c = pf.Id, RFQI_Section__c = passiveSection.Id, CPN_Attribute__c = true));
        fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Supplier_SID_Part_Number_Other__c').Id, Sequence__c = 3180, Package_Family__c = pf.Id, Belongs_To_Section__c = 'Passive Description', RFQI_Section__c = passiveSection.Id));

    }

    public static void AMK1496() {
        List<RFQI_PF_Field_Def__c> pfFieldDefs = [select Id, RFQI_Field_Def__r.Name, RFQI_Section__c, Package_Family__r.Name from RFQI_PF_Field_Def__c];
        List<RFQI_PF_Field_Def__c> fieldsToDelete = new List<RFQI_PF_Field_Def__c>();

        List<RFQI_Field_Def__c> defs = new List<RFQI_Field_Def__c>();

        defs.add(new RFQI_Field_Def__c(Name = 'Amperage__c', Object__c = 'Passive'));
        defs.add(new RFQI_Field_Def__c(Name = 'Power__c', Object__c = 'Passive'));
        defs.add(new RFQI_Field_Def__c(Name = 'Voltage_Other__c', Object__c = 'Passive'));
        defs.add(new RFQI_Field_Def__c(Name = 'Power_Other__c', Object__c = 'Passive'));
        defs.add(new RFQI_Field_Def__c(Name = 'Passivation_Type_Other__c', Object__c = 'Die'));

        insert defs;

        families = [select Id, Name from Package_Family__c where Product_Group__r.Name =: 'Flip Chip'];

        AMK1496PassiveChanges('FC BGA', pfFieldDefs, fieldsToDelete);
        AMK1496PassiveChanges('FC CSP', pfFieldDefs, fieldsToDelete);
        AMK1496PassiveChanges('FC SCSP', pfFieldDefs, fieldsToDelete);

        for (Package_Family__c pf : families) {
            pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = defs[0].Id, Package_Family__c = pf.Id, Belongs_To_Section__c = 'Passive Description', Sequence__c = 3105));
            pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = defs[1].Id, Package_Family__c = pf.Id, Belongs_To_Section__c = 'Passive Description', Sequence__c = 3110));
            pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = defs[2].Id, Package_Family__c = pf.Id, CPN_Attribute__c = true, Belongs_To_Section__c = 'Passive Description', Sequence__c = 3115));
            pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = defs[3].Id, Package_Family__c = pf.Id, CPN_Attribute__c = true, Belongs_To_Section__c = 'Passive Description', Sequence__c = 3113));
            if(pf.Name == 'FC CSP' || pf.Name == 'FC SCSP') {
                pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = defs[4].Id, Package_Family__c = pf.Id, CPN_Attribute__c = true, Belongs_To_Section__c = 'Die Description', Sequence__c = 3145));
            }
        }
        
        upsert pfFieldDefs;
        delete fieldsToDelete;



    }

    private static void AMK1496PassiveChanges(String packageFamily, List<RFQI_PF_Field_Def__c> pfFieldDefs, List<RFQI_PF_Field_Def__c> fieldsToDelete) {
        for(RFQI_PF_Field_Def__c field : pfFieldDefs) {
            if (field.Package_Family__r.Name == packageFamily) {
                if(field.RFQI_Field_Def__r.Name == 'Amkor_SID_Other__c')
                    {field.RFQI_Section__c = null;}
                if(field.RFQI_Field_Def__r.Name == 'Capacitance__c')
                    {field.RFQI_Section__c = null;}
                if(field.RFQI_Field_Def__r.Name == 'Dielectric_Material_Other__c')
                    {field.RFQI_Section__c = null;}
                if(field.RFQI_Field_Def__r.Name == 'Inductance__c')
                    {field.RFQI_Section__c = null;}
                if(field.RFQI_Field_Def__r.Name == 'Passive_Size_Other__c')
                    {field.RFQI_Section__c = null;}
                if(field.RFQI_Field_Def__r.Name == 'Passive_Supplier_Other__c')
                    {field.RFQI_Section__c = null;}
                if(field.RFQI_Field_Def__r.Name == 'Passive_Type_Other__c')
                    {field.RFQI_Section__c = null;}
                if(field.RFQI_Field_Def__r.Name == 'Resistance_Value__c')
                    {field.RFQI_Section__c = null;}
                if(field.RFQI_Field_Def__r.Name == 'Supplier_SID_Part_Number_Other__c')
                    {field.RFQI_Section__c = null;}
                if(field.RFQI_Field_Def__r.Name == 'Tolerance_Other__c')
                    {field.RFQI_Section__c = null;}
                if(field.RFQI_Field_Def__r.Name == 'Voltage__c')
                    {field.RFQI_Section__c = null;}
                if(field.RFQI_Field_Def__r.Name == 'Voltage_Power_Amperage__c')
                    {fieldsToDelete.add(field);}
                if(packageFamily == 'FC CSP' || packageFamily == 'FC SCSP' ) {
                    if(field.RFQI_Field_Def__r.Name == 'Wire_Diameter_Other__c')
                        {field.RFQI_Section__c = null;}
                    if(field.RFQI_Field_Def__r.Name == 'Substrate_Dam_Thickness__c')
                        {field.RFQI_Section__c = null;}
                    if(field.RFQI_Field_Def__r.Name == 'Substrate_Dam_Material__c')
                        {field.RFQI_Section__c = null;}
                }
            }

        }
    }

    public static void AMK1503() {

        List<RFQI_Field_Def__c> fieldDefsToAdd = new List<RFQI_Field_Def__c>();
        List<RFQI_Default_Driver__c> drivers = new List<RFQI_Default_Driver__c>();
        List<RFQI_PF_Field_Def__c> fieldToRemove = new List<RFQI_PF_Field_Def__c>();
        fieldDefsToAdd.add(new RFQI_Field_Def__c(Name='Prepreg_Material__c'));
        fieldDefsToAdd.add(new RFQI_Field_Def__c(Name='Thickness_Prepreg_BuildUp__c', Type__c = 'Decimal'));
        fieldDefsToAdd.add(new RFQI_Field_Def__c(Name='Substrate_Thickness_Other__c', Type__c = 'Decimal'));

        insert fieldDefsToAdd;

        Map<String, RFQI_Field_Def__c> fieldDefs  = new Map<String, RFQI_Field_Def__c>(); 
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
                fieldDefs.put(fieldDef.Name, fieldDef);
            }

        List<RFQI_PF_Field_Def__c> pfFields = [select Id, RFQI_Field_Def__r.Name, Package_Family__r.Name, Default_Driver__c from RFQI_PF_Field_Def__c];

        for (RFQI_PF_Field_Def__c field : pfFields) {
            if (field.Package_Family__r.Name == 'FC CSP' || field.Package_Family__r.Name == 'FC SCSP') {
                if(field.RFQI_Field_Def__r.Name == 'Total_Layer_Count__c')
                    {field.Default_Driver__c = true;}
                if(field.RFQI_Field_Def__r.Name == 'Copper_Thickness_External__c')
                    {field.Default_Driver__c = true;}
                if(field.RFQI_Field_Def__r.Name == 'Copper_Thickness_Internal__c')
                    {field.Default_Driver__c = true;}
                if(field.RFQI_Field_Def__r.Name == 'Copper_Thickness_Core__c')
                    {field.Default_Driver__c = true;}
                if(field.RFQI_Field_Def__r.Name == 'Core_Thickness__c')
                    {field.Default_Driver__c = true;}
                if(field.RFQI_Field_Def__r.Name == 'Substrate_Thickness__c')
                    {fieldToRemove.add(field);}
                if(field.RFQI_Field_Def__r.Name == 'BGA_IGA_Pad_Metal_Size_Other__c')
                    {fieldToRemove.add(field);}
            }
        }

        List<Package_Family__c> packageFamilies = [select Id, Name from Package_Family__c where Product_Group__r.Name = 'Flip Chip'];
        RFQI_Section__c substrateDesc = [select Id from RFQI_Section__c where Name =: 'Substrate Description'];   

        for(Package_Family__c pf : packageFamilies) {
            if(pf.Name == 'FC CSP' || pf.Name == 'FC SCSP') {
                pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Prepreg_Material__c').Id, Sequence__c = 3232, Package_Family__c = pf.Id, RFQI_Section__c = substrateDesc.Id));
                pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Buildup_Material__c').Id, Sequence__c = 3234, Package_Family__c = pf.Id, RFQI_Section__c = substrateDesc.Id));
                pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Substrate_Thickness_Other__c').Id, Sequence__c = 3242, Package_Family__c = pf.Id, RFQI_Section__c = substrateDesc.Id));
                pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Thickness_Prepreg_BuildUp__c').Id, Sequence__c = 3328, Package_Family__c = pf.Id, RFQI_Section__c = substrateDesc.Id, Default_Driver__c = true));
                pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Soldermask_Thickness__c').Id, Sequence__c = 3212, Package_Family__c = pf.Id, RFQI_Section__c = substrateDesc.Id, Default_Driver__c = true));
                pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('BGA_IGA_Pad_Metal_Size__c').Id, Sequence__c = 3460, Package_Family__c = pf.Id, RFQI_Section__c = substrateDesc.Id));
                FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Total_Layer_Count__c'), 'Substrate_Thickness_Forumla__c', fieldDefs.get('Substrate_Thickness_Other__c'), drivers);
                FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Copper_Thickness_External__c'), 'Substrate_Thickness_Forumla__c', fieldDefs.get('Substrate_Thickness_Other__c'), drivers);
                FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Copper_Thickness_Internal__c'), 'Substrate_Thickness_Forumla__c', fieldDefs.get('Substrate_Thickness_Other__c'), drivers);
                FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Copper_Thickness_Core__c'), 'Substrate_Thickness_Forumla__c', fieldDefs.get('Substrate_Thickness_Other__c'), drivers);
                FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Core_Thickness__c'), 'Substrate_Thickness_Forumla__c', fieldDefs.get('Substrate_Thickness_Other__c'), drivers);
                FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Thickness_Prepreg_BuildUp__c'), 'Substrate_Thickness_Forumla__c', fieldDefs.get('Substrate_Thickness_Other__c'), drivers);
                FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Soldermask_Thickness__c'), 'Substrate_Thickness_Forumla__c', fieldDefs.get('Substrate_Thickness_Other__c'), drivers);
            }
        }
        
        insert drivers;
        upsert pfFields;

        delete fieldToRemove;
    }

    public static void AMK1493() {
        List<RFQI_PF_Field_Def__c> fieldsToUpdate = [select Id, Default_Driver__c, RFQI_Field_Def__r.Name, Belongs_To_Section__c, RFQI_Section__c, RFQI_Section__r.Name, Required__c from RFQI_PF_Field_Def__c where Package_Family__r.Name =: 'FC BGA'];

        for(RFQI_PF_Field_Def__c field : fieldsToUpdate) {
            if(field.RFQI_Field_Def__r.Name == 'Ball_Pitch__c') {
                field.Default_Driver__c = true; 
            }
            if(field.RFQI_Field_Def__r.Name == 'Ground_Lid_Adhesive__c') {
                field.RFQI_Section__c = null; field.Belongs_To_Section__c = 'Package Description';
            }
            if(field.RFQI_Field_Def__r.Name == 'HS_Adhesive__c') {
                field.RFQI_Section__c = null; field.Belongs_To_Section__c = 'Package Description';
            }
            if(field.RFQI_Field_Def__r.Name == 'Stiffener_Adhesive__c') {
                field.RFQI_Section__c = null; field.Belongs_To_Section__c = 'Package Description';
            }

            if(field.RFQI_Section__r.Name == 'Substrate Description') {
                field.Required__c = false;
            }
        }

        update fieldsToUpdate;
        updateOtherFields();
    }

    public static void AMK1493_2()
    {
        List<RFQI_PF_Field_Def__c> fieldsToUpdate = [select Id, Default_Driver__c, RFQI_Field_Def__r.Name, Belongs_To_Section__c, RFQI_Section__c, RFQI_Section__r.Name, Required__c from RFQI_PF_Field_Def__c where Package_Family__r.Name =: 'FC BGA' and RFQI_Field_Def__r.Name='Lid__c'];

        for (RFQI_PF_Field_Def__c row : fieldsToUpdate)
        {
            row.Belongs_To_Section__c = 'Package Description';
            row.RFQI_Section__c = null;
        }

        update fieldsToUpdate;
        updateOtherFields();

    }

    public static void AMK1816()
    {
        updateOtherFields();
    }
}