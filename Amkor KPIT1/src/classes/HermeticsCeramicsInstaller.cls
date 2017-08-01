global class HermeticsCeramicsInstaller {

    global static Product_Group__c installHermeticsCeramicsProductGroup(string pg) {
        
        Product_Group__c ProductGroup = new Product_Group__c(Name = pg);
        ProductGroup.Generated_Price_Requires_BU_Review__c = true;
        ProductGroup.No_Cost_Model__c = true;

        try {
            insert ProductGroup;
        }catch(Exception e) {
            system.debug('Could not install' + pg + ':' + e);
        }
        return ProductGroup;
    }

    global static void install() {
        
        FieldBuilderHelper.clean('Hermetics/Ceramics');
        installHermeticsCeramicsProductGroup('Hermetics/Ceramics');
        installHermeticsCeramicsPackageFamilies();
        installExtended('Hermetics/Ceramics');

    }

    public static List<Package_Family__c> installHermeticsCeramicsPackageFamilies(){

        Product_Group__c prodGroup = [select Id from Product_Group__c where Name =: 'Hermetics/Ceramics'];
        
        List<Package_Family__c> families = new List<Package_Family__c>();

        FieldBuilderHelper.addPf('Hermetics/Ceramics', prodGroup, 'RFQI_HERMETICS__c', null, null,null, null, families, false, 'CMExtendedBuilder');

        for(Package_Family__c family : families){
            family.No_Cost_Model__c = true;
        }

        try {
            insert families;
        }catch(Exception e) {
            system.debug('Could not install Hermetics/Ceramics Package Families: ' + e);
        }
        return families;

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

    public static void AMK1716(){

        List <RFQ_Item__c> updateList = new List<RFQ_Item__c>();

        Product_Group__c targetPg = ProductGroupDao.getInstance().getProductGroupByName('Hermetics/Ceramics');
        Package_Family__c targetPf;

        if(targetPg != null){
            targetPf = PackageFamilyDao.getInstance().getFamiliesByProductGroup(targetPg.Id)[0];
        }

        List <RFQI_HERMETICS__c> idsToChangeList = [select RFQ_Item__r.Id from RFQI_HERMETICS__c where RFQ_Item__r.Product_Group_Name__c = 'Dual Leadframe' and RFQ_Item__r.Package_Family_Name__c = 'Hermetics'];
        Set <Id> idsToChangeSet = new Set <Id>();

        if(idsToChangeList != null){

            for (RFQI_HERMETICS__c item: idsToChangeList) {
                idsToChangeSet.add(item.RFQ_Item__r.Id);
            }

        }

        if(targetPg != null && targetPf != null && !idsToChangeSet.isEmpty()){

            for(RFQ_Item__c item : [select Package_Family__c from RFQ_Item__c where Id in :idsToChangeSet]){                
                item.Package_Family__c = targetPf.Id;

                updateList.add(item);
            }

            update updateList;
        }

        //-- Get rid of the Hermetics package family since it is now its own Product Group and PF (Hermetics/Ceramics)
        List <Package_Family__c> pfsToDelete = [select Id from Package_Family__c where Name = 'Hermetics'];

        if(pfsToDelete != null && !pfsToDelete.isEmpty()){
            delete pfsToDelete;
        }

    }
}