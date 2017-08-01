@isTest
public with sharing class AccountAdderChargeControllerTest {
	public static testmethod void testGetters()
	{
		setupPBGA();
		Package_Family__c pf = setupTest();
		setupFields(pf);

		Account a = SharedUnitTestUtils.createTestSBU();
		PageUtil.putParam('accountId', a.Id);

		AccountAdderChargeController cont = new AccountAdderChargeController();

		cont.adderCost.Product_Group__c = pf.Product_Group__c;
		System.assert(cont.getCanEdit());
		System.assert(cont.getProductGroups().size() > 0);
		System.assert(cont.getPackageFamilies().size() > 0);

		cont.adderCost.Package_Family__c = pf.Id;
		//more items than --None--
		System.assert(cont.getAdderFields().size() > 1);


		System.assert(cont.cancel().getURL() == '/' + a.Id);
	}

	public static testmethod void testmatchCriteria()
	{
		setupPBGA();
		Package_Family__c pf = setupTest();
		setupFields(pf);

		Account a = SharedUnitTestUtils.createTestSBU();
		PageUtil.putParam('accountId', a.Id);

		AccountAdderChargeController cont = new AccountAdderChargeController();
		cont.adderCost.Product_Group__c = pf.Product_Group__c;
		cont.adderCost.Package_Family__c = pf.Id;
		String adderId = [SELECT Id FROM RFQI_PF_Field_Def__c WHERE RFQI_Field_Def__r.Name='Extra_Plasma__c' AND Package_Family__r.Name='Test'][0].Id;
		DebugUtils.write('adderId', adderId);
		cont.adderCost.Adder__c = adderId;
		cont.adderId = adderId;
		cont.adderCost.Charge_Amount__c = 5;
		cont.addMatchCriteria();
		cont.addMatchCriteria();
		for (AccountAdderChargeController.MatchCriteriaHolder match : cont.matchCriteria)
		{
			match.obj.Body_Size__c = '1';
			match.obj.Charge_Amount__c = 15;
		}

		System.assert(cont.matchCriteria.size() == 2);
		cont.saveChargeItem();

		RFQ_Account_Adder_Cost__c adder = [SELECT Id FROM RFQ_Account_Adder_Cost__c];

		ApexPages.StandardController sc = new ApexPages.StandardController(adder);
		cont = new AccountAdderChargeController(sc);
		cont.addMatchCriteria();
		cont.addMatchCriteria();


		cont.matchCriteria[1].selected = true;
		cont.matchCriteria[2].selected = true;

		cont.removeSelectedCriteria();
		System.assert(cont.matchCriteria.size() == 2, cont.matchCriteria.size());

	}


	private static void setupPBGA()
	{
		Product_Group__c pg = new Product_Group__c(Name='PBGA');
		pg.Cost_Model_Implementation__c = 'CMPBGABuilder';
		pg.Wire_Calculation_Implementation__c = 'CMWireCalcBase';
		pg.Generated_Price_Requires_BU_Review__c = true;
		insert pg;

		List<Package_Family__c> families = new List<Package_Family__c>();
        FieldBuilderHelper.addPf('PBGA', pg, 'RFQI_PBGA__c', 'RFQIWC_PBGA__c', 'RFQIDC_PBGA__c', families, true);
		insert families;

	}

	private static Package_Family__c setupTest()
	{

		Product_Group__c pg = SharedUnitTestUtils.createProductGroupFromName('Standalone Services', false);
		insert pg;

		Package_Family__c pf = SharedUnitTestUtils.createPackageFamilyFromName('Test', pg, 'RFQI_TESTS__c');
		pf.Default_Number_Of_Insertions__c = 1;
		pf.Specific_Insertion_Configuration_Object__c = 'RFQIIC_TESTS__c';
		pf.Cost_Model_Implementation__c = 'CMTestBuilder';

		insert pf;
		return pf;

	}

	private static void setupFields(Package_Family__c pf)
	{
		RFQI_Section__c section = new RFQI_Section__c(Name='Adders');
		insert section;

		List<RFQI_Field_Def__c> defs = new List<RFQI_Field_Def__c>();

		defs.add(new RFQI_Field_Def__c(Name='Extra_Plasma__c'));
		defs.add(new RFQI_Field_Def__c(Name='Plasma_Before_Wire_Bond__c'));
		defs.add(new RFQI_Field_Def__c(Name='Plasma_Before_Die_Attach__c'));
		defs.add(new RFQI_Field_Def__c(Name='Optical_Inspections__c'));
		defs.add(new RFQI_Field_Def__c(Name='Plasma_Before_Mold__c'));
		defs.add(new RFQI_Field_Def__c(Name='Optical_Inspection_1__c'));
		defs.add(new RFQI_Field_Def__c(Name='Optical_Inspection_2__c'));
		defs.add(new RFQI_Field_Def__c(Name='Optical_Inspection_3__c'));
		defs.add(new RFQI_Field_Def__c(Name='Bake_Dry_Pack__c'));
		defs.add(new RFQI_Field_Def__c(Name='Temperature_Cycle__c'));
		defs.add(new RFQI_Field_Def__c(Name='Bake__c'));
		insert defs;

        FieldBuilderHelper helper = new FieldBuilderHelper(pf.Name);

		helper.add('Adders', 'Extra_Plasma__c', 5000, true);
		helper.add('Adders', 'Plasma_Before_Wire_Bond__c', 5010, true);
		helper.add('Adders', 'Plasma_Before_Die_Attach__c', 5020, true);
		helper.add('Adders', 'Optical_Inspections__c', 5030, true);    
		helper.add('Adders', 'Plasma_Before_Mold__c', 5040, true);
		helper.add('Adders', 'Optical_Inspection_1__c', 5050, true);
		helper.add('Adders', 'Optical_Inspection_2__c', 5060, true);
		helper.add('Adders', 'Optical_Inspection_3__c', 5070, true);
		helper.add('Adders', 'Bake_Dry_Pack__c', 5080, true);
		helper.add('Adders', 'Temperature_Cycle__c', 5090, true);
		helper.add('Adders', 'Bake__c', 5100, true);

        helper.insertFields();

	}
}