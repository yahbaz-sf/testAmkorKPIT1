public with sharing class RFQRegionRoles {

    private static Map<String, Set<String>> mSkipQueueMap;

	public static Set<String> getRegions() {
        return RFQ_Region_Roles__c.getAll().keyset();
    }

    public static Map<String, Set<String>> getSkipQueueMap() {
        if (mSkipQueueMap == null) {
            mSkipQueueMap = new Map<String, Set<String>>();
            for (RFQ_Region_Roles__c regionRole : RFQ_Region_Roles__c.getAll().values()) {
                Set<String> skipRoles = new Set<String>();
                mSkipQueueMap.put(regionRole.Name, skipRoles);
                for (String skipQueueRole : regionRole.Skip_Queue_Roles__c.split(',')) {
                    skipRoles.add(skipQueueRole);
                }
            }
        }
        return mSkipQueueMap;
    }

    public static Boolean getShouldSkipQueue(String region, String roleName) {
        return getIsValidRegion(region) && getSkipQueueMap().get(region).contains(roleName);
    }

    public static Boolean getIsValidRegion(String region) {
        return getSkipQueueMap().containsKey(region);
    }

    public static Boolean getIsInvalidRegion(String region) {
        return !getSkipQueueMap().containsKey(region);
    }
}