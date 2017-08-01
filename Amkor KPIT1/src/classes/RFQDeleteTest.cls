/*************************************************************************
* 
* PURPOSE:  Unit tests for RFQDelete Trigger
*          
*         
* CLASS: RFQDeleteTest
* CREATED: 8/9/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
* 
**************************************************************************/
@isTest
public with sharing class RFQDeleteTest {

	public static testMethod void test1()
	{
		RFQItemWrapper wrapper = SharedUnitTestUtils.createPfAndLineItem();

		String rfqId = wrapper.rfqItem.RFQ__c;
		List<RFQ_Item__c> items = [select id from RFQ_Item__c where RFQ__c =: rfqId];
		System.assert(items.size() > 0);

		delete [select id from RFQ__c where id=:rfqId];

		items = [select id from RFQ_Item__c where RFQ__c =: rfqId];

		System.assert(items.size() == 0);

	}
}