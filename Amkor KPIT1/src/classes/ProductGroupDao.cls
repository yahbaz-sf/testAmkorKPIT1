/*************************************************************************
*
* PURPOSE: Data access and manipulation for Product_Group__c 
*
* CLASS: ProductGroupDao
* CREATED: 3/06/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public class ProductGroupDao extends BaseDao {  

    private static final ProductGroupDao productGroupDao = new ProductGroupDao();
 
    private ProductGroupDao(){  super('Product_Group__c'); }
    /**
    * This method returns an instance of ProductGroupDao
    *
    * @returns a ProductGroupDao instance
    */
    public static ProductGroupDao getInstance() {
        return productGroupDao;
    }
    
    /**
    * This method gets the all Product_Group__c within limits
    *
    * @param isAdvancedProduct  switch to denote if the product group is an advanced product group
    * @returns a list of all Product_Group__c 
    */
    public List<Product_Group__c> getProductGroups(Boolean isAdvancedProduct, Boolean isService) {
        return (List<Product_Group__c>)getSObjects('Advanced__c = ' + isAdvancedProduct + ' AND Service__c = ' + isService);
    }

    /**
    * This method gets the all Product_Group__c within limits
    *
    * @param isAdvancedProduct  switch to denote if the product group is an advanced product group
    * @returns a list of all Product_Group__c 
    */
    public List<Product_Group__c> getProductGroups(Boolean isAdvancedProduct) {
        return (List<Product_Group__c>)getSObjects('Advanced__c = ' + isAdvancedProduct, 'Name ASC');
    }
    
    /**
    * This method gets the all Product_Group__c within limits
    *
    * @returns a list of all Product_Group__c 
    */
    public List<Product_Group__c> getAllProductGroups() {
        return (List<Product_Group__c>)getSObjectsList();
    }
    
    /**
    * This method gets the Product_Group__c that matches the specified name
    *
    * @param productGroupName The name of the product group to get
    * @returns a list of all Product_Group__c 
    */
    public Product_Group__c getProductGroupByName(String productGroupName) {
    	List<Product_Group__c> results = getSObjects('Name = ' + quote(productGroupName));
    	return results.size() == 0 ? null : results[0];
    }
     
    /**
    * This method gets the Product_Group__c with the given Id
    *
    * @param  recordId the Product_Group__c Id
    * @returns Product_Group__c with the given Id
    */
    public Product_Group__c getById(String recordId) {
        return (Product_Group__c)getSObjectById(recordId);
    }
 
    /**
    * This method gets the all Product_Group__c used by the specified RFQ
    *
    * @param rfqId The ID of the RFQ
    * @returns a list of all Product_Group__c used by the specified RFQ
    */
    public Set<Product_Group__c> getAllProductGroupByRfq(String rfqId) {
        List<Package_Family__c> pfs = PackageFamilyDao.getInstance().getAllPackageFamiliesByRfq(rfqId);
        List<Product_Group__c> prodGroupTemp = getAllProductGroups();
        Set<Product_Group__c> pgs = new Set<Product_Group__c>();

        for(Package_Family__c pf : pfs) {
            for(Product_Group__c pg : prodGroupTemp) {
                if(pf.Product_Group__r.Id == pg.Id) {
                    try{
                        pgs.add(pg);
                    }
                    catch(Exception e){}
                }
            }
        }
        return pgs;
    }
    

}