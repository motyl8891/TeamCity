@isTest
global class partnerSoapSforceComCalloutMockTest implements WebServiceMock {
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
            
            if(request instanceof partnerSoapSforceCom.login_element)
                response.put('response_x', new partnerSoapSforceCom.loginResponse_element());
            
            if(request instanceof partnerSoapSforceCom.delete_element)
                response.put('response_x', new partnerSoapSforceCom.deleteResponse_element());            
            
            if(request instanceof partnerSoapSforceCom.create_element)
                response.put('response_x', new partnerSoapSforceCom.createResponse_element());
            return;
        }
}