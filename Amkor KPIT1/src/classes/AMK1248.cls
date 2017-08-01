/*************************************************************************
* 
* PURPOSE:  this class seeds fresh RFQ Item Field Definition specifically
*           for the FCCSP package families (cloned from SOIC150Installer
*           for the purposes of generalization), for prod release
*         
* CLASS: AMK1248
* CREATED: 08/06/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
global class AMK1248 {

	global static void install() {
		installRFQFD();
		changeFD();
		deletePFFD('FC CSP');
		deletePFFD('FC SCSP');
		changePFFD('FC CSP');
		changePFFD('FC SCSP');
		installPFFD('FC CSP');
		installPFFD('FC SCSP');
		installDD('FC CSP');
		installDD('FC SCSP');

	}
	public static void changeFD(){
		List<RFQI_Field_Def__c> fieldDef = [select Id, Name from RFQI_Field_Def__c];

		for (RFQI_Field_Def__c fields : fieldDef) {
			if(fields.Name == 'Dielectric_Thickness__c')
				{fields.Object__c='Package';}
			if(fields.Name == 'Dielectric_Type__c')
				{fields.Object__c='Package';}
		}
		update fieldDef;

	}

	private static void installDD(string packageFamily) {
		Package_Family__c pf = [select Id from Package_Family__c where Name =: packageFamily];

        Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
            for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
            fieldDefs.put(fieldDef.Name, fieldDef);
            }

		FieldBuilderHelper.installDefaultDriversMath(pf, fieldDefs.get('BGA__c'), 'BGA__c', fieldDefs.get('Ball_Pitch__c'));
	}

	private static void installRFQFD() {
		List<RFQI_Field_Def__c> defs = new List<RFQI_Field_Def__c>();

		defs.add(new RFQI_Field_Def__c(Name = 'BGA_IGA_Top_Surface_Finish_Other__c', Object__c='Package', Type__c = 'String'));
		defs.add(new RFQI_Field_Def__c(Name = 'Bond_Finger_Surface_Finish_Other__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Minimum_Line_Core__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Minimum_Space_Core__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'SideSpacer__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'SiNode__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'SMD_Top_Surface_Finish_Other__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'SMD_Bottom_Surface_Finish_Other__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Dam_Thickness__c', Object__c='Package', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Dam_Material__c', Object__c='Package', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Stackup__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BGA_IGA_Bottom_Surface_Finish_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Fiducial_Bottom_Surface_Finish_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Fiducial_Top_Surface_Finish_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Strip_Surface_Finish_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BGA_IGA_Pad_Metal_Size_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BGA_IGA_Pad_Opening_Other__c'));

        insert defs;


	}

	private static List<RFQI_PF_Field_Def__c> installPFFD(string pf) {
		FieldBuilderHelper helper = new FieldBuilderHelper(pf);

		helper.add('Package Description', 'SiNode__c', 2100, true);
        helper.add('Package Description', 'SideSpacer__c', 2110, true);
        helper.add('Package Description', 'Max_package_Thickness__c', 2140, true);

        helper.add('Substrate Description', 'Minimum_Line_Core__c', 3110, true);
        helper.add('Substrate Description', 'Minimum_Space_Core__c', 3120, true);
        helper.add('Substrate Description', 'Substrate_Stackup__c', 3300, true, false, false, false, 'Substrate_Stackup_Other__c');
        helper.add('Substrate Description', 'Dielectric_Thickness__c', 3310, true);
        helper.add('Substrate Description', 'Dielectric_Type__c', 3320, true);
        helper.add('Substrate Description', 'Copper_Thickness_Core__c', 3330, true);
        helper.add('Substrate Description', 'Copper_Thickness_External__c', 3340, true);
        helper.add('Substrate Description', 'Copper_Thickness_Internal__c', 3350, true);
        helper.add('Substrate Description', 'Solder_Mask_Dam__c', 3360, true);
        helper.add('Substrate Description', 'Substrate_Dam_Thickness__c', 3370, true);
        helper.add('Substrate Description', 'Substrate_Dam_Material__c', 3380, true);
        helper.add('Substrate Description', 'BGA_IGA_Top_Surface_Finish_Other__c', 3390, true, false, false, false, 'BGA_IGA_Top_Surface_Finish__c');
        helper.add('Substrate Description', 'Bond_Finger_Surface_Finish_Other__c', 3400, true, false, false, false, 'Bond_Finger_Surface_Finish__c');
        helper.add('Substrate Description', 'SMD_Top_Surface_Finish_Other__c', 3410, true, false, false, false, 'SMD_Top_Surface_Finish__c');
        helper.add('Substrate Description', 'SMD_Bottom_Surface_Finish_Other__c', 3420, true, false, false, false, 'SMD_Bottom_Surface_Finish__c');
        helper.add('Substrate Description', 'BGA_IGA_Bottom_Surface_Finish_Other__c', 3430, true, false, false, false, 'BGA_IGA_Bottom_Surface_Finish__c');
        helper.add('Substrate Description', 'Fiducial_Bottom_Surface_Finish_Other__c', 3440, true, false, false, false, 'Fiducial_Bottom_Surface_Finish__c');
        helper.add('Substrate Description', 'Strip_Surface_Finish_Other__c', 3450, true, false, false, false, 'Strip_Surface_Finish__c');
        helper.add('Substrate Description', 'BGA_IGA_Pad_Metal_Size_Other__c', 3460, true, false, false, false, 'BGA_IGA_Pad_Metal_Size__c');
        helper.add('Substrate Description', 'BGA_IGA_Pad_Opening_Other__c', 3470, true, false, false, false, 'BGA_IGA_Pad_Opening__c');
        helper.add('Substrate Description', 'Substrate_Stackup__c', 3480, true, false, false, false, 'Substrate_Stackup_Other__c');
        
        helper.add('Die Description', 'Wafer_Dicing__c', 3100, true);
        


        helper.insertFields();
        
        return helper.getPfFieldDefs();
	}

	private static void deletePFFD(string pf) {
		List<RFQI_PF_Field_Def__c> fields = [Select Id, RFQI_Field_Def__r.Name from RFQI_PF_Field_Def__c where RFQI_PF_Field_Def__c.Package_Family__r.Name =: pf];
		List<RFQI_PF_Field_Def__c> fieldsToDelete = new List<RFQI_PF_Field_Def__c>();

		for  (RFQI_PF_Field_Def__c field : fields) {
			string fieldName = field.RFQI_Field_Def__r.Name;

			if (fieldName == 'Si_Node__c' ||
				fieldName == 'Side_Spacer__c' ||
				fieldName == 'Wafer_Probe_Yield__c' ||
				fieldName == 'Wafer_Stealth_Dicing__c' ||
				fieldName == 'Laser_Groove__c' )
			{fieldsToDelete.add(field);}
		}

		delete fieldsToDelete;
	}

	private static void changePFFD(string pf) {
		List<RFQI_PF_Field_Def__c> fields = [Select Id, RFQI_Field_Def__r.Name, Sequence__c from RFQI_PF_Field_Def__c where RFQI_PF_Field_Def__c.Package_Family__r.Name =: pf];

		for  (RFQI_PF_Field_Def__c field : fields) {
		if(field.RFQI_Field_Def__r.Name == 'Body_Size_X__c')
			{field.Default_Driver__c = false;}
		if(field.RFQI_Field_Def__r.Name == 'Body_Size_Y__c')
			{field.Default_Driver__c = false;}
		if(field.RFQI_Field_Def__r.Name == 'Lid__c')
			{field.Sequence__c = 2150;}
		if(field.RFQI_Field_Def__r.Name == 'Lid_Attach_Type__c')
			{field.Sequence__c = 2160;}
		if(field.RFQI_Field_Def__r.Name == 'BGA__c')
			{field.Default_Driver__c = true;}
		if(field.RFQI_Field_Def__r.Name == 'Minimum_Bond_Finger_Pitch__c')
			{field.Sequence__c = 3130;}
		if(field.RFQI_Field_Def__r.Name == 'Total_Number_of_Vias__c')
			{field.Sequence__c = 3140;}
		if(field.RFQI_Field_Def__r.Name == 'Mech_Via_Capture_Pad_Diam__c')
			{field.Sequence__c = 3150;}
		if(field.RFQI_Field_Def__r.Name == 'Number_of_Mech_Vias__c')
			{field.Sequence__c = 3160;}
		if(field.RFQI_Field_Def__r.Name == 'Laser_Via_Capture_Pad_Diam__c')
			{field.Sequence__c = 3170; field.Other_Field__c = 'Laser_Via_Capture_Pad_Diam_Other__c';}
		if(field.RFQI_Field_Def__r.Name == 'Number_of_Laser_Vias__c')
			{field.Sequence__c = 3180;}
		if(field.RFQI_Field_Def__r.Name == 'Via_Fill__c')
			{field.Sequence__c = 3190;}
		if(field.RFQI_Field_Def__r.Name == 'Soldermask_Registration__c')
			{field.Sequence__c = 3200; field.Other_Field__c = 'Solder_mask_Registration__c';}
		if(field.RFQI_Field_Def__r.Name == 'Soldermask_Material__c')
			{field.Sequence__c = 3210;}
		if(field.RFQI_Field_Def__r.Name == 'Core_Material__c')
			{field.Sequence__c = 3220;}
		if(field.RFQI_Field_Def__r.Name == 'Core_Thickness__c')
			{field.Sequence__c = 3230;}
		if(field.RFQI_Field_Def__r.Name == 'Substrate_Thickness__c')
			{field.Sequence__c = 3240;}
		if(field.RFQI_Field_Def__r.Name == 'Plating__c')
			{field.Sequence__c = 3250;}
		if(field.RFQI_Field_Def__r.Name == 'Metal_Finish__c')
			{field.Sequence__c = 3260; field.Other_Field__c = 'Metal_Finish_Other__c';}
		if(field.RFQI_Field_Def__r.Name == 'Substrate_Supplier__c')
			{field.Sequence__c = 3270;}
		if(field.RFQI_Field_Def__r.Name == 'Restricted_Substrate_Supplier__c')
			{field.Sequence__c = 3280;}
		if(field.RFQI_Field_Def__r.Name == 'Special_Options__c')
			{field.Sequence__c = 3290;}
		}

		update fields;
	}

	
}