/*************************************************************************
*
* PURPOSE: This dao is used for getting Account_Lot_Charge__c objects
*
* CLASS: PFFieldDefDao
* CREATED: 7/9/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/

public class AccountLotChargeDao extends BaseDao {

	private static final AccountLotChargeDao dao = new AccountLotChargeDao();

	private AccountLotChargeDao() {
		super('Account_Lot_Charge__c');
	}

	public static AccountLotChargeDao getInstance() {
        return dao;
    } 


    public List<Account_Lot_Charge__c> getByAccountId(String accountId) {
    	List<Account_Lot_Charge__c> results = (List<Account_Lot_Charge__c>)getSObjects
        (
            'Account__c = ' + quote(accountId)
        );

        return results;
    }
}