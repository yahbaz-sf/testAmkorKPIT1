public with sharing class CPN {
	
    public String cpnId {get; set;}
    public String cpnName {get; set;}
    public String SHA512 {get; set;}
    public List<CPNAttribute> attributes;
	
    public CPN() {
        attributes = new List<CPNAttribute>();
    }
	
    public void addAttribute(RFQI_PF_Field_Def__c def, Object value, Integer index) {
	attributes.add(
	    new CPNAttribute(def,value,index)
	);
    }
	
    public void computeHash() {
        attributes.sort();
	Blob keyblob = Blob.valueof(getJSON());
        Blob key = Crypto.generateDigest('SHA-512',keyblob);
        SHA512 = EncodingUtil.convertToHex(key);
    }
	
    public String getJSON() {
        return JSON.serialize(this);
    }
}