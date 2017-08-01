/*************************************************************************
* 
* PURPOSE: The base data access object class. This class provides convience methods
*          for retrieving and storing data with dynamic SOQL.
*
* CLASS: BaseDao
* CREATED: 07/23/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Various
***************************************************************************/
public virtual class BaseDao
{
    private static final String MAX_RECORDS = '49999';
    private String fieldList;   
    private String objectName;
    private Set<String> objectFields;
   
    //deprecated
    private String extraFieldList; 

    public BaseDao(String objName) {
    	objectName = objName;
    	objectFields = new Set<String>();
    	SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
    	System.debug('--->objToken : '+objToken);
    	DescribeSObjectResult objDef = objToken.getDescribe();
    	addFields(objDef.fields.getMap().keySet());
    }
    
    public void addSingleField(String field) {
    	addFields(new Set<String> {field});
    }
     
    public void addFields(Set<String> objFields) {
        objectFields.addAll(objFields);
        fieldList = String.join(new List<String>(objectFields), ',').toLowerCase();
    }
    
    public Boolean hasField(String fieldName) {
    	return objectFields.contains(fieldName.toLowerCase());
    }

    public Set<String> getFields() {
        return objectFields;
    }
    
    /**
    * This method gets the dynamic SOQL based on the input parameters
    *
    * @param  whereClause  the where clause of the SOQL statement  e.g. Name = 'Some Name'
    * @param  orderClause  the order clause of the SOQL statement, e.g. Name Desc
    * @param  limitSize  upper bound of how many records to return
    *
    * @returns a String representing the dynamic SOQL
    */
    public String getSelect(String whereClause, String orderClause, Integer limitSize) {
        String query = 'select ' + fieldList + ' from ' + String.escapeSingleQuotes(objectName);
        if (StringUtils.isNotEmpty(whereClause)) query += ' where ' + whereClause;
        if (StringUtils.isNotEmpty(orderClause)) query += ' order by ' + String.escapeSingleQuotes(orderClause);
        if (limitSize != null) query += ' limit ' + String.valueOf(limitSize);
        else query += ' limit ' + MAX_RECORDS;
        
        //DebugUtils.getInstance().log('query', query, false);
        
        return query;
    }
    
    /**
    * This method gets an sObject with the given Id
    *
    * @param  recordId the Id of the record
    *
    * @returns an sObject with the given Id
    */
    public sObject getSObjectById(String recordId) {
    	
    	if (recordId == null) return null;		//---Prevent null error if no records returned;
    	
        String query = 'select ' + fieldList + ' from ' + objectName + ' where id = ' + quote(recordId);
        return (SObject)Database.query(query);
    }

    /**
    * This method gets an sObject with the given Id
    *
    * @param  recordId the Id of the record
    *
    * @returns an sObject with the given Id
    */
    public List<sObject> getSObjectByIdSet(String field, Set<String> ids) {
        return getSObjectByIdSet(field, ids, null);
    }

    public List<sObject> getSObjectByIdSet(String field, Set<String> ids, String whereClause) {
        return getSObjectByIdSet(field, ids, whereClause, null);
    }

    /**
    * This method gets an sObject with the given Id
    *
    * @param field- the field in which the ids are read from
    * @param ids- Set of ids
    * @param whereClause- SOQL where clause
    *
    * @returns a list of sObjects with the given Ids
    */
    public List<sObject> getSObjectByIdSet(String field, Set<String> ids, String whereClause, String orderBy) {
        
        if (ids == null) return null;
        
        String query = 'select ' + fieldList + ' from ' + objectName + ' where ' + field + ' in: ids';
        if (StringUtils.isNotEmpty(whereClause)) query += ' AND ' + whereClause;
        if (StringUtils.isNotEmpty(orderBy)) query += ' order by ' + orderBy;
        system.debug('Query is in BaseDao');
        return Database.query(query);
    }

    /**
    * This method executes a dynamic SOQL query and returns a list 
    * of all sObjects (within limits)
    *
    * @returns a List<sObject> based on the given parameters
    */
    public List<sObject> getSObjectsList() {
        return getSObjects('', 'Name ASC');
        //return getSObjectListByWhere(fieldList, '', 'Name ASC');
    }
    
    /**
    * This method executes a dynamic SOQL query and returns a list of sObjects
    *
    * @param  whereClause  the where clause of the SOQL statement
    *
    * @returns a List<sObject> based on the given parameters
    */
    public List<sObject> getSObjects(String whereClause) {
        return getSObjects(whereClause, null, null);
    }
    
    /**
    * This method executes a dynamic SOQL query and returns a list of sObjects
    *
    * @param  whereClause  the where clause of the SOQL statement  e.g. Name = 'Some Name'
    * @param  orderClause  the order clause of the SOQL statement, e.g. Name Desc
    *
    * @returns a List<sObject> based on the given parameters
    */
    public List<SObject> getSObjects(String whereClause, String orderClause) {
        //Debug ----- Lalit
        system.debug('getSObjects method : whereClause  :'+whereClause);
        system.debug('getSObjects method : orderClause  :'+orderClause);
        String query = getSelect(whereClause, orderClause, Integer.valueOf(MAX_RECORDS));
        system.debug('getSObjects method : query  :'+query);
        //Debug ----- Lalit
        return (List<SObject>)Database.query(query);
    }
    
    
    /**
    * This method executes a dynamic SOQL query and returns a list of sObjects
    *
    * @param  whereClause  the where clause of the SOQL statement  e.g. Name = 'Some Name'
    * @param  orderClause  the order clause of the SOQL statement, e.g. Name Desc
    * @param  limitSize  upper bound of how many records to return
    *
    * @returns a List<sObject> based on the given parameters
    */
    public List<SObject> getSObjects(String whereClause, String orderClause, Integer limitSize) {
        String query = getSelect(whereClause, orderClause, limitSize);
        return (List<SObject>)Database.query(query);
    }
    
    /**
    * This method returns a quoted and escaped version of the string
    *
    * @param inStr the input string
    *
    * @returns a quoted and escaped version of the input string
    */
    public static String quote(String inStr) {
    	if(inStr == null) inStr = '';
        return '\'' + String.escapeSingleQuotes(inStr) + '\'';
    } 
    
}