/*************************************************************************
*
* PURPOSE: Tests the RFQBUImportController Class
*
* CLASS: RFQBUImportControllerTest
* CREATED: 10/16/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/

@isTest
private class RFQBUImportControllerTest {
	
	static testMethod void testBuImport() {

		RFQAdminInstaller.install();
		PBGAInstaller.install();

		//an incremental installer added the field for total cost, so needs to be added
		RFQI_Field_Def__c def = new RFQI_Field_Def__c(Name='Total_Cost_with_Substrate_New__c');
		insert def;

		Package_Family__c pf = [SELECT Id FROM Package_Family__c WHERE Name='PBGA'];
		RFQI_Section__c section = [SELECT Id FROM RFQI_Section__c WHERE Name='Cost and Price'];

		RFQI_PF_Field_Def__c pfDef = new RFQI_PF_Field_Def__c();
		pfDef.RFQI_Field_Def__c = def.Id;
		pfDef.Package_Family__c = pf.Id;
		pfDef.RFQI_Section__c = section.Id;
		insert pfDef;

		RFQItemWrapper item = SharedUnitTestUtils.createLineItem('PBGA');
		item.volumeList.add(new RFQIVolume(false));

		// Save the line item to populate the JSON fields
		RFQItemDao.getInstance().saveLineItem(item);

		Test.startTest();
		String csvString = RFQBuExportController.RFQI_NUM_COLUMN + ',Substrate/LF ,CLAM WB ,Customer Target Price ,%GM ,Materials Wire ,CLAM Others ,Sales Target Price ,BU Price ,Materials ODM - Other ,CLAM ,Competitor ,% IRR ,Materials ODM - Mold ,Substrate % Markup ,Heatspreader ,%CM ,Total Materials ,Substrate Unit ,Complex Adder ,Apply 3D Factor ,Assembly % ,Substrate Waste ,Mold Wastage ,LGP Market Price ,Capacity UE Rate ,Operating Cash/u ,Total Cost\n';
		csvString += item.rfqItem.Name + ',1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27\n';
		csvString +=  'Additional volume 1,1,2,3,1,5,6,7,2,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,3';

		System.debug('CSV String is:' + csvString);

		Blob csvBlob = Blob.valueOf(csvString);


		PageUtil.putParam('rfqId', item.rfqItem.RFQ__c);

		RFQBUImportController cont = new RFQBUImportController();

		cont.fileContent = csvBlob;
		cont.fileName = 'SomeFile.csv';


		cont.import();


		item = RFQItemDao.getInstance().getWrapperById(item.rfqItem.Id);

		Decimal MaterialsSubstrate = (Decimal)item.specificRfqItem.get('Materials_Substrate__c');
		Decimal CLAMWB = (Decimal)item.specificRfqItem.get('CLAM_WB__c');
		Decimal CustomerTargetPrice = (Decimal)item.specificRfqItem.get('Customer_Target_Price__c');
		Decimal BUPricePercGM = (Decimal)item.specificRfqItem.get('BU_Price_Perc_GM__c');
		Decimal MaterialsWire = (Decimal)item.specificRfqItem.get('Materials_Wire__c');
		Decimal CLAMOthers = (Decimal)item.specificRfqItem.get('CLAM_Others__c');
		Decimal SalesTargetPrice = (Decimal)item.specificRfqItem.get('Sales_Target_Price__c');
		Decimal BUPrice = (Decimal)item.specificRfqItem.get('BU_Price__c');
		Decimal MaterialsODMOther = (Decimal)item.specificRfqItem.get('Materials_ODM_Other__c');
		Decimal CLAMTotal = (Decimal)item.specificRfqItem.get('CLAM_Total__c');
		Decimal PercIRRNew = (Decimal)item.specificRfqItem.get('Perc_IRR_New__c');
		Decimal MaterialsODMMold = (Decimal)item.specificRfqItem.get('Materials_ODM_Mold__c');
		Decimal SubstratePercMarkup = (Decimal)item.specificRfqItem.get('Substrate_Perc_Markup__c');
		Decimal PercCM = (Decimal)item.specificRfqItem.get('Perc_CM__c');
		Decimal TotalMaterials = (Decimal)item.specificRfqItem.get('Total_Materials__c');
		Decimal SubstrateUnit = (Decimal)item.specificRfqItem.get('Substrate_Unit__c');
		Decimal Assembly = (Decimal)item.specificRfqItem.get('Assembly__c');
		Decimal SubstrateWaste = (Decimal)item.specificRfqItem.get('Substrate_Waste__c');
		Decimal MoldWastage = (Decimal)item.specificRfqItem.get('Mold_Wastage__c');
		Decimal LGPMarketPrice = (Decimal)item.specificRfqItem.get('LGP_Market_Price__c');
		Decimal CapacityUERate = (Decimal)item.specificRfqItem.get('Capacity_UE_Rate__c');
		Decimal OpCash = (Decimal)item.specificRfqItem.get('Operating_Cash_u__c');
		Decimal TotalCost = (Decimal)item.specificRfqItem.get('Total_Cost_with_Substrate_New__c');

		Decimal volGM = item.volumeList[0].margin;
		Decimal volPrice = item.volumeList[0].price;
		Decimal volTotalCost = item.volumeList[0].costLessSubs;

		System.assertEquals(MaterialsSubstrate, 1, 'Should have updated the Materials Substrate field');
		System.assertEquals(CLAMWB, 2, 'Should have updated the CLAM WB field');
		System.assertEquals(CustomerTargetPrice, 3, 'Should have updated the Customer Target Price field');
		System.assertEquals(BUPricePercGM, 4, 'Should have updated the BU Price % GM field');
		System.assertEquals(MaterialsWire, 5, 'Should have updated the Materials Wire field');
		System.assertEquals(CLAMOthers, 6, 'Should have updated the CLAM Others field');
		System.assertEquals(SalesTargetPrice, 7, 'Should have updated the Sales Target Price field');
		System.assertEquals(BUPrice, 8, 'Should have updated the BU Price field');
		System.assertEquals(MaterialsODMOther, 9, 'Should have updated the Materials ODM - Other field');
		System.assertEquals(CLAMTotal, 10, 'Should have updated the CLAM Total field');
		System.assertEquals(PercIRRNew, 12, 'Should have updated the % IRR field');
		System.assertEquals(MaterialsODMMold, 13, 'Should have updated the Materials ODM - Mold field');
		System.assertEquals(SubstratePercMarkup, 14, 'Should have updated the Substrate % Markup field');
		System.assertEquals(PercCM, 16, 'Should have updated the %CM field');
		System.assertEquals(TotalMaterials, 17, 'Should have updated the Total Materials field');
		System.assertEquals(SubstrateUnit, 18, 'Should have updated the Substrate Unit field');
		System.assertEquals(Assembly, 21, 'Should have updated the Assembly % field');
		System.assertEquals(SubstrateWaste, 22, 'Should have updated the Substrate Waste field');
		System.assertEquals(MoldWastage, 23, 'Should have updated the Mold Wastage field');
		System.assertEquals(LGPMarketPrice, 24, 'Should have updated the LGP Market Price field');
		System.assertEquals(CapacityUERate, 25, 'Should have updated the Capacity UE Rate field');
		System.assertEquals(OpCash, 26, 'Should have updated the Operating Cash U field');
		System.assertEquals(TotalCost, 27, 'Should have updated the Total Cost field');

		System.assertEquals(volGM, 1, 'Should have updated the volume\'s Margin field');
		System.assertEquals(volPrice, 2, 'Should have updated the volume\'s Price field');
		System.assertEquals(volTotalCost, 3, 'Should have updated the volume\'s Total Cost field');

		System.assert(cont.success, 'Import should have completed and success flag set');
		Test.stopTest();
	}


	static testMethod void testBuMultiExportSelect() {
		RFQAdminInstaller.install();
		PBGAInstaller.install();

		RFQItemWrapper item = SharedUnitTestUtils.createLineItem('PBGA');
		item.rfqitem.Status__c = RFQItemDao.STATUS_PRICE_PENDING_BU;
		update item.rfqitem;

		PageUtil.putParam('rfqId', item.rfqItem.RFQ__c);

		RFQBUMultiExportController cont = new RFQBUMultiExportController();

		System.assertEquals(cont.packageFamilyList.size(), 1, 'Should have the PBGA package family');


		List<SelectOption> pfOptions = cont.getPackageFamilyOptions();
		System.assertEquals(pfOptions.size(), 2, 'Should have PBGA and --Select-- options');

		PageReference pg = cont.returnToRfq();

		System.assertNotEquals(pg, null);

		// Test exporting when no items selected
		pg = cont.export();
		System.assertEquals(null, pg, 'Should not have redirected to the export page');

		System.assertEquals(cont.currentItems, null, 'Should not be any available items because no PF selected');

		cont.selectedPackageFamily = item.rfqItem.Package_Family__c;
		cont.setItemList();

		System.assertEquals(cont.currentItems.size(), 1, 'The one item should now be available for selection');

		cont.currentItems[0].selected = true;

		pg  = cont.export();

		System.assertNotEquals(pg, null, 'Should have redirected to the export page');

	}
	
}