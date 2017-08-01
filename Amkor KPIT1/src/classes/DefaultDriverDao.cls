public with sharing class DefaultDriverDao {
	

    public static List<RFQI_Default_Driver__c> getDefaultDriversForPackageFamily(Id packageFamilyId) {

        // Raw soql because dynamic SOQL doesn't allow for each param binding w/ sets
        List<RFQI_Default_Driver__c> allDrivers = [select Child__r.Name,Child__r.Type__c,Child__r.Object__c,Child_Value__c,Driver__r.Name,
                                                              Driver_Value__c,Driver__r.Type__c,Driver__r.Object__c, Package_Family__r.Name,
                                                              Match_Def__r.Type__c,Read__c, Apex__c, Apex_Implementation__c from RFQI_Default_Driver__c
                                                              where Package_Family__c = :packageFamilyId];

        return allDrivers;
    }

	public static Map<String,List<RFQI_Default_Driver__c>> getDefaultDriversNameMap(Id packageFamilyId) {

		// Raw soql because dynamic SOQL doesn't allow for each param binding w/ sets
		List<RFQI_Default_Driver__c> allDrivers = getDefaultDriversForPackageFamily(packageFamilyId);

        Map<String,List<RFQI_Default_Driver__c>> driverMap = new Map<String,List<RFQI_Default_Driver__c>>();


        for(RFQI_Default_Driver__c driver : allDrivers) {
        	if(driverMap.containsKey(driver.Driver__r.Name)) {
        		driverMap.get(driver.Driver__r.Name).add(driver);
        	}
        	else {
        		List<RFQI_Default_Driver__c> newList = new List<RFQI_Default_Driver__c>();
        		newList.add(driver);
        		driverMap.put(driver.Driver__r.Name,newList);
        	}
        }

        return driverMap;
	}
}