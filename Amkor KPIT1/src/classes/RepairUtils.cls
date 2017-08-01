/*************************************************************************
*
* PURPOSE: To fix a disjoint between the BU Price on the
*  general Item and the BU Price on the specific item
*  for some RFQIs
*
* CLASS: RepairUtils
* CREATED: 8/23/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
public with sharing class RepairUtils {
	public BaseDao dao {get; set;}
	public DebugUtils debug {get {return DebugUtils.getInstance();} }

	public RepairUtils(String specificRfqItemName) 
	{
		dao = new BaseDao(specificRfqItemName);
		dao.addSingleField('RFQ_Item__r.BU_Price__c');
		dao.addSingleField('RFQ_Item__r.Name');

	}

	public void repair()
	{
		List<sObject> updateList = new List<sObject>();
		//'BU_Price__c != RFQ_Item__r.BU_Price__c'
		List<sObject> specificList = dao.getSObjectsList();

		for (sObject row : specificList)
		{

			debug.log('row.Name', row.get('Name'));
			debug.log('row.Item.Name', row.getSObject('RFQ_Item__r').get('Name'));
			debug.log('row.Id', row.get('Id'));
			if (row.getSObject('RFQ_Item__r').get('BU_Price__c') != null)
			{
				Decimal itemBUPrice = (Decimal)row.getSObject('RFQ_Item__r').get('BU_Price__c');
				if (Math.abs((Decimal)row.get('BU_Price__c') - itemBUPrice) > 0.0001)
				{
					
					debug.log('row.BU_Price__c', row.get('BU_Price__c'));
					debug.log('row.RFQ_Item__r.BU_Price__c', row.getSObject('RFQ_Item__r').get('BU_Price__c'));
					//debug.log('row.RFQ_Item__r.BU_Price__c', row.get('RFQ_Item__r.BU_Price__c'));

					row.put('BU_Price__c', itemBUPrice);
					debug.log('row.BU_Price__c', row.get('BU_Price__c'));
					
					updateList.add(row);
				}
			}
			debug.log('');
		}

		update updateList;
	}
}