/*************************************************************************
* 
* PURPOSE:  this class seeds fresh RFQ Item Field Definition specifically
*           for the Service package families (cloned from SOIC150Installer
*           for the purposes of generalization)
*         
* CLASS: ServiceInstaller
* CREATED: 05/09/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
global class ServiceInstaller {

    private static Product_Group__c prodGroup {get; set;}
    private static List<Package_Family__c> families {get; set;}
    private static CM_Version__c cmVersion {get; set;}


    global static void install() {
        FieldBuilderHelper.clean('Standalone Services');
        prodGroup = FieldBuilderHelper.installProductGroup('Standalone Services', false, true, 'CMTestBuilder');
        installPackageFamilies();
        installVersion();
        installTestFieldDefs('Final Test');
        installTestFieldDefs('Wafer Probe');
        installTestModels();
        installDieProcessingFields();
        installBumpFields();
        installDieSalesFields();
        installExtended('WLCSP');
        installExtended('LEAD FINISH');
        installExtended('WAFER BACKGRIND');
        FieldBuilderHelper.deleteProductgroupDefaultDriver('Standalone Services');
        installDefaultDrivers();
        FieldBuilderHelper.markNoCostModels('Standalone Services');
        updateSpecialReadonlyFields();
    }
    
    public static void updateSapFields() {
   	RFQAdminInstaller.updateSapFieldsForProductGroup('Standalone Services');  
    }

    private static void updateSpecialReadonlyFields() {
        List<RFQI_PF_Field_Def__c> fieldDefs = 
        [
            Select Id from RFQI_PF_Field_Def__c where 
            RFQI_Field_Def__r.Name in ('Assembly_Package_Name__c', 'Body_Size__c', 'Ball_Lead_Count__c')
            and Package_Family__r.Product_Group__r.Name = 'Standalone Services'
        ];

        for (RFQI_PF_Field_Def__c fieldDef : fieldDefs) {
            fieldDef.Read_Only_If_Parent__c = true;
        }

        update fieldDefs;
    }
    
    private static List<Package_Family__c> installPackageFamilies() {
        
        //Product_Group__c prodGroup = [select Id from Product_Group__c where Name =: 'Standalone Services'];
        families = new List<Package_Family__c>();
        FieldBuilderHelper.addPf('Wafer Die Processing', prodGroup, 'RFQI_DieProcessing__c', null, null, families);
        families[0].Has_Manual_Entry_Fields__c = true;
        FieldBuilderHelper.addPf('Bump', prodGroup, 'RFQI_Bump__c', null, null, families);
        FieldBuilderHelper.addPf('Die Sales', prodGroup, 'RFQI_Die_Sales__c', null, null, families);
        FieldBuilderHelper.addPf('Final Test', prodGroup, 'RFQI_Final__c', null,null, null, 'RFQIIC_Final__c',  families, false);
        FieldBuilderHelper.addPf('Wafer Probe', prodGroup, 'RFQI_Wafer__c', null, null, null, 'RFQIIC_Wafer__c', families, false);
        FieldBuilderHelper.addPf('WLCSP', prodGroup, 'RFQI_WLCSP__c', null, null,null, null, families, false, 'CMExtendedBuilder');
        FieldBuilderHelper.addPf('LEAD FINISH', prodGroup, 'RFQI_LEAD_FINISH__c', null, null,null, null, families, false, 'CMExtendedBuilder');
        FieldBuilderHelper.addPf('WAFER BACKGRIND', prodGroup, 'RFQI_WAFER_BACKGRIND__c', null, null,null, null, families, false, 'CMExtendedBuilder');
        
        try {
            insert families;
        }catch(Exception e) {
            system.debug('Could not install Standalone Services Package Families: ' + e);
        }
        return families;
    }

    private static void installVersion()
    {
        cmVersion = new CM_Version__c(Product_Group__c=prodGroup.Id, Status__c='Active', Version__c=1);
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

    private static void installDefaultDrivers(){
        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
        
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
            }

            installBumpDefaultDrivers(fieldDefs);
            installDieProcessingDefaultDrivers(fieldDefs, 'Wafer Die Processing');
            installDieProcessingDefaultDrivers(fieldDefs, 'Die Sales');
            installTestDefaultDrivers(fieldDefs);
    }
    
    private static void installBumpDefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'Bump'];
            
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Wafer_Size_PK__c'), '200', fieldDefs.get('Passivation__c'), 'Polyimide');
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Wafer_Size_PK__c'), '300', fieldDefs.get('Passivation__c'), 'PBO');
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('WLCSP_Type__c'), 'CSPnl', fieldDefs.get('RDL_Thickness__c'), '4');
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('WLCSP_Type__c'), 'CSPn2', fieldDefs.get('RDL_Thickness__c'), '8.2');
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('WLCSP_Type__c'), 'CSPn3', fieldDefs.get('RDL_Thickness__c'), '8.2');
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Type_of_Bump__c'), 'Ball Drop (WLCSP)', fieldDefs.get('WLCSP_Type__c'), 'CSPnl');
    }
    
    private static void installDieProcessingDefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs, string packageFamily) {
    	
        Package_Family__c pf = [select Id from Package_Family__c where Name =: packageFamily];
            
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Wafer_Size_PK__c'), '200', fieldDefs.get('Backgrind__c'), '250');
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Wafer_Size_PK__c'), '300', fieldDefs.get('Backgrind__c'), '350');
    }

    private static void installTestDefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
        families = new List<Package_Family__c>();
        families.add([select Id from Package_Family__c where Package_Family__c.Name = 'Final Test']);
        families.add([select Id from Package_Family__c where Package_Family__c.Name = 'Wafer Probe']);

        for (Package_Family__c pf : families) {
            FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('Factory_Selection__c'), 'Factory_Selection__c', fieldDefs.get('Factory_Selected__c'));
        }


    }
    
    private static List<RFQI_PF_Field_Def__c> installDieProcessingFields(){
        FieldBuilderHelper helper = new FieldBuilderHelper('Wafer Die Processing');
        
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
        helper.add('BU Header', 'RFQ_Item__r.RFQ__r.SBU_Name__r.Customer_AU_Base_fml__c', 1100);
        helper.add('BU Header', 'RFQ_Item__r.Customer_Tier__c', 1190);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__c', 1140);
        //End Header section for BU

        helper.add('Quote Information', 'New_Business__c', 1000);
        helper.add('Quote Information', 'Sales_BU_Price__c', 1010);
        helper.add('Quote Information', 'Price_To_Customer__c', 1020);
        helper.add('Quote Information', 'Customer_Project_Name__c', 1030);
        helper.add('Quote Information', 'Customer_Device_Name__c', 1040);
        helper.add('Quote Information', 'Customer_Target_Price__c', 1060);
        helper.add('Quote Information', 'Sales_Target_Price__c', 1070);
        helper.add('Quote Information', 'End_Market_Segment__c', 1080);
        helper.add('Quote Information', 'Competitor__c', 1090);
        helper.add('Quote Information', 'Competitor_Au_Inclusive_Price__c', 1100);
        helper.add('Quote Information', 'HVP_Anticipated_Start_Date__c', 1110);
        helper.add('Quote Information', 'Has_Been_Quoted_Before__c', 1120);
        
        helper.add('Cost and Price', 'Materials_Total__c', 2000, false, true);
        helper.add('Cost and Price', 'Depreciation__c', 2010, false, true);
        helper.add('Cost and Price', 'Customer_Target_Price__c', 2020, false, true);
        helper.add('Cost and Price', 'BU_Price__c', 2030, false, true);
        helper.add('Cost and Price', 'Variable_Costs__c', 2040, false, true);
        helper.add('Cost and Price', 'Fixed_Costs__c', 2050, false, true);
        helper.add('Cost and Price', 'Sales_Target_Price__c', 2060, false, true);
        helper.add('Cost and Price', 'BU_Margin__c', 2070, false, true);
        helper.add('Cost and Price', 'Variable_Costs_Total__c', 2080, false, true);
        helper.add('Cost and Price', 'Total_Fixed_Costs__c', 2090, false, true);
        helper.add('Cost and Price', 'Competitor__c', 2100);
        helper.add('Cost and Price', 'Contribution_Margin_Perc__c', 2110, false, true);
        helper.add('Cost and Price', 'Cost_Data_Source__c', 2120, false, true);
        helper.add('Cost and Price', 'Total_Cost__c', 2130, false, true);
        helper.add('Cost and Price', 'Competitor_Au_Inclusive_Price__c', 2140, false, true);
        helper.add('Cost and Price', 'Gross_Margin_Perc__c', 2150, false, true);
        helper.add('Cost and Price', 'Guildlline_Price_500__c', 2160, false, true);
        helper.add('Cost and Price', 'Guildlline_Price_1500__c', 2170, false, true);
        helper.add('Cost and Price', 'Guildlline_Price_GT_1500__c', 2180, false, true);

        helper.add('Package Description', 'Assembly_Package_Name__c', 500);
        helper.add('Package Description', 'Body_Size__c', 510);
        helper.add('Package Description', 'Ball_Lead_Count__c', 520);
        helper.add('Package Description', 'Device_or_Program__c', 2010, true);
        helper.add('Package Description', 'Wafer_Size_PK__c', 2020, false, false, true, true);
        helper.add('Package Description', 'Die_Size_X_PK__c', 2030, true, false, true, false, '', true);
        helper.add('Package Description', 'Die_Size_Y_PK__c', 2040, true, false, true, false, '', true);
        //helper.add('Package Description', 'Factory__c', 2060, true);
        helper.add('Package Description', 'Backgrind__c', 2070, true);
        helper.add('Package Description', 'Backside_Coat__c', 2080, true);
        helper.add('Package Description', 'Laser_Mark__c', 2100, true);
        helper.add('Package Description', 'Dice__c', 2110, true);
        helper.add('Package Description', 'Inspect__c', 2070, true);
        helper.add('Package Description', 'Inspect_2__c', 2080, true);
        helper.add('Package Description', 'Packing__c', 2090, true);
        helper.add('Package Description', 'Dry_Polish__c', 2100, true);
        helper.add('Package Description', 'Pizza_Wafer__c', 2110, true);
        helper.add('Package Description', 'Binning__c', 2100, true);
        helper.add('Package Description', 'Die_per_Month__c', 2110, true);

        helper.add('NRE', 'Masks__c', 6000, true);
        helper.add('NRE', 'Ball_Stencil__c', 6010, true);
        helper.addLotChargeField('NRE', 'Engineering_Lot_Charge__c', 6020, true);
        helper.addLotChargeField('NRE', 'Small_Lot_Charge__c', 6030, true);
        
        helper.insertFields();
        
        return helper.getPfFieldDefs();
    }
    
    private static List<RFQI_PF_Field_Def__c> installDieSalesFields(){
        FieldBuilderHelper helper = new FieldBuilderHelper('Die Sales');
        
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
        helper.add('BU Header', 'RFQ_Item__r.RFQ__r.SBU_Name__r.Customer_AU_Base_fml__c', 1100);
        helper.add('BU Header', 'RFQ_Item__r.Customer_Tier__c', 1190);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__c', 1140);
        //End Header section for BU

        helper.add('Quote Information', 'New_Business__c', 1000);
        helper.add('Quote Information', 'Sales_BU_Price__c', 1010);
        helper.add('Quote Information', 'Price_To_Customer__c', 1020);
        helper.add('Quote Information', 'Customer_Project_Name__c', 1030);
        helper.add('Quote Information', 'Customer_Device_Name__c', 1040);
        helper.add('Quote Information', 'Customer_Target_Price__c', 1060);
        helper.add('Quote Information', 'Sales_Target_Price__c', 1070);
        helper.add('Quote Information', 'End_Market_Segment__c', 1080);
        helper.add('Quote Information', 'Competitor__c', 1090);
        helper.add('Quote Information', 'Competitor_Au_Inclusive_Price__c', 1100);
        helper.add('Quote Information', 'HVP_Anticipated_Start_Date__c', 1110);
        helper.add('Quote Information', 'Has_Been_Quoted_Before__c', 1120);
        
        helper.add('Cost and Price', 'Materials_Total__c', 2000, false, true);
        helper.add('Cost and Price', 'Depreciation__c', 2010, false, true);
        helper.add('Cost and Price', 'Customer_Target_Price__c', 2020, false, true);
        helper.add('Cost and Price', 'BU_Price__c', 2030, false, true);
        helper.add('Cost and Price', 'Variable_Costs__c', 2040, false, true);
        helper.add('Cost and Price', 'Fixed_Costs__c', 2050, false, true);
        helper.add('Cost and Price', 'Sales_Target_Price__c', 2060, false, true);
        helper.add('Cost and Price', 'BU_Margin__c', 2070, false, true);
        helper.add('Cost and Price', 'Variable_Costs_Total__c', 2080, false, true);
        helper.add('Cost and Price', 'Total_Fixed_Costs__c', 2090, false, true);
        helper.add('Cost and Price', 'Competitor__c', 2100);
        helper.add('Cost and Price', 'Contribution_Margin_Perc__c', 2110, false, true);
        helper.add('Cost and Price', 'Cost_Data_Source__c', 2120, false, true);
        helper.add('Cost and Price', 'Total_Cost__c', 2130, false, true);
        helper.add('Cost and Price', 'Competitor_Au_Inclusive_Price__c', 2140, false, true);
        helper.add('Cost and Price', 'Gross_Margin_Perc__c', 2150, false, true);
        helper.add('Cost and Price', 'Guildlline_Price_500__c', 2160, false, true);
        helper.add('Cost and Price', 'Guildlline_Price_1500__c', 2170, false, true);
        helper.add('Cost and Price', 'Guildlline_Price_GT_1500__c', 2180, false, true);

        helper.add('Package Description', 'Assembly_Package_Name__c', 500);
        helper.add('Package Description', 'Body_Size__c', 510);
        helper.add('Package Description', 'Ball_Lead_Count__c', 520);
        helper.add('Package Description', 'Device_or_Program__c', 2010, true);
        helper.add('Package Description', 'Wafer_Size_PK__c', 2020, true, false, true, true);
        helper.add('Package Description', 'Die_Size_X_PK__c', 2030, true, false, true);
        helper.add('Package Description', 'Die_Size_Y_PK__c', 2040, true, false, true);
        //helper.add('Package Description', 'Factory__c', 2060, true);
        helper.add('Package Description', 'Backgrind__c', 2070, true);
        //helper.add('Package Description', 'Backside_Coat__c', 2080, true);
        //helper.add('Package Description', 'Laser_Mark__c', 2100, true);
        helper.add('Package Description', 'Dice__c', 2110, true);
        helper.add('Package Description', 'Inspect__c', 2070, true);
        helper.add('Package Description', 'Inspect_2__c', 2080, true);
        helper.add('Package Description', 'Packing__c', 2090, true);
        //helper.add('Package Description', 'Dry_Polish__c', 2100, true);
        helper.add('Package Description', 'Pizza_Wafer__c', 2110, true);
        helper.add('Package Description', 'Binning__c', 2100, true);
        helper.add('Package Description', 'Die_per_Month__c', 2110, true);

        helper.add('NRE', 'Masks__c', 6000, true);
        helper.add('NRE', 'Ball_Stencil__c', 6010, true);
        helper.addLotChargeField('NRE', 'Engineering_Lot_Charge__c', 6020, true);
        helper.addLotChargeField('NRE', 'Small_Lot_Charge__c', 6030, true);
        
        helper.insertFields();
        
        return helper.getPfFieldDefs();
    }

    private static List<RFQI_PF_Field_Def__c> installBumpFields(){
        FieldBuilderHelper helper = new FieldBuilderHelper('Bump');
        
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
        //helper.add('BU Header', 'BU_Price__c', 1150);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__r.SBU_Name__r.AccountNumber', 1060);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__r.SBU_Name__r.Customer_AU_Base_fml__c', 1100);
        helper.add('BU Header', 'RFQ_Item__r.Customer_Tier__c', 1190);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__c', 1140);
        //End Header section for BU

        helper.add('Quote Information', 'New_Business__c', 1000);
        helper.add('Quote Information', 'Sales_BU_Price__c', 1010); 
        helper.add('Quote Information', 'Price_To_Customer__c', 1020);
        helper.add('Quote Information', 'Customer_Project_Name__c', 1030);
        helper.add('Quote Information', 'Customer_Device_Name__c', 1040);
        helper.add('Quote Information', 'Customer_Target_Price__c', 1060);
        helper.add('Quote Information', 'Sales_Target_Price__c', 1070);
        helper.add('Quote Information', 'End_Market_Segment__c', 1080);
        helper.add('Quote Information', 'Competitor__c', 1090);
        helper.add('Quote Information', 'Competitor_Au_Inclusive_Price__c', 1100);
        helper.add('Quote Information', 'HVP_Anticipated_Start_Date__c', 1110);
        helper.add('Quote Information', 'Has_Been_Quoted_Before__c', 1120);
        
        helper.add('Cost and Price', 'Materials_Total__c', 2000, false, true);
        helper.add('Cost and Price', 'Depreciation__c', 2010, false, true);
        helper.add('Cost and Price', 'Customer_Target_Price__c', 2020, false, true);
        helper.add('Cost and Price', 'BU_Price__c', 2030, false, true);
        helper.add('Cost and Price', 'Variable_Costs__c', 2040, false, true);
        helper.add('Cost and Price', 'Fixed_Costs__c', 2050, false, true);
        helper.add('Cost and Price', 'Sales_Target_Price__c', 2060, false, true);
        helper.add('Cost and Price', 'BU_Margin__c', 2070, false, true);
        helper.add('Cost and Price', 'Variable_Costs_Total__c', 2080, false, true);
        helper.add('Cost and Price', 'Total_Fixed_Costs__c', 2090, false, true);
        helper.add('Cost and Price', 'Competitor__c', 2100);
        helper.add('Cost and Price', 'Contribution_Margin_Perc__c', 2110, false, true);
        helper.add('Cost and Price', 'Cost_Data_Source__c', 2120, false, true);
        helper.add('Cost and Price', 'Total_Cost__c', 2130, false, true);
        helper.add('Cost and Price', 'Competitor_Au_Inclusive_Price__c', 2140, false, true);
        helper.add('Cost and Price', 'Gross_Margin_Perc__c', 2150, false, true);
        helper.add('Cost and Price', 'Guildlline_Price_500__c', 2160, false, true);
        helper.add('Cost and Price', 'Guildlline_Price_1500__c', 2170, false, true);
        helper.add('Cost and Price', 'Guildlline_Price_GT_1500__c', 2180, false, true);

        helper.add('Package Description', 'Assembly_Package_Name__c', 500);
        helper.add('Package Description', 'Body_Size__c', 510);
        helper.add('Package Description', 'Ball_Lead_Count__c', 520);
        helper.add('Package Description', 'HVP_Anticipated_Start_Date__c', 2000, true);
        helper.add('Package Description', 'Device_or_Program__c', 2010, true);
        helper.add('Package Description', 'Wafer_Size_PK__c', 2020, true, false, false, true);
        helper.add('Package Description', 'Type_of_Bump__c', 2030, true, false, true, true);
        helper.add('Package Description', 'WLCSP_Type__c', 2040, true);
        helper.add('Package Description', 'Structure__c', 2060, true, false, true);
        helper.add('Package Description', 'Bump_Composition__c', 2070, true);
        helper.add('Package Description', 'Passivation__c', 2080, true, false);
        helper.add('Package Description', 'RDL_Thickness__c', 2090, true);
        helper.add('Package Description', 'Bump_Pitch__c', 2100, true, false);
        //helper.add('Package Description', 'Factory__c', 2110, true);
        helper.add('Package Description', 'Forecast__c', 2070, true);
        helper.add('Package Description', 'WLCSP_Die_Processing_Needed__c', 2080, true, false, false, true);

        helper.add('NRE', 'Masks__c', 6000, true);
        helper.add('NRE', 'Ball_Stencil__c', 6010, true);
        helper.addLotChargeField('NRE', 'Engineering_Lot_Charge__c', 6020, true);
        helper.addLotChargeField('NRE', 'Small_Lot_Charge__c', 6030, true);
        
        helper.insertFields();
        
        return helper.getPfFieldDefs();
    }

    /**
    * This method installs the field defs for the package families for final test
    * @return the list of field definitions for a specific package family
    */
    private static List<RFQI_PF_Field_Def__c> installTestFieldDefs(string pg) {
        FieldBuilderHelper helper = new FieldBuilderHelper(pg);
        
        //Adding Header section for Sales
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
        helper.add('BU Header', 'End_Market_Segment__c', 1120);
        helper.add('BU Header', 'RFQ_Item__r.Customer_Tier__c', 1130);
        helper.add('BU Header', 'RFQ_Item__r.RFQ__c', 1140);
        //End Header section for BU
        
        helper.add('Quote Information', 'Assembly_Package_Name__c', 500, true);
        helper.add('Quote Information', 'Body_Size__c', 510, true);
        helper.add('Quote Information', 'Ball_Lead_Count__c', 520, true);
        helper.add('Quote Information', 'New_Business__c', 1000);
        helper.add('Quote Information', 'Sales_BU_Price__c', 1010);
        helper.add('Quote Information', 'Price_To_Customer__c', 1020);        
        helper.add('Quote Information', 'Customer_Project_Name__c', 1030);
        helper.add('Quote Information', 'Customer_Device_Name__c', 1040);
        helper.add('Quote Information', 'Forecast__c', 1050);
        helper.add('Quote Information', 'Customer_Target_Price__c', 1060);        
        helper.add('Quote Information', 'Sales_Target_Price__c', 1070);
        helper.add('Quote Information', 'End_Market_Segment__c', 1080);
        helper.add('Quote Information', 'Competitor__c', 1090);        
        helper.add('Quote Information', 'Competitor_Au_Inclusive_Price__c', 1100);
        helper.add('Quote Information', 'HVP_Anticipated_Start_Date__c', 1110);
        helper.add('Quote Information', 'Has_Been_Quoted_Before__c', 1120);
        

        /*helper.add('CPN Drivers', 'Factory_Selection__c', 2010, false, false, false, true);
        helper.add('CPN Drivers', 'Tester__c', 2020);
        helper.add('CPN Drivers', 'Tester_Model__c', 2030);
        helper.add('CPN Drivers', 'Handler__c', 2040);
        helper.add('CPN Drivers', 'Handler_Model__c', 2050);
        helper.add('CPN Drivers', 'Test_Time__c', 2060);
        helper.add('CPN Drivers', 'Index_Time__c', 2070);
        //helper.add('CPN Drivers', 'CPU_Price_Second__c', 2080);
        helper.add('CPN Drivers', 'CPU_Price_Hour__c', 2090);
        helper.add('CPN Drivers', 'Number_of_Sites_in_Parallel__c', 2100);
        helper.add('CPN Drivers', 'Total_Test_Time__c', 2110);
        helper.add('CPN Drivers', 'Test_Time_to_Unit__c', 2120);
        helper.add('CPN Drivers', 'Unit_Price_per_Test_Time__c', 2130);*/
        
        helper.add('Insertion Description', 'Factory_Selected__c', 2000, true);
        helper.add('Insertion Description', 'Tester__c', 2010, true);
        helper.add('Insertion Description', 'Tester_Model__c', 2030);
        helper.add('Insertion Description', 'Handler__c', 2040, true);
        helper.add('Insertion Description', 'Handler_Model__c', 2050, true);
        helper.add('Insertion Description', 'Test_Time__c', 2060, true);        
        helper.add('Insertion Description', 'CPU_Price_Hour__c', 2090);
        helper.add('Insertion Description', 'Number_of_Sites_in_Parallel__c', 2261, true);        
        helper.add('Insertion Description', 'Total_Test_Time__c', 2110);
        helper.add('Insertion Description', 'Test_Time_to_Unit__c', 2120);
        helper.add('Insertion Description', 'Unit_Price_per_Test_Time__c', 2130);
        helper.add('Insertion Description', 'Temperate__c', 2053, true);
        helper.add('Insertion Description', 'MIC__c', 2150);
        helper.add('Insertion Description', 'Consign_Tester__c', 2160);
        helper.add('Insertion Description', 'Consign_Handler__c', 2170);

        helper.add('Cost and Price', 'Tester_Price__c', 2000, false, true);
        helper.add('Cost and Price', 'Unit_Cost_CLAM__c', 2010, false, true);
        helper.add('Cost and Price', 'Cost_Sec_CLAM__c', 2020, false, true);
        helper.add('Cost and Price', 'Total_GM_Perc__c', 2030, false, true);
        helper.add('Cost and Price', 'Handler_Prober_Price__c', 2040, false, true);
        helper.add('Cost and Price', 'Unit_Cost_Material__c', 2050, false, true);
        helper.add('Cost and Price', 'Cost_Sec_Labor__c', 2060, false, true);
        helper.add('Cost and Price', 'Target_IRR_at_GM__c', 2070, false, true);
        helper.add('Cost and Price', 'Other_Equipment_Cost__c', 2080, false, true);
        helper.add('Cost and Price', 'Unit_Cost_Labor__c', 2090, false, true);
        helper.add('Cost and Price', 'Cost_sec_Depreciation__c', 2100);
        helper.add('Cost and Price', 'Payback__c', 2110, false, true);
        helper.add('Cost and Price', 'Tax_and_Freight_Cost__c', 2120, false, true);
        helper.add('Cost and Price', 'Unit_Cost_Depreciation__c', 2130, false, true);
        helper.add('Cost and Price', 'Cost_sec_Other__c', 2140, false, true);
        helper.add('Cost and Price', 'BU_Price_Per_Hour__c', 2150, false, true);
        helper.add('Cost and Price', 'Weekly_Revenue_Setup__c', 2160, false, true);
        helper.add('Cost and Price', 'Unit_Cost_Other__c', 2170, false, true);
        helper.add('Cost and Price', 'Total_Cost_per_Hour__c', 2180, false, true);
        helper.add('Cost and Price', 'BU_Price_per_Minute__c', 2190, false, true);
        helper.add('Cost and Price', 'Monthly_Revenue_Setup__c', 2200, false, true);
        helper.add('Cost and Price', 'Total_Unit_Cost__c', 2210, false, false);
        helper.add('Cost and Price', 'Total_Cost_per_minute__c', 2220, false, false);
        helper.add('Cost and Price', 'BU_Price_Unit__c', 2230, false, false);
        
        if(pg == 'Final Test') {        
        helper.add('NRE', 'Load_Board_Design__c', 6000, false);
        helper.add('NRE', 'Program_Develop__c', 6010, false);
        helper.add('NRE', 'Custom_Tray_Tooling__c', 6020, false);
        helper.add('NRE', 'Changekit_Tooling__c', 6030, false);
        helper.add('NRE', 'Carrier_Tape_Tooling__c', 6040, false);
        helper.add('NRE', 'Other_Hardware_Design__c', 6050, false);
        }

        if(pg == 'Wafer Probe') {        
        helper.add('NRE', 'Probe_Card_Design__c', 6000, true);
        helper.add('NRE', 'Program_Develop__c', 6010, true);
        helper.add('NRE', 'Wafflepack_Tooling__c', 6020, true);
        helper.add('NRE', 'Pogotower_Tooling__c', 6030, true);
        helper.add('NRE', 'Ring_Carrier_Tooling__c', 6040, true);
        helper.add('NRE', 'Other_Hardware_Design__c', 6050, true);
        }

        helper.add('Adders', 'Scan__c', 4000, true);
        helper.add('Adders', 'Bake__c', 4010, true);
        helper.add('Adders', 'Bake_Dry_Pack__c', 4020, true);
        helper.add('Adders', 'Laser_Mark__c', 4030, true);
        helper.add('Adders', 'Ink_Mark__c', 4040, true);
        helper.add('Adders', 'Burn_In__c', 4050, true);
        helper.add('Adders', 'Packing_Method__c', 4060, true);
        helper.add('Adders', 'Expected_Revenue__c', 4070, true);
        helper.add('Adders', 'Tape_and_Reel__c', 4070, true);

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
        //helper.add('Quote Information', 'Prototype__c', 1090, false, false, false, true);
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

        helper.insertFields();
        
        return helper.getPfFieldDefs(); 

    }

    public static void incrementalInstall1()
    {
        DebugUtils debug = DebugUtils.getInstance();
        insert new RFQI_Field_Def__c(Name = 'Index_Time_New__c', Type__c = 'Decimal');
        insert new RFQI_Field_Def__c(Name = 'Test_Time_to_Unit_Factor__c', Type__c = 'Decimal');

        Package_Family__c pf = [select Id, Name from Package_Family__c where Name ='Final Test'];

        FieldBuilderHelper helper = new FieldBuilderHelper(pf.Name);
        helper.add('CPN Drivers', 'Index_Time_New__c', 2070, false, true);
        helper.add('Insertion Description', 'Index_Time_New__c', 2070, false, true);
        helper.add('CPN Drivers', 'Test_Time_to_Unit_Factor__c', 2119);
        helper.add('Insertion Description', 'Test_Time_to_Unit_Factor__c', 2119);
        helper.insertFields();
        
        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 

        for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
        }

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '1', fieldDefs.get('Index_Time_New__c'), '1.1');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '2', fieldDefs.get('Index_Time_New__c'), '1.3');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '4', fieldDefs.get('Index_Time_New__c'), '1.5');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '8', fieldDefs.get('Index_Time_New__c'), '2');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '16', fieldDefs.get('Index_Time_New__c'), '2.5');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '32', fieldDefs.get('Index_Time_New__c'), '4');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '64', fieldDefs.get('Index_Time_New__c'), '6.6');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '128', fieldDefs.get('Index_Time_New__c'), '8');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '256', fieldDefs.get('Index_Time_New__c'), '14');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '512', fieldDefs.get('Index_Time_New__c'), '22');

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '1', fieldDefs.get('Test_Time_to_Unit_Factor__c'), '1');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '2', fieldDefs.get('Test_Time_to_Unit_Factor__c'), '1.6');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '4', fieldDefs.get('Test_Time_to_Unit_Factor__c'), '3.3');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '8', fieldDefs.get('Test_Time_to_Unit_Factor__c'), '6.6');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '16', fieldDefs.get('Test_Time_to_Unit_Factor__c'), '13');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '32', fieldDefs.get('Test_Time_to_Unit_Factor__c'), '27');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '64', fieldDefs.get('Test_Time_to_Unit_Factor__c'), '55');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '128', fieldDefs.get('Test_Time_to_Unit_Factor__c'), '112');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '256', fieldDefs.get('Test_Time_to_Unit_Factor__c'), '224');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Number_of_Sites_in_Parallel__c'), '512', fieldDefs.get('Test_Time_to_Unit_Factor__c'), '448');

        List<RFQI_PF_Field_Def__c> fields = [select id, name, Default_Driver__c, Required__c, RFQI_Field_Def__c, RFQI_Field_Def__r.Name from RFQI_PF_Field_Def__c where Package_Family__r.Name='Final Test'];
        List<RFQI_PF_Field_Def__c> updateList = new List<RFQI_PF_Field_Def__c>();
        List<RFQI_PF_Field_Def__c> deleteList = new List<RFQI_PF_Field_Def__c>();

        for (RFQI_PF_Field_Def__c row : fields)
        {
            if (row.RFQI_Field_Def__r.Name == 'Index_Time__c') deleteList.add(row);
            else if (row.RFQI_Field_Def__r.Name == 'Number_of_Sites_in_Parallel__c')
            {
                row.Default_Driver__c = true;
                updateList.add(row);
            }
            else if (row.RFQI_Field_Def__r.Name == 'Test_Time_to_Unit__c') 
            {
                row.Generated__c = true;
                updateList.add(row);
            }
            else if (row.RFQI_Field_Def__r.Name == 'Tester__c' ||
                       row.RFQI_Field_Def__r.Name == 'Tester_Model__c' ||
                       row.RFQI_Field_Def__r.Name == 'Handler__c' ||
                       row.RFQI_Field_Def__r.Name == 'Handler_Model__c' ||
                       row.RFQI_Field_Def__r.Name == 'Test_Time__c' ||
                       row.RFQI_Field_Def__r.Name == 'Factory_Selection__c')
            {
                row.Required__c = true;
                updateList.add(row);
            }
        }
        upsert updateList;
        delete deleteList;
    }

    public static void incrementalInstallAMK1383()
    {
        Package_Family__c pf = [select id, name, cost_model_implementation__c from Package_Family__c where Name='Bump' and Product_group__r.Name='Standalone Services'];

        pf.Cost_Model_Implementation__c = 'CMBumpBuilder';

        update pf;
    }

    private static void installTestModels()
    {
        List<CM_Test_Model__c> modelList = new List<CM_Test_Model__c>();
        modelList.add(new CM_Test_Model__c(Name='Credence Quartet', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.016, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Credence Kalos HEX', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.013, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne iFLEX', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.023, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne iFLEX RF', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.025, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne iFLEX PM', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.025, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne J750', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.019, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne J750EX', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.02, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne UltraFlex', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.026, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne UltraFlex HD', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.032, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne UltraFlex HD RF', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.033, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne UltraFlex PM', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.039, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Next Magnum', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.02, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Advantest T2000', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.035, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Advantest T5371', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.055, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Advantest T5372', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.055, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Advantest T5375', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.055, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Advantest T5581', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.042, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K C200e', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0185, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K C400e', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.023, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K PS400', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.025, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K PS800', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.035, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K PS1600', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.05, CM_Version__c=cmVersion.Id, Factory__c='C3'));

        modelList.add(new CM_Test_Model__c(Name='Mirae MR5500', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0023, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS6040', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0024, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS7000', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0024, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS7080W', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0024, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS8040', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0024, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS8080W', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0024, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Hontech HT7045', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0024, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Hontech HT9045WH', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0023, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Hontech WS3000', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0023, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Advantest M6771', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0026, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Advantest M6741AD', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0026, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Advantest M6751', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0026, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT9510', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0025, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT2168', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0023, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='OPUS3', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0023, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='Tel P12XL', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0023, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='TSK UF200', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0023, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='C3'));
        modelList.add(new CM_Test_Model__c(Name='TSK UF3000EX', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0023, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='C3'));

        modelList.add(new CM_Test_Model__c(Name='Advantest T3347P', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.01, Amkor_Price_Per_Sec__c=0.0175, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Advantest T6673', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.011, Amkor_Price_Per_Sec__c=0.0425, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Advantest T5581H', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.011, Amkor_Price_Per_Sec__c=0.0325, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Advantest T5585', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.049, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Advantest T5503', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.013, Amkor_Price_Per_Sec__c=0.1175, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K C200e', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.013, Amkor_Price_Per_Sec__c=0.022, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K C400e', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.013, Amkor_Price_Per_Sec__c=0.025, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K P600', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.013, Amkor_Price_Per_Sec__c=0.035, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K PS800', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.056, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K PS1600', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.052, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Credence ASL3000', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.0115, Amkor_Price_Per_Sec__c=0.0265, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Catalyst 128CH', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.0205, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Catalyst 256CH', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.0215, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Catalyst 288CH', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.0225, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Catalyst 384CH', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.023, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Catalyst RF GEN III', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.0215, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Flex RF', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.0255, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='EagleTest ETS364', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.01, Amkor_Price_Per_Sec__c=0.021, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Agilent HP83000 F330T', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.014, Amkor_Price_Per_Sec__c=0.0145, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne J750', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.01, Amkor_Price_Per_Sec__c=0.0215, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne J971SP', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.01, Amkor_Price_Per_Sec__c=0.034, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne J973', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.01, Amkor_Price_Per_Sec__c=0.015, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne UltraFlex', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.0105, Amkor_Price_Per_Sec__c=0.0325, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Credence Quartet 384', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.0155, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Credence Quartet 512', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.015, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='RFT', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.008, Amkor_Price_Per_Sec__c=0.0145, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Credence SC 212', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.0105, Amkor_Price_Per_Sec__c=0.0155, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Credence SC 312', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.0115, Amkor_Price_Per_Sec__c=0.0215, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Credence STS6120', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.009, Amkor_Price_Per_Sec__c=0.016, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Credence STS8256', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.0105, Amkor_Price_Per_Sec__c=0.0175, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='LTX DeltaMaster', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.01, Amkor_Price_Per_Sec__c=0.015, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Credence LT1001', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.0085, Amkor_Price_Per_Sec__c=0.0135, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Credence LT1101', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.009, Amkor_Price_Per_Sec__c=0.014, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Credence Sapphire', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.01, Amkor_Price_Per_Sec__c=0.0315, CM_Version__c=cmVersion.Id, Factory__c='K1'));

        modelList.add(new CM_Test_Model__c(Name='Advan M6741D', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0025, Amkor_Price_Per_Sec__c=0.01, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Advan M6541AD', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0025, Amkor_Price_Per_Sec__c=0.01, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Aetrium 5800', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.001, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Aetrium 8832', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.02, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Aseco S-130', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.001, Amkor_Price_Per_Sec__c=0.0015, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Delta Castle LX', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0025, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Delta Edge DE8K', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0025, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Delta TurboFlex', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.001, Amkor_Price_Per_Sec__c=0.003, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Delta NitroFlex', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0005, Amkor_Price_Per_Sec__c=0.0015, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='MCT 5115', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.003, Amkor_Price_Per_Sec__c=0.006, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='MCT 7632', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.003, Amkor_Price_Per_Sec__c=0.0055, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Mirae MR2700', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Mirae MR5500', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0025, Amkor_Price_Per_Sec__c=0.006, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT9918', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.003, Amkor_Price_Per_Sec__c=0.006, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS6040', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0045, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS7000', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0025, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Synex 1201', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.003, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Synex 1211', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Synex 1701N', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='TES IPS 8653DC', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.002, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='TESEC 8710 TH.T', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0015, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Techwing TW282', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.009, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Electroglass EG 4080', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Electroglass EG 4090', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Electroglass EG 4200', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0045, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='OPUS3', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0025, Amkor_Price_Per_Sec__c=0.0045, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS8040', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.003, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS8080W', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.003, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Hontech HT7045', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.003, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='K1'));
        modelList.add(new CM_Test_Model__c(Name='Hontech HT9045W', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.003, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='K1'));

        modelList.add(new CM_Test_Model__c(Name='Advantest T3347P', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.01, Amkor_Price_Per_Sec__c=0.0175, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Advantest T6673', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.011, Amkor_Price_Per_Sec__c=0.0425, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Advantest T5581H', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.011, Amkor_Price_Per_Sec__c=0.0325, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Advantest T5585', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.049, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Advantest T5503', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.013, Amkor_Price_Per_Sec__c=0.1175, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K C200e', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.013, Amkor_Price_Per_Sec__c=0.022, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K C400e', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.013, Amkor_Price_Per_Sec__c=0.025, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K P600', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.013, Amkor_Price_Per_Sec__c=0.035, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K PS800', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.056, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K PS1600', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.052, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Credence ASL3000', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.0115, Amkor_Price_Per_Sec__c=0.0265, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Catalyst 128CH', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.0205, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Catalyst 256CH', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.0215, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Catalyst 288CH', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.0225, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Catalyst 384CH', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.023, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Catalyst RF GEN III', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.0215, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Flex RF', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.0255, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='EagleTest ETS364', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.01, Amkor_Price_Per_Sec__c=0.021, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Agilent HP83000 F330T', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.014, Amkor_Price_Per_Sec__c=0.0145, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne J750', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.01, Amkor_Price_Per_Sec__c=0.0215, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne J971SP', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.01, Amkor_Price_Per_Sec__c=0.034, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne J973', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.01, Amkor_Price_Per_Sec__c=0.015, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne UltraFlex', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.0105, Amkor_Price_Per_Sec__c=0.0325, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Credence Quartet 384', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.0155, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Credence Quartet 512', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.012, Amkor_Price_Per_Sec__c=0.015, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='RFT', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.008, Amkor_Price_Per_Sec__c=0.0145, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Credence SC 212', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.0105, Amkor_Price_Per_Sec__c=0.0155, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Credence SC 312', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.0115, Amkor_Price_Per_Sec__c=0.0215, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Credence STS6120', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.009, Amkor_Price_Per_Sec__c=0.016, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Credence STS8256', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.0105, Amkor_Price_Per_Sec__c=0.0175, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='LTX DeltaMaster', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.01, Amkor_Price_Per_Sec__c=0.015, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Credence LT1001', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.0085, Amkor_Price_Per_Sec__c=0.0135, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Credence LT1101', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.009, Amkor_Price_Per_Sec__c=0.014, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Credence Sapphire', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.01, Amkor_Price_Per_Sec__c=0.0315, CM_Version__c=cmVersion.Id, Factory__c='K3'));

        modelList.add(new CM_Test_Model__c(Name='Advan M6741D', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0025, Amkor_Price_Per_Sec__c=0.01, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Advan M6541AD', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0025, Amkor_Price_Per_Sec__c=0.01, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Aetrium 5800', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.001, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Aetrium 8832', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.02, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Aseco S-130', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.001, Amkor_Price_Per_Sec__c=0.0015, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Delta Castle LX', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0025, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Delta Edge DE8K', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0025, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Delta TurboFlex', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.001, Amkor_Price_Per_Sec__c=0.003, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Delta NitroFlex', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0005, Amkor_Price_Per_Sec__c=0.0015, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='MCT 5115', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.003, Amkor_Price_Per_Sec__c=0.006, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='MCT 7632', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.003, Amkor_Price_Per_Sec__c=0.0055, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Mirae MR2700', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Mirae MR5500', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0025, Amkor_Price_Per_Sec__c=0.006, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT9918', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.003, Amkor_Price_Per_Sec__c=0.006, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS6040', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0045, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS7000', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0025, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Synex 1201', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.003, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Synex 1211', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Synex 1701N', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='TES IPS 8653DC', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.002, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='TESEC 8710 TH.T', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0015, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Techwing TW282', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.009, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Electroglass EG 4080', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Electroglass EG 4090', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Electroglass EG 4200', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0045, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='OPUS3', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0025, Amkor_Price_Per_Sec__c=0.0045, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS8040', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.003, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS8080W', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.003, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Hontech HT7045', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.003, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='K3'));
        modelList.add(new CM_Test_Model__c(Name='Hontech HT9045W', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.003, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='K3'));

        modelList.add(new CM_Test_Model__c(Name='Agilent HP83000 F330T', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.023, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Agilent HP84000 RF A22PA', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.018, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Agilent Versatest 1100', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.008, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='ASL 1000', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.008, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='ASL 3000', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.01, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='ASL 3000 RF', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.026, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Credence DUO/XP', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.014, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Credence Kalos ', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.019, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Credence LT1101', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0135, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Credence Quartet 384', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.022, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Credence SC 212', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.018, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Credence SC 312', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.017, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Credence SC Micro', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.015, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Credence STS3500', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.007, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Credence STS6120', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.009, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Credence STS8256', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.01, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='DTS system', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.006, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='ILT DG100020', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0055, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='LTX Deltamaster', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.016, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='LTX Fusion CX RF', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.027, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='LTX Fusion HT', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.029, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='LTX Fusion MX', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.021, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='LTX D10', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.017, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='MTS RF', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.008, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Nextest Maverick GT', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0015, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Nextest Maverick II GT', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0016, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Nextest Maverick II PT', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0055, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Nextest Maverick II SST', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.011, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Nextest Maverick PT', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.007, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Nextest Maverick PTHF', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.006, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Nextest Maverick VT', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.013, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='PSX 500', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='PSX1000 programmer', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0055, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='RFT', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.015, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Schlumberger S1650', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.009, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Schlumberger S20', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0085, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Schlumberger S21', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.009, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='SZ/M3650', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.019, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne A360', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0165, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne A575', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.018, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne A585', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0185, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Catalyst 288CH', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.041, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Genesis II', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.007, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne J750', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0195, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne J971SP', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0285, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne J973', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0265, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Q2/52', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0085, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Q2/62', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.009, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Eagletest ETS364', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.019, CM_Version__c=cmVersion.Id, Factory__c='P1'));

        modelList.add(new CM_Test_Model__c(Name='Aetrium 5050F', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.001, Amkor_Price_Per_Sec__c=0.002, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Aetrium 5050S', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.001, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Aetrium 5050SDTS', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.003, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Aetrium 5050T', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Aseco S-130/2', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.001, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Aseco S-130/3', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.001, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Aseco S-132', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.001, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Aseco S-170', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.002, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Aseco S-170C', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Daymarc 3287', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.007, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Delta NitroFlex', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.002, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Delta TurboFlex', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.003, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='OPUS3', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Electroglas EG2080S', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.002, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Electroglas EG4090', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Ismeca NT-216', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0015, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='MCE H244CE', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.002, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='MCT 3608', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='MCT 3616', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.002, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='MCT 4610', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='MCT 4610 HC', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='MCT 5100', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='MCT 5105', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='MCT 5105D', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='MHA MH803-1', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='MHA MH803-2', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.003, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Mirae MR5500', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT8503', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT8588', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT8704iHF', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.002, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT9308', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT9320', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.007, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT9510', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT9918', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.006, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='RASCO SO1000AH', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='RASCO SO1000T', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='RASCO SO2000', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0045, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS6000', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS7000', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0045, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Sillner/IPS352', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.006, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='SRM D-248', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='SRM S-248', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Synex 1201', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Synex 1211', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS6040', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS7080W', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS8040', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS8080W', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Hontech HT7045', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P1'));
        modelList.add(new CM_Test_Model__c(Name='Hontech HT9045W', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P1'));

        modelList.add(new CM_Test_Model__c(Name='Agilent HP83000 F330T', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.023, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Agilent HP84000 RF A22PA', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.018, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Agilent Versatest 1100', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.008, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='ASL 1000', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.008, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='ASL 3000', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.01, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='ASL 3000 RF', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.026, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Credence DUO/XP', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.014, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Credence Kalos ', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.019, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Credence LT1101', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0135, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Credence Quartet 384', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.022, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Credence SC 212', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.018, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Credence SC 312', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.017, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Credence SC Micro', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.015, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Credence STS3500', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.007, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Credence STS6120', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.009, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Credence STS8256', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.01, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='DTS system', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.006, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='ILT DG100020', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0055, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='LTX Deltamaster', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.016, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='LTX Fusion CX RF', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.027, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='LTX Fusion HT', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.029, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='LTX Fusion MX', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.021, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='LTX D10', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.017, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='MTS RF', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.008, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Nextest Maverick GT', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0015, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Nextest Maverick II GT', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0016, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Nextest Maverick II PT', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0055, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Nextest Maverick II SST', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.011, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Nextest Maverick PT', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.007, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Nextest Maverick PTHF', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.006, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Nextest Maverick VT', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.013, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='PSX 500', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='PSX1000 programmer', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0055, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='RFT', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.015, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Schlumberger S1650', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.009, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Schlumberger S20', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0085, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Schlumberger S21', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.009, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='SZ/M3650', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.019, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne A360', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0165, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne A575', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.018, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne A585', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0185, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Catalyst 288CH', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.041, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Genesis II', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.007, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne J750', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0195, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne J971SP', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0285, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne J973', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0265, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Q2/52', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.0085, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Q2/62', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.009, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Eagletest ETS364', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.005, Amkor_Price_Per_Sec__c=0.019, CM_Version__c=cmVersion.Id, Factory__c='P3'));

        modelList.add(new CM_Test_Model__c(Name='Aetrium 5050F', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.001, Amkor_Price_Per_Sec__c=0.002, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Aetrium 5050S', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.001, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Aetrium 5050SDTS', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.003, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Aetrium 5050T', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Aseco S-130/2', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.001, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Aseco S-130/3', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.001, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Aseco S-132', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.001, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Aseco S-170', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.002, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Aseco S-170C', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Daymarc 3287', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.007, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Delta NitroFlex', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.002, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Delta TurboFlex', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.003, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='OPUS3', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Electroglas EG2080S', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.002, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Electroglas EG4090', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0015, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Ismeca NT-216', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0015, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='MCE H244CE', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.002, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='MCT 3608', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='MCT 3616', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.002, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='MCT 4610', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='MCT 4610 HC', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='MCT 5100', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='MCT 5105', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='MCT 5105D', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='MHA MH803-1', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='MHA MH803-2', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.003, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Mirae MR5500', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT8503', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT8588', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0025, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT8704iHF', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.002, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT9308', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT9320', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.007, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT9510', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT9918', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.006, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='RASCO SO1000AH', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='RASCO SO1000T', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='RASCO SO2000', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0045, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS6000', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS7000', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0045, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Sillner/IPS352', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.006, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='SRM D-248', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='SRM S-248', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Synex 1201', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Synex 1211', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS6040', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS7080W', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS8040', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS8080W', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Hontech HT7045', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P3'));
        modelList.add(new CM_Test_Model__c(Name='Hontech HT9045W', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.0035, CM_Version__c=cmVersion.Id, Factory__c='P3'));

        modelList.add(new CM_Test_Model__c(Name='Credence SC 212', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.006, Amkor_Price_Per_Sec__c=0.0145, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Credence SC 312', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.006, Amkor_Price_Per_Sec__c=0.015, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Credence SC Micro', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.006, Amkor_Price_Per_Sec__c=0.0175, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K C400e', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.007, Amkor_Price_Per_Sec__c=0.028, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K P600', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.007, Amkor_Price_Per_Sec__c=0.032, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Catalyst 384CH', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.007, Amkor_Price_Per_Sec__c=0.0225, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='ADV T6672', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.007, Amkor_Price_Per_Sec__c=0.023, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne Catalyst A595', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.007, Amkor_Price_Per_Sec__c=0.0205, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne ETS364', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.007, Amkor_Price_Per_Sec__c=0.02, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K PS400', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.007, Amkor_Price_Per_Sec__c=0.038, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='ADV V93K PS800', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.007, Amkor_Price_Per_Sec__c=0.041, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Advantest T2000', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.007, Amkor_Price_Per_Sec__c=0.0328, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne UltraFlex MS', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.007, Amkor_Price_Per_Sec__c=0.041, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Teradyne UltraFlex RF', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.007, Amkor_Price_Per_Sec__c=0.035, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='LTX CX', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.007, Amkor_Price_Per_Sec__c=0.021, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='LTX MX', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.007, Amkor_Price_Per_Sec__c=0.023, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='LTX Sapphire', Type__c='Tester Model', Customer_Price_Per_Sec__c=0.007, Amkor_Price_Per_Sec__c=0.026, CM_Version__c=cmVersion.Id, Factory__c='T3'));

        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS5000', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0026, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS6040', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0026, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS7000', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0026, Amkor_Price_Per_Sec__c=0.004, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS7080W', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0026, Amkor_Price_Per_Sec__c=0.0045, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS8040', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0026, Amkor_Price_Per_Sec__c=0.0045, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Seiko Epson NS8080W', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0026, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Hontech HT7045', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0025, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Hontech HT9045WH', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0025, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Hontech WS3000', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.002, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Delta Castle LX', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0026, Amkor_Price_Per_Sec__c=0.008, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Delta Summit SHP', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0029, Amkor_Price_Per_Sec__c=0.009, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Delta Summit HP', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0029, Amkor_Price_Per_Sec__c=0.009, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT9510', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0026, Amkor_Price_Per_Sec__c=0.006, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Multitest MT2168', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0025, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='OPUS3', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0024, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='Tel P12XL', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0024, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='TSK UF200', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0024, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        modelList.add(new CM_Test_Model__c(Name='TSK UF3000EX', Type__c='Handler Model', Customer_Price_Per_Sec__c=0.0024, Amkor_Price_Per_Sec__c=0.005, CM_Version__c=cmVersion.Id, Factory__c='T3'));
        insert modelList;
    }


    public static void AMK1818()
    {
        RFQI_PF_Field_Def__c pfDef = [SELECT Id, Sequence__c, Package_Family__c, RFQI_Section__c, CPN_Attribute__c FROM RFQI_PF_Field_Def__c WHERE Package_Family__r.Name='Final Test' AND RFQI_Field_Def__r.Name='BU_Price_Unit__c'];
        RFQI_Field_Def__c def = [SELECT Id, Name from RFQI_Field_Def__c WHERE  Name='BU_Price__c'];
        RFQI_Section__c section = [SELECT Id from RFQI_Section__c WHERE Name='Quote Information'];

        List<RFQI_Field_Def__c> defList = new List<RFQI_Field_Def__c>();
        List<RFQI_PF_Field_Def__c> pfDefList = new List<RFQI_PF_Field_Def__c>();

        defList.add(new RFQI_Field_Def__c(Name='Sales_BU_Price_Hour__c'));
        defList.add(new RFQI_Field_Def__c(Name='Price_To_Customer_Hour__c'));
        defList.add(new RFQI_Field_Def__c(Name='Sales_BU_Price_Minute__c'));
        defList.add(new RFQI_Field_Def__c(Name='Price_To_Customer_Minute__c'));
        insert defList;

        Decimal seq = 1000;
        for (RFQI_Field_Def__c row : defList)
        {
            pfDefList.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c=row.Id, RFQI_Section__c=section.Id, Sequence__c=++seq, Package_Family__c=pfDef.Package_Family__c));
        }


        RFQI_PF_Field_Def__c newDef = pfDef.clone();

        newDef.RFQI_Field_Def__c = def.Id;
        pfDefList.add(newDef);
        insert pfDefList;
        delete pfDef;
    }
    
    public static void AMK1819Part1() {
        List<RFQI_Field_Def__c> fields = [select Id, Name from RFQI_Field_Def__c where Object__c =: 'Package'];
        for(RFQI_Field_Def__c field : fields ) {
            if(field.Name == 'Tester_Model__c') {
                field.Name = 'Tester_Model_PK__c';
            }
            if(field.Name == 'Handler_Model__c') {
                field.Name = 'Handler_Model_PK__c';
            }
        }
        update fields;
    }

    public static void AMK1819() {
        List<RFQI_Field_Def__c> fieldDefs = new List<RFQI_Field_Def__c>();
        Map<string, RFQI_Field_Def__c> fieldDefsMap = FieldBuilderHelper.getFieldDefs();
        List<RFQI_PF_Field_Def__c> pfFieldDefs = [select Id, RFQI_Field_Def__r.Name, RFQI_Section__r.Name from RFQI_PF_Field_Def__c where Package_Family__r.Name =: 'Final Test'];
        Package_Family__c finalTest = [select Id from Package_Family__c where Name =: 'Final Test'];

        fieldDefs.add(new RFQI_Field_Def__c(Name = 'Tester_Model_PK_Other__c', Object__c='Package', Type__c='String'));
        fieldDefs.add(new RFQI_Field_Def__c(Name = 'Handler_Model_PK_Other__c', Object__c='Package', Type__c='String'));
        fieldDefs.add(new RFQI_Field_Def__c(Name = 'Tester_Model_Other__c', Object__c='Insertion', Type__c='String'));
        fieldDefs.add(new RFQI_Field_Def__c(Name = 'Handler_Model_Other__c', Object__c='Insertion', Type__c='String'));

        insert fieldDefs;

        for(RFQI_PF_Field_Def__c field : pfFieldDefs) {
            if(field.RFQI_Field_Def__r.Name == 'Tester_Model__c' && field.RFQI_Section__r.Name == 'CPN Drivers') {
                field.RFQI_Field_Def__c = fieldDefsMap.get('Tester_Model_PK__c').Id;
            }
            if(field.RFQI_Field_Def__r.Name == 'Handler_Model__c' && field.RFQI_Section__r.Name == 'CPN Drivers') {
                field.RFQI_Field_Def__c = fieldDefsMap.get('Handler_Model_PK__c').Id;
            }
        }


        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs[0].Id, Sequence__c = 2035, Package_Family__c = finalTest.Id, Belongs_To_Section__c = 'CPN Drivers', CPN_Attribute__c = true, Include_on_Quote__c = true));
        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs[1].Id, Sequence__c = 2055, Package_Family__c = finalTest.Id, Belongs_To_Section__c = 'CPN Drivers', CPN_Attribute__c = true, Include_on_Quote__c = true));
        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs[2].Id, Sequence__c = 2035, Package_Family__c = finalTest.Id, Belongs_To_Section__c = 'Insertion Description', CPN_Attribute__c = true, Include_on_Quote__c = true));
        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs[3].Id, Sequence__c = 2055, Package_Family__c = finalTest.Id, Belongs_To_Section__c = 'Insertion Description', CPN_Attribute__c = true, Include_on_Quote__c = true));

        upsert pfFieldDefs;
        
    }

    public static void AMK1825()
    {
        List<SObject> updateList = new List<SObject>();

        Package_Family__c pf = [SELECT Id, Cost_Model_Implementation__c FROM Package_Family__c WHERE Name='Final Test'];
        pf.Cost_Model_Implementation__c = 'CMDefaultBuilder';
        updateList.add(pf);

        List<RFQI_PF_Field_Def__c> defs = [SELECT Id, Include_on_Quote__c FROM RFQI_PF_Field_Def__c WHERE Package_Family__r.Name='Final Test' AND RFQI_Field_Def__r.Name='HVP_Anticipated_Start_Date__c'];

        for (RFQI_PF_Field_Def__c def : defs)
        {
            def.Include_on_Quote__c = true;
        }
        updateList.addAll((List<SObject>)defs);
        update updateList;
    }

    public static void AMK1870()
    {
        List<RFQI_Field_Def__c> allDefs = new List<RFQI_Field_Def__c>();
        Map<string, RFQI_Field_Def__c> fieldDefsMap = FieldBuilderHelper.getFieldDefs();
        List<RFQI_PF_Field_Def__c> pfFieldDefs = [select Id, RFQI_Field_Def__r.Name, RFQI_Section__r.Name, Package_Family__c from RFQI_PF_Field_Def__c where Package_Family__r.Name =: 'Wafer Probe'];
        Package_Family__c waferProbe = [select Id from Package_Family__c where Name =: 'Wafer Probe'];

        allDefs.add(new RFQI_Field_Def__c(Name = 'Tester_Model_PK_Other__c', Object__c='Package', Type__c='String'));
        allDefs.add(new RFQI_Field_Def__c(Name = 'Handler_Model_PK_Other__c', Object__c='Package', Type__c='String'));
        allDefs.add(new RFQI_Field_Def__c(Name = 'Tester_Model_Other__c', Object__c='Insertion', Type__c='String'));
        allDefs.add(new RFQI_Field_Def__c(Name = 'Handler_Model_Other__c', Object__c='Insertion', Type__c='String'));

        allDefs.add(new RFQI_Field_Def__c(Name='Sales_BU_Price_Hour__c'));
        allDefs.add(new RFQI_Field_Def__c(Name='Price_To_Customer_Hour__c'));
        allDefs.add(new RFQI_Field_Def__c(Name='Sales_BU_Price_Minute__c'));
        allDefs.add(new RFQI_Field_Def__c(Name='Price_To_Customer_Minute__c'));

        insert allDefs;

        for(RFQI_PF_Field_Def__c field : pfFieldDefs) {
            if(field.RFQI_Field_Def__r.Name == 'Tester_Model__c' && field.RFQI_Section__r.Name == 'CPN Drivers') {
                field.RFQI_Field_Def__c = fieldDefsMap.get('Tester_Model_PK__c').Id;
            }
            if(field.RFQI_Field_Def__r.Name == 'Handler_Model__c' && field.RFQI_Section__r.Name == 'CPN Drivers') {
                field.RFQI_Field_Def__c = fieldDefsMap.get('Handler_Model_PK__c').Id;
            }
        }


        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = allDefs[0].Id, Sequence__c = 2035, Package_Family__c = waferProbe.Id, Belongs_To_Section__c = 'CPN Drivers', CPN_Attribute__c = true, Include_on_Quote__c = true));
        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = allDefs[1].Id, Sequence__c = 2055, Package_Family__c = waferProbe.Id, Belongs_To_Section__c = 'CPN Drivers', CPN_Attribute__c = true, Include_on_Quote__c = true));
        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = allDefs[2].Id, Sequence__c = 2035, Package_Family__c = waferProbe.Id, Belongs_To_Section__c = 'Insertion Description', CPN_Attribute__c = true, Include_on_Quote__c = true));
        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = allDefs[3].Id, Sequence__c = 2055, Package_Family__c = waferProbe.Id, Belongs_To_Section__c = 'Insertion Description', CPN_Attribute__c = true, Include_on_Quote__c = true));

        RFQI_Section__c section = [SELECT Id from RFQI_Section__c WHERE Name='Quote Information'];


        

        Decimal seq = 1000;
        Id pfId = pfFieldDefs[0].Package_Family__c;
        RFQI_Field_Def__c row;
        for (Integer i = 4; i < allDefs.size(); i++)
        {
            row = allDefs[i];
            pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c=row.Id, RFQI_Section__c=section.Id, Sequence__c=++seq, Package_Family__c=pfId));
        }

        upsert pfFieldDefs;
        
    }

    public static void AMK1870_2()
    {
        //Update lead count on generic object for final test items created before push, AMK-1826
        //Update bu_price_label fields in general item objects, AMK-1828
         
        List<RFQI_Wafer__c> specificList = [SELECT Id, Name, RFQ_Item__c, Ball_Lead_Count__c, BU_Price_Per_Hour__c, BU_Price_per_Minute__c, BU_Price__c from RFQI_Wafer__c];
        Set<Id> itemIds = new Set<Id>();
        for (RFQI_Wafer__c row : specificList) itemIds.add(row.RFQ_Item__c);
        List<RFQ_Item__c> itemList = [SELECT Id, Leads__c from RFQ_Item__c where Id in :itemIds];
        Map<Id, RFQ_Item__c> itemMap = new Map<Id, RFQ_Item__c>();
        for (RFQ_Item__c item : itemList) itemMap.put(item.Id, item);
        RFQ_Item__c item;
        for (RFQI_Wafer__c specific : specificList) 
        {
            item = itemMap.get(specific.RFQ_Item__c);
            if (specific.BU_Price_Per_Hour__c > 0)
            {
                item.BU_Price_Label__c = ' / Hour';
            }
            else if(specific.BU_Price_per_Minute__c > 0)
            {
                item.BU_Price_Label__c = ' / Minute';
            }
            else if(specific.BU_Price__c > 0)
            {
                item.BU_Price_Label__c = ' / Unit';
            }
        }
        update itemList;
         
         
        //Copy BU Price fields to new fields on Final Test objects
        //------------------------------
        List<RFQI_Wafer__c> specificItems = [SELECT Id, rfq_item__c, BU_Price__c, BU_Price_Unit__c, Price_To_Customer__c, BU_Price_Per_Minute__c, Price_To_Customer_Minute__c, BU_Price_Per_Hour__c, Price_To_Customer_Hour__c, createddate from RFQI_Wafer__c WHERE RFQ_Item__r.Status__c not in ('Program Win', 'Price Pending BU Approval')];
        itemIds = new Set<Id>();
        for (RFQI_Wafer__c specItem : specificItems) itemIds.add(specItem.RFQ_Item__c);
        itemMap = new Map<Id, RFQ_Item__c>([SELECT Id, BU_Price__c, Price_To_Customer__c from RFQ_Item__c WHERE Id in :itemIds]);
        for (RFQI_Wafer__c specItem : specificItems)
        {
            specItem.Price_To_Customer_Hour__c = specItem.BU_Price_Per_Hour__c;
            specItem.Price_To_Customer_Minute__c = specItem.BU_Price_per_Minute__c;
            specItem.Price_To_Customer__c = specItem.BU_Price_Unit__c;
            specItem.BU_Price__c = specItem.BU_Price_Unit__c;
            if (specItem.BU_Price_Per_Hour__c != null && specItem.BU_Price_Per_Hour__c > 0)
            {
                itemMap.get(specItem.RFQ_Item__c).Price_To_Customer__c = specItem.Price_To_Customer_Hour__c;
                itemMap.get(specItem.RFQ_Item__c).BU_Price__c = specItem.BU_Price_Per_Hour__c;
            }
            else if(specItem.BU_Price_per_Minute__c != null && specItem.BU_Price_per_Minute__c > 0)
            {
                itemMap.get(specItem.RFQ_Item__c).Price_To_Customer__c = specItem.Price_To_Customer_Minute__c;
                itemMap.get(specItem.RFQ_Item__c).BU_Price__c = specItem.BU_Price_per_Minute__c;
            }
            else if(specItem.BU_Price__c != null && specItem.BU_Price__c > 0)
            {
                itemMap.get(specItem.RFQ_Item__c).Price_To_Customer__c = specItem.Price_To_Customer__c;
                itemMap.get(specItem.RFQ_Item__c).BU_Price__c = specItem.BU_Price__c;
            }
        }
         
        update itemMap.values();
        update specificItems;
    }

    public static void AMK1870_3()
    {
        List<RFQI_Field_Def__c> defs = [SELECT Id from RFQI_Field_Def__c WHERE Name='Index_Time_New__c'];
        List<RFQI_PF_Field_Def__c> pfDefs = [SELECT Id, RFQI_Field_Def__c, RFQI_Section__c, Required__c, CPN_Attribute__c, Default_Driver__c, Factory_Values__c, Generated__c, Has_Amkor_Selected__c, Include_on_Quote__c, Is_Manual_Entry__c, Not_Required_on_Import__c, On_Change__c, Other_Fields__c, Other_Field__c, Package_Family__c, Read_Only_If_Parent__c, SAP_Name__c, Sequence__c FROM RFQI_PF_Field_Def__c WHERE RFQI_Field_Def__r.Name='Index_Time__c'];

        List<RFQI_PF_Field_Def__c> insertList = new List<RFQI_PF_Field_Def__c>();
        for (RFQI_PF_Field_Def__c def : pfDefs)
        {
            RFQI_PF_Field_Def__c row = def.clone();
            row.RFQI_Field_Def__c = defs[0].Id;
            insertList.add(row);
        }

        delete pfDefs;
        insert insertList;

    }
}