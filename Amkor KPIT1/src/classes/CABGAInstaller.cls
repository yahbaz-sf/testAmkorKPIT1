/*************************************************************************
* 
* PURPOSE:  this class seeds fresh RFQ Item Field Definition specifically
*           for the CABGA package families (cloned from SOIC150Installer
*           for the purposes of generalization)
*         
* CLASS: CABGAInstaller
* CREATED: 05/06/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
global class CABGAInstaller {

    private static Product_Group__c prodGroup {get; set;}
    private static List<Package_Family__c> families {get; set;}

    global static void install() {
        FieldBuilderHelper.clean('CABGA');  
        prodGroup = FieldBuilderHelper.installProductGroup('CABGA', 'CMCABGABuilder');
        installCABGAPackageFamilies();
        installVersion();
        installDDCABGA();
        installFields('CABGA');
        FieldBuilderHelper.markNoCostModels('CABGA');
        incrementalInstallAMK1434();
        RFQAdminInstaller.AMK1237();
        AMK1711();
        
    }
    
    public static void updateSapFields() {
    	RFQAdminInstaller.updateSapFieldsForProductGroup('CABGA');  
    }
    
    private static List<Package_Family__c> installCABGAPackageFamilies(){
        
        families = new List<Package_Family__c>();
        
        FieldBuilderHelper.addPf('CABGA', prodGroup, 'RFQI_CABGA__c', 'RFQIWC_CABGA__c', 'RFQIDC_CABGA__c', families, true);
        try {
            insert families;
        }catch(Exception e) {
            system.debug('Could not install CABGA Package Families: ' + e);
        }return families;
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

    private static void installDDCABGA() {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'CABGA'];
        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
            }

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Prototype__c'), 'true', fieldDefs.get('Forecast__c'), '0-5');    


        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Size_Z__c'), 'Max_Package_Thickness_Formula__c', fieldDefs.get('MaxPackage_Thickness__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Number_of_BGA_Balls__c'), 'Number_of_BGA_Balls__c', fieldDefs.get('Ball_Count__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_X__c'), 'Ball_Count_Formula__c', fieldDefs.get('Ball_Count__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Y__c'), 'Ball_Count_Formula__c', fieldDefs.get('Ball_Count__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_X__c'), 'Ball_Count_Formula__c', fieldDefs.get('Number_of_BGA_Balls__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Y__c'), 'Ball_Count_Formula__c', fieldDefs.get('Number_of_BGA_Balls__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Layer_Configuration__c'), 'Total_Via_Formula__c', fieldDefs.get('Total_Number_of_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Layer_Configuration__c'), 'Laser_Via_Formula__c', fieldDefs.get('Number_of_Laser_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Layer_Configuration__c'), 'Mech_Via_Formula__c', fieldDefs.get('Number_of_Mech_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Core_Thickness__c'), 'Substrate_Thickness_Formula__c', fieldDefs.get('Substrate_Thickness__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_X__c'), 'Wire_Count_Formula__c', fieldDefs.get('Number_of_Wires__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Y__c'), 'Wire_Count_Formula__c', fieldDefs.get('Number_of_Wires__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Number_of_BGA_Balls__c'), 'Wire_Count_Formula__c', fieldDefs.get('Number_of_Wires__c'));

        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_X__c'), 'Total_Via_Formula__c', fieldDefs.get('Total_Number_of_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_X__c'), 'Laser_Via_Formula__c', fieldDefs.get('Number_of_Laser_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_X__c'), 'Mech_Via_Formula__c', fieldDefs.get('Number_of_Mech_Vias__c'));

        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Y__c'), 'Total_Via_Formula__c', fieldDefs.get('Total_Number_of_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Y__c'), 'Laser_Via_Formula__c', fieldDefs.get('Number_of_Laser_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Body_Y__c'), 'Mech_Via_Formula__c', fieldDefs.get('Number_of_Mech_Vias__c'));

        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Number_of_BGA_Balls__c'), 'Total_Via_Formula__c', fieldDefs.get('Total_Number_of_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Number_of_BGA_Balls__c'), 'Laser_Via_Formula__c', fieldDefs.get('Number_of_Laser_Vias__c'));
        FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Number_of_BGA_Balls__c'), 'Mech_Via_Formula__c', fieldDefs.get('Number_of_Mech_Vias__c'));




    } 

    public static void incrementalInstallAMK1434()
    {
        List<Product_Group__c> pgList = [select Id, Name, Cost_Model_Implementation__c from Product_Group__c where Name='CABGA'];
        for (Product_Group__c row : pgList) row.Cost_Model_Implementation__c = null;

        List<Package_Family__c> pfList = [select Id, Name, Cost_Model_Implementation__c, Has_Manual_Entry_Fields__c from Package_Family__c where Product_Group__c in: pgList];
        for (Package_Family__c row : pfList) row.Has_Manual_Entry_Fields__c = false;

        List<RFQI_PF_Field_Def__c> fieldList = [Select Id, Name, Required__c, Is_Manual_Entry__c, RFQI_Field_Def__c, RFQI_Field_Def__r.Name, Package_Family__r.Name, RFQI_Section__r.Name from RFQI_PF_Field_Def__c where Package_Family__c in: pfList and RFQI_Section__r.Name='Cost and Price'];
        for (RFQI_PF_Field_Def__c row : fieldList)
        {
            row.Required__c = (row.RFQI_Field_Def__r.Name == 'Total_Cost__c' || row.RFQI_Field_Def__r.Name == 'BU_Price__c');
            row.Is_Manual_Entry__c = false;
        }

        update pgList;
        update pfList;
        update fieldList;
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
        
        //Adding Cost and Price section for BUs
        helper.add('Cost and Price','CLAM_Direct_Labor__c',1000,false,true);
        helper.add('Cost and Price','Materials_Substrate__c',1010,false,true);
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
        helper.add('Cost and Price','Package_Item_Value__c',1150,false,true);
        helper.add('Cost and Price','CLAM_Total__c',1160,false,true);
        helper.add('Cost and Price','Materials_As_Perc_Cost__c',1170,false,true);
        helper.add('Cost and Price','Manufacturing_Overhead__c',1180,false,true);
        helper.add('Cost and Price','Total_Cost__c',1190,false,true);
        helper.add('Cost and Price','Variable_Costs__c',1200,false,true);
        helper.add('Cost and Price','QA_Cost__c',1210,false,true);
        helper.add('Cost and Price','Adder_Cost__c',1220,false,true);
        helper.add('Cost and Price','Fixed_Costs__c',1230,false,true);
        helper.add('Cost and Price','Service_Group_Cost__c',1230,false,true); 
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
        helper.add('Quote Information', 'Prototype__c', 1090);
        helper.add('Quote Information', 'Customer_Target_Price__c', 1100);
        helper.add('Quote Information', 'Sales_Target_Price__c', 1110);
        helper.add('Quote Information', 'End_Market_Segment__c', 1120);
        helper.add('Quote Information', 'Competitor__c', 1130);
        helper.add('Quote Information', 'Competitor_Au_Inclusive_Price__c', 1140);
        helper.add('Quote Information', 'HVP_Anticipated_Start_Date__c', 1150);
        helper.add('Quote Information', 'Has_Been_Quoted_Before__c', 1160);
        
        helper.add('Package Description', 'Body_X__c', 2000, true, false, true, true);
        helper.add('Package Description', 'Body_Y__c', 2010, true, false, true, true);
        helper.add('Package Description', 'Body_Size_Z__c', 2020, true, false, false, true, 'Body_Z__c');
        helper.add('Package Description', 'Number_of_BGA_Balls__c', 2030, true, false, true, true);
        helper.add('Package Description', 'EMC__c', 2080, true);
        //helper.add('Package Description', 'MCM_or_Stacked__c', 2100, true);
        //helper.add('Package Description', 'Backgrinding_Required__c', 2110, true);

        helper.add('Wire Description', 'Wire_Configuration__c', 3000, false, false, true);
        helper.add('Wire Description', 'Wire_Material__c', 3010, true, false, true);
        helper.add('Wire Description', 'Wire_Diameter__c', 3020, true, false, true);
        helper.add('Wire Description', 'Number_Of_Wires__c', 3030, true, false, true);
        helper.add('Wire Description', 'Average_2D_Wire_Length__c', 3040);
        helper.add('Wire Description', 'Total_2D_Wire_Length__c', 3050);
        helper.add('Wire Description', 'Total_3D_Wire_Length__c', 3060, true);
        helper.add('Wire Description', 'Au_Factor__c', 3070);
        
        helper.add('Die Description', 'Wafer_Size__c', 3000, true);
        helper.add('Die Description', 'Wafer_Technology__c', 3010, true);
        helper.add('Die Description', 'Wafer_Saw_Street__c', 3020, true);
        helper.add('Die Description', 'Die_Size_X__c', 3030, true, false, false, false, '', true); 
        helper.add('Die Description', 'Die_Size_Y__c', 3040, true, false, false, false, '', true);
        helper.add('Die Description', 'Die_Thickness__c', 3050, true);
        helper.add('Die Description', 'Die_Attach__c', 3060, true);
        helper.add('Die Description', 'Laser_Groove__c', 3060, true);
        
        helper.add('Substrate Description', 'MaxPackage_Thickness__c', 3020);
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
        helper.add('Substrate Description', 'Core_Thickness__c', 3200, true, false, false, true);
        helper.add('Substrate Description', 'Substrate_Thickness__c', 3200, true);
        helper.add('Substrate Description', 'Plating__c', 3210, true);
        helper.add('Substrate Description', 'Metal_Finish__c', 3220, true);
        helper.add('Substrate Description', 'Substrate_Supplier__c', 3230, true);   
        helper.add('Substrate Description', 'Restricted_Substrate_Supplier__c', 3240, true);
        helper.add('Substrate Description', 'Special_Options__c', 3250, true);
        
        helper.add('Adders', 'Plasma_Before_Die_Attach__c', 4000, true);
        helper.add('Adders', 'Endline_OS_Test__c', 4010, true);
        //helper.add('Adders', 'Plasma_Before_Mold__c', 4020, true);
        helper.add('Adders', 'Ball_Scan__c', 4040, true);
        helper.add('Adders', 'X2_OPT_INSP_100__c', 4050, true);
        helper.add('Adders', 'X3RD_OPT_100__c', 4060, true);
        helper.add('Adders', 'FVI_100__c', 4070, true);
        helper.add('Adders', 'Bake_Dry_Pack__c', 4080, true);
        helper.add('Adders', 'Temperature_Cycle__c', 4090, true);
        helper.add('Adders', 'Bake__c', 4100, true);
        helper.add('Adders', 'Passives__c', 4120, true);
        
        helper.add('NRE', 'Substrate_Design__c', 4000);
        helper.add('NRE', 'Stencil_Tooling__c', 4010);
        helper.add('NRE', 'Art_Work__c', 4040);
        helper.add('NRE', 'Substrate_ET_Checker__c', 4050);
        helper.add('NRE', 'Mold_Chase__c', 4090);
        helper.add('NRE', 'Singulation__c', 4120);
        helper.add('NRE', 'Auto_BAT__c', 4130);
        helper.add('NRE', 'Manual_BAT__c', 4160);
        helper.add('NRE', 'Other__c', 4170);
        
        
        
        helper.insertFields();
        
        return helper.getPfFieldDefs();  
    }

    public static void AMK1185() {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'CABGA'];
        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
            }
        
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Wire_Material__c'), 'Au', fieldDefs.get('Wire_Diameter__c'), '0.7'); 
        //Lalit SF-85 Wire Material PickList Change MLF Package Families . Date:23th Aug. 
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Wire_Material__c'), 'AuPCC', fieldDefs.get('Wire_Diameter__c'), '0.8'); 
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Wire_Material__c'), 'Ag', fieldDefs.get('Wire_Diameter__c'), '0.8');

        List<RFQI_PF_Field_Def__c> pfFieldDefs = [select Id, Default_Driver__c, Other_Field__c, RFQI_Field_Def__r.Name from RFQI_PF_Field_Def__c where Package_Family__c =: pf.Id];

        for(RFQI_PF_Field_Def__c def : pfFieldDefs) {
            if(def.RFQI_Field_Def__r.Name == 'Wire_Material__c')
                {def.Default_Driver__c = true;}
            if(def.RFQI_Field_Def__r.Name == 'Body_Size_Z__c')
                {def.Other_Field__c = null;}
        }
        
        update pfFieldDefs;     

    }
    

    public static void AMK1711() {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'CABGA'];
        pf.Default_Number_Of_Die_BU_Export__c = 4;
        pf.Default_Number_Of_Wires_BU_Export__c = 2;
        update pf;
    }

    
    
    
}