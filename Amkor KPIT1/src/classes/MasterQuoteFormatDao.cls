public with sharing class MasterQuoteFormatDao extends BaseDao {

	public static String RFQ = 'RFQ';
	public static String RFQ_ITEM = 'RFQ Item';
	public static String SPECIFIC_RFQ_ITEM = 'Specific RFQ Item';
	public static String WIRE_CONFIG = 'Wire Config';
	public static String DIE_CONFIG = 'Die Config';
	public static String PASSIVE_CONFIG = 'Passive Config';
	public static String INSERTION_CONFIG = 'Insertion Config';

	private static final MasterQuoteFormatDao dao = new MasterQuoteFormatDao();

	private MasterQuoteFormatDao() {
		super('Master_Quote_Format_Column__c');
	}

	public static MasterQuoteFormatDao getInstance() {
		return dao;
	}

	public List<Master_Quote_Format_Column__c> getMasterQuoteColumns() {
		Master_Quote_Format__c quoteFormat = [Select Id from Master_Quote_Format__c where Is_Active__c =: true limit 1];
		return (List<Master_Quote_Format_Column__c>)getSObjects('Master_Quote_Format__c = ' + quote(quoteFormat.Id), 'Sequence__c asc');
	}
}