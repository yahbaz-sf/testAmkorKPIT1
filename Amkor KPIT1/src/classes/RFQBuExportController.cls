/*************************************************************************
* 
* PURPOSE:  This class is the controller for the BU Rfq Item excel export page
* CLASS: RFQBuExportController
* CREATED: 4/17/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington npilkington@ethos.com
* 
**************************************************************************/

public with sharing class RFQBuExportController extends BaseController {

    public static final String RFQI_NUM_COLUMN = 'RFQI #';
	
	protected Package_Family__c packageFamily;
	public RFQILayout layout {get; set;}

	public List<RFQItemWrapper> wrappers {get; set;}

    public String csvOutput { get; set; }

    private Integer maxWireConfigs;
    private Integer maxDieConfigs;
    private Integer maxInsertionConfigs;
    private Integer maxPassiveConfigs;
    private Integer maxServiceConfigs;

    public String fileName { get; set; }

	
	public RFQBuExportController() {

        String packageFamilyId = getParam('pfId');
        String rfqId = getParam('rfqId');
		String rfqItemId = getParam('id');
        String selectedIds = getParam('selectedIds');
        Boolean isWaferProbeTest = false;
        Boolean isPostOnly = false;
        Boolean renderNRE = false;

        Map<Id, Factory__c> factories = new Map<Id, Factory__c>([Select Id, Name from Factory__c]);

        wrappers = new List<RFQItemWrapper>();

        // If Package family and selected IDs are passed in, we are doing multiple export. Otherwise, single export
        if (!StringUtils.isBlank(rfqItemId)) {
            RFQItemWrapper wrapper = RFQItemDao.getInstance().getWrapperById(rfqItemId);
            wrapper.applyFactoryName(factories);
            if(wrapper.rfqItem.NRE_Inclusion__c != null && (wrapper.rfqItem.NRE_Inclusion__c.equals('If Applicable') || wrapper.rfqItem.NRE_Inclusion__c.equals('Required'))) renderNRE = true;
            wrappers.add(wrapper);

            packageFamily = wrapper.packageFamily;

            if(packageFamily.Name == AMKVARS.PF_TEST) {
                if((String)wrapper.getAttribute('Test_Type__c', RFQItemWrapper.PACKAGE_OBJECT, null) == AMKVARS.TT_PROBE) {
                    isWaferProbeTest = true;
                }
                else if((String)wrapper.getAttribute('Test_Type__c', RFQItemWrapper.PACKAGE_OBJECT, null) == AMKVARS.TT_POST) {
                    isPostOnly = true;
                }     
            }

            fileName = wrapper.rfqItem.RFQ__r.Name + '-' + packageFamily.Name + '-' + DateTime.now().format('MM.dd.yyyy.hh:mma');
        }
		else {
            packageFamily = PackageFamilyDao.getInstance().getById(packageFamilyId);
            List<RFQ_Item__c> rfqItems = RFQItemDao.getInstance().getByRfqId(rfqId);
            fileName = rfqItems[0].RFQ__r.Name + '-' + packageFamily.Name + '-' + DateTime.now().format('MM.dd.yyyy.hh:mma');

            for (RFQ_Item__c rfqItem : rfqItems) {
                if (selectedIds.contains(rfqItem.Id)) {
                    RFQItemWrapper wrapper = new RFQItemWrapper();
                    wrapper.rfqItem = rfqItem;
                    wrapper.packageFamily = packageFamily;
                    wrapper.inflateSpecificObjectsFromJson();
                    wrapper.applyFactoryName(factories);
                    wrapper.inflateVolume();
                    if(wrapper.rfqItem.NRE_Inclusion__c != null && (wrapper.rfqItem.NRE_Inclusion__c.equals('If Applicable') || wrapper.rfqItem.NRE_Inclusion__c.equals('Required'))) renderNRE = true;
                    wrappers.add(wrapper);
                }
            }
            if(packageFamily.Name == AMKVARS.PF_TEST) {
                if((String)wrappers[0].getAttribute('Test_Type__c', RFQItemWrapper.PACKAGE_OBJECT, null) == AMKVARS.TT_PROBE) {
                    isWaferProbeTest = true;
                }
                else if((String)wrappers[0].getAttribute('Test_Type__c', RFQItemWrapper.PACKAGE_OBJECT, null) == AMKVARS.TT_POST) {
                    isPostOnly = true;
                }    
            }
        }

        maxWireConfigs = RFQItemWrapper.getMaximumWireConfigurations(wrappers);
        maxDieConfigs = RFQItemWrapper.getMaximumDieConfigurations(wrappers);
        maxInsertionConfigs = RFQItemWrapper.getMaximumInsertionConfigurations(wrappers);
        maxPassiveConfigs = RFQItemWrapper.getMaximumPassiveConfigurations(wrappers);
        maxServiceConfigs = RFQItemWrapper.getMaximumServiceConfigurations(wrappers);

        layout = setupLayout();


        List<String> sectionList = new List<String> { 'Cost and Price', 'Package Description', 'CPN Drivers', 'Substrate Description', 'Wire Description', 'Die Description', 'Passive Description', 'Post Test Services Cost and Price', 'Adders'};
        if(renderNRE) {
            sectionList.add('NRE');
            sectionList.add('NRE Configurations');
        }
        if(packageFamily.Product_Group__r.Name == 'MLF' || packageFamily.Name == AMKVARS.PF_TEST) sectionList.add('BU Header');

        if(packageFamily.Name == AMKVARS.PF_TEST) {
            if(isWaferProbeTest) {
                sectionList.add('Post Test Services - Wafer Probe');
            }
            else {
                 sectionList.add('Post Test Services Prices');
                 sectionList.add('Post Test Services');
                 sectionList.add('Post Test Services Burn In');
            }
            if(!isPostOnly) {
                sectionList.add('Insertion Description');
                sectionList.add('Insertion Cost and Price');
                sectionList.add('Minimum Tester Configuration');
            }
        }

        CsvParser.CsvHolder csvHolder = setupCsvHolder(sectionList);

        csvOutput = csvHolder.toCsvString();
	}

    private CsvParser.CsvHolder setupCsvHolder(List<String> sectionList) {
        List<String> columnHeaders = new List<String>();

        columnHeaders.add(RFQI_NUM_COLUMN);



        for (String sectionName : sectionList) {
            addColumnHeadersForSection(columnHeaders, layout, sectionName);
        }
        Integer totalNumRows = wrappers.size();
        for (RFQItemWrapper wrap : wrappers) totalNumRows += wrap.volumeList.size();

        CsvParser.CsvHolder csvHolder = new CsvParser.CsvHolder(totalNumRows, columnHeaders);  

        if (packageFamily.Has_Factory_Field__c) {
            csvHolder.appendColumn('Factory');
        }

        //rowNum is the index of the wrapper of the row that is being filled in
        //if that row has multi volumes, then each multivolume is added as another row in the csvparser
        //and rowNum is incremented by the number of multivolumes so that it lines up with the next wrapper
        Integer rowNum = 0;
        CMBuilder builder = CMBuilder.getCMBuilderByWrapper(wrappers[0]);
        Map<String, String> volumeFieldMap = builder.getFieldMap();

        for (RFQItemWrapper wrapper : wrappers) {

            if(wrapper.packageFamily.Name == AMKVARS.PF_TEST) {

            }

            csvHolder.putVal(wrapper.rfqItem.Name, rowNum, RFQI_NUM_COLUMN);
            for (Integer j = 0; j < wrapper.volumeList.size(); j++)
            {
                csvHolder.putVal('Additional volume ' + (j + 1), j + rowNum + 1, RFQI_NUM_COLUMN);
            }

            for (String sectionName : sectionList) {
                List<RFQISectionAttribute> attributes = new List<RFQISectionAttribute>();
                if(sectionName != 'Post Test Services Cost and Price') {
                    try{
                        attributes = layout.sectionMap.get(sectionName).attributes;
                    }
                    catch(Exception e) {DebugUtils.write('e:', e);}
                }
                else {
                    attributes = getOtherAttributes(packageFamily.Name, 'Post Test Services Cost and Price');
                }
                Integer maxObjects = 1;
                if (sectionName == 'Wire Description') maxObjects = wrapper.getNumberOfWireConfigurations();
                if (sectionName == 'Die Description') maxObjects = wrapper.getNumberOfDieConfigurations();
                if (sectionName == 'Insertion Description' || sectionName == 'Insertion Cost and Price' || sectionName == 'Minimum Tester Configuration') maxObjects = wrapper.getNumberOfInsertionConfigurations();
                if (sectionName == 'Passive Description') maxObjects = wrapper.getNumberOfPassiveConfigurations();
                if (sectionName == 'Service Description') maxObjects = wrapper.getNumberOfServiceConfigurations();
                if (sectionName == 'NRE Configurations') maxObjects = wrapper.getNumberOfNREConfigurations();

                for (Integer objectIndex = 0; objectIndex < maxObjects; objectIndex++) {

                    sObject obj = wrapper.specificRfqItem;
                    if (sectionName == 'Wire Description') obj = wrapper.wireConfigurations == null || wrapper.wireConfigurations.size() == 0 ? null : wrapper.wireConfigurations[objectIndex];
                    if (sectionName == 'Die Description') obj = wrapper.dieConfigurations == null || wrapper.dieConfigurations.size() == 0 ? null : wrapper.dieConfigurations[objectIndex];
                    if (sectionName == 'Insertion Description' || sectionName == 'Insertion Cost and Price' || sectionName == 'Minimum Tester Configuration') obj = wrapper.insertionConfigurations == null || wrapper.insertionConfigurations.size() == 0 ? null : wrapper.insertionConfigurations[objectIndex];
                    if (sectionName == 'Passive Description') obj = wrapper.passiveConfigurations == null || wrapper.passiveConfigurations.size() == 0 ? null : wrapper.passiveConfigurations[objectIndex];
                    if (sectionName == 'Service Description') obj = wrapper.serviceConfigurations == null || wrapper.serviceConfigurations.size() == 0 ? null : wrapper.serviceConfigurations[objectIndex];
                    if (sectionName == 'NRE Configurations') obj = wrapper.nreConfigurations == null || wrapper.nreConfigurations.size() == 0 ? null : wrapper.nreConfigurations[objectIndex];

                    if (obj != null) {
                        //String objName = obj.getSObjectType().getDescribe().getName();

                        for (RFQISectionAttribute attribute : attributes) {
                            if (!StringUtils.isMatch(attribute.fieldAPIName, 'BLANK')) {
                                String sVal = null;
                                String columnName = null;
                                List<String> remoteFields;
                                try{
                                    sVal = String.valueOf(obj.get(attribute.fieldAPIName));
                                    String suffix = (obj != wrapper.specificRfqItem) ? ' ' + (objectIndex + 1) : '';
                                    columnName = FieldLabelHelper.getInstance().getLabel(attribute.objectAPIName, attribute.fieldAPIName) + suffix;
                                }catch(Exception ex){
                                    remoteFields = getRemoteFieldValues(wrapper, attribute.fieldAPIName);
                                    if(remoteFields != null && !remoteFields.isEmpty()){
                                        sVal = remoteFields[0];
                                        columnName = remoteFields[1];
                                        csvHolder.appendColumn(columnName);

                                    }
                                 }

                                if (sVal == null) sVal = '';
                                for (Integer j = rowNum; j < rowNum + wrapper.volumeList.size() + 1; j++)
                                {
                                    csvHolder.putVal(sVal, j, columnName);
                                }
                            }
                        }
                    }
                }
            }
            String specificObjName = wrapper.specificRfqItem.getSObjectType().getDescribe().getName();
            //replace the values in addtl volumes that were copied from the parent 
            //with the values entered on the page

            if (!wrapper.volumeList.isEmpty())
            {
                if (wrapper.insertionConfigurations.size() != wrapper.volumeList[0].testInsertions.size())
                {
                    builder.calculateNew(wrapper, new CMSettings());
                }
            }
            for (Integer j = 0; j < wrapper.volumeList.size(); j++)
            {
                //only copy values defined in the builder's fieldMap
                for (String key : volumeFieldMap.keyset())
                {
                    String columnName = FieldLabelHelper.getInstance().getLabel(specificObjName, volumeFieldMap.get(key));
                    String volVal = wrapper.volumeList[j].getDynamicValue(key);
                    csvHolder.putVal(volVal, j + rowNum + 1, columnName);
                    
                }

                //test items have extra fields to copy
                if (wrapper.packageFamily.Name == AMKVARS.PF_TEST && !wrapper.insertionConfigurations.isEmpty())
                {
                    RFQIVolume.RFQITestInsertion totals = wrapper.volumeList[j].testInsertionsTotals;
                    copyTestFieldsToCSV(csvHolder, specificObjName, j + rowNum + 1, null, totals.buPriceHour, 'BU_Price_Per_Hour__c');
                    copyTestFieldsToCSV(csvHolder, specificObjName, j + rowNum + 1, null, totals.buPriceUnit, 'BU_Final_Test_Price_Unit__c');
                    copyTestFieldsToCSV(csvHolder, specificObjName, j + rowNum + 1, null, totals.buPriceMonthly, 'BU_Price_Monthly_Charge__c');
                    
                    //copy values from the RFQIVolume's testInsertions to the appropriate price in the insertion
                    if (!wrapper.insertionConfigurations.isEmpty())
                    {
                        String insObjName = wrapper.insertionConfigurations[0].getSObjectType().getDescribe().getName();
                        for (Integer k = 0; k < wrapper.insertionConfigurations.size(); k++)
                        {
                            sObject obj = wrapper.insertionConfigurations[k];
                            RFQIVolume.RFQITestInsertion testVolume = wrapper.volumeList[j].testInsertions[k];
                            copyTestFieldsToCSV(csvHolder, insObjName, j + rowNum + 1, k + 1, testVolume.buPriceHour, 'Insertion_BU_Price_Per_Hour__c');
                            copyTestFieldsToCSV(csvHolder, insObjName, j + rowNum + 1, k + 1, testVolume.buPriceUnit, 'BU_Price_Per_Unit_Final__c');
                            copyTestFieldsToCSV(csvHolder, insObjName, j + rowNum + 1, k + 1, testVolume.buPriceMonthly, 'Insertion_BU_Price_Monthly_Charge__c');
                        }
                    }
                }
            }

            if (packageFamily.Has_Factory_Field__c) {
                for (Integer j = rowNum; j < rowNum + wrapper.volumeList.size() + 1; j++)
                {
                    csvHolder.putVal(wrapper.factoryName, j, 'Factory');
                }
            }
            //increment for additional volumes
            rowNum += wrapper.volumeList.size();

            //increment for loop iteration
            rowNum++;
        }

        return csvHolder;
    }

    private void copyTestFieldsToCSV(CsvParser.CsvHolder csvHolder, String objName, Integer csvIndex, Integer insertionIndex, Decimal value, String field)
    {
        String columnName = FieldLabelHelper.getInstance().getLabel(objName, field);
        if (insertionIndex != null) columnName += ' ' + insertionIndex;
        String volVal = value == null ? '' : value.toPlainString();
        csvHolder.putVal(volVal, csvIndex, columnName);
    }


    private void addColumnHeadersForSection(List<String> columnHeaders, RFQILayout layout, String sectionName) {
        Integer maxObjectCount = 1;

        if (sectionName == 'Wire Description') {
            maxObjectCount = maxWireConfigs;
            if (packageFamily.Default_Number_Of_Wires_BU_Export__c != null) maxObjectCount = (Integer)Math.max(maxObjectCount, packageFamily.Default_Number_Of_Wires_BU_Export__c);
        } 
        if (sectionName == 'Die Description') {
            maxObjectCount = maxDieConfigs;
            if (packageFamily.Default_Number_Of_Die_BU_Export__c != null) maxObjectCount = (Integer)Math.max(maxObjectCount, packageFamily.Default_Number_Of_Die_BU_Export__c);
        }
        if (sectionName == 'Insertion Description' || sectionName == 'Insertion Cost and Price' || sectionName == 'Minimum Tester Configuration') {
            maxObjectCount = maxInsertionConfigs;
            if (packageFamily.Default_Number_Of_Insertions_BU_Export__c != null) maxObjectCount = (Integer)Math.max(maxObjectCount, packageFamily.Default_Number_Of_Insertions_BU_Export__c);
        }
        if (sectionName == 'Passive Description') {
            maxObjectCount = maxPassiveConfigs;
            if (packageFamily.Default_Number_Of_Passives_BU_Export__c != null) maxObjectCount = (Integer)Math.max(maxObjectCount, packageFamily.Default_Number_Of_Passives_BU_Export__c);
        }
        if (sectionName == 'Service Description') {
            maxObjectCount = maxServiceConfigs;
            if (packageFamily.Default_Number_Of_Services_BU_Export__c != null) maxObjectCount = (Integer)Math.max(maxObjectCount, packageFamily.Default_Number_Of_Services_BU_Export__c);
        }


        try{
            if (layout.enabledSections.get(sectionName)) {
                RFQILayoutSection section = layout.sectionMap.get(sectionName);

                // For each child object put another set of column headers
                for (Integer i = 0; i < maxObjectCount; i++) {
                    List<RFQISectionAttribute> attributes = new List<RFQISectionAttribute>();
                    if(section.sectionName != 'Post Test Services Cost and Price') {
                        attributes = section.attributes;
                    }
                    else {
                        attributes = getOtherAttributes(packageFamily.Name, 'Post Test Services Cost and Price');
                    }
                    for (RFQISectionAttribute attrib : attributes) {
                        if (!StringUtils.isMatch(attrib.fieldAPIName, 'BLANK')) {
                            String objectName = attrib.objectAPIName;
                            //We have this information stored directly on the attribute
                            //String objectName = packageFamily.Specific_RFQ_Item_Object__c;
                            //if (sectionName == 'Wire Description') objectName = packageFamily.Specific_Wire_Configuration_Object__c;
                            //if (sectionName == 'Die Description') objectName = packageFamily.Specific_Die_Configuration_Object__c;
                            //if (sectionName == 'Insertion Description' || sectionName == 'Insertion Cost and Price' || sectionName == 'Minimum Tester Configuration') objectName = packageFamily.Specific_Insertion_Configuration_Object__c;
                            //if (sectionName == 'Passive Description') objectName = packageFamily.Specific_Passive_Configuration_Object__c;
                            //if (sectionName == 'Service Description') objectName = packageFamily.Specific_Service_Configuration_Object__c;

                            // If not on the main object, then append the child obj # to the column
                            String suffix = (objectName != packageFamily.Specific_RFQ_Item_Object__c && objectName != 'RFQ_Item__c') ? ' ' + (i + 1) : '';

                            //add a check to make sure that fields we can't correctly resolve the label for on remote objects are not added as column headers
                            if(!String.valueOf(FieldLabelHelper.getInstance().getLabel(objectName, attrib.fieldAPIName)).contains('__')){
                                String colHeader = FieldLabelHelper.getInstance().getLabel(objectName, attrib.fieldAPIName) + suffix;
                                if(sectionName == 'NRE Configurations') colHeader = 'NRE ' + colHeader; 
                                columnHeaders.add(colHeader);
                            }
                        }
                        
                    }
                }
                
            }
        }
        catch(Exception e){DebugUtils.write('Exception e:', e);}
    }

	private RFQILayout setupLayout() {
        RFQItemWrapper wrapper = wrappers[0];

        RFQILayout layout = PFFieldDefDao.getInstance().getPackageFamilyLayout(wrapper.packageFamily.Id, wrapper.packageFamily.Layout_Version__c, (Decimal)wrapper.rfqItem.get('Layout_Version__c'), 'BU');

        //Loop over OtherAttributes, check if they contain other
        //if they do, add attribute 
        for(String fieldName : layout.getOtherFieldApiNames()) { 
            String fieldValue = String.valueOf(wrapper.getAttribute(fieldName, RFQItemWrapper.PACKAGE_OBJECT, 0));
            if(fieldValue != null && fieldValue.toLowerCase() == 'other') {
                layout.addAttributeForOtherField(fieldName);
            }
        }
        wrapper.setupChildObjectSections(layout);
        wrapper.calculateAttributeVisibility(layout);

        for (String sectionName : layout.enabledSections.keySet()) {
        	if (layout.enabledSections.get(sectionName) != true) {
        		// Put dummy section in the section map so the apex:repeat won't choke on a keyNotFound exception
        		layout.sectionMap.put(sectionName, new RFQILayoutSection(sectionName));
        	}
        }
        return layout;
    }

    public List<String> getRemoteFieldValues(RFQItemWrapper wrapper, String fieldAPIName){

        List<String> retVals = new List<String>();
        String [] fields = fieldAPIName.split('[.]');
        sObject tempObject; 
        

        if(fields != null && fields.size() == 2) {
            tempObject = wrapper.rfqItem;
            String sVal = String.valueOf(tempObject.get(fields[1]));
            
            if(StringUtils.getIsId(sVal)) {
                String tmpString = fields[1].replace('__c', '__r');
                if(fields[1] != 'OwnerId') {
                    tempObject = tempObject.getsObject(tmpString);
                }
                else {
                    tempObject = tempObject.getsObject('Owner');
                }
                sVal = String.valueOf(tempObject.get('Name'));
            }
            retVals.add(sVal);
        }
        else if(fields != null && fields.size() > 2){
            tempObject = wrapper.specificRfqItem;
            for(Integer i = 0; i < fields.size()-1; i++){
                tempObject = tempObject.getSObject(fields[i]);
            }

            if(tempObject.get(fields[fields.size()-1]) != null){
                if(StringUtils.getIsId(String.valueOf(tempObject.get(fields[fields.size()-1])))){ 
                        String tmpString = fields[fields.size()-1].replace('__c', '__r');
                        try{
                            sObject newTempObject = tempObject.getSObject(tmpString);
                            retVals.add(String.valueOf(newTempObject.get('Name')));  
                        }catch(Exception ex){
                            DebugUtils.write('ex', ex);
                            //retVals.add(String.valueOf(tempObject.get(fields[fields.size()-1])));
                        }
                }
                else{
                    retVals.add(String.valueOf(tempObject.get(fields[fields.size()-1]))); 
                }
            }
            else {
                retVals.add('');
            }     
        }

        String objName = tempObject.getSObjectType().getDescribe().getName();
        String columnName = FieldLabelHelper.getInstance().getLabel(objName, fields[fields.size()-1]);
        if(columnName == 'ownerid') columnName = 'Owner';
        else if (columnName == 'rfq__c') columnName = 'RFQ';

        if(!retVals.isEmpty()) retVals.add(columnName);

        return retVals;
    }

    private List<RFQISectionAttribute> getOtherAttributes(String packageFamilyName, String belongsToSection) {
        List<RFQISectionAttribute> attributes = new List<RFQISectionAttribute>();

        List<RFQI_PF_Field_Def__c> pfFieldDefs = PFFieldDefDao.getInstance().getFieldsForPackageFamilyBelongsToSection(packageFamilyName, belongsToSection);

        for(RFQI_PF_Field_Def__c def : pfFieldDefs) {
            attributes.add(new RFQISectionAttribute(def));
        }

        return attributes;
    }

}