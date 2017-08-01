/*************************************************************************
*
* PURPOSE: A Base Controller for shared controller methods
*
* CLASS: BaseController
* CREATED: 3/12/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public virtual class BaseController {
    public String message {get; set;}    
    public DebugUtils debug {get {return DebugUtils.getInstance();} }
    /**
    * This method adds an error message to the top of a visualforce page that
    * uses the <apex:pageMessages> tag if you use this method consider using
    * Custom Labels : Setup > Develop > Custom Labels
    *
    * @param mesg a String containing your message
    */
    public void addError(String mesg){
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, mesg) );
    }

    /**
    * This method adds an info message to the top of a visualforce page that
    * uses the <apex:pageMessages> tag if you use this method consider using
    * Custom Labels : Setup > Develop > Custom Labels
    *
    * @param mesg a String containing your message
    */
    public void addInfo(String mesg) {
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, mesg));
    }
    
     /**
    * This method adds a warning message to the top of a visualforce page that
    * This method adds an info message to the top of a visualforce page that
    * uses the <apex:pageMessages> tag if you use this method consider using
    * Custom Labels : Setup > Develop > Custom Labels
    *
    * @param mesg a String containing your message
    */
    public void addWarning(String mesg) {
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, mesg));
    }
    
    /**
    * This method adds an info message to the top of a visualforce page that
    * uses the <apex:pageMessages> tag if you use this method consider using
    * Custom Labels : Setup > Develop > Custom Labels
    *
    * @param mesg a String containing your message
    */
    public void addConfirm(String mesg) {
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, mesg));
    }
    
    /**
    * Convenience method to get a parameter from the current page
    *
    * @param paramName the named parameter to retrieve
    */
    public String getParam(String paramName) {
        String param = PageUtil.getParam(paramName);
        if(param == 'null') param = null;
    	return param;
    }
    /**
    * Convenience method to put a parameter to the current page
    *
    * @param param the named parameter to put
    * @param value the value of the parameter
    */
    public void putParam(String param, String value) {
        PageUtil.putParam(param,value);
    }


    public PageReference showMessage(){
        if(getParam('message')!=null){
            message = getParam('message');
        }
        return null;
    }
    
}