/*************************************************************************
* 
* PURPOSE:  this class seeds fresh RFQ Item Field Definition specifically
*           for the dual leadframe package families (cloned from SOIC150Installer
*           for the purposes of generalization)
*         
* CLASS: DualLeadframeInstaller
* CREATED: 03/12/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
* 
**************************************************************************/
global class DualLeadframeInstaller {
    
    public static List<RFQI_Default_Driver__c> drivers {get; set;}

    global static Product_Group__c installDLFProductGroup(string pg) {
        
        Product_Group__c ProductGroup = new Product_Group__c(Name = pg);
        ProductGroup.Cost_Model_Implementation__c = 'CMDualBuilder';
        ProductGroup.Wire_Calculation_Implementation__c = 'CMDualWireCalc';
        ProductGroup.Generated_Price_Requires_BU_Review__c = true;
        try {
            insert ProductGroup;
        }catch(Exception e) {
            system.debug('Could not install' + pg + ':' + e);
        }
        return ProductGroup;
    }

    global static void installTest() {

        installDLFProductGroup('Dual Leadframe');
        Product_Group__c prodGroup = [select Id from Product_Group__c where Name =: 'Dual Leadframe'];
        
        List<Package_Family__c> families = new List<Package_Family__c>();
        FieldBuilderHelper.addPf('SOIC 150mil Body', prodGroup, 'RFQI_SOIC_150mil_body__c', 'RFQIWC_SOIC_150mil_body__c', 'RFQIDC_SOIC_150mil__c', families);
        insert families;

        installFieldDefs('SOIC 150mil Body');

    }
    
    global static void install() {
        
        FieldBuilderHelper.clean('Dual Leadframe');
        installDLFProductGroup('Dual Leadframe');
        installDualLeadFramePackageFamilies();
        installFieldDefs('SOIC 150mil Body');
        installFieldDefs('SOT 223');
        installFieldDefs('TO 92');
        installFieldDefs('PSOP3');
        installFieldDefs('SOIC 208mil Body');
        installFieldDefs('SOIC 300mil Body');
        installFieldDefs('VSSOP');
        installFieldDefs('PDIP');
        installFieldDefs('TSOT');
        installFieldDefs('SOT 23');
        installFieldDefs('SC 70');
        installFieldDefs('SSOP 150mil body');
        installFieldDefs('SSOP 300mil body');
        installFieldDefs('SSOP metric 5.3mm');
        installFieldDefs('TSSOP 3.0mm body MSOP');
        installFieldDefs('TSSOP 4.4mm body');
        installFieldDefs('TSSOP 6.1mm body');
        installFieldDefs('epad TSSOP 4.4 body');
        installFieldDefs('epad TSSOP 6.1 body');
        installExtended('CERDIP');
        installExtended('SZIP J1 Only'); 
    }
    
    public static void updateSapFields() {
    	RFQAdminInstaller.updateSapFieldsForProductGroup('Dual Leadframe'); 
    }

    public static void installDLFDefaultDriversTest() {
         List<RFQI_Default_Driver__c> driversT = new List<RFQI_Default_Driver__c>();
         Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
         }


        Package_Family__c pf = [select Name, Id from Package_Family__c where Name =: 'SOIC 150mil Body'];

    
        driversT.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Prototype__c').Id, Driver_Value__c = 'true', Child__c = fieldDefs.get('Forecast__c').Id, Child_Value__c = '< 50'));
        driversT.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Count__c').Id, Driver_Value__c = 'Ave_2D_Wire_Formula__c', Child__c = fieldDefs.get('Average_2D_Wire_Length__c').Id, Read__c = true));
        driversT.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Count__c').Id, Driver_Value__c = 'DPW__c', Child__c = fieldDefs.get('Wafer_Number_of_DPW__c').Id, Read__c = true));
        driversT.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Wafer_Yield__c').Id, Read__c = true));
        driversT.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Wafer_Number_of_DPW__c').Id, Read__c = true));
   
        
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '8ld', fieldDefs.get('Number_Of_Wires__c'), '10', driversT);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), 'epad 8ld', fieldDefs.get('Number_Of_Wires__c'), '13', driversT);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '14ld', fieldDefs.get('Number_Of_Wires__c'), '14', driversT);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '16ld', fieldDefs.get('Number_Of_Wires__c'), '17', driversT);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), 'epad 16ld', fieldDefs.get('Number_Of_Wires__c'), '20', driversT);

        insert driversT;
    }
    
    public static void installDLFDefaultDrivers() {
        drivers = new List<RFQI_Default_Driver__c>();
    	FieldBuilderHelper.deleteProductgroupDefaultDriver('Dual Leadframe');
        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
            }

        List<Package_Family__c> pf = [select Name, Id from Package_Family__c where Product_Group__r.Name =: 'Dual Leadframe'];

        for(Package_Family__c packagefamilies : pf) {
            drivers.add(new RFQI_Default_Driver__c(Package_Family__c = packagefamilies.Id, Driver__c = fieldDefs.get('Prototype__c').Id, Driver_Value__c = 'true', Child__c = fieldDefs.get('Forecast__c').Id, Child_Value__c = '< 50'));
            drivers.add(new RFQI_Default_Driver__c(Package_Family__c = packagefamilies.Id, Driver__c = fieldDefs.get('Lead_Count__c').Id, Driver_Value__c = 'Ave_2D_Wire_Formula__c', Child__c = fieldDefs.get('Average_2D_Wire_Length__c').Id, Read__c = true));
            drivers.add(new RFQI_Default_Driver__c(Package_Family__c = packagefamilies.Id, Driver__c = fieldDefs.get('Lead_Count__c').Id, Driver_Value__c = 'DPW__c', Child__c = fieldDefs.get('Wafer_Number_of_DPW__c').Id, Read__c = true));
            drivers.add(new RFQI_Default_Driver__c(Package_Family__c = packagefamilies.Id, Driver__c = fieldDefs.get('Wafer_Yield__c').Id, Read__c = true));
            drivers.add(new RFQI_Default_Driver__c(Package_Family__c = packagefamilies.Id, Driver__c = fieldDefs.get('Wafer_Number_of_DPW__c').Id, Read__c = true));
        }

    	installSoic150DefaultDrivers(fieldDefs);
        installSOIC208DefaultDrivers(fieldDefs);
        installepadTSSOP44DefaultDrivers(fieldDefs);
        installepadTSSOP61DefaultDrivers(fieldDefs);
        installPDIPDefaultDrivers(fieldDefs);
        installPSOP3DefaultDrivers(fieldDefs);
        installSC70DefaultDrivers(fieldDefs);
        installSOIC300DefaultDrivers(fieldDefs);
        installSOT223DefaultDrivers(fieldDefs);
        installSOT23DefaultDrivers(fieldDefs);
        installSSOP150DefaultDrivers(fieldDefs);
        installSSOP300DefaultDrivers(fieldDefs);
        installSSOP53DefaultDrivers(fieldDefs);
        installTO92DefaultDrivers(fieldDefs);
        installTSOTDefaultDrivers(fieldDefs);
        installTSSOP30DefaultDrivers(fieldDefs);
        installTSSOP44DefaultDrivers(fieldDefs);
        installTSSOP61DefaultDrivers(fieldDefs);
        installVSSOPDefaultDrivers(fieldDefs);
        insert drivers;

        AMK1642();
    }
    
    private static List<Package_Family__c> installDualLeadFramePackageFamilies() {
        
        Product_Group__c prodGroup = [select Id from Product_Group__c where Name =: 'Dual Leadframe'];
        
        List<Package_Family__c> families = new List<Package_Family__c>();
        
        FieldBuilderHelper.addPf('SOIC 150mil Body', prodGroup, 'RFQI_SOIC_150mil_body__c', 'RFQIWC_SOIC_150mil_body__c', 'RFQIDC_SOIC_150mil__c', families);
        FieldBuilderHelper.addPf('SOIC 208mil Body', prodGroup, 'RFQI_SOIC_208mil_body__c', 'RFQIWC_SOIC_208mil_body__c', 'RFQIDC_SOIC_208mil_body__c', families);
        FieldBuilderHelper.addPf('SOIC 300mil Body', prodGroup, 'RFQI_SOIC_300mil_body__c', 'RFQIWC_SOIC_300mil_body__c', 'RFQIDC_SOIC_300mil_body__c', families);
        FieldBuilderHelper.addPf('VSSOP', prodGroup, 'RFQI_VSSOP__c', 'RFQIWC_VSSOP__c', 'RFQIDC_VSSOP__c', families);
        FieldBuilderHelper.addPf('PDIP', prodGroup, 'RFQI_PDIP__c', 'RFQIWC_PDIP__c', 'RFQIDC_PDIP__c', families);
        FieldBuilderHelper.addPf('TSOT', prodGroup, 'RFQI_TSOT__c', 'RFQIWC_TSOT__c', 'RFQIDC_TSOT__c', families);
        FieldBuilderHelper.addPf('PSOP3', prodGroup, 'RFQI_PSOP3__c', 'RFQIWC_PSOP3__c', 'RFQIDC_PSOP_3__c', families);
        FieldBuilderHelper.addPf('TO 92', prodGroup, 'RFQI_TO_92__c', 'RFQIWC_TO_92__c', 'RFQIDC_TO_92__c', families);
        FieldBuilderHelper.addPf('SOT 223', prodGroup, 'RFQI_SOT_223__c', 'RFQIWC_SOT_223__c', 'RFQIDC_SOT_223__c', families);
        FieldBuilderHelper.addPf('SOT 23', prodGroup, 'RFQI_SOT_23__c', 'RFQIWC_SOT_23__c', 'RFQIDC_SOT_23__c', families);
        FieldBuilderHelper.addPf('SC 70', prodGroup, 'RFQI_SC_70__c', 'RFQIWC_SC_70__c', 'RFQIDC_SC_70__c', families);
        FieldBuilderHelper.addPf('SSOP 150mil body', prodGroup, 'RFQI_SSOP_150mil_body__c', 'RFQIWC_SSOP_150mil_body__c', 'RFQIDC_SSOP_150mil_body__c', families);
        FieldBuilderHelper.addPf('SSOP 300mil body', prodGroup, 'RFQI_SSOP_300mil_body__c', 'RFQIWC_SSOP_300mil_body__c', 'RFQIDC_SSOP_300mil_body__c', families);
        FieldBuilderHelper.addPf('SSOP metric 5.3mm', prodGroup, 'RFQI_SSOP_metric_53mm__c', 'RFQIWC_SSOP_metric_53mm__c', 'RFQIDC_SSOP_metric_53__c', families);
        FieldBuilderHelper.addPf('TSSOP 3.0mm body MSOP', prodGroup, 'RFQI_TSSOP_30mm_body_MSOP__c', 'RFQIWC_TSSOP_30mm_body_MSOP__c', 'RFQIDC_TSSOP_30mm_body_MSOP__c', families);
        FieldBuilderHelper.addPf('TSSOP 4.4mm body', prodGroup, 'RFQI_TSSOP_44mm_body__c', 'RFQIWC_TSSOP_44mm_body__c', 'RFQIDC_TSSOP_4_4mm_body__c', families);        
        FieldBuilderHelper.addPf('TSSOP 6.1mm body', prodGroup, 'RFQI_TSSOP_61mm_body__c', 'RFQIWC_TSSOP_61mm_body__c', 'RFQIDC_TSSOP_6_1mm_body__c', families);        
        FieldBuilderHelper.addPf('epad TSSOP 4.4 body', prodGroup, 'RFQI_epad_TSSOP_44_body__c', 'RFQIWC_epad_TSSOP_44_body__c', 'RFQIDC_epad_TSSOP_4_4mm_body__c', families);  
        FieldBuilderHelper.addPf('epad TSSOP 6.1 body', prodGroup, 'RFQI_epad_TSSOP_61_body__c', 'RFQIWC_epad_TSSOP_61_body__c', 'RFQIDC_epad_TSSOP_6_1mm_body__c', families);
        FieldBuilderHelper.addPf('CERDIP', prodGroup, 'RFQI_CERDIP__c', null, null,null, null, families, false, 'CMExtendedBuilder');
        FieldBuilderHelper.addPf('SZIP J1 Only', prodGroup, 'RFQI_SZIP_J1_ONLY__c', null, null,null, null, families, false, 'CMExtendedBuilder');

        for(Integer i=19; i < families.size(); i++){
            families[i].No_Cost_Model__c = true;
        }


        try {
            insert families;
        }catch(Exception e) {
            system.debug('Could not install Dual Leadframe Package Families: ' + e);
        }
        return families;
    }

    private static void addPf(string name, Product_Group__c prodGroup, string rfqItem, string wireConfig, List<Package_Family__c> targetList) {
        Package_Family__c PDIP =  new Package_Family__c(Name=name,Product_Group__c = prodGroup.Id);
        PDIP.Specific_RFQ_Item_Object__c = rfqItem;
        PDIP.Specific_Wire_Configuration_Object__c = wireConfig;
        targetList.add(PDIP);
    }
    
    private static void installSoic150DefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'SOIC 150mil Body'];
        
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '8ld', fieldDefs.get('Number_Of_Wires__c'), '10', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), 'epad 8ld', fieldDefs.get('Number_Of_Wires__c'), '13', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '14ld', fieldDefs.get('Number_Of_Wires__c'), '14', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '16ld', fieldDefs.get('Number_Of_Wires__c'), '17', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), 'epad 16ld', fieldDefs.get('Number_Of_Wires__c'), '20', drivers);

    }
    
    private static void installSOIC208DefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	Package_Family__c pf = [select Id from Package_Family__c where Name =: 'SOIC 208mil Body'];
            
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '8ld', fieldDefs.get('Number_Of_Wires__c'), '8', drivers);    
    }
    
    private static void installepadTSSOP44DefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	Package_Family__c pf = [select Id from Package_Family__c where Name =: 'epad TSSOP 4.4 body'];
            
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '8ld', fieldDefs.get('Number_Of_Wires__c'), '9', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '14ld', fieldDefs.get('Number_Of_Wires__c'), '22', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '16ld', fieldDefs.get('Number_Of_Wires__c'), '21', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '20ld', fieldDefs.get('Number_Of_Wires__c'), '21', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '24ld', fieldDefs.get('Number_Of_Wires__c'), '26', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '28ld', fieldDefs.get('Number_Of_Wires__c'), '32', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '30ld', fieldDefs.get('Number_Of_Wires__c'), '32', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '38ld', fieldDefs.get('Number_Of_Wires__c'), '36', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '44ld', fieldDefs.get('Number_Of_Wires__c'), '59', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '48ld', fieldDefs.get('Number_Of_Wires__c'), '64', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '56ld', fieldDefs.get('Number_Of_Wires__c'), '73', drivers);
       
    }
    
    private static void installepadTSSOP61DefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	Package_Family__c pf = [select Id from Package_Family__c where Name =: 'epad TSSOP 6.1 body'];
            
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '28ld', fieldDefs.get('Number_Of_Wires__c'), '28', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '48ld', fieldDefs.get('Number_Of_Wires__c'), '53', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '56ld', fieldDefs.get('Number_Of_Wires__c'), '61', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '64ld', fieldDefs.get('Number_Of_Wires__c'), '80', drivers);
    }
    
    private static void installPDIPDefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	Package_Family__c pf = [select Id from Package_Family__c where Name =: 'PDIP'];
            
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '300_body_8ld', fieldDefs.get('Number_Of_Wires__c'), '9', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '300_body_14ld', fieldDefs.get('Number_Of_Wires__c'), '14', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '300_body_16ld', fieldDefs.get('Number_Of_Wires__c'), '17', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '300_body_18ld', fieldDefs.get('Number_Of_Wires__c'), '19', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '300_body_20ld', fieldDefs.get('Number_Of_Wires__c'), '22', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '300_body_22ld', fieldDefs.get('Number_Of_Wires__c'), '26', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '300_body_24ld', fieldDefs.get('Number_Of_Wires__c'), '25', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '600_body_24ld', fieldDefs.get('Number_Of_Wires__c'), '26', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '600_body_28ld', fieldDefs.get('Number_Of_Wires__c'), '31', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '288_body_28ld', fieldDefs.get('Number_Of_Wires__c'), '29', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '600_body_32ld', fieldDefs.get('Number_Of_Wires__c'), '34', drivers);
     
    }
    
    private static void installPSOP3DefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	Package_Family__c pf = [select Id from Package_Family__c where Name =: 'PSOP3'];
            
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '20ld', fieldDefs.get('Number_Of_Wires__c'), '20', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '24ld', fieldDefs.get('Number_Of_Wires__c'), '24', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '30ld', fieldDefs.get('Number_Of_Wires__c'), '55', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '36ld', fieldDefs.get('Number_Of_Wires__c'), '80', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '44ld', fieldDefs.get('Number_Of_Wires__c'), '90', drivers);

    }
    
    private static void installSC70DefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	Package_Family__c pf = [select Id from Package_Family__c where Name =: 'SC 70'];
            
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '3ld', fieldDefs.get('Number_Of_Wires__c'), '3', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '4ld', fieldDefs.get('Number_Of_Wires__c'), '4', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '5ld', fieldDefs.get('Number_Of_Wires__c'), '5', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '6ld', fieldDefs.get('Number_Of_Wires__c'), '6', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '8ld', fieldDefs.get('Number_Of_Wires__c'), '8', drivers);
    }
    
    private static void installSOIC300DefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	Package_Family__c pf = [select Id from Package_Family__c where Name =: 'SOIC 300mil Body'];
            
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '16ld', fieldDefs.get('Number_Of_Wires__c'), '14', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '18ld', fieldDefs.get('Number_Of_Wires__c'), '19', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '20ld', fieldDefs.get('Number_Of_Wires__c'), '21', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '24ld', fieldDefs.get('Number_Of_Wires__c'), '25', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '28ld', fieldDefs.get('Number_Of_Wires__c'), '30', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '32ld', fieldDefs.get('Number_Of_Wires__c'), '36', drivers);        
    }
    
    private static void installSOT223DefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	Package_Family__c pf = [select Id from Package_Family__c where Name =: 'SOT 223'];
            
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '4ld', fieldDefs.get('Number_Of_Wires__c'), '4', drivers);
    }
    
    private static void installSOT23DefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	Package_Family__c pf = [select Id from Package_Family__c where Name =: 'SOT 23'];
            
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '3ld', fieldDefs.get('Number_Of_Wires__c'), '3', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '4ld', fieldDefs.get('Number_Of_Wires__c'), '4', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '5ld', fieldDefs.get('Number_Of_Wires__c'), '5', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '6ld', fieldDefs.get('Number_Of_Wires__c'), '6', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '8ld', fieldDefs.get('Number_Of_Wires__c'), '8', drivers);  
    }
    
    private static void installSSOP150DefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	Package_Family__c pf = [select Id from Package_Family__c where Name =: 'SSOP 150mil body'];
            
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '16ld', fieldDefs.get('Number_Of_Wires__c'), '16', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '20ld', fieldDefs.get('Number_Of_Wires__c'), '24', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '24ld', fieldDefs.get('Number_Of_Wires__c'), '27', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '28ld', fieldDefs.get('Number_Of_Wires__c'), '30', drivers);      
    }
    
    private static void installSSOP300DefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	Package_Family__c pf = [select Id from Package_Family__c where Name =: 'SSOP 300mil body'];
            
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '36ld', fieldDefs.get('Number_Of_Wires__c'), '37', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '48ld', fieldDefs.get('Number_Of_Wires__c'), '54', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '56ld', fieldDefs.get('Number_Of_Wires__c'), '65', drivers);
    }
    
    private static void installSSOP53DefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	Package_Family__c pf = [select Id from Package_Family__c where Name =: 'SSOP metric 5.3mm'];
            
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '14ld', fieldDefs.get('Number_Of_Wires__c'), '14', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '16ld', fieldDefs.get('Number_Of_Wires__c'), '17', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '20ld', fieldDefs.get('Number_Of_Wires__c'), '21', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '24ld', fieldDefs.get('Number_Of_Wires__c'), '25', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '28ld', fieldDefs.get('Number_Of_Wires__c'), '30', drivers);
    }
    
    private static void installTO92DefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	Package_Family__c pf = [select Id from Package_Family__c where Name =: 'TO 92'];
            
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '2ld', fieldDefs.get('Number_Of_Wires__c'), '2', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '3ld', fieldDefs.get('Number_Of_Wires__c'), '3', drivers);            
    }
    
    private static void installTSOTDefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	Package_Family__c pf = [select Id from Package_Family__c where Name =: 'TSOT'];
     
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '3ld', fieldDefs.get('Number_Of_Wires__c'), '3', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '4ld', fieldDefs.get('Number_Of_Wires__c'), '4', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '5ld', fieldDefs.get('Number_Of_Wires__c'), '5', drivers);
    
    }
    
    private static void installTSSOP30DefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	Package_Family__c pf = [select Id from Package_Family__c where Name =: 'TSSOP 3.0mm body MSOP'];
        
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '8ld', fieldDefs.get('Number_Of_Wires__c'), '11', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '10ld', fieldDefs.get('Number_Of_Wires__c'), '13', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), 'epad_8ld', fieldDefs.get('Number_Of_Wires__c'), '9', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), 'epad_10ld', fieldDefs.get('Number_Of_Wires__c'), '14', drivers);    
    }
    
    private static void installTSSOP44DefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	Package_Family__c pf = [select Id from Package_Family__c where Name =: 'TSSOP 4.4mm body'];
    
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '8ld', fieldDefs.get('Number_Of_Wires__c'), '10', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '14ld', fieldDefs.get('Number_Of_Wires__c'), '14', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '16ld', fieldDefs.get('Number_Of_Wires__c'), '19', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '20ld', fieldDefs.get('Number_Of_Wires__c'), '24', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '24ld', fieldDefs.get('Number_Of_Wires__c'), '27', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '28ld', fieldDefs.get('Number_Of_Wires__c'), '26', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '30ld', fieldDefs.get('Number_Of_Wires__c'), '32', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '38ld', fieldDefs.get('Number_Of_Wires__c'), '38', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '44ld', fieldDefs.get('Number_Of_Wires__c'), '43', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '48ld', fieldDefs.get('Number_Of_Wires__c'), '48', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '56ld', fieldDefs.get('Number_Of_Wires__c'), '61', drivers);
       
    }
    
    private static void installTSSOP61DefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	Package_Family__c pf = [select Id from Package_Family__c where Name =: 'TSSOP 6.1mm body'];
        
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '28ld', fieldDefs.get('Number_Of_Wires__c'), '28', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '48ld', fieldDefs.get('Number_Of_Wires__c'), '53', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '56ld', fieldDefs.get('Number_Of_Wires__c'), '61', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '64ld', fieldDefs.get('Number_Of_Wires__c'), '80', drivers);
    
    }
    
    private static void installVSSOPDefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
    	Package_Family__c pf = [select Id from Package_Family__c where Name =: 'VSSOP'];
            
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '8ld', fieldDefs.get('Number_Of_Wires__c'), '8', drivers);     
    }
    
        
    private static List<RFQI_PF_Field_Def__c> installFieldDefs(string pf) {
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
        helper.add('Cost and Price','Materials_Leadframe__c',1010,false,true);
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
        helper.add('Cost and Price','Manufacturing_Overhead__c',1150,false,true);
        helper.add('Cost and Price','Materials_As_Perc_Cost__c',1160,false,true);
        helper.add('Cost and Price','QA_Cost__c',1170,false,true);
        helper.add('Cost and Price','Total_Cost__c',1180,false,true);
        helper.add('Cost and Price','Variable_Costs__c',1190,false,true);
        helper.add('Cost and Price','Service_Group_Cost__c',1200,false,true);
        helper.add('Cost and Price','Adder_Cost__c',1210,false,true);
        helper.add('Cost and Price','Fixed_Costs__c',1220,false,true);    
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
        helper.add('Package Description', 'Lead_Count__c', 2010, true, false, false, true);
        helper.add('Package Description', 'Stamped_Etched_Leadframe__c', 2020, true);
        helper.add('Package Description', 'Leadframe_Finish__c', 2030, true);
        helper.add('Package Description', 'Standard_Rough_Leadframe__c', 2040, true);
        helper.add('Package Description', 'Additional_Components_In_Package__c', 2090, true);
        helper.add('Package Description', 'Packing_Method__c', 2100, true);
        helper.add('Package Description', 'Zero_Delam_Required__c', 2110, true);
            
        helper.add('Wire Description', 'Wire_Configuration__c', 3000, false, false, true);
        helper.add('Wire Description', 'Wire_Material__c', 3010, true, false, true);
        helper.add('Wire Description', 'Wire_Diameter__c', 3020, true, false, true);
        helper.add('Wire Description', 'Number_Of_Wires__c', 3030, true, false, true);
        helper.add('Wire Description', 'Average_2D_Wire_Length__c', 3040);
        helper.add('Wire Description', 'Total_2D_Wire_Length__c', 3050);
        helper.add('Wire Description', 'Total_3D_Wire_Length__c', 3060, true);
        helper.add('Wire Description', 'Au_Factor__c', 3070);
        
        helper.add('Die Description', 'Die_Attach__c', 3000, true);
        helper.add('Die Description', 'Die_1_Size_Dim_X__c', 3010, true);
        helper.add('Die Description', 'Die_1_Size_Dim_Y__c', 3020, true);
        helper.add('Die Description', 'Die_1_Thickness__c', 3030, true);    
        helper.add('Die Description', 'Wafer_Number_of_DPW__c', 3040, true, false, false, true);
        helper.add('Die Description', 'Wafer_Yield__c', 3050, true, false, false, true);
        helper.add('Die Description', 'GDPW__c', 3060, true);
        helper.add('Die Description', 'Wafer_Size__c', 3070, true);
        helper.add('Die Description', 'Wafer_Backgrind__c', 3080, true);
        helper.add('Die Description', 'Wafer_Singulation__c', 3090, true);
        
        
        helper.add('Adders', 'Plasma_Before_Die_Attach__c', 4000, true);
        helper.add('Adders', 'Plasma_Before_Wire_Bond__c', 4010, true);
        helper.add('Adders', 'Plasma_Before_Mold__c', 4020, true);
        helper.add('Adders', 'Die_Coat__c', 4030, true);
        helper.add('Adders', 'Wafer_Inspection__c', 4040, true);
        helper.add('Adders', 'X2_OPT_INSP_100__c', 4050, true);
        helper.add('Adders', 'X3RD_OPT_100__c', 4060, true);
        helper.add('Adders', 'FVI_100__c', 4070, true);
        helper.add('Adders', 'Bake_Dry_Pack__c', 4080, true);
        helper.add('Adders', 'Temperature_Cycle__c', 4090, true);
        helper.add('Adders', 'Bake__c', 4100, true);
        
        helper.add('NRE', 'Stamped_Leadframe_Tooling__c', 5000);
        helper.add('NRE', 'Etched_Leadframe_Tooling__c', 5010);
        helper.add('NRE', 'Other__c', 5020);
                                                    
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
        helper.add('BU Header', 'RGQ_Projected_Annual_Revenue__c', 1120);
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

        helper.add('NRE', 'Stamped_Leadframe_Tooling__c', 5000);
        helper.add('NRE', 'Etched_Leadframe_Tooling__c', 5010);
        helper.add('NRE', 'Other__c', 5020);

        helper.insertFields();
        
        return helper.getPfFieldDefs(); 

    }

    public static void AMK1642()
    {
        RFQI_Field_Def__c def1642 = [select Id, Name from RFQI_Field_Def__c where Name='Total_2D_Wire_Length__c'];

        List<RFQI_Default_Driver__c> drivers1642 = [select Id, Driver__c, Child__c, Child__r.Name, Package_Family__r.Name, Package_Family__c, Driver_Value__c, Read__c from RFQI_Default_Driver__c where Child__r.Name='Average_2D_Wire_Length__c'];
        List<RFQI_Default_Driver__c> newDrivers = new List<RFQI_Default_Driver__c>();
        RFQI_Default_Driver__c newDriv;

        for (RFQI_Default_Driver__c driver : drivers1642)
        {
            newDriv = new RFQI_Default_Driver__c();
            newDriv.Driver__c = driver.Driver__c;
            newDriv.Package_Family__c = driver.Package_Family__c;
            newDriv.Read__c = driver.Read__c;
            newDriv.Driver_Value__c = 'Total_2D_Wire_Formula__c';
            newDriv.Child__c = def1642.Id;
            newDrivers.add(newDriv);
        }

        insert newDrivers;
    }

    public static void AMK1717() {
        List<RFQI_PF_Field_Def__c> fields = [select Id, Name, CPN_Attribute__c, Deprecated__c, Include_on_Quote__c, RFQI_Field_Def__r.Name, RFQI_Section__r.Name, Sequence__c from RFQI_PF_Field_Def__c where Package_Family__r.Product_Group__r.Name =: 'Dual Leadframe'];
        Map<string, RFQI_Field_Def__c> fieldDefs = FieldBuilderHelper.getFieldDefs();
        RFQI_Section__c dieSection = [select Id from RFQI_Section__c where Name =: 'Die Description'];
        drivers = new List<RFQI_Default_Driver__c>(); 
        List<Package_Family__c> dualFamilies = [select Id, Name,Layout_Version__c from Package_Family__c where Product_Group__r.Name =: 'Dual Leadframe'];

        for(Package_Family__c family : dualFamilies) {
            if(family.Name != 'SZIP J1 Only' && family.Name != 'CERDIP' && family.Name != 'Hermetics') {
                family.Layout_Version__c = 2;
                for(RFQI_PF_Field_Def__c field : fields) {
                    if(field.RFQI_Field_Def__r.Name == 'Die_1_Size_Dim_X__c' || field.RFQI_Field_Def__r.Name == 'Die_1_Size_Dim_Y__c' || field.RFQI_Field_Def__r.Name == 'Die_1_Thickness__c') {field.Deprecated__c = true;}
                }
                fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Die_Size_X__c').Id, CPN_Attribute__c = true, Include_on_Quote__c = true, RFQI_Section__c = dieSection.Id, Sequence__c = 3010, Package_Family__c = family.Id));
                fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Die_Size_Y__c').Id, CPN_Attribute__c = true, Include_on_Quote__c = true, RFQI_Section__c = dieSection.Id, Sequence__c = 3020, Package_Family__c = family.Id));
                fields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Die_Thickness__c').Id, CPN_Attribute__c = true, Include_on_Quote__c = true, RFQI_Section__c = dieSection.Id, Sequence__c = 3030, Package_Family__c = family.Id));
                drivers.add(new RFQI_Default_Driver__c(Read__c = true, Driver__c = fieldDefs.get('Lead_Count__c').Id, Driver_Value__c = 'Die_1_Size_Dim_X__c', Child__c = fieldDefs.get('Die_Size_X__c').Id, Package_Family__c = family.Id));
                drivers.add(new RFQI_Default_Driver__c(Read__c = true, Driver__c = fieldDefs.get('Lead_Count__c').Id, Driver_Value__c = 'Die_1_Size_Dim_Y__c', Child__c = fieldDefs.get('Die_Size_Y__c').Id, Package_Family__c = family.Id));
                drivers.add(new RFQI_Default_Driver__c(Read__c = true, Driver__c = fieldDefs.get('Lead_Count__c').Id, Driver_Value__c = 'Die_1_Thickness__c', Child__c = fieldDefs.get('Die_Thickness__c').Id, Package_Family__c = family.Id));
            }
        }
        upsert fields;
        insert drivers;
        update dualFamilies;
    }
    
}