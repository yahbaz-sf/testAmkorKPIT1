/*************************************************************************
* 
* PURPOSE:  this class seeds fresh RFQ Item Field Definition specifically
*           for the FC CoC Product package families (cloned from SOIC150Installer
*           for the purposes of generalization)
*         
* CLASS: FCCOCInstaller
* CREATED: 06/19/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
global class FCCOCInstaller {

		global static void install() {
			FieldBuilderHelper.clean('FC CoC');	
			FieldBuilderHelper.installProductGroup('FC CoC');
			installPackageFamiles();
			installFCCOCFields();
		}
		
		public static void updateSapFields() {
    		RFQAdminInstaller.updateSapFieldsForProductGroup('FC CoC');  
    	}
		
		private static List<Package_Family__c> installPackageFamiles() {
			Product_Group__c prodGroup = [select Id from Product_Group__c where Name =: 'FC CoC'];
        
        	List<Package_Family__c> families = new List<Package_Family__c>();
        	FieldBuilderHelper.addPf('FC CoC', prodGroup, 'RFQI_FCCOC__c', 'RFQIWC_FCCOC__c', 'RFQIDC_FCCOC__c', families);

	        try {
	            insert families;
	        }catch(Exception e) {
	            system.debug('Could not install Advanced Product Package Families: ' + e);
	        }
	        return families;
		}

		private static List<RFQI_PF_Field_Def__c> installFCCOCFields(){
        FieldBuilderHelper helper = new FieldBuilderHelper('FC CoC');
    
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
        helper.add('Cost and Price','CLAM_OCOGS__c',1020,false,false);
        helper.add('Cost and Price','CLAM_OH__c',1030,false,false);
        helper.add('Cost and Price','CLAM_Subtotal_New__c',1040,false,true);
        helper.add('Cost and Price','Materials_Substrate__c',1050,false,true);
        helper.add('Cost and Price','Materials_ODM__c',1060,false,false);
        helper.add('Cost and Price','Materials_Subtotal__c',1070,false,false);
        helper.add('Cost and Price','Cost_less_Substrate_New__c',1080,false,true);
        helper.add('Cost and Price','Total_Cost_with_Substrate_New__c',1090,false,true);
        helper.add('Cost and Price','Customer_Target_Price__c', 1100,false,false);
        helper.add('Cost and Price','Sales_Target_Price__c',1110,false,false);
        helper.add('Cost and Price','Competitor__c',1120,false,true);
        helper.add('Cost and Price','Competitor_Au_Inclusive_Price__c',1130,false,true);
        helper.add('Cost and Price','Model_UE_Perc__c',1140,false,true);
        helper.add('Cost and Price','Subs_Markup_Perc__c',1150,false,true);
        helper.add('Cost and Price','Assembly_GM_wo_Substrate__c',1160,false,true);
        helper.add('Cost and Price','Total_Perc_GM__c',1170,false,true);
        helper.add('Cost and Price','Perc_IRR_New__c',1180,false,true);
        helper.add('Cost and Price','Perc_VAM_New__c',1190,false,true);
        helper.add('Cost and Price','BU_Price__c',1200,false,true);
        helper.add('Cost and Price','BU_Price_Perc_Delta_To_Target__c',1210,false,true);
            
        helper.add('Quote Information', 'New_Business__c', 1000);
        helper.add('Quote Information', 'Sales_BU_Price__c', 1010);
        helper.add('Quote Information', 'Price_To_Customer__c', 1020);
        helper.add('Quote Information', 'Automotive__c', 1030);
        helper.add('Quote Information', 'ITAR__c', 1040);
        helper.add('Quote Information', 'EAR__c', 1050);
        helper.add('Quote Information', 'Customer_Project_Name__c', 1060);
        helper.add('Quote Information', 'Customer_Device_Name__c', 1070);
        helper.add('Quote Information', 'Forecast__c', 1080);
        helper.add('Quote Information', 'Customer_Target_Price__c', 1090);
        helper.add('Quote Information', 'Sales_Target_Price__c', 1100);
        helper.add('Quote Information', 'End_Market_Segment__c', 1110);
        helper.add('Quote Information', 'Competitor__c', 1120);
        helper.add('Quote Information', 'Competitor_Au_Inclusive_Price__c', 1130);
        helper.add('Quote Information', 'HVP_Anticipated_Start_Date__c', 1140);
        helper.add('Quote Information', 'Has_Been_Quoted_Before__c', 1150);
        
        //helper.add('Package Description', 'Factory__c', 2000, true, false, true);
        helper.add('Package Description', 'Strip_Width__c', 2010, true);
        helper.add('Package Description', 'Body_Size_X__c', 2020, true);
        helper.add('Package Description', 'Body_Size_Y__c', 2030, true);
        helper.add('Package Description', 'BGA_Pitch__c', 2040, true);
        helper.add('Package Description', 'Number_of_BGA_Balls__c', 2060, true);
        helper.add('Package Description', 'Ball_Composition__c', 2070, true);
        helper.add('Package Description', 'Ball_Composition_2nd_Step__c', 2080, true);
        helper.add('Package Description', 'Ball_Size__c', 2090, true);
        helper.add('Package Description', 'Si_Node__c', 2100, true);
        helper.add('Package Description', 'Side_Spacer__c', 2110, true);
        helper.add('Package Description', 'Lid__c', 2120, true);
        helper.add('Package Description', 'Lid_Attach_Type__c', 2130, true);
        helper.add('Package Description', 'Pre_Stacking__c', 2140, true);
        helper.add('Package Description', 'Include_TMV__c', 2150, true);
        helper.add('Package Description', 'Number_of_TMV_Balls__c', 2160, true);
        helper.add('Package Description', 'TMV_Pitch__c', 2170, true);
        helper.add('Package Description', 'Include_SMT__c', 2180, true);
        helper.add('Package Description', 'Number_of_Passives__c', 2190, true);
        helper.add('Package Description', 'Size_of_Passives__c', 2200, true);
        helper.add('Package Description', 'MEMS__c', 2210, true);
        helper.add('Package Description', 'MEMS_CAP__c', 2220, true);

        helper.add('Wire Description', 'Wire_Configuration__c', 3000, true);
        helper.add('Wire Description', 'Wire_Material__c', 3000, true);
        helper.add('Wire Description', 'Wire_Diameter__c', 3020, true);
        helper.add('Wire Description', 'Number_Of_Wires__c', 3030, true, false, true);   
        helper.add('Wire Description', 'Average_2D_Wire_Length__c', 3040);
        helper.add('Wire Description', 'Total_2D_Wire_Length__c', 3050);
        helper.add('Wire Description', 'Total_3D_Wire_Length__c', 3060, true);
        helper.add('Wire Description', 'Au_Factor__c', 3070, true);

        helper.add('Die Description', 'Die_Bump_Type__c', 3000, true);
        helper.add('Die Description', 'Die_Size__c', 3010, true);
        helper.add('Die Description', 'Die_Bump_Pitch__c', 3020, true);
        helper.add('Die Description', 'Wafer_Size__c', 3030, true);  
        helper.add('Die Description', 'Wafer_Number_of_DPW__c', 3040, true);
        helper.add('Die Description', 'Wafer_Probe_Yield__c', 3050, true);
        helper.add('Die Description', 'Wafer_Number_of_GDPW__c', 3060, true);
        helper.add('Die Description', 'Wafer_Thickness__c', 3070, true);
        helper.add('Die Description', 'Wafer_Stealth_Dicing__c', 3080, true);
        helper.add('Die Description', 'Laser_Groove__c', 3090, true);
        helper.add('Die Description', 'Die_Attach__c', 3100, true);
        helper.add('Die Description', 'UF__c', 3110, true);

        helper.add('Substrate Description', 'Ball_Pad_Pitch__c', 3000, true);
        helper.add('Substrate Description', 'Bond_Finger_Pitch__c', 3010, true);
        helper.add('Substrate Description', 'Layer_Configuration__c', 3020, true);
        helper.add('Substrate Description', 'Line_and_Space_Inner__c', 3030, true); 
        helper.add('Substrate Description', 'Line_and_Space_Outer__c', 3040, true);
        helper.add('Substrate Description', 'Number_of_Stacked_Via__c', 3050, true);
        helper.add('Substrate Description', 'Restricted_Substrate_Supplier__c', 3060, true);
        helper.add('Substrate Description', 'Special_Options__c', 3070, true);
        helper.add('Substrate Description', 'Total_Layer_Count__c', 3080, true);
        helper.add('Substrate Description', 'Via_Size_Build_up__c', 3090, true);
        helper.add('Substrate Description', 'Via_Size_Core__c', 3100, true);

        helper.add('Adders', 'Plasma_Before_Die_Attach__c', 5000, true);
        helper.add('Adders', 'Plasma_Before_Wire_Bond__c', 5010, true);
        helper.add('Adders', 'Plasma_Before_Mold__c', 5020, true);
        helper.add('Adders', 'X2_OPT_INSP_100__c', 5030, true);
        helper.add('Adders', 'X3RD_OPT_100__c', 5040, true);
        helper.add('Adders', 'FVI_100__c', 5050, true);
        helper.add('Adders', 'Bake_Dry_Pack__c', 5060, true);
        helper.add('Adders', 'Temperature_Cycle__c', 5070, true);
        helper.add('Adders', 'Bake__c', 5080, true);
        
        helper.add('NRE', 'NRE_per_Jig__c', 4000, true);
        helper.add('NRE', 'Number_Of_Jigs__c', 4010, true);
        helper.add('NRE', 'Total_NRE__c', 4020, true);
        helper.addLotChargeField('NRE', 'Engineering_Lot_Charge__c', 4030, true);
        
        helper.insertFields();
        
        return helper.getPfFieldDefs();
    }

	
}