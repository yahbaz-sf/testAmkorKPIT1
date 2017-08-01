/*************************************************************************
*
* PURPOSE: Controller for the import account file wizard
*
* NOTE: 	The vast majority of all of this logic will be moved off
*       	onto a Heroku service at some point in the near future,
*       	so refactoring this class may not be useful at this time
*
* CLASS: RFQExportController
* CREATED: 3/28/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/

public with sharing class RFQExportController extends BaseController {

	private static String PRICE_COLUMN = 'Amkor Quoted Unit Price';
	
	public RFQ__c rfq;
	public List<RFQ_Item__c> rfqItems;
	
	// Map of Package Family->RFQ Items
	public Map<String, Map<ID, RFQ_Item__c>> pfRfqItems;
	
	public RFQ_Ac_Map__c accountMap { get; set; }
	public List<RFQ_Ac_Map_Column__c>  spreadsheetColumns { get; set; }
	
	// Map of Package Family-> PF Map
	public Map<String, RFQ_Ac_Map_Pf__c> mapPfs { get; set; }
	public List<RFQ_Ac_Map_Pf__c> mapPfList { get; set; }
	
	// Package Family->Column Mappings
	public Map<String, List<RFQ_Ac_Map_Pf_Column__c>> mapPfColumns { get; set; } 
	
	
	// Holder for the CSV file
	public CsvParser.CsvHolder holder { get; set; }
	
	
	public String getCsvOutput() {
		// TODO add in error handling, if blank params or whatnot
		
		String rfqId = getParam('rfqId');
		String selectedItems = getParam('selectedIds');
		
		rfq = RFQDao.getInstance().getRfqById(rfqId);
		rfqItems = RFQItemDao.getInstance().getRfqsByRfqId(rfq.Id);

		// Remove RFQ Items not selected

		for (Integer i = rfqItems.size() - 1; i >= 0; i--) {
			if (!selectedItems.contains(rfqItems[i].Id)) {
				rfqItems.remove(i);
			}
		}
		
		String mapId = rfq.RFQ_Account_File_Map__c;
		if (String.isBlank(mapId)) {
			return 'Error: This RFQ was not imported using an account file mapping and so cannot be exported';
		}
		
		setupMapObjects();
		setupPackageFamilyToRfqItemMap();
		setupCsvHolder();
		
		holder.appendColumn(PRICE_COLUMN);
		
		// Loop through list of RFQ Items (rfqItems)
		Integer rowCount = holder.getLineCount();
		for (Integer i = 0; i < rowCount; i++) {
			RFQ_Item__c rfqItem = rfqItems[i];
			RFQItemWrapper wrapper = new RFQItemWrapper();
			wrapper.rfqItem = rfqItem;
			wrapper.inflateSpecificObjectsFromJson();
			
			// Get the package family mapping from the mapPfs object
			RFQ_Ac_Map_Pf__c packageFamilyMap = mapPfs.get(rfqItem.Package_Family__c);
			
			List<RFQ_Ac_Map_Pf_Column__c> packageFamilyColumns = mapPfColumns.get(rfqItem.Package_Family__c);
			
			for (RFQ_Ac_Map_Pf_Column__c column : packageFamilyColumns) {
				String fieldName = column.RFQI_PF_Field_Def__r.RFQI_Field_Def__r.Name;
				String sectionName = column.RFQI_PF_Field_Def__r.RFQI_Section__r.Name;

				Decimal dIndex = column.Object_Index__c;
				if (dIndex == null || dIndex == 0) dIndex = 0;
				else dIndex = dIndex - 1;
				Integer objectIndex = (Integer)dIndex;

				String sVal = '';

				try {
					sObject sourceObject;
					if (sectionName.equals('Wire Description')) sourceObject = wrapper.wireConfigurations[objectIndex];
					else if (sectionName.equals('Die Description')) sourceObject = wrapper.dieConfigurations[objectIndex];
					else if (sectionName.equals('Passive Description')) sourceObject = wrapper.passiveConfigurations[objectIndex];
					else if (sectionName.equals('Insertion Description')) sourceObject = wrapper.insertionConfigurations[objectIndex];
					else if (sectionName.equals('Service Description')) sourceObject = wrapper.serviceConfigurations[objectIndex];
					else sourceObject = wrapper.specificRfqItem;
					
					Object oVal = sourceObject.get(fieldName);
					sVal = oVal == null ? '' : String.valueOf(oVal);
				} catch (Exception e) {}
				
				holder.putVal(sVal, i, column.RFQ_Ac_Map_Column__c);
				
			}
			
			Decimal price = rfqItem.Price_To_Customer__c;
			if (price == null) price = 0;
			
			System.debug(LoggingLevel.INFO, '### PRICE IS: ' + String.valueOf(price));
			
			holder.putVal(String.valueOf(price), i, PRICE_COLUMN);
		}
		
		
		return holder.toCsvString(); 	
	}
	
	private void setupCsvHolder() {
		List<String> columnHeaders = new List<String>();
		
		for (RFQ_Ac_Map_Column__c column : spreadsheetColumns) {
			columnHeaders.add(column.Name);
		}
		
		holder = new CsvParser.CsvHolder(rfqItems.size(), columnHeaders);	
	}
	
	private void setupPackageFamilyToRfqItemMap() {
		pfRfqItems = new Map<String, Map<ID, RFQ_Item__c>>();
		
		//---Populate the list of PFs and all of the Items for each PF
		for (RFQ_Item__c item : rfqItems) {
			if (!pfRfqItems.containsKey(item.Package_Family__c)) { pfRfqItems.put(item.Package_Family__c, new Map<Id, RFQ_Item__c>()); }
			pfRfqItems.get(item.Package_Family__c).put(item.Id, item);
		}
	}
	
	private void setupMapObjects() {
		String mapId = rfq.RFQ_Account_File_Map__c;
		accountMap = AccountFileMapDao.getInstance().getMapById(mapId);
		spreadSheetColumns = AccountFileMapDao.getInstance().getMapColumnsByMapId(mapId);
		
		mapPfList = AccountFileMapDao.getInstance().getPfMapsByMapId(mapId);
			
		mapPfs = new Map<String, RFQ_Ac_Map_Pf__c>();
		
		mapPfColumns = new Map<String, List<RFQ_Ac_Map_Pf_Column__c>>();
		
		for (RFQ_Ac_Map_Pf__c row : mapPfList) {
			List<RFQ_Ac_Map_Pf_Column__c> pfColumns = AccountFileMapDao.getInstance().getPfFieldMapsByParentId(row.Id);
			mapPfColumns.put(row.Package_Family__c, pfColumns);
			
			mapPfs.put(row.Package_Family__c, row);
		}
	}
	
	
	public class RfqItemHolder {}

}