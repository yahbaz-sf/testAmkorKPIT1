@isTest
public with sharing class HermeticsCeramicsInstallerTest 
{
	public static testmethod void testInstall()
	{
		installData();
		HermeticsCeramicsInstaller.install();
		List<Product_Group__c> pgs = [SELECT Id FROM Product_Group__c];
		System.assert(pgs.size() > 0);

		List<Package_Family__c> pfs = [SELECT Id FROM Package_Family__c];
		System.assert(pfs.size() > 0);

		List<RFQI_PF_Field_Def__c> defs = [SELECT Id FROM RFQI_PF_Field_Def__c];
		System.assert(defs.size() > 0);

		HermeticsCeramicsInstaller.AMK1716();

	}

	private static void installData()
	{
		List<RFQI_Section__c> sections = new List<RFQI_Section__c>();
		sections.add(new RFQI_Section__c(Name='Sales Header'));
		sections.add(new RFQI_Section__c(Name='BU Header'));
		sections.add(new RFQI_Section__c(Name='Quote Information'));
		sections.add(new RFQI_Section__c(Name='Cost and Price'));
		sections.add(new RFQI_Section__c(Name='Package Description'));
		sections.add(new RFQI_Section__c(Name='NRE'));
		insert sections;

		List<RFQI_Field_Def__c> defs = new List<RFQI_Field_Def__c>();
		defs.add(new RFQI_Field_Def__c(Name='RFQ_Item__r.RFQ__c'));
		defs.add(new RFQI_Field_Def__c(Name='RFQ_Item__r.RFQ__r.RFQ_Name__c'));
		defs.add(new RFQI_Field_Def__c(Name='RFQ_Item__r.Package_Family__r.Name'));
		defs.add(new RFQI_Field_Def__c(Name='RFQ_Item__r.Status__c'));
		defs.add(new RFQI_Field_Def__c(Name='RFQ_Item__r.RFQ__r.SBU_Name__c'));
		defs.add(new RFQI_Field_Def__c(Name='RFQ_Item__r.CreatedById'));
		defs.add(new RFQI_Field_Def__c(Name='RFQ_Item__r.RFQ__r.RFQ_Name__c'));
		defs.add(new RFQI_Field_Def__c(Name='RFQ_Item__r.Package_Family__r.Name'));
		defs.add(new RFQI_Field_Def__c(Name='RFQ_Item__r.RFQ__r.SBU_Name__c'));
		defs.add(new RFQI_Field_Def__c(Name='RFQ_Item__r.OwnerId'));
		defs.add(new RFQI_Field_Def__c(Name='RFQ_Item__r.Status__c'));
		defs.add(new RFQI_Field_Def__c(Name='RFQ_Item__r.Service__c'));
		defs.add(new RFQI_Field_Def__c(Name='RFQ_Item__r.RFQ__r.SBU_Name__r.AccountNumber'));
		defs.add(new RFQI_Field_Def__c(Name='Customer_Project_Name__c'));
		defs.add(new RFQI_Field_Def__c(Name='New_Business__c'));
		defs.add(new RFQI_Field_Def__c(Name='Forecast__c'));
		defs.add(new RFQI_Field_Def__c(Name='RFQ_Item__r.RFQ__r.SBU_Name__r.Customer_AU_Base_fml__c'));
		defs.add(new RFQI_Field_Def__c(Name='Customer_Device_Name__c'));
		defs.add(new RFQI_Field_Def__c(Name='RGQ_Projected_Annual_Revenue__c'));
		defs.add(new RFQI_Field_Def__c(Name='Au_Inclusive__c'));
		defs.add(new RFQI_Field_Def__c(Name='End_Market_Segment__c'));
		defs.add(new RFQI_Field_Def__c(Name='Automotive__c'));
		defs.add(new RFQI_Field_Def__c(Name='ITAR__c'));
		defs.add(new RFQI_Field_Def__c(Name='EAR__c'));
		defs.add(new RFQI_Field_Def__c(Name='RFQ_Item__r.Customer_Tier__c'));
		defs.add(new RFQI_Field_Def__c(Name='RFQ_Item__r.RFQ__c'));
		defs.add(new RFQI_Field_Def__c(Name='New_Business__c'));
		defs.add(new RFQI_Field_Def__c(Name='Sales_BU_Price__c'));
		defs.add(new RFQI_Field_Def__c(Name='Price_To_Customer__c'));
		defs.add(new RFQI_Field_Def__c(Name='Automotive__c'));
		defs.add(new RFQI_Field_Def__c(Name='ITAR__c'));
		defs.add(new RFQI_Field_Def__c(Name='EAR__c'));
		defs.add(new RFQI_Field_Def__c(Name='Customer_Project_Name__c'));
		defs.add(new RFQI_Field_Def__c(Name='Customer_Device_Name__c'));
		defs.add(new RFQI_Field_Def__c(Name='Forecast__c'));
		defs.add(new RFQI_Field_Def__c(Name='Prototype__c'));
		defs.add(new RFQI_Field_Def__c(Name='Customer_Target_Price__c'));
		defs.add(new RFQI_Field_Def__c(Name='Sales_Target_Price__c'));
		defs.add(new RFQI_Field_Def__c(Name='End_Market_Segment__c'));
		defs.add(new RFQI_Field_Def__c(Name='Competitor__c'));
		defs.add(new RFQI_Field_Def__c(Name='Competitor_Au_Inclusive_Price__c'));
		defs.add(new RFQI_Field_Def__c(Name='HVP_Anticipated_Start_Date__c'));
		defs.add(new RFQI_Field_Def__c(Name='Has_Been_Quoted_Before__c'));
		defs.add(new RFQI_Field_Def__c(Name='CLAM_Direct_Labor__c'));
		defs.add(new RFQI_Field_Def__c(Name='Materials_Total_Wire__c'));
		defs.add(new RFQI_Field_Def__c(Name='Customer_Target_Price__c'));
		defs.add(new RFQI_Field_Def__c(Name='Assembly_GM_wo_Substrate__c'));
		defs.add(new RFQI_Field_Def__c(Name='CLAM_Depreciation__c'));
		defs.add(new RFQI_Field_Def__c(Name='Materials_Substrate__c'));
		defs.add(new RFQI_Field_Def__c(Name='Sales_Target_Price__c'));
		defs.add(new RFQI_Field_Def__c(Name='Total_Perc_GM__c'));
		defs.add(new RFQI_Field_Def__c(Name='CLAM_OCOGS__c'));
		defs.add(new RFQI_Field_Def__c(Name='Materials_ODM__c'));
		defs.add(new RFQI_Field_Def__c(Name='Competitor__c'));
		defs.add(new RFQI_Field_Def__c(Name='Perc_VAM_New__c'));
		defs.add(new RFQI_Field_Def__c(Name='CLAM_OH__c'));
		defs.add(new RFQI_Field_Def__c(Name='Materials_Subtotal__c'));
		defs.add(new RFQI_Field_Def__c(Name='Competitor_Au_Inclusive_Price__c'));
		defs.add(new RFQI_Field_Def__c(Name='BU_Price__c'));
		defs.add(new RFQI_Field_Def__c(Name='CLAM_Subtotal__c'));
		defs.add(new RFQI_Field_Def__c(Name='Subs_Markup_Perc__c'));
		defs.add(new RFQI_Field_Def__c(Name='Total_Cost__c'));
		defs.add(new RFQI_Field_Def__c(Name='Package_Description_Extended__c'));
		defs.add(new RFQI_Field_Def__c(Name='Stamped_Leadframe_Tooling__c'));
		defs.add(new RFQI_Field_Def__c(Name='Etched_Leadframe_Tooling__c'));
		defs.add(new RFQI_Field_Def__c(Name='Other__c'));
		insert defs;
	}
}