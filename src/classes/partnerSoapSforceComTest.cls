@isTest
public class partnerSoapSforceComTest {
    @isTest 
	static void testRunAs() { 
        Test.setMock(WebServiceMock.class, new partnerSoapSforceComCalloutMockTest());        
        Test.startTest();
        new partnerSoapSforceCom.LoginResult();
        new partnerSoapSforceCom.GetUserInfoResult();
        new partnerSoapSforceCom.SessionHeader_element();
        new partnerSoapSforceCom.SaveResult();
        new partnerSoapSforceCom.Error();
        new partnerSoapSforceCom.ExtendedErrorDetails();
        new partnerSoapSforceCom.create_element();
        new partnerSoapSforceCom.createResponse_element();
        new partnerSoapSforceCom.login_element();
        new partnerSoapSforceCom.loginResponse_element();
        new partnerSoapSforceCom.delete_element();
        new partnerSoapSforceCom.deleteResponse_element();
        new partnerSoapSforceCom.DeleteResult();
        new partnerSoapSforceCom.Soap();
        Test.stopTest();
        new partnerSoapSforceCom.Soap().create(null);
        new partnerSoapSforceCom.Soap().login(null, null);
        new partnerSoapSforceCom.Soap().delete_x(null);
        
    }   
	
	@isTest 
	static void testWrapper() { 
        sobjectPartnerSoapSforceCom.sObject_x objectRecord = new sobjectPartnerSoapSforceCom.sObject_x();
    }   
}