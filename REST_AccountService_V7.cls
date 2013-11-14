/****************************************************************************************************
 * Description - Sample Apex REST service with GET and POST methods
 * Author - Matthew Lamb
 * Inspiration taken from Mohit Srivastav @ cloudyworlds.blogspot.in
 * Original source blog post: http://cloudyworlds.blogspot.in/2012/11/native-parsing-of-json-input-into-user.html
 * Example request:
 *
{
  "rqst" :
  {
    "acct" : 
    { 
      "Name" : "Salesforce.com",
      "AccountNumber" : "1001",
      "Website" : "www.salesforce.com"
    },
    "contList" :
    [
      {"FirstName" : "Test", "LastName" : "O'Riley", "Email" : "testcontact1@salesforce.com"},
      {"FirstName" : "Test", "LastName" : "Contact2", "Email" : "testcontact2@salesforce.com"},
      {"FirstName" : "Test", "LastName" : "Contact3", "Email" : "testcontact3@salesforce.com"}
    ]
  }
}
 *    
 ****************************************************************************************************/

@RestResource(urlMapping='/v7/accounts/*')
global with sharing class REST_AccountService_V7 {
    
    @HttpPost
    global static PostResponseWrapper doPost(RequestWrapper rqst) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        PostResponseWrapper response = new PostResponseWrapper();
        
        try {
            insert rqst.acct;
            response.acct = rqst.acct;

            for(Contact con : rqst.contList) {
                con.AccountId = rqst.acct.Id;
            }
            
            insert rqst.contList;
            response.contList = rqst.contList;
            
            response.status = 'Success';
            response.message = 'Your Accounts have been created successfully';
        }
        catch(Exception exc) {
            res.StatusCode = 500;
            response.acct = null;
            response.contList = null;
            response.status = 'Error';
            response.message = 'Your request failed with the following error: ' + exc.getMessage();
        }
        
        return response;
    }
    
    @HttpGet
    global static GetResponseWrapper doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        GetResponseWrapper response = new GetResponseWrapper();
        
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
    private static void searchAccounts(RestRequest req, RestResponse res, GetResponseWrapper response) {

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
    private static void findAccount(RestResponse res, GetResponseWrapper response, String accountId) {
        
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
    
    global class RequestWrapper {
        Account acct;
        List<Contact> contList;
    }
    
    global class PostResponseWrapper {
        Account acct;
        List<Contact> contList;
        String status;
        String message;
        
        public PostResponseWrapper(){
            
        }
    }
    
    global class GetResponseWrapper {
        public List<Account> acctList;
        public String status;
        public String message;
        
        public GetResponseWrapper(){
            acctList = new List<Account>();
        }
    }
}