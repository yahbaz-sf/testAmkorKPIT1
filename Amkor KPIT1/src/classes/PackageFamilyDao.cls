/*************************************************************************
*
* PURPOSE: Data access and manipulation for Package_Family__c 
*
* CLASS: PackageFamilyDao
* CREATED: 3/06/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public class PackageFamilyDao extends BaseDao {  

    private static final PackageFamilyDao packageFamilyDao = new PackageFamilyDao();
 
    private PackageFamilyDao(){  super('Package_Family__c'); }
    /**
    * This method returns an instance of PackageFamilyDao
    *
    * @returns a PackageFamilyDao instance
    */
    public static PackageFamilyDao getInstance() {
        return packageFamilyDao;
    }
    
    /**
    * This method gets a lsit of Package_Family__c for a 
    * particular product group
    *
    * @param  productGroupId the Id of the product group
    * @returns Package_Family__c for the particular product group
    */
    public List<Package_Family__c> getFamiliesByProductGroup(String productGroupId) {
    	if(productGroupId == null) return new List<Package_Family__c>();
        return  (List<Package_Family__c>)getSObjects('Product_Group__c = ' + quote(productGroupId)+' AND Inactive__c = false', 'Name ASC');
    }
    /**
    * This method gets a lsit of Package_Family__c for a 
    * particular product group
    *
    * @param  productGroupName the Name of the product group
    * @returns Package_Family__c for the particular product group
    */
    public List<Package_Family__c> getFamiliesByProductGroupName(String productGroupName) {
        if(productGroupName == null) return new List<Package_Family__c>();
        return  (List<Package_Family__c>)getSObjects('Product_Group__r.Name = ' + quote(productGroupName)+' AND Inactive__c = false', 'Name ASC');
    }
    
    /**
    * This method gets the Package_Family__c with the given Id
    *
    * @param  recordId the Package_Family__c Id
    * @returns Package_Family__c with the given Id
    */
    public Package_Family__c getById(String recordId) {
        addSingleField('Package_Family__c.Product_Group__r.Name');
        addSingleField('Package_Family__c.Product_Group__r.Cost_Model_Implementation__c');
        return (Package_Family__c)getSObjectById(recordId);
    }
    
    /**
    * This method gets the all Package_Family__c within limits
    *
    * @returns a list of all Package_Family__c 
    */
    public List<Package_Family__c> getAllPackageFamilies() {
        return (List<Package_Family__c>)getSObjects('Inactive__c = false');
    }
    
     /**
    * This method gets a package family by product group and package family name
    *
    * @param  productGroupName The name of the product group
    * @param packageFamilyName The name of the package family
    * @returns Package_Family__c for the particular product group
    */
    public Package_Family__c getFamilyByName(String productGroupName, String packageFamilyName) {
        List<Package_Family__c> results = (List<Package_Family__c>)getSObjects('Product_Group__r.Name = ' + quote(productGroupName) + ' and Name = ' + quote(packageFamilyName)+' and Inactive__c = false', 'Name ASC');
        return results.size() == 0 ? null : results[0];
    }
    
    /**
    * This method gets the all Package_Family__c used by the specified RFQ
    *
    * @param rfqId The ID of the RFQ
    * @returns a list of all Package_Family__c used by the specified RFQ
    */
    public List<Package_Family__c> getAllPackageFamiliesByRfq(String rfqId) {
        addSingleField('Package_Family__c.Product_Group__r.Id');
    	return  (List<Package_Family__c>)getSObjects('Id in (select Package_Family__c from RFQ_Item__c where RFQ__c = ' + quote(rfqId) + ')');
    }

}