/*************************************************************************
* 
* PURPOSE:  this class manages the logic for relating parent
*           and child accounts based on data sent over from
*           SAP
*         
* CLASS: SAPCustomerHierachyController
* CREATED: 05/17/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
public class SAPCustomerHierachyController {
    
     //Bhanu 12-Apr-2016
     //public static void updateCustomerHierarchy(ZICUSHIE01 customerHierarchy) 
     public static SAPInterfaceResult updateCustomerHierarchy(ZICUSHIE01 customerHierarchy) {
        
        //Bhanu 12-Apr-2016
        SAPInterfaceResult resultInstance = new SAPInterfaceResult();
        
        try{
            
            if(customerHierarchy != null && customerHierarchy.IDOC != null && customerHierarchy.IDOC.ZISKKHIE != null) {
                 
                 Map<String,String> parentLink = new Map<String,String>();
                 Set<String> accountNumberSet = new Set<String>();
                 
                 //Loop through the ZICUSHI01ZISKKHIE objects they contain the segments
                 //that define the parent child account relationship
                 
                 //Bhanu 12-Apr-2016
                 resultInstance.process = 'Extracting and linking Customer Number from SAP Data';
                 
                 for(ZICUSHIE01ZISKKHIE z : customerHierarchy.IDOC.ZISKKHIE) {
                    String parentNum = z.HKUNNR; //parent
                    String childNum = z.KUNNR;   //child
                    
                    //Add all account Ids to a set so we can do an easy IN select
                    if(String.isNotBlank(childNum)) 
                        accountNumberSet.add(childNum);
                    if(String.isNotBlank(parentNum)) 
                        accountNumberSet.add(parentNum);
                    
                    //put the linkage CHILD-PARENT in a map
                    if(String.isNotBlank(parentNum) && String.isNotBlank(childNum)) {
                        parentLink.put(childNum,parentNum);
                    }   
                 }
                 
                 resultInstance.accountReference = '' + accountNumberSet;
                
                 //Get all of the Accounts in SF recorded above by doing a select IN Set
                 //shove those into a Map <AccountNumber, AccountObject>
                 Map<String,Account> accMap = new Map<String,Account>();
                 for(Account acc : [SELECT Id,AccountNumber FROM Account WHERE AccountNumber IN :accountNumberSet]) {
                    accMap.put(acc.AccountNumber,acc);
                 }
                 
                 //Bhanu 12-Apr-2016 : Adding processed SAP Account 
                 resultInstance.accountList.addAll(accMap.values());
                 
                 List<Account> updateList = new List<Account>();
                 //Loop through the parent link map
                 
                 //Bhanu 12-Apr-2016
                 resultInstance.process = 'Populating Parent Account Reference in Child Account';
                 
                 for (String childNum : parentLink.keySet()){
                     //get the parent and child from the account map from
                     //above, now that we have actual account objects we can
                     //set the parentId on the child to the Id of the parent
                     Account childAccount = accMap.get(childNum);
                     String parentNum = parentLink.get(childNum);
                     Account parentAccount = accMap.get(parentNum);
                     
                     if(childAccount != null && parentAccount != null) {
                        childAccount.ParentId = parentAccount.Id;
                        //add this to the update list
                        updateList.add(childAccount);
                     }
                 }
                 
                 //Bhanu 12-Apr-2016
                 resultInstance.process = 'Updating Accounts';
                 
                 if(updateList.size() > 0) update updateList;
                 
                 //Bhanu 12-Apr-2016
                 resultInstance.process = '';
             }
        } catch(Exception e){
            resultInstance.addError('Error while ' + resultInstance.process + ' : ' + e.getMessage() + ', Location : ' + e.getStackTraceString());
        }
        
        system.debug('----> SAPCustomerHierachyController.updateCustomerHierarchy(), returning resultInstance : ' + resultInstance);
        return resultInstance;
     }
}