/*************************************************************************
*
* PURPOSE: When an active Account File Map is deleted, activate the previous
* file map that was marked as Inactive
*
* CLASS: ActivateInactiveFileMapOnDelete
* CREATED: 11/04/2014 Ethos Solutions - www.ethos.com 
* AUTHOR: Austin Delorme
***************************************************************************/
trigger ActivateInactiveFileMapOnDelete on RFQ_Ac_Map__c (after delete) {

	Set<String> prevMapIds = new Set<String>();

	for (RFQ_Ac_Map__c deletedMaps : Trigger.old)
	{
		prevMapIds.add(deletedMaps.Parent_Map__c);
	}

	List<RFQ_Ac_Map__c> prevMaps = AccountFileMapDao.getInstance().getSObjectByIdSet('Id', prevMapIds);

	String rtId = AccountFileMapDao.getInstance().getActiveRtId();

	for (RFQ_Ac_Map__c prevMap : prevMaps) prevMap.RecordTypeId = rtId;

	update prevMaps;

}