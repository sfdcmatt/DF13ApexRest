/****************************************************************************************************
 * Description - Sample Apex REST service with GET method
 * Author - Matthew Lamb
 ****************************************************************************************************/

@RestResource(urlMapping='/v1/accounts/*')
global with sharing class REST_AccountService_V1 {
    
    @HttpGet
    global static Account doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        Account result = [SELECT Id, Name, Phone, Website, BillingState FROM Account WHERE External_Id__c = :accountId];
        return result;
    }
}