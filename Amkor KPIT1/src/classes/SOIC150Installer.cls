/*************************************************************************
* 
* PURPOSE:  this class seeds fresh RFQ Item Field Definition specifically
*           for the SOIC 150 mil body package family
*         
* CLASS: SOIC150Installer
* CREATED: 03/12/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
global class SOIC150Installer {
	
	global static void install() {
		
		installDualLeadFrameProductGroup();
		installDualLeadFramePackageFamilies();
		installSOIC150milFieldDefs();
	}
	
	global static void clean() {
				
		List<Product_Group__c> prodGroup = [select Id from Product_Group__c where Name =: 'Dual Leadframe'];
		delete prodGroup;
	}
	
	private static Product_Group__c installDualLeadFrameProductGroup() {
		
		Product_Group__c dualLeadFrameGroup = new Product_Group__c(Name ='Dual Leadframe');
		try {
		    insert dualLeadFrameGroup;
		}catch(Exception e) {
			system.debug('Could not install Dual Leadframe Group: ' + e);
		}
		return dualLeadFrameGroup;
	}
	
	private static List<Package_Family__c> installDualLeadFramePackageFamilies() {
		
		Product_Group__c prodGroup = [select Id from Product_Group__c where Name =: 'Dual Leadframe'];
		
		List<Package_Family__c> families = new List<Package_Family__c>();
		
		Package_Family__c SOIC150milBody =  new Package_Family__c(Name='SOIC 150mil Body',Product_Group__c = prodGroup.Id);
		SOIC150milBody.Specific_RFQ_Item_Object__c = 'RFQI_SOIC_150mil_body__c';
		SOIC150milBody.Specific_Wire_Configuration_Object__c = 'RFQIWC_SOIC_150mil_body__c';
		families.add(SOIC150milBody);
		
		try {
		    insert families;
		}catch(Exception e) {
			system.debug('Could not install Dual Leadframe Package Families: ' + e);
		}
		return families;
	}
		
	private static List<RFQI_PF_Field_Def__c> installSOIC150milFieldDefs() {
		
		Package_Family__c pf = [select Id from Package_Family__c where Name =: 'SOIC 150mil Body'];
		
		Map<String, RFQI_Section__c> sections = new Map<String, RFQI_Section__c>(); 
        for(RFQI_Section__c section : [select Id,Name From RFQI_Section__c])
        sections.put(section.Name, section);
        
        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
        for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c])
        fieldDefs.put(fieldDef.Name, fieldDef);
		
		List<RFQI_PF_Field_Def__c> pfFieldDefs = new List<RFQI_PF_Field_Def__c>();
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Quote Information').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('New_Business__c').Id,
				                                    Sequence__c = 1000,
				                                    Package_Family__c = pf.Id));
				                                    
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Quote Information').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('BU_Price__c').Id,
				                                    Sequence__c = 1010,
				                                    Package_Family__c = pf.Id));		                                    
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Quote Information').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Price_To_Customer__c').Id,
				                                    Sequence__c = 1020,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Quote Information').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Automotive__c').Id,
				                                    Sequence__c = 1030,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Quote Information').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('ITAR__c').Id,
				                                    Sequence__c = 1040,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Quote Information').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('EAR__c').Id,
				                                    Sequence__c = 1050,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Quote Information').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Customer_Project_Name__c').Id,
				                                    Sequence__c = 1060,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Quote Information').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Customer_Device_Name__c').Id,
				                                    Sequence__c = 1070,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Quote Information').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Customer_Target_Price__c').Id,
				                                    Sequence__c = 1080,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Quote Information').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Sales_Target_Price__c').Id,
				                                    Sequence__c = 1090,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Quote Information').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('End_Market_Segment__c').Id,
				                                    Sequence__c = 1090,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Quote Information').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Competitor__c').Id,
				                                    Sequence__c = 1200,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Quote Information').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Competitor_Au_Inclusive_Price__c').Id,
				                                    Sequence__c = 1210,
				                                    Package_Family__c = pf.Id));
		
		/*pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Quote Information').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Production_Year__c').Id,
				                                    Sequence__c = 1220,
				                                    Package_Family__c = pf.Id));*/
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Package Description').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Factory__c').Id,
				                                    Sequence__c = 2000,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Package Description').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Lead_Count__c').Id,
				                                    Sequence__c = 2010,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Package Description').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Stamped_Etched_Leadframe__c').Id,
				                                    Sequence__c = 2020,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Package Description').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Leadframe_Finish__c').Id,
				                                    Sequence__c = 2030,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Package Description').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Standard_Rough_Leadframe__c').Id,
				                                    Sequence__c = 2040,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Package Description').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Die_Attach__c').Id,
				                                    Sequence__c = 2050,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Package Description').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Number_Of_Die__c').Id,
				                                    Sequence__c = 2060,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Package Description').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Wafer_Backgrind__c').Id,
				                                    Sequence__c = 2070,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Package Description').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Wafer_Singulation_Type__c').Id,
				                                    Sequence__c = 2080,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Package Description').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Additional_Components_In_Package__c').Id,
				                                    Sequence__c = 2090,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Wire Description').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Wire_Configuration__c').Id,
				                                    Sequence__c = 3000,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Wire Description').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Wire_Material__c').Id,
				                                    Sequence__c = 3010,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Wire Description').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Wire_Diameter__c').Id,
				                                    Sequence__c = 3020,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Wire Description').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Number_Of_Wires__c').Id,
				                                    Sequence__c = 3030,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Wire Description').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Average_2D_Wire_Length__c').Id,
				                                    Sequence__c = 3040,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Wire Description').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Total_2D_Wire_Length__c').Id,
				                                    Sequence__c = 3050,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Wire Description').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Total_3D_Wire_Length__c').Id,
				                                    Sequence__c = 3060,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Adders').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Plasma_Before_Die_Attach__c').Id,
				                                    Sequence__c = 4000,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Adders').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Plasma_Before_Wire_Bond__c').Id,
				                                    Sequence__c = 4010,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Adders').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Plasma_Before_Mold__c').Id,
				                                    Sequence__c = 4020,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Adders').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Die_Coat__c').Id,
				                                    Sequence__c = 4030,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Adders').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Wafer_Inspection__c').Id,
				                                    Sequence__c = 4040,
				                                    Package_Family__c = pf.Id));
		
		/*pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Adders').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Optical_Inspection__c').Id,
				                                    Sequence__c = 4050,
				                                    Package_Family__c = pf.Id));*/
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Adders').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Bake_Dry_Pack__c').Id,
				                                    Sequence__c = 4060,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Adders').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Temperature_Cycle__c').Id,
				                                    Sequence__c = 4070,
				                                    Package_Family__c = pf.Id));
		
		pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Adders').Id, 
				                                    RFQI_Field_Def__c = fieldDefs.get('Bake__c').Id,
				                                    Sequence__c = 4080,
				                                    Package_Family__c = pf.Id));
				                                    
       try {
		    insert pfFieldDefs;
		}catch(Exception e) {
			system.debug('Could not install SOIC150 Package Family Field Definitions : ' + e);
		}
		return pfFieldDefs;                                      
		                                         
	}

}