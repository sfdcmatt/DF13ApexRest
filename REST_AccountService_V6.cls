/****************************************************************************************************
 * Description - Sample Apex REST service with GET and POST methods
 * Author - Matthew Lamb
 * Example request:
 *
   { "acctList" : 
     [{
       "Name" : "Test Account 2",
       "AccountNumber" : "888",
       "Website" : "www.site1.com",
       "BillingCity" : "San Francisco"
      },
      {
       "Name" : "Test Account 3",
       "AccountNumber" : "999",
       "BillingState" : "CA",
       "Active__c" : "true"
      }]
   }
 *    
 ****************************************************************************************************/

@RestResource(urlMapping='/v6/accounts/*')
global with sharing class REST_AccountService_V6 {
    
    @HttpPost
    global static AccountWrapper doPost(List<Account> acctList) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        AccountWrapper response = new AccountWrapper();
        
        try {
            insert acctList;
            response.acctList = acctList;
            response.status = 'Success';
            response.message = 'Your Accounts have been created successfully';
        }
        catch(Exception exc) {
            res.StatusCode = 500;
            response.acctList = null;
            response.status = 'Error';
            response.message = 'Your request failed with the following error: ' + exc.getMessage();
        }
        
        return response;
    }
    
    @HttpGet
    global static AccountWrapper doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        AccountWrapper response = new AccountWrapper();
        
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        if(doSearch(accountId)) {
            searchAccounts(req, res, response);
        }
        else {
            findAccount(res, response, accountId);
        }
        
        return response;
    }
    

    // If the item to the right of the last forward slash is "accounts", the request went to v3/accounts?Name=United
    // Else the request went to v3/accounts/<something>, which is not a search, but a specific entity
    private static boolean doSearch(String accountId) {
        if(accountId == 'accounts') {
            return true;
        }
        return false;
    }
    
    //If the request came to /v3/accounts, then we want to execute a search
    private static void searchAccounts(RestRequest req, RestResponse res, AccountWrapper response) {

        //Use the RestRequest's params to fetch the Name parameter
        String searchTerm = req.params.get('Name');
        
        if(searchTerm == null || searchTerm == '') {
            response.status = 'Error';
            response.message = 'You must provide a Name for your search term.';
            res.StatusCode = 400;
        }
        else {
            String searchText = '%'+searchTerm+'%';
            List<Account> searchResults = [SELECT Id, Name, Phone, Website FROM Account WHERE Name LIKE : searchText];
            
            if(searchResults != null && searchResults.size() > 0) {
                response.acctList = searchResults;
                response.status = 'Success';
                response.message = searchResults.size() + ' Accounts were found that matched your search term.';
            }
            else {
                response.status = 'Error';
                response.message = 'No Accounts where found based on that Name, please search again.';
            }
        }
    }
    
    //If the request came to v3/accounts/<external_Id>, then we want to find a specific account
    private static void findAccount(RestResponse res, AccountWrapper response, String accountId) {
        
        // Provided we recevied an External Id, perform the search and return the results
        if(accountId != null && accountId != '') {
            List<Account> result = [SELECT Id, Name, Phone, Website FROM Account WHERE External_Id__c =: accountId];
            
            if(result != null && result.size() > 0) {
                response.acctList.add(result[0]);
                response.status = 'Success';
            }
            else {
                response.status = 'Error';
                response.message = 'This account could not be found, please try again.';
                res.StatusCode = 404;
            }
        }
        // If the request came to /v3/accounts/ (without an Account Id), return an error
        else {
            response.status = 'Error';
            response.message = 'You must specify an External Id.';
            res.StatusCode = 400;
        }
    }
    
    global class AccountWrapper {
        public List<Account> acctList;
        public String status;
        public String message;
        
        public AccountWrapper(){
            acctList = new List<Account>();
        }
    }
}