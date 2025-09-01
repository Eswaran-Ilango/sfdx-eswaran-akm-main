public class GitHubNamedCredentials {
    public static void getAuthenticatedUserInfo() {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:Get_Authenticated_User_Info_GitHub');
        
        HttpResponse res = http.send(req);
        
        system.debug('Get_Authenticated_User_Info_GitHub' + res.getBody());
        
    }

}