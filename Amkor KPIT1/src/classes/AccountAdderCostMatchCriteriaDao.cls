/*************************************************************************
*
* PURPOSE: This dao is used for getting RFQ_Acct_Adder_Match_Crit__c objects
*
* CLASS: AccountAdderCostMatchCriteriaDao
* CREATED: 7/9/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/
public class AccountAdderCostMatchCriteriaDao extends BaseDao {

    private static final AccountAdderCostMatchCriteriaDao dao = new AccountAdderCostMatchCriteriaDao();

    
    private AccountAdderCostMatchCriteriaDao() {
        super('RFQ_Acct_Adder_Match_Crit__c'); 
    }
    
    public static AccountAdderCostMatchCriteriaDao getInstance() {
        return dao;
    } 

    public List<RFQ_Acct_Adder_Match_Crit__c> getByParent(String parentId) {
    	List<RFQ_Acct_Adder_Match_Crit__c> results = (List<RFQ_Acct_Adder_Match_Crit__c>)getSObjects
        (
            'Parent__c = ' + quote(parentId)
        );

        return results;
    }

}