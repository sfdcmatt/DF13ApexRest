@isTest
private class REST_AccountService_V6_Test {
    
    static testMethod void testDoGet_WithoutId() {
        setupTestData();
        
        Test.startTest();
        // Set up the RestContext object
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();
        RestContext.request.requestURI = 'https://na15.salesforce.com/services/apexrest/v6/accounts/';  
        RestContext.request.httpMethod = 'GET';
        
        REST_AccountService_V6.AccountWrapper results = new REST_AccountService_V6.AccountWrapper();
        results = REST_AccountService_V6.doGet();
        Test.stopTest();
        
        system.assertEquals(results.status, 'Error');
        system.assertEquals(results.message,'You must specify an External Id.');
        system.assertEquals(System.RestContext.response.StatusCode, 400);
    }
    
    static testMethod void testDoGet_WithGoodId() {
        setupTestData();
        
        Test.startTest();
        // Set up the RestContext object
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();
        RestContext.request.requestURI = 'https://na15.salesforce.com/services/apexrest/v6/accounts/1002';  
        RestContext.request.httpMethod = 'GET';
        
        REST_AccountService_V6.AccountWrapper results = new REST_AccountService_V6.AccountWrapper();
        results = REST_AccountService_V6.doGet();
        Test.stopTest();
        
        system.assertEquals(results.status, 'Success');
    }
    
    static testMethod void testDoGet_WithBadId() {
        setupTestData();
        
        Test.startTest();
        // Set up the RestContext object
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();
        RestContext.request.requestURI = 'https://na15.salesforce.com/services/apexrest/v6/accounts/6550';  
        RestContext.request.httpMethod = 'GET';
        
        REST_AccountService_V6.AccountWrapper results = new REST_AccountService_V6.AccountWrapper();
        results = REST_AccountService_V6.doGet();
        Test.stopTest();
        
        system.assertEquals(results.status, 'Error');
        system.assertEquals(results.message,'This account could not be found, please try again.');
        system.assertEquals(System.RestContext.response.StatusCode, 404);
    }
    
    private static void setupTestData() {
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name='Account 1', Phone='(111) 222-3344', Website='www.account1.com', External_Id__c='1000'));
        accounts.add(new Account(Name='Account 2', Phone='(222) 333-4455', Website='www.account1.com', External_Id__c='1001'));
        accounts.add(new Account(Name='Account 3', Phone='(333) 444-5566', Website='www.account1.com', External_Id__c='1002'));
        accounts.add(new Account(Name='Account 4', Phone='(444) 555-6677', Website='www.account1.com', External_Id__c='1003'));
        accounts.add(new Account(Name='Account 5', Phone='(555) 666-7788', Website='www.account1.com', External_Id__c='1004'));
        insert accounts;
    }
}