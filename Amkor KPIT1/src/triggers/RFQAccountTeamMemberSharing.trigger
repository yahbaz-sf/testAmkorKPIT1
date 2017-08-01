trigger RFQAccountTeamMemberSharing on RFQ__c (after insert) {

    RFQ__c[] newItems = Trigger.New;
    Set<Id> sbuIds = new Set<Id>();

    if(Trigger.isAfter && Trigger.isInsert) {
        for(RFQ__c n : newItems) {
            sbuIds.add(n.SBU_Name__c);
        }

        List<AccountTeamMember> mems = [select Id, UserId, AccountId from AccountTeamMember where AccountId in: sbuIds];
        List<RFQ__Share> rfqSharings = new List<RFQ__Share>();
        for(RFQ__c n : newItems) {
            for(AccountTeamMember m : mems) {
                if(m.AccountId == n.SBU_Name__c) {
                    rfqSharings.add(new RFQ__Share(ParentId = n.Id, UserOrGroupId = m.UserId, AccessLevel = 'Edit', RowCause = Schema.RFQ__Share.RowCause.Account_Sharing__c));
                }
            }
        }

        insert rfqSharings;


    }
}