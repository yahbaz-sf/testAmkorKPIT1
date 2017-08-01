public with sharing class ImportDefaultsController extends BaseController {

	public String rfqId { get; set; }


	public Integer numberRemaining { get; set; }

	public ImportDefaultsController() {
		rfqId = getParam('rfqId');

		List<RFQ_Item__c> remainingItems = [select Id, Package_Family__c from RFQ_Item__c where RFQ__c =: rfqId and Status__c =: RFQItemDao.STATUS_IMPORT_PENDING];
		numberRemaining = remainingItems.size();
	}

	public void submitNextItem() {
		rfqId = getParam('rfqId');
		
		List<RFQ_Item__c> remainingItems = [select Id, Package_Family__c from RFQ_Item__c where RFQ__c =: rfqId and Status__c =: RFQItemDao.STATUS_IMPORT_PENDING];
		numberRemaining = remainingItems.size();
		
		if (StringUtils.isBlank(rfqId)) {
			throw new FieldBuilderHelperException('No RFQ');
		}

		if (numberRemaining > 0) {
			RFQ_Item__c nextItem = remainingItems[0];

			List<RFQI_Default_Driver__c> defaultDrivers = DefaultDriverDao.getDefaultDriversForPackageFamily(nextItem.Package_Family__c);

			RFQItemWrapper wrapper = RFQItemDao.getInstance().getWrapperById(nextItem.Id);

			applyDefaultDrivers(wrapper, defaultDrivers);
		}
		else {
			addConfirm('');
		}
	}

	private void applyDefaultDrivers(RFQItemWrapper wrapper, List<RFQI_Default_Driver__c> defaultDrivers) {
		String itemObject = wrapper.packageFamily.Specific_RFQ_Item_Object__c;
		String wireObject = wrapper.packageFamily.Specific_Wire_Configuration_Object__c;
		String dieObject = wrapper.packageFamily.Specific_Die_Configuration_Object__c;
		String passiveObject = wrapper.packageFamily.Specific_Passive_Configuration_Object__c;
		String insertionObject = wrapper.packageFamily.Specific_Insertion_Configuration_Object__c;
		
		BaseDao itemDao = new BaseDao(itemObject);
		BaseDao wireDao = StringUtils.isBlank(wireObject) ? null : new BaseDao(wireObject);
		BaseDao dieDao = StringUtils.isBlank(dieObject) ? null : new BaseDao(dieObject);
		BaseDao passiveDao = StringUtils.isBlank(passiveObject) ? null : new BaseDao(passiveObject);
		BaseDao insertionDao = StringUtils.isBlank(insertionObject) ? null : new BaseDao(insertionObject);
		

		

		for (RFQI_Default_Driver__c driver : defaultDrivers) {

			String fieldName = driver.Driver__r.Name;
			String oType = driver.Driver__r.Object__c;
	        String fieldValue = String.valueOf(wrapper.getAttribute(fieldName, oType, 0));

	        // If parent driver value is not null
	        if (!StringUtils.isBlank(fieldValue)) {

	            Object val = null;
		        String childVal = driver.Child_Value__c;

		        Object childFieldVal = wrapper.getAttribute(driver.Child__r.Name, driver.Child__r.Object__c, 0);

		        // Only apply the default value if the child value is null or 0
		        if (childFieldVal == null || childFieldVal == 0) {
		            if (driver.Read__c) {
		                if (driver.Driver_Value__c != null) {

		                	// Re-save and re-grab to refresh the formula
		                	if (!RFQItemDao.getInstance().saveLineItem(wrapper)) break;
							refreshObjectForWrapper(wrapper, oType, itemDao, wireDao, dieDao, passiveDao, insertionDao);

							// Get the formula field value
		                    Object rawVal = wrapper.getAttribute(driver.Driver_Value__c, oType, 0);
		                    
		                    if (rawVal != null){
		                        String strVal = String.valueOf(rawVal);
		                        if (!StringUtils.isBlank(strVal)) {
		                            val = DataUtils.convert(strVal, driver.Child__r.Type__c);
		                            wrapper.setAttribute(driver.Child__r.Name, driver.Child__r.Object__c, val, false);   
		                        }
		                    }
		                }
		            }
			        else if (fieldValue == driver.Driver_Value__c) {
		                val = DataUtils.convert(childVal,driver.Child__r.Type__c);
			            wrapper.setAttribute(driver.Child__r.Name, driver.Child__r.Object__c, val, false);
			        }
		    	}
	        }
        }

        wrapper.rfqItem.Status__c = RFQItemDao.STATUS_READY_TO_PRICE;

        RFQItemDao.getInstance().saveLineItem(wrapper, true);
	}

	private void refreshObjectForWrapper(RFQItemWrapper wrapper, String objectType, BaseDao itemDao, BaseDao wireDao, BaseDao dieDao, BaseDao passiveDao, BaseDao insertionDao) {
		if (objectType == RFQItemWrapper.PACKAGE_OBJECT) {
			wrapper.specificRfqItem = itemDao.getSObjectById(wrapper.specificRfqItem.Id);
		}
		else if (objectType == RFQItemWrapper.WIRE_OBJECT) {
			wrapper.wireConfigurations = wireDao.getSObjects('Parent__c = ' + BaseDao.quote(wrapper.specificRfqItem.Id));  
		}
		else if (objectType == RFQItemWrapper.DIE_OBJECT) {
			wrapper.dieConfigurations = dieDao.getSObjects('Parent__c = ' + BaseDao.quote(wrapper.specificRfqItem.Id));  
		}
		else if (objectType == RFQItemWrapper.INSERTION_OBJECT) {
			wrapper.insertionConfigurations = insertionDao.getSObjects('Parent__c = ' + BaseDao.quote(wrapper.specificRfqItem.Id));  
		}
		else if (objectType == RFQItemWrapper.PASSIVE_OBJECT) {
			wrapper.passiveConfigurations = passiveDao.getSObjects('Parent__c = ' + BaseDao.quote(wrapper.specificRfqItem.Id));  
		}
	}
}