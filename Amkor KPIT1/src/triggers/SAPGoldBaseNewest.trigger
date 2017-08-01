/*************************************************************************
*
* PURPOSE: Marks the SAB Gold Base with the newest date whenever a new one is added
*
* TRIGGER: SAPGoldBaseNewest
* CREATED: 7/12/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
trigger SAPGoldBaseNewest on SAP_Gold_Base__c (before insert, before update) {

	/*SAP_Gold_Base__c newNewest = Trigger.New[0];
	List<SAP_Gold_Base__c> updateList = new List<SAP_Gold_Base__c>();

	DebugUtils debug = DebugUtils.getInstance();

	//find the newest in the SAP Gold Bases being added
	for (SAP_Gold_Base__c newAuBase: Trigger.New)
	{
		if (newNewest.Valid_From_Date__c < newAuBase.Valid_From_Date__c)
		{
			newNewest.Newest__c = false;
			newAuBase.Newest__c = true;
		}
	}

	//compare the date from the newest from the list being insterted to the date from the old "newest"
	List<SAP_Gold_Base__c> oldNewestList = SAPGoldBaseDao.getInstance().getByAccountAndNewest(newNewest.Account__c);
	if (oldNewestList != null)
	{
		if (oldNewestList.size() > 0)
		{
			SAP_Gold_Base__c oldNewest = oldNewestList[0];
			if (oldNewest.Valid_From_Date__c < newNewest.Valid_From_Date__c)
			{
				oldNewest.Newest__c = false;
				updateList.add(oldNewest);
				newNewest.Newest__c = true;
			}	
		}
		else
		{
			newNewest.Newest__c = true;
		}

	}


	update(updateList);*/

}