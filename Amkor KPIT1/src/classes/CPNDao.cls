/*************************************************************************
*
* PURPOSE: Generates CPN
*
* CLASS: CPNDao
* CREATED: 03/18/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public class CPNDao extends BaseDao {
	
    public static final String STATUS_PENDING = 'Pending';
    public static final String STATUS_TRANSMITTED = 'Transmitted';
    public static final String STATUS_TRANSMIT_FAILED = 'Transmit Failed';

    private static final CPNDao mCPNDao = new CPNDao();
 
    private CPNDao(){  super('Configured_Part_Number__c'); }
    
    /**
    * This method returns an instance of CPNDao
    *
    * @returns a CPNDao instance
    **/
    public static CPNDao getInstance() {
        return mCPNDao;
    }
    
    /**
    * This method gets the Configured_Part_Number__c with the given Id
    *
    * @param  recordId the Configured_Part_Number__c Id
    * @returns Configured_Part_Number__cwith the given Id
    */
    public Configured_Part_Number__c getById(String recordId) {
        return (Configured_Part_Number__c)getSObjectById(recordId);
    }
     
    /**
    * This method returns a generated or existing CPN
    *
    * @param wrapper an RFQItemWrapper to generate the CPN for 
    **/
    public CPN getCPN(RFQItemWrapper wrapper) {
    	CPN itemCpn = new CPN();
        try {
            itemCpn = getCPNEx(wrapper);
        } 
        catch(Exception e) {
            System.debug('Something went wrong trying to generate the CPN: ' + e);
        }
        return itemCpn;
    }

    private CPN getCPNEx(RFQItemWrapper wrapper) {
    	
    	CPN itemCpn = new CPN();
    	List<RFQI_PF_Field_Def__c> fieldDefinitions = PFFieldDefDao.getInstance().getCPNAttributeFields(wrapper.packageFamily.Id);
        
        for(RFQI_PF_Field_Def__c def : fieldDefinitions) {
        	
        	if(def.RFQI_Field_Def__r.Object__c == RFQItemWrapper.PACKAGE_OBJECT) {
        		
        		Object value = null;
        		//SAP wont like look ups very much
        		if(def.RFQI_Field_Def__r.Name == 'Factory__c') {
        		
        		   sObject factory = wrapper.specificRfqItem.getSObject('Factory__r');
        		   if(factory != null) value = factory.get('Name');
        		}
                        else {
                            value = wrapper.specificRfqItem.get(def.RFQI_Field_Def__r.Name);	
                        }
        		itemCpn.addAttribute(def, value,0);
        	}
        	else if(def.RFQI_Field_Def__r.Object__c == RFQItemWrapper.WIRE_OBJECT) {
        		Integer index = 0;
        		for(sObject wire : wrapper.wireConfigurations) {
        		    Object value = wire.get(def.RFQI_Field_Def__r.Name);
        		    itemCpn.addAttribute(def, value, index);
        		    index++;
        		}
        	} 
        	else if(def.RFQI_Field_Def__r.Object__c == RFQItemWrapper.DIE_OBJECT) {
        		Integer index = 0;
        		for(sObject die : wrapper.dieConfigurations) {
        		    Object value = die.get(def.RFQI_Field_Def__r.Name);
        		    itemCpn.addAttribute(def, value,index);
        		    index++;
        		}
        	}
        	else if(def.RFQI_Field_Def__r.Object__c == RFQItemWrapper.PASSIVE_OBJECT) {
        		Integer index = 0;
        		for(sObject passive : wrapper.passiveConfigurations) {
        		    Object value = passive.get(def.RFQI_Field_Def__r.Name);
        		    itemCpn.addAttribute(def, value,index);
        		    index++;
        		}
                }
        	else if(def.RFQI_Field_Def__r.Object__c == RFQItemWrapper.INSERTION_OBJECT) {
        		Integer index = 0;
        		for(sObject insertion : wrapper.insertionConfigurations) {
        		    Object value = insertion.get(def.RFQI_Field_Def__r.Name);
        		    itemCpn.addAttribute(def, value,index);
        		    index++;
        		}
                }
        }

        Configured_Part_Number__c cpnData = null;
        itemCPN.computeHash();
        //check if one exists
        List<Configured_Part_Number__c> existingCPNs = 
            [select Id,Name from Configured_Part_Number__c where SHA512__c =: itemCPN.SHA512];
            
        if(existingCPNs.size() > 0) cpnData = existingCPNs[0];
        else cpnData = saveNewCPN(itemCpn,wrapper);
 
	itemCPN.cpnName = cpnData.Name;
	itemCPN.cpnId = cpnData.Id;
        return itemCPN;
    }
    
    private Configured_Part_Number__c saveNewCPN(CPN cpn, RFQItemWrapper wrapper) {
    	
    	Configured_Part_Number__c cpnData = new Configured_Part_Number__c();
        cpnData.Package_Family__c = wrapper.packageFamily.Id;
        cpnData.SHA512__c = cpn.SHA512;
  
        insert cpnData;
        List<CPN_Attribute__c> attributesData = new List<CPN_Attribute__c>();
        for(CPNAttribute attrib : cpn.attributes) {
        	attributesData.add(new CPN_Attribute__c
        	    ( 
        	        Configured_Part_Number__c = cpnData.Id,
        	        Object__c = attrib.attributeType,
        	        Index__c = Decimal.valueOf(attrib.attributeIndex),
        	        SAP_Name__c = attrib.fieldName,
        	        Units__c = attrib.unitOfMeasure,
        	        Value__c = attrib.value
        	    )
        	);
        }
        insert attributesData;
    	return cpnData;
    }
    
    public void saveCPN(Configured_Part_Number__c cpn) {
        update cpn;	
    }
}