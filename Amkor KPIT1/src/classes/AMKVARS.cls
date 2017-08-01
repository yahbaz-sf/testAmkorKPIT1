public with sharing class AMKVARS {
    
    //--Product Group Names
    public static final String PG_QUAD      = 'Quad Leadframe';
    public static final String PG_MLF       = 'MLF';
    public static final String PG_SCSP      = 'SCSP';
    public static final String PG_EGRSVC    = 'Engineering Services';
    public static final String PG_ATM       = 'Power Discrete';
    public static final String PG_FC        = 'Flip Chip';
    
    //---Package Family Names
    public static final String PF_BUMP      = 'Bump/WLCSP (Wafer Services)';
    public static final String PF_TEST      = 'Test';
    public static final String PF_WLCSP     = 'WLCSP (Die Services)';
    public static final String PF_DPS       = 'Die Processing Service';
    public static final String PF_PBGA      = 'PBGA';
    public static final String PF_CABGA     = 'CABGA';
    public static final String PF_DS        = 'Die Sales';
    public static final String PF_LF        = 'LEAD FINISH';
    public static final String PF_WB        = 'WAFER BACKGRIND';
    public static final String PF_HERM      = 'Hermetics/Ceramics';
    public static final String PF_TSV       = 'TSV';

    //---Specific Object Names
    public static final String OBJ_FCBGA    = 'RFQI_fcBGA__c';
    public static final String OBJ_BUMP     = 'RFQI_Bump__c';

    //---Test Types
    public static final String TT_STRIP     = 'Strip Test';
    public static final String TT_PROBE     = 'Wafer Probe';
    public static final String TT_POST      = 'Post-Test Services Only';
    public static final String TT_FINAL     = 'Final Test';
    //Bharat - 25-Jul-2017 : Salesforce-81 : JDevice Plant Quoting capability in SFDC
    // New test types: Final Test-JDev and Wafer Probe-JDev.
    public static final String TT_FINAL_JDEV     = 'Final Test-JDev';
    public static final String TT_PROBE_JDEV     = 'Wafer Probe-JDev';
    

    public static final List<String> YEARS = new List<String> {
        '2013',
        '2014',
        '2015',
        '2016',
        '2017',
        '2018',
        '2019',
        '2020',
        '2021',
        '2022',
        '2023'
    };
}