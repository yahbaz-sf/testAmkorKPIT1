/*************************************************************************
* 
* PURPOSE:  This class is for populating defaults for NRE Others
* CLASS: NREHelper
* CREATED: 02/27/14 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
public with sharing class NREHelper {

	public static Map<String, Map<String, String>> nreOtherMap = new Map<String, Map<String, String>>{
			'RFQI_TESTS__C' => 
			new Map<String, String>{
				'Custom Tray' => '0',
				'Custom Tape' => '0'
			}
		};

	public static String getNREMapStringForPackageFamily(String packageFamily) {

		if (nreOtherMap.containsKey(packageFamily)) {
			Map<String, String> otherValues = nreOtherMap.get(packageFamily);
			String jsonVal = System.JSON.serialize(otherValues);

			System.debug('### Found Other values: ' + jsonVal); 

			return jsonVal;
		}
		return null;
	}

	public static void updatePackageFamilyNREConfigs() {
		List<Package_Family__c> families = [select Id, Specific_RFQ_Item_Object__c, Default_NRE_Configs__c from Package_Family__c];
		for(Package_Family__c family : families) {
			family.Default_NRE_Configs__c = getNREMapStringForPackageFamily(family.Specific_RFQ_Item_Object__c.toUpperCase());
		}
		update families;
	}
}