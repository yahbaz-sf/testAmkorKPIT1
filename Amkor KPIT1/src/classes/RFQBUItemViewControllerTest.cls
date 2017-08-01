/*************************************************************************
*
* PURPOSE: Tests for the RFQ BU Item view page
*
* CLASS: RFQBUItemViewControllerTest
* CREATED: 3/21/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
@isTest
private class RFQBUItemViewControllerTest {
  
  
    private static testmethod void testConstructor() {
      
      RFQBUItemViewController rfqItemCont = setupController();      
      System.assert(rfqItemCont.layout != null);
      System.assert(rfqItemCont.layout.sectionMap != null);
      System.assert(rfqItemCont.wrapper.specificRfqItem != null);
      System.assert(rfqItemCont.wrapper.wireConfigurations.size() > 0);
       
      //make sure we have the right sections for BU layout
      System.assert(rfqItemCont.layout.enabledSections.get('BU Header'));
      System.assert(rfqItemCont.layout.enabledSections.get('Cost and Price'));
    }
  
  private static testmethod void testPF() {
    RFQBUItemViewController rfqItemCont = setupController();
    
    PageReference pf = rfqItemCont.editPrice();
    system.assert(pf != null);
    
    pf = rfqItemCont.buExport();
    system.assert(pf != null);
  }

  private static testmethod void testBUPriceAMK1442() {

    RFQBUItemViewController rfqItemCont = setupController();


    rfqItemCont.wrapper.rfqItem.put('Status__c', RFQItemDao.STATUS_NEW);
    rfqItemCont.setupCostModel();
    Object o = rfqItemCont.wrapper.specificRfqItem.get('BU_Price__c');

    rfqItemCont.wrapper.rfqItem.put('Status__c', RFQItemDao.STATUS_PRICE_PENDING_BU);
    rfqItemCont.setupCostModel();
    Object o2 = rfqItemCont.wrapper.specificRfqItem.get('BU_Price__c');

        //I'm a BU person, i just manually edited the price
        rfqItemCont.wrapper.specificRfqItem.put('BU_Price__c',42);
        //simulate BU edit price and saving/approving rejecting modified price
    RFQItemDao.getInstance().saveLineItem(rfqItemCont.wrapper);

    rfqItemCont.setupCostModel(); // <-- better not eff with my price

    Test.stopTest();
    
    System.assert(o == null);
    System.assert(o2 != null);
    //System.assert((Decimal)o2 > 0);

    RFQItemWrapper wrapper = RFQItemDao.getInstance().getWrapperById(rfqItemCont.wrapper.rfqItem.Id);
        Decimal testPrice = (Decimal) wrapper.specificRfqItem.get('BU_Price__c');
        System.assert(Math.abs(testPrice - 42) < 0.00000001, 'Test Price: ' + testPrice + ' Expected: 42');

  }

  public static RFQBUItemViewController setupController() {
    
    //make sure the sections and a layout exist
      RFQAdminInstaller.install();
      RFQAdminInstaller.installFactories();
        RFQItemWrapper wrapper = setUpQuadLeadframe();
      Test.startTest();
    
    
    //setup Quote information
    setupQuoteInformation(wrapper, '< 500');
    //Setup Package description
    setupPackage(wrapper, 'P1', '7x7', '48');
    //Setup wire
    setupWire(wrapper, 'Au', '0.8', 48.0, 48.0, 1.6);
    //Setup die
  
    List<Decimal> dieX = new List<Decimal>();
    List<Decimal> dieY = new List<Decimal>();
    
    dieX.add(3.1);
    dieY.add(3.1);
    setupDie(wrapper, 1, dieX, dieY);
    
    //instantiate a wire calculator
    Type t = Type.forName(wrapper.productGroup.Wire_Calculation_Implementation__c);    
    CMWireCalcBase wireCalculator = (CMWireCalcBase)t.newInstance();
        wireCalculator.calculate(wrapper);

        RFQItemDao.getInstance().saveLineItem(wrapper);

      ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(wrapper.rfqItem);
      ApexPages.currentPage().getParameters().put('edit','1');
      RFQBUItemViewController rfqItemCont = new RFQBUItemViewController(sc);
      return rfqItemCont;
  }

  static private RFQItemWrapper setUpQuadLeadframe(){
    
    QuadLeadframeInstaller.install();        
    CMQuadInstaller.install();
    
    //get wrapper
    RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('TQFP', 1, 1);
    
        
    return wrapper;
  }

  static private void setupQuoteInformation(RFQItemWrapper wrapper, String Forecast){
    wrapper.setAttribute('Forecast__c', 'Package', Forecast);
  }

  static private void setupPackage(RFQItemWrapper wrapper, String location, String bodySize, String Lead_Count){
    
    System.debug(LoggingLevel.ERROR, '#### start config package');
    
    if(location != null){
      Factory__c factory = [Select Name, id From Factory__c where Name =: location];
      wrapper.setAttribute('Factory__c', 'Package', factory.Id);
    }
    
    wrapper.setAttribute('Body_Size__c', 'Package', bodySize);
    wrapper.setAttribute('Lead_Count__c', 'Package', Lead_Count);          
  }
  
  static private void setupDie(RFQItemWrapper wrapper, Integer Num_of_Die, List<Decimal> dieX, List<Decimal> dieY){
      
    for(Integer i = 0; i < Num_of_Die; i++){
      wrapper.dieConfigurations[i].put('Die_Size_X__c', dieX[i]);
      wrapper.dieConfigurations[i].put('Die_Size_Y__c', dieY[i]);
    }
  }
  
  static private void setupWire(RFQItemWrapper wrapper, String Wire_Material, String Wire_Diameter, Decimal Number_Of_Wires, Decimal numberFwdWires, Decimal Total_2D_Wire_Length){
    
    wrapper.wireConfigurations[0].put('Wire_Material__c',Wire_Material);
    wrapper.wireConfigurations[0].put('Wire_Diameter__c',  Wire_Diameter);
    wrapper.wireConfigurations[0].put('Number_Of_Wires__c',Number_Of_Wires);
    wrapper.wireConfigurations[0].put('Number_Of_FWD_Wires__c',numberFwdWires);
    wrapper.wireConfigurations[0].put('Total_2D_Wire_Length__c',Total_2D_Wire_Length);
    
  }
  
  //Lalit - 09-Dec-2016 : Salesforce-138 : Add file attachment capability for BU users when responding to RFQ Items
    private static testmethod void createBUNotesNAttachments(){
        
        RFQBUItemViewController rfqItemCont = setupController();
        RFQItemWrapper wrapper = rfqItemCont.wrapper; 
        RFQI_BU_Notes_Attachments__c buna = new RFQI_BU_Notes_Attachments__c(RFQ_Item__c = wrapper.rfqItem.Id);
        insert buna;
        rfqItemCont.buNotesandAttachment = buna;
        if(buna != null){
            Note note = new Note(parentId = buna.Id, Title = 'Test Note');
            insert note;
            Blob attBody=Blob.valueOf('Unit Test Attachment Body');
            Attachment att =new Attachment(Name='Unit Test Attachment', body=attBody, parentId = buna.Id);  
            insert att;
            
            rfqItemCont.noteId = note.Id;
            rfqItemCont.Id = note.Id;
            rfqItemCont.attachmentId = att.Id;
            
            rfqItemCont.editNotes();
            rfqItemCont.deleteNotes();
            rfqItemCont.viewAttachments();
            rfqItemCont.editAttachments();
            rfqItemCont.deleteAttachments();
            rfqItemCont.goToId();
        }
    }
}