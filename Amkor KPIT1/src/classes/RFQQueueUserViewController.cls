/*************************************************************************
*
* PURPOSE: Controller to populate user/group lists for a given queue
*
* CLASS: RFQQueueUserViewController
* CREATED: 1/6/2014 Ethos Solutions - www.ethos.com  
* AUTHOR: Austin Delorme
***************************************************************************/ 
public with sharing class RFQQueueUserViewController {

	public List<User> users {get; set;}
	public List<Group> groups {get; set;}
	public Group g {get; set;}

	public RFQQueueUserViewController(ApexPages.StandardController sc) {
		users = new List<User>();
		groups = new List<Group>();
		List<Group> gList = [SELECT Id, Name FROM Group WHERE Id= :sc.getRecord().Id];
		if (gList.size() > 0) g = gList[0];
		else g = new Group();

		Map<Id, GroupMember> groupMemberIds = new Map<Id, GroupMember>([SELECT UserOrGroupId FROM GroupMember WHERE GroupId =: g.Id ]);

		List<Id> userGroupIds = new List<Id>();
		for (GroupMember row : groupMemberIds.values()) userGroupIds.add(row.UserOrGroupId);

		groups = [SELECT Id, Name FROM Group WHERE Id in :userGroupIds];
		users  = [SELECT Id, Name FROM User WHERE Id in :userGroupIds];

	}
}