@isTest
private class PFAttributeExportControllerTest {
	
	static testMethod void testAttributeExport() {
		RFQAdminInstaller.install();
		PBGAInstaller.install();

		PageUtil.putParam('packageFamilyId', [Select Id from Package_Family__c where Name =: 'PBGA'].Id);

		PFAttributeExportController cont = new PFAttributeExportController();

		System.assertNotEquals(cont.attributes.size(), 0, 'Should have created some attributes');

		for (PFAttributeExportController.FieldHolder attribute : cont.attributes) {
			System.assert(!StringUtils.isBlank(attribute.fieldLabel));
			System.assert(!StringUtils.isBlank(attribute.dataType));
		}

		PageUtil.putParam('showCpnOnly', 'true');

		cont = new PFAttributeExportController();

		for (PFAttributeExportController.FieldHolder attribute : cont.attributes) {
			System.assert(attribute.isCpnAttribute, 'All attributes should be CPN attributes when showing only CPNs');
		}

	}
	
}