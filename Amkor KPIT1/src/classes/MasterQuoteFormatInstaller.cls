public with sharing class MasterQuoteFormatInstaller {

	public static String RFQ = 'RFQ';
	public static String RFQ_ITEM = 'RFQ Item';
	public static String SPECIFIC_RFQ_ITEM = 'Specific RFQ Item';
	public static String WIRE_CONFIG = 'Wire Config';
	public static String DIE_CONFIG = 'Die Config';
	public static String PASSIVE_CONFIG = 'Passive Config';
	public static String INSERTION_CONFIG = 'Insertion Config';

	private static Integer sequence = 10;
	private static Id formatId;
	private static List<Master_Quote_Format_Column__c> columns;

	public static void clean() {
		delete [Select Id from Master_Quote_Format__c];
	}

	public static void install() {
		clean();

		Master_Quote_Format__c format = new Master_Quote_Format__c();
		insert format;

		sequence = 10;
		formatId = format.Id;
		columns = new List<Master_Quote_Format_Column__c>();

		addColumn(RFQ, 'Customer Parent', 'Parent_Customer_Name__c');
		addColumn(RFQ, 'Customer #', 'SBU_Name_Number__c');
		addColumn(RFQ, 'Quote Number', 'Customer_RFQ_Number__c');
		addColumn(RFQ, 'Rev #', ''); // TODO What is this column
		addColumn(RFQ, 'RFQ Creation Date', 'CreatedDate');
		addColumn(RFQ, 'RFQ Effective To Date', 'Effective_Through_Date__c');
		addColumn(RFQ_ITEM, 'Status', 'Status__c');
		addColumn(RFQ_ITEM, 'Program Win', '');
		addColumn(RFQ_ITEM, 'Production Win', '');
		addColumn(RFQ_ITEM, 'Factory', 'Factory__c');
		addColumn(RFQ_ITEM, 'Service', 'Service__c');
		addColumn(RFQ_ITEM, 'Package Family', 'Package_Family_Name__c');
		addColumn(RFQ, 'RFQ Name', 'RFQ_Name__c');
		addColumn(SPECIFIC_RFQ_ITEM, 'Customer Project Name', 'Customer_Project_Name__c');
		addColumn(SPECIFIC_RFQ_ITEM, 'Customer Device Name', 'Customer_Device_Name__c');
		addColumn(RFQ_ITEM, 'Application Information', ''); // As per spreadsheet this will be filled in by sales manually
		addColumn(SPECIFIC_RFQ_ITEM, 'Number of Die', 'Number_Of_Die__c');
		addColumn(SPECIFIC_RFQ_ITEM, 'Automotive', 'Automotive__c');
		addColumn(SPECIFIC_RFQ_ITEM, 'ITAR', 'ITAR__c');
		addColumn(SPECIFIC_RFQ_ITEM, 'EAR', 'EAR__c');
		addColumn(RFQ_ITEM, 'PDL', ''); // Filled in by sales
		addColumn(RFQ_ITEM, 'Lead', ''); // Filled in by sales
		addColumn(RFQ_ITEM, 'Body Size', 'Body_Size__c');
		addColumn(SPECIFIC_RFQ_ITEM, 'Pkg. Z dim (thickness)', 'Body_Size_Z__c');
		addColumn(RFQ_ITEM, 'Lead/Ball Count', 'Leads__c');
		addColumn(RFQ_ITEM, 'Pitch', ''); // TODO Which field is this column pulling from???
		addColumn(RFQ_Item, 'Tgt Device', ''); // TODO What is this column
		addColumn(SPECIFIC_RFQ_ITEM, 'LF Type / Layer Count', 'Total_Layer_Count__c,layer_count__c');
		addColumn(WIRE_CONFIG, 'Wire Material', 'Wire_Material__c');
		addColumn(WIRE_CONFIG, 'Wire Diameter', 'Wire_Diameter__c');
		addColumn(SPECIFIC_RFQ_ITEM, 'UnitPrice', 'Unit_Price_To_Customer__c,');
		addColumn(SPECIFIC_RFQ_ITEM, 'Adder Information', ''); // TODO What is this column
		addColumn(SPECIFIC_RFQ_ITEM, 'Packing Type', 'Packing_Type__c');
		addColumn(SPECIFIC_RFQ_ITEM, 'Consigned', ''); // TODO What is this column
		addColumn(SPECIFIC_RFQ_ITEM, 'Gold Base', ''); //TODO What is this pulling from
		addColumn(SPECIFIC_RFQ_ITEM, 'Gold Factor', 'Au_Factor__c');
		addColumn(RFQ_ITEM, 'AU Daily gold adder', ''); // Filed in by sales
		addColumn(RFQ_ITEM, 'Lot Charge', ''); // Filled in by sales
		addColumn(RFQ_ITEM, 'Lot Charge Code', ''); // Filled in by sales
		addColumn(RFQ_ITEM, 'Lot Code Premiums', ''); // By sales
		addColumn(RFQ_ITEM, 'Lot Code Premium Codes', ''); // By sales
		addColumn(RFQ_ITEM, 'SilverFactor', ''); // Sales
		addColumn(RFQ_ITEM, 'Customer Reference Field', ''); // Sales
		addColumn(RFQ_ITEM, 'TestAdderCode', ''); // Sales
		addColumn(RFQ_ITEM, 'QuoteBasePrice', ''); // Sales
		addColumn(RFQ_ITEM, 'Test/Reject Code Description', ''); // To be finalized with test group
		addColumn(SPECIFIC_RFQ_ITEM, 'CPUPrice', 'CPU_Price_Hour__c');
		addColumn(SPECIFIC_RFQ_ITEM, 'TotalTestTime', 'Total_Test_Time__c');
		addColumn(SPECIFIC_RFQ_ITEM, 'TotalIndexTime', 'Index_Time__c');
		addColumn(RFQ_ITEM, 'Operation', ''); // To be finalized with test group
		addColumn(RFQ_ITEM, 'Temp', ''); // To be finalized with test group
		addColumn(RFQ_ITEM, 'Bake/Burn-in Time', ''); // To be Finalized with test group
		addColumn(SPECIFIC_RFQ_ITEM, 'Tester Model', 'Tester_Model__c');
		addColumn(SPECIFIC_RFQ_ITEM, 'TesterConsigned', ''); // TODO what is this column
		addColumn(SPECIFIC_RFQ_ITEM, 'Handler Model', 'Handler_Model__c');
		addColumn(SPECIFIC_RFQ_ITEM, 'HandlerConsigned', '');
		addColumn(SPECIFIC_RFQ_ITEM, 'HandlerSites', ''); // TODO what is this column
		addColumn(SPECIFIC_RFQ_ITEM, 'Retest Flag', ''); // To be finalized with test group


		insert columns;
	}

	private static void addColumn(String objectType, String columnName, String apiNames) {
		Master_Quote_Format_Column__c column = new Master_Quote_Format_Column__c
		(
			Name= columnName,
			Master_Quote_Format__c = formatId, 
			Object_Type__c = objectType, 
			API_Names__c = apiNames,
			Sequence__c = sequence
		);

		sequence += 10;
		columns.add(column);

	}
}