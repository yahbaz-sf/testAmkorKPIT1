/*************************************************************************
*
* PURPOSE: DAO for Opportunities 
*
* CLASS: OpportunityDao
* CREATED: 4/30/2014 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
***************************************************************************/
public with sharing class OpportunityDao extends BaseDao {
	private static final OpportunityDao OpportunityDao = new OpportunityDao();

	private OpportunityDao(){  super('Opportunity'); }

	public static OpportunityDao getInstance() {
        return OpportunityDao;
    }

    public Opportunity getOppById(String oppId) {
    	return (Opportunity)getSObjectById(oppId);
    }
}