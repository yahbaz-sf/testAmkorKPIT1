/**********************************************************************************

 PURPOSE: A utility class for dealing with record types

 CLASS: RecordTypeUtil
 CREATED: 07/23/2012 Ethos Solutions - www.ethos.com
 AUTHOR: Unknown
***********************************************************************************/
public with sharing class RecordTypeUtils {

	/**
    * This method returns a RecordTypeId for a given RecordType Name and Object
    *
    * @param objectName the object type for which we are examining record types
    * @param recordTypeName  the name of the Record Type
    *
    * @returns the Id of the record type
    */
    public static Id getRecordTypeId(String objectName, String recordTypeName) {
        List<RecordType> recordType = [select Id from RecordType
                                 where SobjectType = :objectName and Name = :recordTypeName];

        if(recordType.size() > 0) return recordType[0].Id;
        return null;
    }
}