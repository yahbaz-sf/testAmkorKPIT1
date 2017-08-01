/*************************************************************************
*
* PURPOSE: Tests the CPNAddController class
*
* CLASS: CPNAddControllerTest
* CREATED: 3/12/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/
@isTest
private class CPNAddControllerTest {

    static testMethod void testCpnAddController() {
    	
    	// Install layout records that are needed for the page
    	RFQAdminInstaller.install();
    	PBGAInstaller.installTest();
    	Test.startTest();
		CPNAddController controller = new CPNAddController(null);
		
		// Test page when it hasn't been set up yet 
		
		System.assert(!controller.getShowAttributes(), 'Don\'t show RFQ Item fields when no package selected');
		
		List<SelectOption> packageGroups = controller.getPackageGroups();
		
		System.assert(packageGroups.size() > 1, 'At least one package group available on page (not including dummy select option)');
		
		List<SelectOption> pfOptions = controller.getPackageFamilies();
		
		System.assert(pfOptions.size() == 1, 'No package groups selected yet so only the dummy PF is available');
		
		// Now select a package group and test everything is set up right
		
		controller.itemPackageGroup = packageGroups[1].getValue();
		
		pfOptions = controller.getPackageFamilies();
		
		System.assert(pfOptions.size() > 1, 'Now that package group is selected PFs are available');
		
		System.assert(controller.itemWrapper == null, 'PF not selected yet, so specificRfqItem is null');

		Package_Family__c pbga = [Select Id from Package_Family__c where Name =: 'PBGA'];
		
		// Now select a package family
		
		controller.itemPackageFamily = pbga.Id;
		
		controller.setSelectedPackageFamily();

		System.debug('### Number of wire configs: ' + controller.itemWrapper.wireConfigurations.size());
		
		System.assert(controller.itemWrapper != null, 'Now that PF is selected there should be an RFQ Item holder obj');
		System.assert(controller.itemWrapper.wireConfigurations != null && controller.itemWrapper.wireConfigurations.size() > 0, 'At least one wire config');
		System.assert(controller.itemWrapper.dieConfigurations != null && controller.itemWrapper.dieConfigurations.size() > 0, 'At least one die config');
		System.assert(controller.layout != null, 'Page layout should be populated');

		// Test only showing CPN Attributes

		for (RFQILayoutSection section : controller.layout.sections) {
			List<RFQISectionAttribute> attributes = section.attributes;

			for (RFQISectionAttribute attribute : attributes) {
				System.assert(attribute.isCpnAttribute, 'Should only be using CPN attributes');
			}
		}
		
		// Test add/remove wire config methods
		
		Integer oldSize = controller.itemWrapper.wireConfigurations.size();
		controller.removeWireConfiguration();
		
		System.assert(controller.itemWrapper.wireConfigurations.size() == oldSize, 'Should not be able to remove wire config when only one on page');
		
		controller.addWireConfiguration();
		
		System.assert(controller.itemWrapper.wireConfigurations.size() == oldSize + 1, 'Should have added one wire config');
		
		controller.removeWireConfiguration();
		
		System.assert(controller.itemWrapper.wireConfigurations.size() == oldSize, 'Should have removed one wire config');
		
		// Test cancelling out of creating the CPN
		
		PageReference pf = controller.cancel();
		System.assert(pf.getUrl() != null, 'Should have redirected to the CPN list page');
				
		// Test inserting the CPN
		
		pf = controller.createCpn();
		
		System.assert(pf.getUrl() != null, 'Should have redirected to the new CPN');
		
		List<Configured_Part_Number__c> cpnList = [Select Id from Configured_Part_Number__c];
		System.assert(cpnList.size() > 0, 'Should now be at least one CPN in the system');
		Test.stopTest();
    }
}