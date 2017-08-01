/*************************************************************************
* 
* PURPOSE:  this class seeds fresh RFQ Item Field Definition specifically
*           for the FCCSP package families (cloned from SOIC150Installer
*           for the purposes of generalization)
*         
* CLASS: EngineeringServiceInstaller
* CREATED: 10/10/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
global class EngineeringServiceInstaller {
	private static Product_Group__c prodGroup {get; set;}
    private static List<Package_Family__c> families {get; set;}
    private static List<RFQI_PF_Field_Def__c> pfFields {get; set;}
    private static List<RFQI_Default_Driver__c> defaultDrivers {get; set;}

    global static void install(){
        installFieldDefs();
        Map<String, RFQI_Section__c> sections = FieldBuilderHelper.getSectionMap();
        Map<string, RFQI_Field_Def__c> fieldDefs = FieldBuilderHelper.getFieldDefs();
        pfFields = new List<RFQI_PF_Field_Def__c>();
        defaultDrivers = new List<RFQI_Default_Driver__c>(); 
    	FieldBuilderHelper.clean('Engineering Services');
    	prodGroup = FieldBuilderHelper.installProductGroup('Engineering Services', false, true);
    	installEngineeringServicePackageFamilies();
        for(Package_Family__c family : families) {
            installBase(family, sections, fieldDefs);
        }

        insert defaultDrivers;
        insert pfFields;
    }

    private static List<Package_Family__c> installEngineeringServicePackageFamilies() {
    	families = new List<Package_Family__c>();

    	families.add(new Package_Family__c(Name='Board Level Reliability', Product_Group__c=prodGroup.Id, Specific_RFQ_Item_Object__c ='RFQI_Board_Level_Reliability__c', Specific_Service_Configuration_Object__c ='RFQISC_Board_Level_Reliability__c', Has_Factory_Field__c = false));
    	families.add(new Package_Family__c(Name='Component Level Reliability', Product_Group__c=prodGroup.Id, Specific_RFQ_Item_Object__c ='RFQI_Component_Reliability__c', Specific_Service_Configuration_Object__c ='RFQISC_Component_Level_Reliability__c', Has_Factory_Field__c = false));
    	families.add(new Package_Family__c(Name='Design', Product_Group__c=prodGroup.Id, Specific_RFQ_Item_Object__c ='RFQI_Design__c', Has_Factory_Field__c = false));
    	families.add(new Package_Family__c(Name='Electrical Services', Product_Group__c=prodGroup.Id, Specific_RFQ_Item_Object__c ='RFQI_Electrical_Service__c', Has_Factory_Field__c = false));
    	families.add(new Package_Family__c(Name='Electromigration Tests', Product_Group__c=prodGroup.Id, Specific_RFQ_Item_Object__c ='RFQI_Electromigration_Test__c', Specific_Service_Configuration_Object__c ='RFQISC_Electromigration_Test__c', Has_Factory_Field__c = false));
    	families.add(new Package_Family__c(Name='Imaging only', Product_Group__c=prodGroup.Id, Specific_RFQ_Item_Object__c ='RFQI_Imaging_Only__c', Specific_Service_Configuration_Object__c ='RFQISC_Imaging_only__c', Has_Factory_Field__c = false));
    	families.add(new Package_Family__c(Name='Mechanical', Product_Group__c=prodGroup.Id, Specific_RFQ_Item_Object__c ='RFQI_Mechanical__c', Specific_Service_Configuration_Object__c ='RFQISC_Mechanical__c', Has_Factory_Field__c = false));
    	families.add(new Package_Family__c(Name='Nano Materials Analysis', Product_Group__c=prodGroup.Id, Specific_RFQ_Item_Object__c ='RFQI_Nano_Materials_Analysis__c', Specific_Service_Configuration_Object__c ='RFQISC_Nano_Materials_Analysis__c', Has_Factory_Field__c = false));
    	families.add(new Package_Family__c(Name='Package Materials Testing', Product_Group__c=prodGroup.Id, Specific_RFQ_Item_Object__c ='RFQI_Package_Materials_Testing__c', Specific_Service_Configuration_Object__c ='RFQISC_Package_Materials_Testing__c', Has_Factory_Field__c = false));
    	families.add(new Package_Family__c(Name='Thermal', Product_Group__c=prodGroup.Id, Specific_RFQ_Item_Object__c ='RFQI_Thermal__c', Specific_Service_Configuration_Object__c ='RFQISC_Thermal__c', Has_Factory_Field__c = false));
    	families.add(new Package_Family__c(Name='X-Section-SEM-EDX', Product_Group__c=prodGroup.Id, Specific_RFQ_Item_Object__c ='RFQI_X_Section_SEM_EDX__c', Specific_Service_Configuration_Object__c ='RFQISC_X_Section_SEM_EDX__c', Has_Factory_Field__c = false));

    	try {
            insert families;
        }catch(Exception e) {
            system.debug('Could not install Engineering Services Package Families: ' + e);
        }return families;
    }

    public static void installFieldDefs() {
        List<RFQI_Field_Def__c> fieldDefs = new List<RFQI_Field_Def__c>();

        fieldDefs.add(new RFQI_Field_Def__c(Name ='BLR_Test_Description__c', Object__c ='Service'));
        fieldDefs.add(new RFQI_Field_Def__c(Name ='Quantity_Service__c', Object__c ='Service', Type__c = 'Decimal'));
        fieldDefs.add(new RFQI_Field_Def__c(Name ='Sub_Total__c', Object__c ='Service', Type__c = 'Decimal'));
        fieldDefs.add(new RFQI_Field_Def__c(Name ='Component_Reliability_Test__c', Object__c ='Service'));
        fieldDefs.add(new RFQI_Field_Def__c(Name ='EM_Test_Description__c', Object__c ='Service'));
        fieldDefs.add(new RFQI_Field_Def__c(Name ='Leg_Quantity__c', Object__c ='Service'));
        fieldDefs.add(new RFQI_Field_Def__c(Name ='Imaging_Only_Selections__c', Object__c ='Service'));
        fieldDefs.add(new RFQI_Field_Def__c(Name ='Nano_Analysis_Type__c', Object__c ='Service'));
        fieldDefs.add(new RFQI_Field_Def__c(Name ='Material_Analysis_Description__c', Object__c ='Service'));
        fieldDefs.add(new RFQI_Field_Def__c(Name ='Cross_Section_SEM_EDX__c', Object__c ='Service'));
        fieldDefs.add(new RFQI_Field_Def__c(Name ='Simulation__c', Object__c ='Service'));
        fieldDefs.add(new RFQI_Field_Def__c(Name ='Substrate_Family__c'));
        fieldDefs.add(new RFQI_Field_Def__c(Name ='Service_Type__c'));
        fieldDefs.add(new RFQI_Field_Def__c(Name ='Number_of_Die__c'));
        fieldDefs.add(new RFQI_Field_Def__c(Name ='Quantity_BOM_Changes__c', Object__c ='Service', Type__c = 'Decimal'));
        fieldDefs.add(new RFQI_Field_Def__c(Name ='Quantity_Boundary_Conditions__c', Object__c ='Service', Type__c = 'Decimal'));
        fieldDefs.add(new RFQI_Field_Def__c(Name ='Quantity_Design_Changes__c', Object__c ='Service', Type__c = 'Decimal'));
        fieldDefs.add(new RFQI_Field_Def__c(Name ='Electrical_Services__c'));

        insert fieldDefs;
    }

    private static void installBase(Package_Family__c pf, Map<String, RFQI_Section__c> sections, Map<string, RFQI_Field_Def__c> fieldDefs) {
        //Sales Header
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('RFQ_Item__r.RFQ__c').Id, Sequence__c = 1000, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Sales Header').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('RFQ_Item__r.RFQ__r.RFQ_Name__c').Id, Sequence__c = 1010, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Sales Header').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('RFQ_Item__r.Package_Family__r.Name').Id, Sequence__c = 1020, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Sales Header').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('RFQ_Item__r.Status__c').Id, Sequence__c = 1030, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Sales Header').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('RFQ_Item__r.RFQ__r.SBU_Name__c').Id, Sequence__c = 1040, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Sales Header').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('RFQ_Item__r.CreatedById').Id, Sequence__c = 1050, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Sales Header').Id));

        //BU Header
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('RFQ_Item__r.RFQ__r.RFQ_Name__c').Id, Sequence__c = 1000, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('BU Header').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('RFQ_Item__r.Package_Family__r.Name').Id, Sequence__c = 1010, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('BU Header').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('RFQ_Item__r.RFQ__r.SBU_Name__c').Id, Sequence__c = 1020, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('BU Header').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('RFQ_Item__r.OwnerId').Id, Sequence__c = 1030, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('BU Header').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('RFQ_Item__r.Status__c').Id, Sequence__c = 1040, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('BU Header').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('RFQ_Item__r.Service__c').Id, Sequence__c = 1050, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('BU Header').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('RFQ_Item__r.RFQ__r.SBU_Name__r.AccountNumber').Id, Sequence__c = 1060, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('BU Header').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Customer_Project_Name__c').Id, Sequence__c = 1070, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('BU Header').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('New_Business__c').Id, Sequence__c = 1080, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('BU Header').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('RFQ_Item__r.RFQ__r.SBU_Name__r.Customer_AU_Base_fml__c').Id, Sequence__c = 1090, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('BU Header').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Customer_Device_Name__c').Id, Sequence__c = 1100, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('BU Header').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('End_Market_Segment__c').Id, Sequence__c = 1110, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('BU Header').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('RFQ_Item__r.Customer_Tier__c').Id, Sequence__c = 1120, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('BU Header').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('RFQ_Item__r.RFQ__c').Id, Sequence__c = 1130, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('BU Header').Id));
        
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Assembly_Package_Name__c').Id, Sequence__c = 500, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Body_Size_X__c').Id, Sequence__c = 510, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Body_Size_Y__c').Id, Sequence__c = 520, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Ball_Lead_Count__c').Id, Sequence__c = 1000, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('New_Business__c').Id, Sequence__c = 1010, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Sales_BU_Price__c').Id, Sequence__c = 1020, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Price_To_Customer__c').Id, Sequence__c = 1030, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Customer_Project_Name__c').Id, Sequence__c = 1040, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Customer_Device_Name__c').Id, Sequence__c = 1050, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Customer_Target_Price__c').Id, Sequence__c = 1060, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Sales_Target_Price__c').Id, Sequence__c = 1070, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('End_Market_Segment__c').Id, Sequence__c = 1080, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Competitor__c').Id, Sequence__c = 1090, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Competitor_Au_Inclusive_Price__c').Id, Sequence__c = 1100, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('HVP_Anticipated_Start_Date__c').Id, Sequence__c = 1110, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Has_Been_Quoted_Before__c').Id, Sequence__c = 1120, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Quote_Request_Type__c').Id, Sequence__c = 2200, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Decision_To_Buy__c').Id, Sequence__c = 2210, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Target_Price_Multiservice__c').Id, Sequence__c = 1105, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Quote Information').Id));

        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Customer_Target_Price__c').Id, Sequence__c = 3000, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Cost and Price').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Sales_Target_Price__c').Id, Sequence__c = 3010, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Cost and Price').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Competitor__c').Id, Sequence__c = 3020, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Cost and Price').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Competitor_Au_Inclusive_Price__c').Id, Sequence__c = 3030, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Cost and Price').Id));
        pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('BU_Price__c').Id, Sequence__c = 3040, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Cost and Price').Id));
        
        
        if(pf.Name == 'Board Level Reliability') {
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('BLR_Test_Description__c').Id, Sequence__c = 2000, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id, Default_Driver__c = true));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Quantity_Service__c').Id, Sequence__c = 2010, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id, Default_Driver__c = true));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Sub_Total__c').Id, Sequence__c = 2020, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id));
            defaultDrivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('BLR_Test_Description__c').Id, Driver_Value__c = 'Sub_Total_fml__c', Child__c = fieldDefs.get('Sub_Total__c').Id, Read__c = true));
            defaultDrivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Quantity_Service__c').Id, Driver_Value__c = 'Sub_Total_fml__c', Child__c = fieldDefs.get('Sub_Total__c').Id, Read__c = true));
        }
        if(pf.Name == 'Component Level Reliability') {
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Component_Reliability_Test__c').Id, Sequence__c = 2000, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id, Default_Driver__c = true));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Quantity_Service__c').Id, Sequence__c = 2010, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id, Default_Driver__c = true));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Sub_Total__c').Id, Sequence__c = 2020, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id));
            defaultDrivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Component_Reliability_Test__c').Id, Driver_Value__c = 'Sub_Total_fml__c', Child__c = fieldDefs.get('Sub_Total__c').Id, Read__c = true));
            defaultDrivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Quantity_Service__c').Id, Driver_Value__c = 'Sub_Total_fml__c', Child__c = fieldDefs.get('Sub_Total__c').Id, Read__c = true));
        }
        if(pf.Name == 'Electromigration Tests') {
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('EM_Test_Description__c').Id, Sequence__c = 2000, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id, Default_Driver__c = true));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Leg_Quantity__c').Id, Sequence__c = 2010, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id, Default_Driver__c = true));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Sub_Total__c').Id, Sequence__c = 2020, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id));
            defaultDrivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('EM_Test_Description__c').Id, Driver_Value__c = 'Sub_Total_fml__c', Child__c = fieldDefs.get('Sub_Total__c').Id, Read__c = true));
            defaultDrivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Leg_Quantity__c').Id, Driver_Value__c = 'Sub_Total_fml__c', Child__c = fieldDefs.get('Sub_Total__c').Id, Read__c = true));
        }
        if(pf.Name == 'Imaging only') {
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Imaging_Only_Selections__c').Id, Sequence__c = 2000, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id, Default_Driver__c = true));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Quantity_Service__c').Id, Sequence__c = 2010, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id, Default_Driver__c = true));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Sub_Total__c').Id, Sequence__c = 2020, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id));
            defaultDrivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Imaging_Only_Selections__c').Id, Driver_Value__c = 'Sub_Total_fml__c', Child__c = fieldDefs.get('Sub_Total__c').Id, Read__c = true));
            defaultDrivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Quantity_Service__c').Id, Driver_Value__c = 'Sub_Total_fml__c', Child__c = fieldDefs.get('Sub_Total__c').Id, Read__c = true));
        }
        if(pf.Name == 'Nano Materials Analysis') {
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Nano_Analysis_Type__c').Id, Sequence__c = 2000, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id, Default_Driver__c = true));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Quantity_Service__c').Id, Sequence__c = 2010, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id, Default_Driver__c = true));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Sub_Total__c').Id, Sequence__c = 2020, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id));
            defaultDrivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Nano_Analysis_Type__c').Id, Driver_Value__c = 'Sub_Total_fml__c', Child__c = fieldDefs.get('Sub_Total__c').Id, Read__c = true));
            defaultDrivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Quantity_Service__c').Id, Driver_Value__c = 'Sub_Total_fml__c', Child__c = fieldDefs.get('Sub_Total__c').Id, Read__c = true));
        }
        if(pf.Name == 'Package Materials Testing') {
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Material_Analysis_Description__c').Id, Sequence__c = 2000, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id, Default_Driver__c = true));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Quantity_Service__c').Id, Sequence__c = 2010, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id, Default_Driver__c = true));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Sub_Total__c').Id, Sequence__c = 2020, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id));
            defaultDrivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Material_Analysis_Description__c').Id, Driver_Value__c = 'Sub_Total_fml__c', Child__c = fieldDefs.get('Sub_Total__c').Id, Read__c = true));
            defaultDrivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Quantity_Service__c').Id, Driver_Value__c = 'Sub_Total_fml__c', Child__c = fieldDefs.get('Sub_Total__c').Id, Read__c = true));
        }
        if(pf.Name == 'X-Section-SEM-EDX') {
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Cross_Section_SEM_EDX__c').Id, Sequence__c = 2000, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id, Default_Driver__c = true));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Quantity_Service__c').Id, Sequence__c = 2010, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id, Default_Driver__c = true));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Sub_Total__c').Id, Sequence__c = 2020, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id));
            defaultDrivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Cross_Section_SEM_EDX__c').Id, Driver_Value__c = 'Sub_Total_fml__c', Child__c = fieldDefs.get('Sub_Total__c').Id, Read__c = true));
            defaultDrivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Quantity_Service__c').Id, Driver_Value__c = 'Sub_Total_fml__c', Child__c = fieldDefs.get('Sub_Total__c').Id, Read__c = true));
        }
        if(pf.Name == 'Mechanical' || pf.Name == 'Thermal') {
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Simulation__c').Id, Sequence__c = 2000, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id, Default_Driver__c = true));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Quantity_BOM_Changes__c').Id, Sequence__c = 2010, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id, Default_Driver__c = true));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Quantity_Boundary_Conditions__c').Id, Sequence__c = 2010, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id, Default_Driver__c = true));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Quantity_Design_Changes__c').Id, Sequence__c = 2010, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id, Default_Driver__c = true));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Sub_Total__c').Id, Sequence__c = 2020, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Service Description').Id));
            defaultDrivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Simulation__c').Id, Driver_Value__c = 'Sub_Total_fml__c', Child__c = fieldDefs.get('Sub_Total__c').Id, Read__c = true));
            defaultDrivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Quantity_BOM_Changes__c').Id, Driver_Value__c = 'Sub_Total_fml__c', Child__c = fieldDefs.get('Sub_Total__c').Id, Read__c = true));
            defaultDrivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Quantity_Boundary_Conditions__c').Id, Driver_Value__c = 'Sub_Total_fml__c', Child__c = fieldDefs.get('Sub_Total__c').Id, Read__c = true));
            defaultDrivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Quantity_Design_Changes__c').Id, Driver_Value__c = 'Sub_Total_fml__c', Child__c = fieldDefs.get('Sub_Total__c').Id, Read__c = true));
        }
        if(pf.Name == 'Design') {
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Service_Type__c').Id, Sequence__c = 2000, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Package Description').Id));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Substrate_Family__c').Id, Sequence__c = 2010, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Package Description').Id));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Lead_Count__c').Id, Sequence__c = 2010, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Package Description').Id));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Number_of_Die__c').Id, Sequence__c = 2010, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Package Description').Id));
        }
        if(pf.Name == 'Electrical Services') {
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Electrical_Services__c').Id, Sequence__c = 2000, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Package Description').Id));
            pfFields.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Package_Description_Extended__c').Id, Sequence__c = 2010, Package_Family__c = pf.Id, RFQI_Section__c = sections.get('Package Description').Id));
        }
        
    }


    public static void installServiceSection() {
        RFQI_Section__c serviceSection = new RFQI_Section__c(Name = 'Service Description', Sequence__c = 11500);
        insert serviceSection;
    }

    public static void AMK1710() {
        List<RFQI_PF_Field_Def__c> pfFieldDefs = [select Id, RFQI_Field_Def__r.Name, RFQI_Section__r.Name, CPN_Attribute__c, Include_on_Quote__c, Is_Manual_Entry__c, Package_Family__r.Name, Read_Only_If_Parent__c from RFQI_PF_Field_Def__c where Package_Family__r.Product_Group__r.Name =: 'Engineering Services'];
        Product_Group__c es = [select Id from Product_Group__c where Name =: 'Engineering Services'];
        es.Generated_Price_Requires_BU_Review__c = true;
        update es;

        List<Package_family__c> pfs = [select Id, Has_Manual_Entry_Fields__c from Package_Family__c where Product_Group__r.Name =: 'Engineering Services'];
        for(Package_Family__c pf : pfs){pf.Has_Manual_Entry_Fields__c = true;}
        update pfs;

        for (RFQI_PF_Field_Def__c field : pfFieldDefs) {
            if(field.RFQI_Section__r.Name == 'Service Description') {
                if(field.RFQI_Field_Def__r.Name != 'Sub_Total__c') {
                    field.CPN_Attribute__c = true;
                }
                field.Include_on_Quote__c = true;}
            if(field.Package_Family__r.Name == 'Design') {
                if(field.RFQI_Field_Def__r.Name == 'Service_Type__c' || field.RFQI_Field_Def__r.Name == 'Lead_Count__c' || field.RFQI_Field_Def__r.Name == 'Number_of_Die__c') {field.CPN_Attribute__c = true; field.Include_on_Quote__c = true;}
            }
            if(field.RFQI_Field_Def__r.Name == 'Sub_Total__c') {field.Is_Manual_Entry__c = true;}
            if(field.RFQI_Section__r.Name == 'Quote Information') {
                if(field.RFQI_Field_Def__r.Name == 'Assembly_Package_Name__c' || field.RFQI_Field_Def__r.Name == 'Body_Size_X__c' || field.RFQI_Field_Def__r.Name == 'Body_Size_Y__c' || field.RFQI_Field_Def__r.Name == 'Ball_Lead_Count__c') {field.Read_Only_If_Parent__c = true; field.Include_on_Quote__c = true; field.CPN_Attribute__c = true;}
                if(field.RFQI_Field_Def__r.Name == 'Customer_Project_Name__c' || field.RFQI_Field_Def__r.Name == 'Customer_Device_Name__c' || field.RFQI_Field_Def__r.Name == 'HVP_Anticipated_Start_Date__c') {field.Include_on_Quote__c = true;}
            }

        }
        update pfFieldDefs;


    }

    public static void AMK1726() {
        List<RFQI_Field_Def__c> newFields = new List<RFQI_Field_Def__c>();
        newFields.add(new RFQI_Field_Def__c(Name='Substrate__c'));
        newFields.add(new RFQI_Field_Def__c(Name='Number_of_Balls__c'));
        newFields.add(new RFQI_Field_Def__c(Name='Number_of_Wirebonds__c'));
        newFields.add(new RFQI_Field_Def__c(Name='Design_Request_Number__c'));
        newFields.add(new RFQI_Field_Def__c(Name='Number_of_Signal_Wirebonds__c'));
        newFields.add(new RFQI_Field_Def__c(Name='Number_of_Signal_Bumps__c'));
        newFields.add(new RFQI_Field_Def__c(Name='Number_of_Power_Domains__c'));
        newFields.add(new RFQI_Field_Def__c(Name='Bus_Width__c'));
        newFields.add(new RFQI_Field_Def__c(Name='Simulation_Direction__c'));
        newFields.add(new RFQI_Field_Def__c(Name='Process_Corner__c'));
        newFields.add(new RFQI_Field_Def__c(Name='Time_or_Frequency_Domain__c'));
        newFields.add(new RFQI_Field_Def__c(Name='Number_of_Lanes__c'));
        newFields.add(new RFQI_Field_Def__c(Name='Simulation_Direction_SLA__c'));
        newFields.add(new RFQI_Field_Def__c(Name='Buffer_Model_Type__c'));
        newFields.add(new RFQI_Field_Def__c(Name='Number_of_Bumps_PK__c'));

        insert newFields;


        List<RFQI_PF_Field_Def__c> pfFieldDefs = [select Id, Belongs_To_Section__c, Default_Driver__c, Other_Fields__c, RFQI_Section__r.Name, RFQI_Field_Def__r.Name, RFQI_Section__c from RFQI_PF_Field_Def__c where Package_Family__r.Name =:'Electrical Services'];
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'Electrical Services'];
        Map<String, RFQI_Section__c> sections = FieldBuilderHelper.getSectionMap();
        Map<string, RFQI_Field_Def__c> fieldDefs = FieldBuilderHelper.getFieldDefs();

        for(RFQI_PF_Field_Def__c field : pfFieldDefs) {
            if(field.RFQI_Field_Def__r.Name == 'Package_Description_Extended__c') {
                field.RFQI_Section__c = null;
                field.Belongs_To_Section__c = 'Package Description';
            }
            if(field.RFQI_Field_Def__r.Name == 'BU_Price__c') {
                field.Is_Manual_Entry__c = true;
            }
        }

        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Substrate__c').Id, Sequence__c = 2020, Package_Family__c = pf.Id, CPN_Attribute__c = true, Include_on_Quote__c = true, Belongs_To_Section__c = 'Package Description', Default_Driver__c = true));

        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Number_of_Die__c').Id, Sequence__c = 2030, Package_Family__c = pf.Id, CPN_Attribute__c = true, Include_on_Quote__c = true, Belongs_To_Section__c = 'Package Description', Default_Driver__c = true));
        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Number_of_Balls__c').Id, Sequence__c = 2040, Package_Family__c = pf.Id, CPN_Attribute__c = true, Include_on_Quote__c = true, Belongs_To_Section__c = 'Package Description', Default_Driver__c = true));
        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Number_of_Wirebonds__c').Id, Sequence__c = 2050, Package_Family__c = pf.Id, CPN_Attribute__c = true, Include_on_Quote__c = true, Belongs_To_Section__c = 'Package Description', Default_Driver__c = true));
        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Number_of_Bumps_PK__c').Id, Sequence__c = 2070, Package_Family__c = pf.Id, CPN_Attribute__c = true, Include_on_Quote__c = true, Belongs_To_Section__c = 'Package Description', Default_Driver__c = true));

        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Number_of_Layers__c').Id, Sequence__c = 2080, Package_Family__c = pf.Id, CPN_Attribute__c = true, Include_on_Quote__c = true, Belongs_To_Section__c = 'Package Description', Default_Driver__c = true));
        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Number_of_Signal_Wirebonds__c').Id, Sequence__c = 2090, Package_Family__c = pf.Id, CPN_Attribute__c = true, Include_on_Quote__c = true, Belongs_To_Section__c = 'Package Description', Default_Driver__c = true));
        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Number_of_Signal_Bumps__c').Id, Sequence__c = 2100, Package_Family__c = pf.Id, CPN_Attribute__c = true, Include_on_Quote__c = true, Belongs_To_Section__c = 'Package Description', Default_Driver__c = true));

        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Number_of_Power_Domains__c').Id, Sequence__c = 2110, Package_Family__c = pf.Id, CPN_Attribute__c = true, Include_on_Quote__c = true, Belongs_To_Section__c = 'Package Description', Default_Driver__c = true));

        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Bus_Width__c').Id, Sequence__c = 2120, Package_Family__c = pf.Id, CPN_Attribute__c = true, Include_on_Quote__c = true, Belongs_To_Section__c = 'Package Description', Default_Driver__c = true));
        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Simulation_Direction__c').Id, Sequence__c = 2130, Package_Family__c = pf.Id, CPN_Attribute__c = true, Include_on_Quote__c = true, Belongs_To_Section__c = 'Package Description', Default_Driver__c = true));
        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Process_Corner__c').Id, Sequence__c = 2140, Package_Family__c = pf.Id, CPN_Attribute__c = true, Include_on_Quote__c = true, Belongs_To_Section__c = 'Package Description', Default_Driver__c = true));

        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Time_or_Frequency_Domain__c').Id, Sequence__c = 2105, Package_Family__c = pf.Id, CPN_Attribute__c = true, Include_on_Quote__c = true, Belongs_To_Section__c = 'Package Description', Default_Driver__c = true));

        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Number_of_Lanes__c').Id, Sequence__c = 2120, Package_Family__c = pf.Id, CPN_Attribute__c = true, Include_on_Quote__c = true, Belongs_To_Section__c = 'Package Description', Default_Driver__c = true));
        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Simulation_Direction_SLA__c').Id, Sequence__c = 2130, Package_Family__c = pf.Id, CPN_Attribute__c = true, Include_on_Quote__c = true, Belongs_To_Section__c = 'Package Description', Default_Driver__c = true));
        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Buffer_Model_Type__c').Id, Sequence__c = 2140, Package_Family__c = pf.Id, CPN_Attribute__c = true, Include_on_Quote__c = true, Belongs_To_Section__c = 'Package Description', Default_Driver__c = true));

        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDefs.get('Design_Request_Number__c').Id, Sequence__c = 2200, Package_Family__c = pf.Id, CPN_Attribute__c = true, Include_on_Quote__c = true, Belongs_To_Section__c = 'Package Description'));


        upsert pfFieldDefs;

        FCCSPInstaller.updateOtherFields();
    }






}