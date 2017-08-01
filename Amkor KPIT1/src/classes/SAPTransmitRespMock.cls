@isTest
global class SAPTransmitRespMock implements WebServiceMock {
    global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
       
       amkorComSd27Cpnattributetoecc.SD27_DT_CPNAttributeResponse respElement = 
       new amkorComSd27Cpnattributetoecc.SD27_DT_CPNAttributeResponse();
       respElement.CPNAttributeResponse = 'Success';
       
       response.put('response_x', respElement); 
   }
}