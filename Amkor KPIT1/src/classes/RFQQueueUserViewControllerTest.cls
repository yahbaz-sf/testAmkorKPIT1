@isTest
public with sharing class RFQQueueUserViewControllerTest {

	private static List<String> userNames = new List<String>
	{
		'test1rfqqueueviewcontroller@test.com',
		'test2rfqqueueviewcontroller@test.com',
		'test3rfqqueueviewcontroller@test.com',
		'test4rfqqueueviewcontroller@test.com',
		'test5rfqqueueviewcontroller@test.com'
	};

	private static testMethod void testPage()
	{
		List<User> users = new List<User>();

		User testUser;


		Profile p = [SELECT id FROM profile WHERE name='System Administrator'];

		for (String name : userNames)
		{
	        User u = new User(alias = 'standt', email='standarduser@testorg.com',
	            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
	            localesidkey='en_US', profileid = p.Id,
	            timezonesidkey='America/Los_Angeles', username=name);
	        users.add(u);
		}
		insert users;

		Group g = new Group(Name='TestGroup');
		insert g;

		Group subGroup = new Group(Name='SubGroup');
		insert subGroup;

		List<GroupMember> memberList = new List<GroupMember>();
		for (User u : users)
		{
			memberList.add(new GroupMember(GroupId=g.Id, UserOrGroupId=u.Id));
		}
		memberList.add(new GroupMember(GroupId=g.Id, UserOrGroupId=subGroup.Id));
		insert memberList;

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(g);
  		RFQQueueUserViewController controller = new RFQQueueUserViewController(sc);

  		System.assert(controller.users.size() == userNames.size(), 'Actual size is: ' + controller.users.size());
  		System.assert(controller.groups.size() == 1, 'Actual size is: ' + controller.groups.size());


		Test.stopTest();
	}
}