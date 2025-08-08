public with sharing class GitHubReposController {
    // Constant URL for GitHub API to fetch repositories starting from ID 1
    static final String GIT_HUB_REPOS_API = 'https://api.github.com/repositories?since=1';
    
    /**
     * @AuraEnabled method to fetch GitHub repositories
     * The cacheable=true annotation allows the result to be cached on the client side
     * @return String JSON response containing repository data
     * @throws AuraHandledException if the API call fails
     */
    @AuraEnabled(cacheable=true)
    public static String getGitRepos() {
        // Initialize HTTP object to make callouts
        Http http = new Http();
        
        // Create and configure the HTTP request
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');                  // Set HTTP method to GET
        req.setEndpoint(GIT_HUB_REPOS_API);    // Set the target endpoint URL
        
        try {
            // Send the HTTP request and get the response
            HttpResponse res = http.send(req);
            
            // Check if the request was successful (HTTP 200 OK)
            if(res.getStatusCode() == 200) {
                return res.getBody();          // Return the response body if successful
            }
            // Note: If status code is not 200, falls through to return error message below
        } catch(Exception e) {
            // Handle any exceptions that occur during the HTTP request
            throw new AuraHandledException(e.getMessage());
        }
        
        // Return a generic error message if response status was not 200
        return 'Something went wrong, please try again!!';
    }
}
