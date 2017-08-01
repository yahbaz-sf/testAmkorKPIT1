/*************************************************************************
* 
* PURPOSE:  This class seeds fresh RFQ Item Field Definition specifically
*           for the quad leadframe package families (cloned from SOIC150Installer
*           for the purposes of generalization)
*         
* CLASS: QuadLeadframeInstaller
* CREATED: 03/22/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
global class QuadLeadframeInstaller {

    public static List<RFQI_Default_Driver__c> drivers {get; set;}
    /*
    * This method houses all of the install methods further defined later in code
    */
    global static void install() {
        
        FieldBuilderHelper.clean('Quad Leadframe');
        FieldBuilderHelper.installProductGroup('Quad Leadframe');
        installQuadLeadFramePackageFamilies();
        installFieldDefs('TQFP');
        installFieldDefs('LQFP');
        installFieldDefs('MQFP');
        installFieldDefs('PLCC');
        installFieldDefs('PowerQuad 4');
        installFieldDefs('tsCSP');
        installFieldDefs('MQFP W/ Heat Spreader');
        installFieldDefs('Fusion Quad');
        installFieldDefs('MQFP W/ FCIR');
        FieldBuilderHelper.deleteProductgroupDefaultDriver('Quad Leadframe');
        installDefaultDrivers();    
    }
    
    public static void installDefaultDrivers() {
        
        List<Package_Family__c> pf = [select Name, Id from Package_Family__c where Product_Group__r.Name =: 'Quad Leadframe'];
        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 

        for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
        }

        drivers = new List<RFQI_Default_Driver__c>();

        for(Package_Family__c packagefamilies : pf) {
            FieldBuilderHelper.installDefaultDrivers(packagefamilies, fieldDefs.get('Prototype__c'), 'true', fieldDefs.get('Forecast__c'), '< 50', drivers);
        }

        installTQFPDrivers(fieldDefs);
        installLQFPDrivers(fieldDefs);
        

        installMQFPDefaultDrivers(fieldDefs);
        installMQFPHSDefaultDrivers(fieldDefs);
        installPowerQuad4DefaultDrivers(fieldDefs);
        installPLCCDrivers(fieldDefs);

        insert drivers;
        
    }

    private static void installMQFPDefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'MQFP'];

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '10x10', fieldDefs.get('Leadframe_NRE__c'), '15000', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '14x14', fieldDefs.get('Leadframe_NRE__c'), '15000', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '14x20', fieldDefs.get('Leadframe_NRE__c'), '15000', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '28x28', fieldDefs.get('Leadframe_NRE__c'), '20000', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '32x32', fieldDefs.get('Leadframe_NRE__c'), '20000', drivers);

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '44', fieldDefs.get('Number_of_FWD_Wires__c'), '44', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '52', fieldDefs.get('Number_of_FWD_Wires__c'), '52', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '64', fieldDefs.get('Number_of_FWD_Wires__c'), '64', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '80', fieldDefs.get('Number_of_FWD_Wires__c'), '80', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '100', fieldDefs.get('Number_of_FWD_Wires__c'), '100', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '120', fieldDefs.get('Number_of_FWD_Wires__c'), '120', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '128', fieldDefs.get('Number_of_FWD_Wires__c'), '128', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '144', fieldDefs.get('Number_of_FWD_Wires__c'), '144', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '160', fieldDefs.get('Number_of_FWD_Wires__c'), '160', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '208', fieldDefs.get('Number_of_FWD_Wires__c'), '208', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '240', fieldDefs.get('Number_of_FWD_Wires__c'), '240', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '256', fieldDefs.get('Number_of_FWD_Wires__c'), '256', drivers);


        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '44', fieldDefs.get('Number_of_Wires__c'), '44', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '52', fieldDefs.get('Number_of_Wires__c'), '52', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '64', fieldDefs.get('Number_of_Wires__c'), '64', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '80', fieldDefs.get('Number_of_Wires__c'), '80', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '100', fieldDefs.get('Number_of_Wires__c'), '100', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '120', fieldDefs.get('Number_of_Wires__c'), '120', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '128', fieldDefs.get('Number_of_Wires__c'), '128', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '144', fieldDefs.get('Number_of_Wires__c'), '144', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '160', fieldDefs.get('Number_of_Wires__c'), '160', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '208', fieldDefs.get('Number_of_Wires__c'), '208', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '240', fieldDefs.get('Number_of_Wires__c'), '240', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '256', fieldDefs.get('Number_of_Wires__c'), '256', drivers);



    }
    private static void installMQFPHSDefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'MQFP W/ Heat Spreader'];

            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '14x14', fieldDefs.get('Leadframe_NRE__c'), '15000', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '14x20', fieldDefs.get('Leadframe_NRE__c'), '15000', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '28x28', fieldDefs.get('Leadframe_NRE__c'), '20000', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '32x32', fieldDefs.get('Leadframe_NRE__c'), '20000', drivers);

            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '52', fieldDefs.get('Number_of_FWD_Wires__c'), '52', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '64', fieldDefs.get('Number_of_FWD_Wires__c'), '64', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '80', fieldDefs.get('Number_of_FWD_Wires__c'), '80', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '100', fieldDefs.get('Number_of_FWD_Wires__c'), '100', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '120', fieldDefs.get('Number_of_FWD_Wires__c'), '120', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '128', fieldDefs.get('Number_of_FWD_Wires__c'), '128', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '144', fieldDefs.get('Number_of_FWD_Wires__c'), '144', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '160', fieldDefs.get('Number_of_FWD_Wires__c'), '160', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '208', fieldDefs.get('Number_of_FWD_Wires__c'), '208', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '240', fieldDefs.get('Number_of_FWD_Wires__c'), '240', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '256', fieldDefs.get('Number_of_FWD_Wires__c'), '256', drivers);

            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '52', fieldDefs.get('Number_of_Wires__c'), '52', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '64', fieldDefs.get('Number_of_Wires__c'), '64', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '80', fieldDefs.get('Number_of_Wires__c'), '80', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '100', fieldDefs.get('Number_of_Wires__c'), '100', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '120', fieldDefs.get('Number_of_Wires__c'), '120', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '128', fieldDefs.get('Number_of_Wires__c'), '128', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '144', fieldDefs.get('Number_of_Wires__c'), '144', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '160', fieldDefs.get('Number_of_Wires__c'), '160', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '208', fieldDefs.get('Number_of_Wires__c'), '208', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '240', fieldDefs.get('Number_of_Wires__c'), '240', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '256', fieldDefs.get('Number_of_Wires__c'), '256', drivers);

    }

    private static void installPowerQuad4DefaultDrivers(Map<String, RFQI_Field_Def__c> fieldDefs) {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'Fusion Quad'];

            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '28x28', fieldDefs.get('Leadframe_NRE__c'), '20000', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '32x32', fieldDefs.get('Leadframe_NRE__c'), '20000', drivers);

            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '128', fieldDefs.get('Number_of_FWD_Wires__c'), '128', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '144', fieldDefs.get('Number_of_FWD_Wires__c'), '144', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '160', fieldDefs.get('Number_of_FWD_Wires__c'), '160', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '208', fieldDefs.get('Number_of_FWD_Wires__c'), '208', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '240', fieldDefs.get('Number_of_FWD_Wires__c'), '240', drivers);


            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '128', fieldDefs.get('Number_of_Wires__c'), '128', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '144', fieldDefs.get('Number_of_Wires__c'), '144', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '160', fieldDefs.get('Number_of_Wires__c'), '160', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '208', fieldDefs.get('Number_of_Wires__c'), '208', drivers);
            FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '240', fieldDefs.get('Number_of_Wires__c'), '240', drivers);

    } 
    
    private static void installTQFPDrivers(Map<String, RFQI_Field_Def__c> fieldDefs)
    {

        //public static void installDefaultDrivers(Package_Family__c pf, RFQI_Field_Def__c driver, string driverVal, RFQI_Field_Def__c child, string childVal) {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'TQFP'];

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '5x5',   fieldDefs.get('Die_Size_X__c'), '2.35368', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '7x7',   fieldDefs.get('Die_Size_X__c'), '3.11643360000001', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '10x10', fieldDefs.get('Die_Size_X__c'), '3.77938267716537', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '12x12', fieldDefs.get('Die_Size_X__c'), '4.28014492753623', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '14x14', fieldDefs.get('Die_Size_X__c'), '4.1819582608696', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '16x16', fieldDefs.get('Die_Size_X__c'), '4.452', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '20x20', fieldDefs.get('Die_Size_X__c'), '4.71822661870505', drivers);
        //FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '24x24', fieldDefs.get('Die_Size_X__c'), '4.94788', drivers);
        //FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '28x28', fieldDefs.get('Die_Size_X__c'), '5.80045454545454', drivers);

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '5x5',   fieldDefs.get('Die_Size_Y__c'), '2.35368', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '7x7',   fieldDefs.get('Die_Size_Y__c'), '3.12119360000001', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '10x10', fieldDefs.get('Die_Size_Y__c'), '3.6749261417323', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '12x12', fieldDefs.get('Die_Size_Y__c'), '4.34101449275362', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '14x14', fieldDefs.get('Die_Size_Y__c'), '4.18731478260873', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '16x16', fieldDefs.get('Die_Size_Y__c'), '4.452', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '20x20', fieldDefs.get('Die_Size_Y__c'), '4.52925179856116', drivers);
        //FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '24x24', fieldDefs.get('Die_Size_Y__c'), '4.95418', drivers);
        //FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '28x28', fieldDefs.get('Die_Size_Y__c'), '6.02190909090909', drivers);

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '5x5',   fieldDefs.get('Average_2D_Wire_Length__c'), '1.54252822603543', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '7x7',   fieldDefs.get('Average_2D_Wire_Length__c'), '1.67001151860305', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '10x10', fieldDefs.get('Average_2D_Wire_Length__c'), '1.81', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '12x12', fieldDefs.get('Average_2D_Wire_Length__c'), '1.95762294429922', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '14x14', fieldDefs.get('Average_2D_Wire_Length__c'), '1.97996484884476', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '16x16', fieldDefs.get('Average_2D_Wire_Length__c'), '2.17', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '20x20', fieldDefs.get('Average_2D_Wire_Length__c'), '2.35891128360155', drivers);
        //FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '24x24', fieldDefs.get('Average_2D_Wire_Length__c'), '2.52704636894044', drivers);
        //FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '28x28', fieldDefs.get('Average_2D_Wire_Length__c'), '2.79809548373087', drivers);

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '5x5', fieldDefs.get('Leadframe_NRE__c'), '10000', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '7x7', fieldDefs.get('Leadframe_NRE__c'), '10000', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '10x10', fieldDefs.get('Leadframe_NRE__c'), '10000', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '12x12', fieldDefs.get('Leadframe_NRE__c'), '14000', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '14x14', fieldDefs.get('Leadframe_NRE__c'), '14000', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '16x16', fieldDefs.get('Leadframe_NRE__c'), '15000', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '20x20', fieldDefs.get('Leadframe_NRE__c'), '16000', drivers);


        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '32', fieldDefs.get('Number_of_FWD_Wires__c'), '32', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '40', fieldDefs.get('Number_of_FWD_Wires__c'), '40', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '48', fieldDefs.get('Number_of_FWD_Wires__c'), '48', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '64', fieldDefs.get('Number_of_FWD_Wires__c'), '64', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '44', fieldDefs.get('Number_of_FWD_Wires__c'), '44', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '52', fieldDefs.get('Number_of_FWD_Wires__c'), '52', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '80', fieldDefs.get('Number_of_FWD_Wires__c'), '80', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '100', fieldDefs.get('Number_of_FWD_Wires__c'), '100', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '120', fieldDefs.get('Number_of_FWD_Wires__c'), '120', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '128', fieldDefs.get('Number_of_FWD_Wires__c'), '128', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '144', fieldDefs.get('Number_of_FWD_Wires__c'), '144', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '176', fieldDefs.get('Number_of_FWD_Wires__c'), '176', drivers);

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '32', fieldDefs.get('Number_of_Wires__c'), '32', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '40', fieldDefs.get('Number_of_Wires__c'), '40', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '48', fieldDefs.get('Number_of_Wires__c'), '48', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '64', fieldDefs.get('Number_of_Wires__c'), '64', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '44', fieldDefs.get('Number_of_Wires__c'), '44', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '52', fieldDefs.get('Number_of_Wires__c'), '52', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '80', fieldDefs.get('Number_of_Wires__c'), '80', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '100', fieldDefs.get('Number_of_Wires__c'), '100', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '120', fieldDefs.get('Number_of_Wires__c'), '120', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '128', fieldDefs.get('Number_of_Wires__c'), '128', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '144', fieldDefs.get('Number_of_Wires__c'), '144', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '176', fieldDefs.get('Number_of_Wires__c'), '176', drivers);



    }
    
    private static void installLQFPDrivers(Map<String, RFQI_Field_Def__c> fieldDefs)
    {

        //public static void installDefaultDrivers(Package_Family__c pf, RFQI_Field_Def__c driver, string driverVal, RFQI_Field_Def__c child, string childVal) {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'LQFP'];

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '5x5',   fieldDefs.get('Die_Size_X__c'), '2.35368', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '7x7',   fieldDefs.get('Die_Size_X__c'), '3.11643360000001', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '10x10', fieldDefs.get('Die_Size_X__c'), '3.77938267716537', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '12x12', fieldDefs.get('Die_Size_X__c'), '4.28014492753623', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '14x14', fieldDefs.get('Die_Size_X__c'), '4.1819582608696', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '16x16', fieldDefs.get('Die_Size_X__c'), '4.452', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '20x20', fieldDefs.get('Die_Size_X__c'), '4.71822661870505', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '24x24', fieldDefs.get('Die_Size_X__c'), '4.94788', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '28x28', fieldDefs.get('Die_Size_X__c'), '5.80045454545454', drivers);

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '5x5',   fieldDefs.get('Die_Size_Y__c'), '2.35368', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '7x7',   fieldDefs.get('Die_Size_Y__c'), '3.12119360000001', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '10x10', fieldDefs.get('Die_Size_Y__c'), '3.6749261417323', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '12x12', fieldDefs.get('Die_Size_Y__c'), '4.34101449275362', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '14x14', fieldDefs.get('Die_Size_Y__c'), '4.18731478260873', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '16x16', fieldDefs.get('Die_Size_Y__c'), '4.452', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '20x20', fieldDefs.get('Die_Size_Y__c'), '4.52925179856116', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '24x24', fieldDefs.get('Die_Size_Y__c'), '4.95418', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '28x28', fieldDefs.get('Die_Size_Y__c'), '6.02190909090909', drivers);

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '5x5',   fieldDefs.get('Average_2D_Wire_Length__c'), '1.54252822603543', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '7x7',   fieldDefs.get('Average_2D_Wire_Length__c'), '1.67001151860305', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '10x10', fieldDefs.get('Average_2D_Wire_Length__c'), '1.81', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '12x12', fieldDefs.get('Average_2D_Wire_Length__c'), '1.95762294429922', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '14x14', fieldDefs.get('Average_2D_Wire_Length__c'), '1.97996484884476', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '16x16', fieldDefs.get('Average_2D_Wire_Length__c'), '2.17', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '20x20', fieldDefs.get('Average_2D_Wire_Length__c'), '2.35891128360155', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '24x24', fieldDefs.get('Average_2D_Wire_Length__c'), '2.52704636894044', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '28x28', fieldDefs.get('Average_2D_Wire_Length__c'), '2.79809548373087', drivers);

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '7x7', fieldDefs.get('Leadframe_NRE__c'), '10000', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '10x10', fieldDefs.get('Leadframe_NRE__c'), '10000', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '12x12', fieldDefs.get('Leadframe_NRE__c'), '10000', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '14x14', fieldDefs.get('Leadframe_NRE__c'), '14000', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '14x20', fieldDefs.get('Leadframe_NRE__c'), '14000', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '20x20', fieldDefs.get('Leadframe_NRE__c'), '16000', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '24x24', fieldDefs.get('Leadframe_NRE__c'), '19000', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Body_Size__c'), '28x28', fieldDefs.get('Leadframe_NRE__c'), '19000', drivers);

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '32', fieldDefs.get('Number_of_FWD_Wires__c'), '32', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '48', fieldDefs.get('Number_of_FWD_Wires__c'), '48', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '64', fieldDefs.get('Number_of_FWD_Wires__c'), '64', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '44', fieldDefs.get('Number_of_FWD_Wires__c'), '44', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '52', fieldDefs.get('Number_of_FWD_Wires__c'), '52', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '80', fieldDefs.get('Number_of_FWD_Wires__c'), '80', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '100', fieldDefs.get('Number_of_FWD_Wires__c'), '100', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '120', fieldDefs.get('Number_of_FWD_Wires__c'), '120', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '128', fieldDefs.get('Number_of_FWD_Wires__c'), '128', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '144', fieldDefs.get('Number_of_FWD_Wires__c'), '144', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '176', fieldDefs.get('Number_of_FWD_Wires__c'), '176', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '160', fieldDefs.get('Number_of_FWD_Wires__c'), '160', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '216', fieldDefs.get('Number_of_FWD_Wires__c'), '216', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '208', fieldDefs.get('Number_of_FWD_Wires__c'), '208', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '256', fieldDefs.get('Number_of_FWD_Wires__c'), '256', drivers);

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '32', fieldDefs.get('Number_of_Wires__c'), '32', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '40', fieldDefs.get('Number_of_Wires__c'), '40', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '48', fieldDefs.get('Number_of_Wires__c'), '48', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '64', fieldDefs.get('Number_of_Wires__c'), '64', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '44', fieldDefs.get('Number_of_Wires__c'), '44', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '52', fieldDefs.get('Number_of_Wires__c'), '52', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '80', fieldDefs.get('Number_of_Wires__c'), '80', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '100', fieldDefs.get('Number_of_Wires__c'), '100', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '120', fieldDefs.get('Number_of_Wires__c'), '120', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '128', fieldDefs.get('Number_of_Wires__c'), '128', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '144', fieldDefs.get('Number_of_Wires__c'), '144', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '176', fieldDefs.get('Number_of_Wires__c'), '176', drivers);


    }

    private static void installPLCCDrivers(Map<String, RFQI_Field_Def__c> fieldDefs)
    {
        //public static void installDefaultDrivers(Package_Family__c pf, RFQI_Field_Def__c driver, string driverVal, RFQI_Field_Def__c child, string childVal) {
        Package_Family__c pf = [select Id from Package_Family__c where Name =: 'PLCC'];

        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '20', fieldDefs.get('Number_of_FWD_Wires__c'), '20', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '28', fieldDefs.get('Number_of_FWD_Wires__c'), '28', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '32', fieldDefs.get('Number_of_FWD_Wires__c'), '32', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '44', fieldDefs.get('Number_of_FWD_Wires__c'), '44', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '52', fieldDefs.get('Number_of_FWD_Wires__c'), '52', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '68', fieldDefs.get('Number_of_FWD_Wires__c'), '68', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '84', fieldDefs.get('Number_of_FWD_Wires__c'), '84', drivers);

        
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '20', fieldDefs.get('Number_of_Wires__c'), '20', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '28', fieldDefs.get('Number_of_Wires__c'), '28', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '32', fieldDefs.get('Number_of_Wires__c'), '32', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '44', fieldDefs.get('Number_of_Wires__c'), '44', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '52', fieldDefs.get('Number_of_Wires__c'), '52', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '68', fieldDefs.get('Number_of_Wires__c'), '68', drivers);
        FieldBuilderHelper.installDefaultDrivers(pf, fieldDefs.get('Lead_Count__c'), '84', fieldDefs.get('Number_of_Wires__c'), '84', drivers);

    }
    public static void updateSapFields() {
    	RFQAdminInstaller.updateSapFieldsForProductGroup('Quad Leadframe');  
    }
    
    /**
    * This method installs Quad Leadframe Package Families
    *
    * @returns a list of package families
    */
    private static List<Package_Family__c> installQuadLeadFramePackageFamilies() {
        
        Product_Group__c prodGroup = [select Id from Product_Group__c where Name =: 'Quad Leadframe'];
        
        Product_Group__c uPg = new Product_Group__c(id=prodGroup.id);
        uPg.Cost_Model_Implementation__c = 'CMQuadBuilder';
        uPg.Wire_Calculation_Implementation__c = 'CMQuadWireCalc';
        uPg.Generated_Price_Requires_BU_Review__c = true;
        update uPg;
        
        List<Package_Family__c> families = new List<Package_Family__c>();
        
        FieldBuilderHelper.addPf('TQFP', prodGroup, 'RFQI_TQFP__c', 'RFQIWC_TQFP__c', 'RFQIDC_TQFP__c', families, true);
        FieldBuilderHelper.addPf('LQFP', prodGroup, 'RFQI_LQFP__c', 'RFQIWC_LQFP__c', 'RFQIDC_LQFP__c', families, true);
        FieldBuilderHelper.addPf('MQFP', prodGroup, 'RFQI_MQFP__c', 'RFQIWC_MQFP__c', 'RFQIDC_MQFP__c', families, true);
        FieldBuilderHelper.addPf('PLCC', prodGroup, 'RFQI_PLCC__c', 'RFQIWC_PLCC__c', 'RFQIDC_PLCC__c', families, true);
        FieldBuilderHelper.addPf('PowerQuad 4', prodGroup, 'RFQI_PowerQuad_4__c', 'RFQIWC_PowerQuad_4__c', 'RFQIDC_PowerQuad_4__c', families, true);
        FieldBuilderHelper.addPf('tsCSP', prodGroup, 'RFQI_tsCSP__c', 'RFQIWC_tsCSP__c', 'RFQIDC_tsCSP__c', families, true);
        FieldBuilderHelper.addPf('MQFP W/ Heat Spreader', prodGroup, 'RFQI_MQFP_Heat_Spreader__c', 'RFQIWC_MQFP_Heat_Spreader__c','RFQIDC_MQFP_Heat_Spreader__c', families, true);
        FieldBuilderHelper.addPf('Fusion Quad', prodGroup, 'RFQI_Fusion_Quad__c', 'RFQIWC_Fusion_Quad__c', 'RFQIDC_Fusion_Quad__c', families, true);
        FieldBuilderHelper.addPf('MQFP W/ FCIR', prodGroup, 'RFQI_MQFP_FCIR__c', 'RFQIWC_MQFP_FCIR__c','RFQIDC_MQFP_FCIR__c', families, true);
        try {
            insert families;
        }catch(Exception e) {
            system.debug('Could not install Quad Leadframe Package Families: ' + e);
        }
        return families;
    }

    global static void incrementalInstall1()
    {
        List<Package_Family__c> pfs = [select id, name from package_family__c where product_group__r.Name='Quad Leadframe' and name != 'TQFP'];

        for (Package_Family__c row : pfs)
        {
            row.No_Cost_Model__c = true;
        }

        update pfs;
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
        helper.add('Package Description', 'Leadframe_Finish__c', 2010, true);
        helper.add('Package Description', 'Lead_Count__c', 2030, true, false, true, true, 'Lead_Count_Other__c');
        helper.add('Package Description', 'Leadframe_Config__c', 2040, true);       
        //helper.add('Package Description', 'Factory__c', 2060, true, false, true );
        helper.add('Package Description', 'Packing_Type__c', 2140, true);
        helper.add('Package Description', 'Mold_Compound__c', 2150, true);

        helper.add('Wire Description', 'Wire_Configuration__c', 3000, true, false, true);
        helper.add('Wire Description', 'Wire_Material__c', 3010, true, false, true);
        helper.add('Wire Description', 'Wire_Diameter__c', 3020, true, false, true);
        helper.add('Wire Description', 'Number_Of_Wires__c', 3030, true, false, true);
        helper.add('Wire Description', 'Average_2D_Wire_Length__c', 3040, true);
        helper.add('Wire Description', 'Total_2D_Wire_Length__c', 3050);
        helper.add('Wire Description', 'Total_3D_Wire_Length__c', 3060);
        helper.add('Wire Description', 'Number_of_FWD_Wires__c', 3070, true);
        helper.add('Wire Description', 'Number_of_SSB_Wires__c', 3080, true);
        helper.add('Wire Description', 'Au_Factor__c', 3079);
        
        helper.add('Die Description', 'Die_Attach__c', 3000, true);
        helper.add('Die Description', 'Die_Size_X__c', 3020, true, false, false, false, '', true);
        helper.add('Die Description', 'Die_Size_Y__c', 3030, true, false, false, false, '', true);
        helper.add('Die Description', 'Die_Size_Z__c', 3040, true);
        helper.add('Die Description', 'Wafer_Node__c', 3050, true);
        helper.add('Die Description', 'Laser_Groove__c', 3060, true);
        helper.add('Die Description', 'Wafer_Size__c', 3070, true);
        helper.add('Die Description', 'Wafer_Backgrind__c', 3080, true);
                
        helper.add('Adders', 'Plasma_Before_Die_Attach__c', 4000, true);
        helper.add('Adders', 'Plasma_Before_Wire_Bond__c', 4010, true);
        helper.add('Adders', 'Plasma_Before_Mold__c', 4020, true);
        helper.add('Adders', 'Die_Coat__c', 4030);
        helper.add('Adders', 'Wafer_Inspection__c', 4040);
        helper.add('Adders', 'X2_OPT_INSP_100__c', 4050, true);
        helper.add('Adders', 'X3RD_OPT_100__c', 4060, true);
        helper.add('Adders', 'FVI_100__c', 4070, true);
        helper.add('Adders', 'Bake_Dry_Pack__c', 4080, true);
        helper.add('Adders', 'Temperature_Cycle__c', 4090, true);
        helper.add('Adders', 'Bake__c', 4100, true);

        helper.add('NRE', 'Leadframe_NRE__c', 5000);
        
                                                    
        helper.insertFields();
        
        return helper.getPfFieldDefs();                   
    }
}