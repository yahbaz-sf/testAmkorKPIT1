public class DebugUtils 
{
    private static DebugUtils mInstance = new DebugUtils();

    private static Boolean debugMode {get {return UserInfo.getUserName().contains('rfqdev');} }
    //IMPORTANT: set this to false if going to customer

    static Integer count = 0;
    public static DebugUtils getInstance() 
    {
        return mInstance;
    }

    private DebugUtils() {}

    public void log()
    {
        System.debug(LoggingLevel.ERROR, '###====================');
    }

    public void log(Object message)
    {
        System.debug(LoggingLevel.ERROR, '###' + message);
        if (System.currentPageReference() != null && debugMode) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, ++count + '. ' + (String)message) );
        }
    }

    public void log(String field, Object value)
    {
        log(field, value, true);
    }

    public void log(String field, Object value, Boolean addPageMessage)
    {
        System.debug(LoggingLevel.ERROR, '###' + field + ': ' + value);
        if (System.currentPageReference() != null && debugMode && addPageMessage) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, ++count + '. ' + field + ': ' + value) );
        }
    }

    public static void write(Object message)
    {
        System.debug(LoggingLevel.ERROR, '###' + message);
        if (System.currentPageReference() != null && debugMode) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, ++count + '. ' + (String)message) );
        }

    }

    public static void write(String field, Object value)
    {
        write(field, value, true);
    }


    public  static void write(String field, Object value, Boolean addPageMessage)
    {
        System.debug(LoggingLevel.ERROR, '###' + field + ': ' + value);
        if (System.currentPageReference() != null && debugMode && addPageMessage) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, ++count + '. ' + field + ': ' + value) );
        }
    }

    public static void write()
    {
        write(true);
    }
    public static void write(Boolean addPageMessage)
    {
        System.debug(LoggingLevel.ERROR, '###========================');
        if (System.currentPageReference() != null && debugMode && addPageMessage) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, ++count + '. ' + '###========================') );
        }
    }

}