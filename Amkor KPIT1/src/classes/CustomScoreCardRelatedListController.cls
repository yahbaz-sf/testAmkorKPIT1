public with sharing class CustomScoreCardRelatedListController{

    public Id accountId{get;set;}
    public  List<Scorecard__c> lstScoreCard{get;set;}
    public set<Id> allSBUAccIds = new set<Id>();
    
    public CustomScoreCardRelatedListController(ApexPages.StandardController controller) {
    
        accountId = Apexpages.currentPage().getParameters().get('id');
        if(accountId != null) {
            findSBUAccIds();
            fetchScorecards();
        }
    }
    
    public void findSBUAccIds() {
        
        List<Account> accountList = [Select Id,Name,ParentId From Account where Id =: accountId ];
        Id parentAccId;
        
        if(accountList.size() > 0) {
            if(accountList[0].ParentId != null){
                parentAccId = accountList[0].ParentId;
            } else {
                parentAccId = accountList[0].Id;
            }
            
            map<Id,Account> sbuAccounts = new map<Id,Account>([SELECT ID,NAME FROM ACCOUNT WHERE PARENTID =: parentAccId]);
            if(sbuAccounts.size() > 0) {
                allSBUAccIds = sbuAccounts.keyset();
            }
        }
    
    }
    
    public void fetchScorecards(){
        if(allSBUAccIds != null && allSBUAccIds.size() > 0){
            lstScoreCard = [SELECT Amkor_Rank__c, CreatedDate, Customer_Maximum_Score__c, Customer_Scorecard_Name__c, Customer_Score__c, Quarter__c, Year__c, SBUAccount__r.Name, Id, Name, SBUAccount__c, SBUNumberWithName__c, Scorecard_Date__c 
                            FROM Scorecard__c
                            WHERE SBUAccount__c IN : allSBUAccIds
                            ORDER BY Year__c DESC,Quarter__c DESC];
        }
    } 
}