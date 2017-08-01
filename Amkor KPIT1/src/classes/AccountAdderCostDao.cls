/*************************************************************************
*
* PURPOSE: This dao is used for getting RFQ_Account_Adder_Cost__c objects
*
* CLASS: PFFieldDefDao
* CREATED: 3/12/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/
public class AccountAdderCostDao extends BaseDao {

    private static final AccountAdderCostDao dao = new AccountAdderCostDao();

    private Static String STATUS_ACTIVE = 'Active';
    private Static String STATUS_APPROVAL = 'Under Approval';
    private Static String STATUS_DECLINED = 'Declined';
    
    private AccountAdderCostDao() {
        super('RFQ_Account_Adder_Cost__c');
        
        addFields(new Set<String>{'Adder__r.RFQI_Field_Def__r.Name', 'Adder__r.Package_Family__r.Specific_RFQ_Item_Object__c'});
    }
    
    public static AccountAdderCostDao getInstance() {
        return dao;
    } 

    public List<RFQ_Account_Adder_Cost__c> getByAccountId(String accountId) {
    	List<RFQ_Account_Adder_Cost__c> results = (List<RFQ_Account_Adder_Cost__c>)getSObjects
        (
            'Account__c = ' + quote(accountId) + ' and Status__c = ' + quote(STATUS_ACTIVE)
        );

        return results;
    }

    public RFQ_Account_Adder_Cost__c getById(String objId) {
        List<RFQ_Account_Adder_Cost__c> results = (List<RFQ_Account_Adder_Cost__c>)getSObjects
        (
            'Id = ' + quote(objId)
        );

        return results.size() == 0 ? null : results[0];
    }

}