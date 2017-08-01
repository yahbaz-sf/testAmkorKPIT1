/*************************************************************************
*
* PURPOSE: This Dao is used for getting the layout as defined by the fields
*          associated with a particular package family and section. This
*          class does not return database objects directly but RFQILayout
*          objects for convenience.
*
* CLASS: PFFieldDefDao
* CREATED: 3/12/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public class PFFieldDefDao extends BaseDao {
	
	private static final PFFieldDefDao fieldDefDao = new PFFieldDefDao();
    public DebugUtils debug = DebugUtils.getInstance();
 
    private PFFieldDefDao() {  
    	super('RFQI_PF_Field_Def__c');
    	
    	addFields(new Set<String>{'RFQI_Field_Def__r.Name',
    		                      'RFQI_Field_Def__r.Object__c',
    		                      'RFQI_Field_Def__r.Type__c',
                                  'RFQI_Section__r.Name',
    		                      'RFQI_Section__r.Page_Type__c',
    		                      'RFQI_Section__r.Sequence__c'}); 
    }
    
    public static PFFieldDefDao getInstance() {
        return fieldDefDao;
    } 

 
    /**
    * This method gets the RFQILayout object which tells
    * the RFQItem* pages how to draw themselves (sections/attributes)
    * 
    * @param packageFamilyId a record Id for a particuluar package family
    *
    * 
    * @returns a RFQILayout object which describers how the RFQItem*
    *          page should draw itself
    */

    public RFQILayout getPackageFamilyLayout(String packageFamilyId, Decimal currentLayoutVersion, Decimal itemLayoutVersion) {
        return getPackageFamilyLayout( packageFamilyId, currentLayoutVersion, itemLayoutVersion, 'Both');
    }

    public RFQILayout getPackageFamilyLayout(String packageFamilyId, Decimal currentLayoutVersion, Decimal itemLayoutVersion, String pageType) {

        List<RFQI_PF_Field_Def__c> fieldDefs = (List<RFQI_PF_Field_Def__c>)getSObjects
        (
            'Package_Family__c = ' + quote(packageFamilyId), 'RFQI_Section__r.Sequence__c ASC, Sequence__c ASC'
        );
        return new RFQILayout(fieldDefs,getAllSections(pageType), currentLayoutVersion, itemLayoutVersion, pageType);
    }


    public RFQILayout getMiniPackageFamilyLayout(String packageFamilyId, Decimal currentLayoutVersion, Decimal itemLayoutVersion) {

        List<RFQI_PF_Field_Def__c> fieldDefs = (List<RFQI_PF_Field_Def__c>)getSObjects
        (
            'Package_Family__c = ' + quote(packageFamilyId) + ' and Include_In_Opportunities__c = true', 'RFQI_Section__r.Sequence__c ASC, Sequence__c ASC'
        );
        return new RFQILayout(fieldDefs,getAllSections('Sales'), currentLayoutVersion, itemLayoutVersion, 'Sales');
    }

    public RFQILayout getCpnPackageFamilyLayout(String packageFamilyId, Decimal currentLayoutVersion, Decimal itemLayoutVersion) {
        return getCpnPackageFamilyLayout( packageFamilyId, currentLayoutVersion, itemLayoutVersion, 'Both');
    }
    public RFQILayout getCpnPackageFamilyLayout(String packageFamilyId, Decimal currentLayoutVersion, Decimal itemLayoutVersion, String pageType) {

        List<RFQI_PF_Field_Def__c> fieldDefs = (List<RFQI_PF_Field_Def__c>)getSObjects
        (
            'CPN_Attribute__c = true and Package_Family__c = ' + quote(packageFamilyId),
            'RFQI_Section__r.Sequence__c ASC, Sequence__c ASC'
        );
        return new RFQILayout(fieldDefs, getAllSections(pageType), currentLayoutVersion, itemLayoutVersion);
    }


    /**
     * This item gets the BU version of the Layout for the specified wrapper
     */
    public RFQILayout getBULayoutForWrapper(RFQItemWrapper wrapper) {
        return getPackageFamilyLayout(wrapper.packageFamily.Id, wrapper.packageFamily.Layout_Version__c, wrapper.rfqItem.Layout_Version__c, 'BU');
    }

    /**
     * This method returns all required fields for particular package family
     * (including required fields for child object sections)
     */
    public List<RFQI_PF_Field_Def__c> getRequiredFieldsForPackageFamily(String packageFamilyId) {
        List<RFQI_PF_Field_Def__c> fieldDefs = (List<RFQI_PF_Field_Def__c>)getSObjects
        (
            'Package_Family__c = ' + quote(packageFamilyId) + ' and Required__c = true', 'RFQI_Section__r.Sequence__c ASC, Sequence__c ASC'
        );
        system.debug('In PFFieldDefDao fieldDefs'+fieldDefs);

        return fieldDefs;
    }

    public Map<Id, List<RFQI_PF_Field_Def__c>> getRequiredFieldsForPackageFamilies(Set<Id> packageFamilies) {
        List<RFQI_PF_Field_Def__c> requiredFields = [Select Id, Package_Family__c, RFQI_Field_Def__r.Name from RFQI_PF_Field_Def__c 
                                                        where Package_Family__c in :packageFamilies
                                                        and Required__c = true];

        Map<Id, List<RFQI_PF_Field_Def__c>> result = new Map<Id, List<RFQI_PF_Field_Def__c>>();

        for (Id pfId : packageFamilies) {
            result.put(pfId, new List<RFQI_PF_Field_Def__c>());

            for (RFQI_PF_Field_Def__c fieldDef : requiredFields) {
                if (fieldDef.Package_Family__c == pfId) {
                    result.get(pfId).add(fieldDef);
                }
            }
        }

        return result;
    }
    
    /**
    * This method gets the CPN attributes for a particuluar package family
    * 
    * 
    * @param packageFamilyId a record Id for a particuluar package family
    *
    * 
    * @returns a List<RFQI_PF_Field_Def__c> objects that are CPN attributes
    */	
    public List<RFQI_PF_Field_Def__c> getCPNAttributeFields(String packageFamilyId) {
    	
        return (List<RFQI_PF_Field_Def__c>)getSObjects
        (
            'CPN_Attribute__c = true and Package_Family__c = ' + quote(packageFamilyId)
        );
          
    }
    
    /**
    * This method gets the RFQI_Sections__c in the system
    * 
    * @returns a List<RFQI_Layout__c> objects 
    */
    public Map<String,Boolean> getAllSections(String pageType) {
        String whereClause = 'where Page_Type__c=\'Both\'';
        whereClause += (pageType=='Both') ? '' : ' or Page_Type__c=\'' + pageType + '\'';
        String query = 'select Name from RFQI_Section__c ' + whereClause;
        List<RFQI_Section__c> sections = Database.query(query);
        Map<String,Boolean> sectionMap = new Map<String,Boolean>();
        for(RFQI_Section__c section : sections) {
        	sectionMap.put(section.Name,false);
        }
        return sectionMap;
    }

    /**
    * This method gets all the fields for a particuluar package family
    * 
    * 
    * @param packageFamilyId a record Id for a particuluar package family
    * @returns List of RFQI_PF_Field_Def__c for the specified package family
    */  
    public List<RFQI_PF_Field_Def__c> getFieldsForPackageFamily(String pfId) {
        List<RFQI_PF_Field_Def__c> fieldDefs = (List<RFQI_PF_Field_Def__c>)getSObjects
        (
            'Package_Family__c = ' + quote(pfId),
            'RFQI_Section__r.Sequence__c ASC, Sequence__c ASC'
        );

        return fieldDefs;
    }

    /**
    * This method gets all the fields for a particuluar package family as a map of <Field Name> -> PF Field Def
    * 
    * 
    * @param packageFamilyId a record Id for a particuluar package family
    * @returns Map of Field Name -> PF Field def for that package family
    */  
    public Map<String, RFQI_PF_Field_Def__c> getFieldsForPackageFamilyAsMap(String pfId) {
        List<RFQI_PF_Field_Def__c> fields = getFieldsForPackageFamily(pfId);

        Map<String, RFQI_PF_Field_Def__c> result = new Map<String, RFQI_PF_Field_Def__c>();

        for (RFQI_PF_Field_Def__c row : fields) {
            String fieldName = row.RFQI_Field_Def__r.Name;
            result.put(fieldName, row);
        }

        return result;
    }

    /**
    * This method gets all the fields for a particuluar package family in a particular section
    * 
    * 
    * @param packageFamilyId a record Id for a particuluar package family
    * @param sectionName A particular section to look for
    * @returns List of RFQI_PF_Field_Def__c for the specified package family and section
    */  
    public List<RFQI_PF_Field_Def__c> getFieldsForPackageFamilySection(String pfId, String sectionName) {

        List<RFQI_PF_Field_Def__c> fieldDefs = (List<RFQI_PF_Field_Def__c>)getSObjects
        (
            'Package_Family__c = ' + quote(pfId) + ' and RFQI_Section__r.Name = ' + quote(sectionName),
            'RFQI_Section__r.Sequence__c ASC, Sequence__c ASC'
        );

        return fieldDefs;
    }

    /**
    * This method gets all fields based on belongsToSection Field
    * 
    */
     public List<RFQI_PF_Field_Def__c> getFieldsForPackageFamilyBelongsToSection(String packageFamilyName, String belongsToSection) {

        List<RFQI_PF_Field_Def__c> fieldDefs = (List<RFQI_PF_Field_Def__c>)getSObjects
        (
            'Package_Family__r.Name = ' + quote(packageFamilyName) + ' and Belongs_To_Section__c = ' + quote(belongsToSection),
            'RFQI_Section__r.Sequence__c ASC, Sequence__c ASC'
        );

        return fieldDefs;
    }
}