/*************************************************************************
* 
* PURPOSE:  This class seeds fresh RFQ Item Field Definition specifically
*           for the MLF package families (cloned from SOIC150Installer
*           for the purposes of generalization)
*         
* CLASS: MLFInstaller
* CREATED: 03/26/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
global class MLFInstaller {
    /**
    * This method houses all of the install methods further defined later in code
    */ 
    global static void install() {
        FieldBuilderHelper.clean('MLF');
        FieldBuilderHelper.installProductGroup('MLF');
        installMLFPackageFamilies();
        installFieldDefs('Punch Single Row DFN');
        installFieldDefs('Punch Dual Row MLF');
        installFieldDefs('Punch Single Row MLF');
        installFieldDefs('Saw Single Row DFN');
        installFieldDefs('Saw Dual Row MLF');
        installFieldDefs('Saw Single Row MLF');
        FieldBuilderHelper.deleteProductgroupDefaultDriver('MLF');
        installDrivers();
    }
    
    private static void installDrivers() {
        installPunchSRDFNDefaultDrivers();
        installPunchDRMLFDeFaultDrivers();
        installPunchSRMLFDefaultDrivers();
        installSawDFNDeFaultDrivers();
        installSawDRMLFDeFaultDrivers();
        installSawSRMLFDefaultDrivers();
    }
    
    
     public static void updateSapFields() {
    	RFQAdminInstaller.updateSapFieldsForProductGroup('MLF'); 
    }
    
    /**
    * This method installs MLF Package Families
    *
    * @returns a list of package families
    */
    private static List<Package_Family__c> installMLFPackageFamilies() {
        
        Product_Group__c prodGroup = [select Id from Product_Group__c where Name =: 'MLF'];
        
        //Install Cost_Model_Implementation as QuadLeadframeInstaller and DualLeadframeInstaller
        Product_Group__c uPg = new Product_Group__c(id=prodGroup.id);
        uPg.Cost_Model_Implementation__c = 'CMMLFBuilder';
        uPg.Wire_Calculation_Implementation__c = 'CMMLFWireCalc';
        uPg.Generated_Price_Requires_BU_Review__c = true;
        update uPg;
        
        List<Package_Family__c> families = new List<Package_Family__c>();
        
        FieldBuilderHelper.addPf('Punch Single Row DFN', prodGroup, 'RFQI_PUNCH_SINGLE_ROW_DFN__c', 'RFQIWC_PUNCH_SINGLE_ROW_DFN__c', 'RFQIDC_PUNCH_SINGLE_ROW_DFN__c', families, true);
        FieldBuilderHelper.addPf('Punch Dual Row MLF', prodGroup, 'RFQI_PUNCH_DUAL_ROW_MLF__c', 'RFQIWC_PUNCH_DUAL_ROW_MLF__c', 'RFQIDC_PUNCH_DUAL_ROW_MLF__c', families, true);
        FieldBuilderHelper.addPf('Punch Single Row MLF', prodGroup, 'RFQI_PUNCH_SINGLE_ROW_MLF__c', 'RFQIWC_PUNCH_SINGLE_ROW_MLF__c', 'RFQIDC_PUNCH_SINGLE_ROW_MLF__c', families, true);
        FieldBuilderHelper.addPf('Saw Single Row DFN', prodGroup, 'RFQI_SAW_SINGLE_ROW_DFN__c', 'RFQIWC_SAW_SINGLE_ROW_DFN__c', 'RFQIDC_SAW_SINGLE_ROW_DFN__c', families, true);
        FieldBuilderHelper.addPf('Saw Dual Row MLF', prodGroup, 'RFQI_SAW_DUAL_ROW_MLF__c', 'RFQIWC_SAW_DUAL_ROW_MLF__c', 'RFQIDC_SAW_DUAL_ROW_MLF__c', families, true);
        FieldBuilderHelper.addPf('Saw Single Row MLF', prodGroup, 'RFQI_SAW_SINGLE_ROW_MLF__c', 'RFQIWC_SAW_SINGLE_ROW_MLF__c', 'RFQIDC_SAW_SINGLE_ROW_MLF__c', families, true);
        try {
            insert families;
        }catch(Exception e) {
            system.debug('Could not install MLF Package Families: ' + e);
        }
        return families;
    }
    
    private static void installPunchSRDFNDefaultDrivers() {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'Punch Single Row DFN'];
        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
            }
        List<RFQI_Default_Driver__c> drivers = new List<RFQI_Default_Driver__c>();
        
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Prototype__c'), 'true', fieldDefs.get('Forecast__c'), '< 200');
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Prototype__c'), 'true', fieldDefs.get('Annual_Volume__c'), '25');  

        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '8-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '8'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '8-1.27', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '8'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '10-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '10'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '12-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '12'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '02x03', Child__c = fieldDefs.get('Packing_Method__c').Id, Child_Value__c = 'Canisters'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '05x06', Child__c = fieldDefs.get('Packing_Method__c').Id, Child_Value__c = 'Tubes'));

        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '02x03', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '1.0'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '03x03', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '1.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '05x06', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '3.5'));
        insert drivers;
    }
    
    private static void installPunchDRMLFDefaultDrivers() {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'Punch Dual Row MLF'];
        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
            }
        List<RFQI_Default_Driver__c> drivers = new List<RFQI_Default_Driver__c>();
        
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Prototype__c'), 'true', fieldDefs.get('Forecast__c'), '< 200'); 
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Prototype__c'), 'true', fieldDefs.get('Annual_Volume__c'), '25'); 

        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '76-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '76'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '84-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '84'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '100-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '100'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '108-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '108'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '116-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '116'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '124-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '124'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '132-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '132'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '140-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '140'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '148-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '148'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '156-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '156'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '164-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '164'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '172-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '172'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '180-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '180'));

        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '08x08', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '4.6'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '09x09', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '5.6'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '10x10', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '6.6'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '11x11', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '7.6'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '12x12', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '8.6'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '13x13', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '9.6'));

        insert drivers;
    }
    
    private static void installPunchSRMLFDefaultDrivers() {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'Punch Single Row MLF'];
        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
            }
        List<RFQI_Default_Driver__c> drivers = new List<RFQI_Default_Driver__c>();
        
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Prototype__c'), 'true', fieldDefs.get('Forecast__c'), '< 200'); 
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Prototype__c'), 'true', fieldDefs.get('Annual_Volume__c'), '25'); 

        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '4-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '4'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '8-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '8'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '8-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '8'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '12-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '12'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '12-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '12'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '12-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '12'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '16-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '16'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '16-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '16'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '16-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '16'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '16-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '16'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '18-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '18'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '20-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '20'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '20-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '20'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '20-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '20'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '20-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '20'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '24-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '24'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '24-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '24'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '24-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '24'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '28-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '28'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '28-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '28'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '28-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '28'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '28-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '28'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '32-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '32'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '32-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '32'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '32-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '32'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '32-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '32'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '36-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '36'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '36-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '36'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '36-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '36'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '40-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '40'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '40-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '40'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '40-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '40'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '40-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '40'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '42-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '42'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '44-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '44'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '44-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '44'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '44-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '44'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '48-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '48'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '48-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '48'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '48-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '48'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '48-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '48'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '52-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '52'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '52-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '52'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '52-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '52'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '56-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '56'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '56-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '56'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '56-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '56'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '60-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '60'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '60-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '60'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '60-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '60'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '64-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '64'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '64-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '64'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '68-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '68'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '68-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '68'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '72-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '72'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '76-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '76'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '80-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '80'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '84-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '84'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '88-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '88'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '88-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '88'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '96-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '96'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '100-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '100'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '108-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '108'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '124-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '124'));
        

        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '03x03', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '1.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '04x04', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '2.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '05x05', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '3.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '05x06', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '3.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '06x06', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '4.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '07x07', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '5.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '08x08', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '6.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '09x09', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '7.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '10x10', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '8.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '12x12', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '10.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '13x13', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '11.5'));

        insert drivers;         
    }
    
    private static void installSawDFNDefaultDrivers() {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'Saw Single Row DFN'];
        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
            }
        List<RFQI_Default_Driver__c> drivers = new List<RFQI_Default_Driver__c>();
        
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Prototype__c'), 'true', fieldDefs.get('Forecast__c'), '< 200'); 
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Prototype__c'), 'true', fieldDefs.get('Annual_Volume__c'), '25'); 

        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '8-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '8'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '8-1.27', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '8'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '10-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '10'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '12-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '12'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '02x03', Child__c = fieldDefs.get('Packing_Method__c').Id, Child_Value__c = 'Canisters'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '05x06', Child__c = fieldDefs.get('Packing_Method__c').Id, Child_Value__c = 'Tubes'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '02x03', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '1.0'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '03x03', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '1.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '05x06', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '3.5'));

        insert drivers;
    }
    
    private static void installSawDRMLFDefaultDrivers() {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'Saw Dual Row MLF'];
        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
            }
        List<RFQI_Default_Driver__c> drivers = new List<RFQI_Default_Driver__c>();
        
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Prototype__c'), 'true', fieldDefs.get('Forecast__c'), '< 200'); 
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Prototype__c'), 'true', fieldDefs.get('Annual_Volume__c'), '25'); 

        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '36-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '36'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '44-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '44'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '52-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '52'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '60-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '60'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '68-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '68'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '76-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '76'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '84-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '84'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '100-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '100'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '05x05', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '1.6'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '06x06', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '2.6'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '07x07', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '3.6'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '08x08', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '4.6'));
        insert drivers;   
    }
    
    private static void installSawSRMLFDefaultDrivers() {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'Saw Single Row MLF'];
        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
            }
        List<RFQI_Default_Driver__c> drivers = new List<RFQI_Default_Driver__c>();
        
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Prototype__c'), 'true', fieldDefs.get('Forecast__c'), '< 200'); 
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Prototype__c'), 'true', fieldDefs.get('Annual_Volume__c'), '25'); 

        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '4-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '4'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '8-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '8'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '8-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '8'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '12-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '12'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '12-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '12'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '12-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '12'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '16-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '16'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '16-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '16'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '16-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '16'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '16-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '16'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '18-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '18'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '20-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '20'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '20-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '20'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '20-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '20'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '20-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '20'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '24-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '24'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '24-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '24'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '24-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '24'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '28-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '28'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '28-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '28'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '28-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '28'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '28-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '28'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '32-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '32'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '32-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '32'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '32-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '32'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '32-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '32'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '36-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '36'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '36-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '36'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '36-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '36'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '40-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '40'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '40-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '40'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '40-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '40'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '40-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '40'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '42-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '42'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '44-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '44'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '44-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '44'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '44-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '44'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '48-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '48'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '48-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '48'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '48-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '48'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '48-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '48'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '52-0.80', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '52'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '52-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '52'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '52-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '52'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '56-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '56'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '56-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '56'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '56-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '56'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '60-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '60'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '60-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '60'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '60-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '60'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '64-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '64'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '64-0.65', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '64'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '68-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '68'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '68-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '68'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '72-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '72'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '76-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '76'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '84-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '84'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '88-0.50', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '88'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '88-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '88'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '100-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '100'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Lead_Pitch__c').Id, Driver_Value__c = '108-0.40', Child__c = fieldDefs.get('Number_Of_Wires__c').Id, Child_Value__c = '108'));

        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '03x03', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '1.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '04x04', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '2.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '05x05', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '3.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '05x06', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '3.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '06x06', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '4.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '07x07', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '5.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '08x08', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '6.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '09x09', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '7.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '10x10', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '8.5'));
        drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = fieldDefs.get('Body_Size__c').Id, Driver_Value__c = '12x12', Child__c = fieldDefs.get('Max_Die__c').Id, Child_Value__c = '10.5'));
        insert drivers;
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
        helper.add('Cost and Price','Package_Item_Value__c',1150,false,true);
        helper.add('Cost and Price','Manufacturing_Overhead__c',1160,false,true);
        helper.add('Cost and Price','Materials_As_Perc_Cost__c',1170,false,true);
        helper.add('Cost and Price','QA_Cost__c',1180,false,true);
        helper.add('Cost and Price','Total_Cost__c',1190,false,true);
        helper.add('Cost and Price','Variable_Costs__c',1200,false,true);
        helper.add('Cost and Price','Service_Group_Cost__c',1210,false,true);
        helper.add('Cost and Price','Adder_Cost__c',1220,false,true);
        helper.add('Cost and Price','Fixed_Costs__c',1230,false,true);         
        //End Adding Cost and Price section for BUs 


        //End Adding Cost and Price section for BUs     
        
        helper.add('Quote Information', 'New_Business__c', 1000);
        helper.add('Quote Information', 'Sales_BU_Price__c', 1010);
        helper.add('Quote Information', 'Price_To_Customer__c', 1020);
        helper.add('Quote Information', 'Automotive__c', 1030);
        helper.add('Quote Information', 'ITAR__c', 1040);
        helper.add('Quote Information', 'EAR__c', 1050);
        helper.add('Quote Information', 'Customer_Project_Name__c', 1060);
        helper.add('Quote Information', 'Customer_Device_Name__c', 1070); 
        helper.add('Quote Information', 'Annual_Volume__c', 1080);
        helper.add('Quote Information', 'Forecast__c', 1090, true, false, true);
        helper.add('Quote Information', 'Prototype__c', 1100, true, false, false, true);
        helper.add('Quote Information', 'Customer_Target_Price__c', 1110);
        helper.add('Quote Information', 'Sales_Target_Price__c', 1120);
        helper.add('Quote Information', 'End_Market_Segment__c', 1130);
        helper.add('Quote Information', 'Competitor__c', 1140);
        helper.add('Quote Information', 'Competitor_Au_Inclusive_Price__c', 1150);
        helper.add('Quote Information', 'HVP_Anticipated_Start_Date__c', 1160);
        helper.add('Quote Information', 'Has_Been_Quoted_Before__c', 1170);

            
        helper.add('Package Description', 'Body_Size__c', 2000, true, false, true, true);
        helper.add('Package Description', 'Body_X__c', 2010);
        helper.add('Package Description', 'Body_Y__c', 2020);
        helper.add('Package Description', 'Body_Size_Z__c', 2030, true);
        helper.add('Package Description', 'Lead_Pitch__c', 2040, false, false, true, true, 'Lead_Pitch_Other__c');
        helper.add('Package Description', 'Lead_Count__c', 2050, true, false, false, true);
        helper.add('Package Description', 'Pitch__c', 2060, true, false);
        helper.add('Package Description', 'Frame_Finish__c', 2070, true);
        helper.add('Package Description', 'Mold_Compound__c', 2080, true);
        //helper.add('Package Description', 'Factory__c', 2090, false, false, true);
        helper.add('Package Description', 'Packing_Method__c', 2100, true);
        helper.add('Package Description', 'External_Finish__c', 2100, true);

        helper.add('Wire Description', 'Wire_Configuration__c', 3000, true, false, true);
        helper.add('Wire Description', 'Wire_Material__c',   3000, true, false, true);
        helper.add('Wire Description', 'Wire_Diameter__c',   3020, true, false, true);
        helper.add('Wire Description', 'Number_Of_Wires__c', 3030, true, false, true);   
        helper.add('Wire Description', 'Average_2D_Wire_Length__c', 3040);
        helper.add('Wire Description', 'Total_2D_Wire_Length__c', 3050);
        helper.add('Wire Description', 'Total_3D_Wire_Length__c', 3060, true);
        helper.add('Wire Description', 'Au_Factor__c', 3070, true);
        
        helper.add('Die Description', 'Max_Die__c', 3000, true);
        helper.add('Die Description', 'Die_Size_X__c', 3010, true, false, false, false, '', true);
        helper.add('Die Description', 'Die_Size_Y__c', 3020, true, false, false, false, '', true);
        helper.add('Die Description', 'Die_Attach__c', 3030, true);
        helper.add('Die Description', 'Wafer_Material__c', 3040, true); 
        helper.add('Die Description', 'Wafer_Size__c', 3050, true, false, false, false, '', true);
        helper.add('Die Description', 'Wafer_Technology__c', 3060, true);
        helper.add('Die Description', 'Wafer_Thickness__c', 3070, true);
                
        helper.add('Adders', 'Plasma_Before_Die_Attach__c', 4000, true);
        helper.add('Adders', 'Plasma_Before_Wire_Bond__c', 4010, true);
        helper.add('Adders', 'Plasma_Before_Mold__c', 4020, true);
        helper.add('Adders', 'X2_OPT_INSP_100__c', 4030, true);
        helper.add('Adders', 'X3RD_OPT_QA_GATE__c', 4040, true);
        helper.add('Adders', 'FVI_100__c', 4050, true);
        helper.add('Adders', 'X3RD_OPT_100__c', 4060, true);
        helper.add('Adders', 'Bake_Dry_Pack__c', 4070, true);
        helper.add('Adders', 'Temperature_Cycle__c', 4080, true);
        helper.add('Adders', 'Bake__c', 4090, true);
                                                    
        helper.insertFields();
        
        return helper.getPfFieldDefs();                   
    }
}