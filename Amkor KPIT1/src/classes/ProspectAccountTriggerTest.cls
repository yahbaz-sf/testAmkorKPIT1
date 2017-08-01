@isTest
private class ProspectAccountTriggerTest {
	

	public static testmethod void testInsertTrigger() {

        Id nonProsRtId = RecordTypeUtils.getRecordTypeId('Account', 'Approved');

        Account prospectParent = new Account();
        prospectParent.Name = 'Parent';
        prospectParent.Sales_Region__c = 'Japan';
        insert prospectParent;

        RFQ_System_Settings__c settings = new RFQ_System_Settings__c(Name='Test', Prospect_Account_Id__c=prospectParent.Id);
        insert settings;


        Test.startTest();
		

        List<Account> childProspects = new List<Account>();

        childProspects.add(new Account(Name = 'Pros 1', Sales_Region__c = 'Japan'));
        childProspects.add(new Account(Name = 'Pros 2', Sales_Region__c = 'Japan'));
        childProspects.add(new Account(Name = 'Pros 3', Sales_Region__c = 'Japan'));
        childProspects.add(new Account(Name = 'Pros 4', Sales_Region__c = 'Japan'));
        childProspects.add(new Account(Name = 'Pros 5', Sales_Region__c = 'Japan'));

        //non prospect
        childProspects.add(new Account(Name = 'Non Pros', AccountNumber='ZA0000F0777X', RecordTypeId=nonProsRtId, Sales_Region__c = 'Japan'));
        insert childProspects;

        Test.stopTest();

        List<Account> testList = [select Id,Name,RecordTypeId,ParentId from Account where parentId =: prospectParent.Id];
        Id rtId = RecordTypeUtils.getRecordTypeId('Account', 'Prospect');

        for(Account a : testList) {

            System.assert(a.Name != 'Non Pros');
            System.assert(a.RecordTypeId == rtId);
            
        }

        System.assert(testList.size() == 5);

        List<Account> nonProspectTestList = [select Id,Name,RecordTypeId,ParentId from Account where AccountNumber =: 'ZA0000F0777X'];
        System.assert(nonProspectTestList.size() == 1);
        for(Account a : nonProspectTestList) {
            System.assert(a.ParentId != prospectParent.Id);
            System.assert(a.RecordTypeId != rtId);
        }

	}
}