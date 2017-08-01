@isTest
private class ApprovalUtilTest {

    private static testmethod void testStartApproval() {

    	RFQItemWrapper wrapper = createItemWrapper();
    	String id = wrapper.rfqItem.Id;
    	List<ProcessInstanceWorkitem> wiList = getProcessInstanceWorkItem(id);
    	System.assert(wiList.size() == 0);
    	ApprovalUtils.startApproval(id,  'Test Comment');

    	//check if data is created
    	wiList = getProcessInstanceWorkItem(id);
    	System.assert(wiList.size() == 1);
    	ProcessInstanceStep procStep = [Select Id, ProcessInstanceId, Comments From ProcessInstanceStep where ProcessInstanceId = : wiList[0].ProcessInstanceId];
    	System.assert(procStep.Comments == 'Test Comment' );
    	        
    }

    private static testmethod void testGetStandardApprovalWizard(){
        RFQItemWrapper wrapper = createItemWrapper();
        String id = wrapper.rfqItem.Id;
        PageReference pg = ApprovalUtils.getStandardApprovalWizard(id);
        System.assert(pg != null);
    }

    private static testmethod void testApproveRecord(){
        RFQItemWrapper wrapper = createItemWrapper();
        String id = wrapper.rfqItem.Id;
        List<ProcessInstanceWorkitem> wiList = getProcessInstanceWorkItem(id);
        System.assert(wiList.size() == 0);
        ApprovalUtils.startApproval(id,  'Test Comment');
        System.assert(ApprovalUtils.isUnderApproval(id) == true);  

        //check if data is created
        wiList = getProcessInstanceWorkItem(id);
        
        ProcessInstanceWorkItem workItem = wiList[0];
        Id procId = workItem.ProcessInstanceId;
        ApprovalUtils.approveRecord(workItem.id, 'item approved');
        List<ProcessInstanceStep> procStepList = [Select Id, ProcessInstanceId, Comments, StepStatus From ProcessInstanceStep where ProcessInstanceId = : procId];
        Integer lastIndex = procStepList.size() - 1;
        System.assert(procStepList[lastIndex].StepStatus == 'Approved',  'Status: ' + procStepList[lastIndex].StepStatus);
        System.assert(procStepList[lastIndex].Comments == 'item approved',  'Comments: ' + procStepList[lastIndex].StepStatus);
        System.assert(ApprovalUtils.isUnderApproval(id) == false);                 
        
    }

    private static testmethod void testRejectRecord(){

        RFQItemWrapper wrapper = createItemWrapper();
        String id = wrapper.rfqItem.Id;
        List<ProcessInstanceWorkitem> wiList = getProcessInstanceWorkItem(id);
        System.assert(wiList.size() == 0);
        ApprovalUtils.startApproval(id,  'Test Comment');
        System.assert(ApprovalUtils.isUnderApproval(id) == true);  

        //check if data is created
        wiList = getProcessInstanceWorkItem(id);
        
        ProcessInstanceWorkItem workItem = wiList[0];
        Id procId = workItem.ProcessInstanceId;
        ApprovalUtils.rejectRecord(workItem.id, 'item rejected');
        List<ProcessInstanceStep> procStepList = [Select Id, ProcessInstanceId, Comments, StepStatus From ProcessInstanceStep where ProcessInstanceId = : procId];
        Integer lastIndex = procStepList.size() - 1;
        System.assert(procStepList[lastIndex].StepStatus == 'Rejected',  'Status: ' + procStepList[lastIndex].StepStatus);
        System.assert(procStepList[lastIndex].Comments == 'item rejected',  'Comments: ' + procStepList[lastIndex].Comments);
        System.assert(ApprovalUtils.isUnderApproval(id) == false);  

        
    }


    private static testmethod void testGetProcessInstanceWorkItem(){

        RFQItemWrapper wrapper = createItemWrapper();
        String wrapperId = wrapper.rfqItem.Id;       
        ApprovalUtils.startApproval(wrapperId,  'Test Comment');

        //check id is the same
        List<ProcessInstanceWorkitem> wiList = getProcessInstanceWorkItem(wrapperId);
        Id workItemId = wiList[0].id;
        System.assert(ApprovalUtils.getProcessInstanceWorkItem(wrapperId) == workItemId); 

        //check return null
        wiList = getProcessInstanceWorkItem(wrapperId);        
        ProcessInstanceWorkItem workItem = wiList[0];
        Id procId = workItem.ProcessInstanceId;
        ApprovalUtils.rejectRecord(workItem.id, 'item rejected');        
        System.assert(ApprovalUtils.isUnderApproval(wrapperId) == false);         
        System.assert(ApprovalUtils.getProcessInstanceWorkItem(wrapperId) == null);

    }

    //Create an itema wrapper
    private static RFQItemWrapper createItemWrapper(){
    	RFQAdminInstaller.install();
		PBGAInstaller.installTest();
		return SharedUnitTestUtils.createLineItem('PBGA');
    }

    private static List<ProcessInstanceWorkitem> getProcessInstanceWorkItem(String objectId){
    	return [Select Id, ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId
		       From ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :objectId];

    }


}