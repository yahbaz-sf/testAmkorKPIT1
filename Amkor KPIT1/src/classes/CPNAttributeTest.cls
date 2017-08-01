/*************************************************************************
* 
* PURPOSE: Test methods for CPNAttribute 
*          
* CLASS: CPNAttributeTest
* CREATED: 03/19/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
@isTest
private class CPNAttributeTest {/*
	
	/**
    * Tests constructor initialization for CPNAttribute
    *
    private static testmethod void testConstructor() {
    	//TODO -- see comments in test CompareTo
    	Product_Group__c pg = SharedUnitTestUtils.createTestProductGroup();
    	RFQItemWrapper item = SharedUnitTestUtils.createLineItem('Unit Test Package Family');
    	RFQI_PF_Field_Def__c fieldDef = new RFQI_PF_Field_Def__c();
    	fieldDef = SharedUnitTestUtils.createTestRFQIPFFieldDef();
        CPNAttribute attribute = new CPNAttribute (item.specificRfqItem, fieldDef);
        system.assert(attribute != null);
    }
    
   	/**
    * Tests getValueDecimal for CPNAttribute
    *
    private static testmethod void testGetValueDecimal() {
    	
    	Product_Group__c pg = SharedUnitTestUtils.createTestProductGroup();
    	RFQItemWrapper item = SharedUnitTestUtils.createLineItem('Unit Test Package Family');
    	RFQI_PF_Field_Def__c fieldDef = SharedUnitTestUtils.createTestRFQIPFFieldDef();
    	CPNAttribute attribute = new CPNAttribute (item.specificRfqItem, fieldDef);
    	system.assert(attribute.getValueDecimal() != null);
    }
    
    /**
    * Tests setValue for CPNAttribute
    *
    private static testmethod void testSetValue() {
     	//TODO -- see comments in test CompareTo
    	Product_Group__c pg = SharedUnitTestUtils.createTestProductGroup();
    	RFQItemWrapper item = SharedUnitTestUtils.createLineItem('Unit Test Package Family');
    	RFQI_PF_Field_Def__c fieldDef = SharedUnitTestUtils.createTestRFQIPFFieldDef();
    	CPNAttribute attribute = new CPNAttribute (item.specificRfqItem, fieldDef);
    	decimal testDec = 20;
    	attribute.setValue(testDec);
    	system.assert(attribute.val == '20');
    }
    
    /**
    * Tests computeHighLowEqualInterval for CPNAttribute
    *
    private static testmethod void testComputeHighLowEqualInterval() {
    	Product_Group__c pg = SharedUnitTestUtils.createTestProductGroup();
    	RFQItemWrapper item = SharedUnitTestUtils.createLineItem('Unit Test Package Family');
    	RFQI_PF_Field_Def__c fieldDef = SharedUnitTestUtils.createTestRFQIPFFieldDef();
    	
    	//TODO -- see comments in test CompareTo
    	CPNAttribute attribute = new CPNAttribute (item.specificRfqItem, fieldDef);
    	decimal testStart = 1;
    	decimal testLength = 2;
    	attribute.computeHighLowEqualInterval(testStart, testLength);
    	decimal testVal = Decimal.valueOf(attribute.val);
    	system.assert(attribute.hVal > testVal);   	
    }
    
    /**
    * Tests isBucketed for CPNAttribute
    *
    private static testmethod void testIsBucketed(){
    	//TODO -- see comments in test CompareTo
    	
    	Product_Group__c pg = SharedUnitTestUtils.createTestProductGroup();
    	RFQItemWrapper item = SharedUnitTestUtils.createLineItem('Unit Test Package Family');
    	RFQI_PF_Field_Def__c fieldDef = SharedUnitTestUtils.createTestRFQIPFFieldDef();
    	CPNAttribute attribute = new CPNAttribute (item.specificRfqItem, fieldDef);
    	attribute.bucket = 'some test string';
    	system.assert(attribute.isBucketed() != false);
    }
    
    /**
    * Tests toString for CPNAttribute
    *
    private static testmethod void testToString(){
    	
    	//TODO -- see comments in test CompareTo
    	
    	Product_Group__c pg = SharedUnitTestUtils.createTestProductGroup();
    	RFQItemWrapper item = SharedUnitTestUtils.createLineItem('Unit Test Package Family');
    	RFQI_PF_Field_Def__c fieldDef = SharedUnitTestUtils.createTestRFQIPFFieldDef();
    	CPNAttribute attribute = new CPNAttribute (item.specificRfqItem, fieldDef);
    	system.assert(attribute.toString() == '$' + attribute.key + '=' + attribute.val + '$');
    	attribute.bucket = 'some test string';
    	system.assert(attribute.toString() == '$' + attribute.key + '=[' + attribute.hVal + ',' + attribute.lVal + ']$');
    }
    
    /**
    * Tests compareTo for CPNAttribute
    *
    private static testmethod void testCompareTo(){
    	Product_Group__c pg = SharedUnitTestUtils.createTestProductGroup();
    	RFQItemWrapper item = SharedUnitTestUtils.createLineItem('Unit Test Package Family');
    	RFQI_PF_Field_Def__c fieldDef = SharedUnitTestUtils.createTestRFQIPFFieldDef();
    	
    	//TODO - there are a number of things wrong here, but first when you instansiate a CPNAttribute, 
    	//the argument should not be an RFQ Object, it should be line item for that RFQ. Shame on me for not
    	//having a constructor comment. It has one now.
    	
    	CPNAttribute attribute = new CPNAttribute (item.specificRfqItem, fieldDef);
    	system.assert(attribute.compareTo(attribute) != null);
    }
    
*/}