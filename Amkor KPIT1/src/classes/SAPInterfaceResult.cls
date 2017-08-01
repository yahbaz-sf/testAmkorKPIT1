public class SAPInterfaceResult {

    public List<Account> accountList;
    public String errorMessage;
    public String errorSource;
    public Boolean isError;
    public String process;
    public String accountReference;
    
    public SAPInterfaceResult() {
        this.isError = false;
        accountList = new List<Account>();
     	accountReference = '';   
    }
    
    public void addError (String errorText) 
    {
        system.debug('----->errorText : ' + errorText);
        if(String.isNotBlank(errorText)) {
            this.isError = true;
            this.errorMessage = errorText; 
        }
    }
}