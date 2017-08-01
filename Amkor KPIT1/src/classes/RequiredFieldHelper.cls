public with sharing class RequiredFieldHelper {
	public static Map<String, Map<String, List<String>>> requiredFieldMaps = new Map<String, Map<String, List<String>>>
	{

		'RFQI_TESTS__c.Test_Quote_Unit_of_Measure__c' =>
		new Map<String, List<String>>
		{
			'/unit' => new List<String> {'Insertion_Test_Time__c', 'Insertion_Index_Time__c', 'Number_of_Sites_in_Parallel__c'}
			//Salesforce-42 lalit Singh
			//,
			//'/Time and Unit' => new  List<String> {'Insertion_Test_Time__c', 'Insertion_Index_Time__c',  'Temperature__c', 'Number_of_Sites_in_Parallel__c'}
		},

		'RFQI_Electrical_Service__c.Electrical_Services_and_Substrate__c' =>
		new Map<String, List<String>>
		{
			'3d rlc extraction:laminate wirebond' => new List<String> {'Number_of_Balls__c','Number_of_Die__c'},
			'3d rlc extraction:leadframe wirebond' => new List<String> {'Number_of_Balls__c','Number_of_Die__c'},
			'3d rlc extraction:laminate fc' => new List<String> {'Number_of_Balls__c','Number_of_Die__c'},
			'3d rlc extraction:leadframe fc' => new List<String> {'Number_of_Balls__c','Number_of_Die__c'},
			'3d rlc extraction:wafer level' => new List<String> {'Number_of_Balls__c','Number_of_Die__c'},

			's-parameter extraction:laminate wirebond' => new List<String> {'Number_of_Signal_Wirebonds__c', 'Number_of_Layers__c'},
			's-parameter extraction:leadframe wirebond' => new List<String> {'Number_of_Signal_Wirebonds__c'},
			's-parameter extraction:laminate fc' => new List<String> {'Number_of_Signal_Bumps__c', 'Number_of_Layers__c'},
			's-parameter extraction:leadframe fc' => new List<String> {'Number_of_Signal_Bumps__c'},
			's-parameter extraction:wafer level' => new List<String> {'Number_of_Signal_Bumps__c'},

			'ir drop analysis:laminate wirebond' => new List<String> {'Number_of_Power_Domains__c'},
			'ir drop analysis:laminate fc' => new List<String> {'Number_of_Power_Domains__c'},

			'parallel bus analysis (ssn, io supply collapse):laminate wirebond' => new List<String> {'Bus_Width__c', 'Simulation_Direction__c', 'Process_Corner__c'},
			'parallel bus analysis (ssn, io supply collapse):laminate fc' => new List<String> {'Bus_Width__c', 'Simulation_Direction__c', 'Process_Corner__c'},

			'serial link (channel) analysis:leadframe wirebond' => new List<String> {'Number_of_Lanes__c', 'Simulation_Direction_SLA__c'},
			'serial link (channel) analysis:leadframe fc' => new List<String> {'Number_of_Lanes__c', 'Simulation_Direction_SLA__c', 'Buffer_Model_Type__c'},
			'serial link (channel) analysis:laminate wirebond' => new List<String> {'Number_of_Lanes__c', 'Simulation_Direction_SLA__c', 'Buffer_Model_Type__c'},
			'serial link (channel) analysis:laminate fc' => new List<String> {'Number_of_Lanes__c', 'Simulation_Direction_SLA__c'},

			'power integrity analysis (f, t domain):leadframe wirebond' => new List<String> {'Time_or_Frequency_Domain__c', 'Number_of_Power_Domains__c'},
			'power integrity analysis (f, t domain):laminate fc' => new List<String> {'Time_or_Frequency_Domain__c', 'Number_of_Power_Domains__c'},

			'electrical design (co-design):laminate wirebond' => new List<String> {'Package_Description_Extended__c'},
			'electrical design (co-design):leadframe wirebond' => new List<String> {'Package_Description_Extended__c'},
			'electrical design (co-design):laminate fc' => new List<String> {'Package_Description_Extended__c'},
			'electrical design (co-design):leadframe fc' => new List<String> {'Package_Description_Extended__c'},
			'electrical design (co-design):wafer level' => new List<String> {'Package_Description_Extended__c'},

			'current density analysis:laminate wirebond' => new List<String> {'Package_Description_Extended__c'},
			'current density analysis:leadframe wirebond' => new List<String> {'Package_Description_Extended__c'},
			'current density analysis:laminate fc' => new List<String> {'Package_Description_Extended__c'},
			'current density analysis:leadframe fc' => new List<String> {'Package_Description_Extended__c'},
			'current density analysis:wafer level' => new List<String> {'Package_Description_Extended__c'},

			'emi / radiation analysis:laminate wirebond' => new List<String> {'Package_Description_Extended__c'},
			'emi / radiation analysis:leadframe wirebond' => new List<String> {'Package_Description_Extended__c'},
			'emi / radiation analysis:laminate fc' => new List<String> {'Package_Description_Extended__c'},
			'emi / radiation analysis:leadframe fc' => new List<String> {'Package_Description_Extended__c'},
			'emi / radiation analysis:wafer level' => new List<String> {'Package_Description_Extended__c'},

			'other services:laminate wirebond' => new List<String> {'Package_Description_Extended__c'},
			'other services:leadframe wirebond' => new List<String> {'Package_Description_Extended__c'},
			'other services:laminate fc' => new List<String> {'Package_Description_Extended__c'},
			'other services:leadframe fc' => new List<String> {'Package_Description_Extended__c'},
			'other services:wafer level' => new List<String> {'Package_Description_Extended__c'}
		}

		//sample test cases for child objects
		//'RFQI_SOIC_150mil_body__c.Competitor__c' =>
		//new Map<String, List<String>>
		//{
		//	'in house' => new List<String> {'Packing_Method__c'},
		//	'ase' => new List<String> {'Au_Factor__c', 'Wafer_Backgrind__c'}
		//},

		//'RFQIWC_SOIC_150mil_body__c.Wire_Material__c' =>
		//new Map<String, List<String>>
		//{
		//	'pcc' => new List<String> {'Total_2D_Wire_Length__c'}
		//}


	};

	private RequiredFieldHelper() {}

	public static String getRequiredMapStringForField(String packageFamily, String fieldName) {
		String fullFieldName = packageFamily + '.' + fieldName;

		if (requiredFieldMaps.containsKey(fullFieldName)) {
			Map<String, List<String>> requiredValues = requiredFieldMaps.get(fullFieldName);
			String jsonVal = System.JSON.serialize(requiredValues);

			DebugUtils.write('Found rquired values', jsonVal); 

			return jsonVal;
		}

		return null;
	}

}