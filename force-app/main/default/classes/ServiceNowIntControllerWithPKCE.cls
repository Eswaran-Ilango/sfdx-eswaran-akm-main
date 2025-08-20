public with sharing class ServiceNowIntControllerWithPKCE {
    static final string INSTANCE_ENDPOINT = 'https://dev295143.service-now.com';
    static final String TOKEN_ENDPOINT = 'https://dev295143.service-now.com/oauth_token.do';
    static final string AUTH_END_POINT = INSTANCE_ENDPOINT + '/oauth_auth.do';
    static final string CLIENT_ID = '8dc7f14c96fd42c28b673d74a13bd911';
    static final string CLIENT_SECRET = 'lbkQsu<Js`';
    static final string REDIRECT_URI = 'https://computing-ability-2148-dev-ed--c.scratch.vf.force.com/apex/ServiceNowRedirectURIVF';
    static final string CODE_VERIFIER = 'yLhg6jcZqqZNugj5eiulUl3S8Wv7OOxdxt9uGa3AQCSsURuZJfUGF59sXK5TDTuWJ8SHNioWsrFH0JEhREEHgdguzvMU-gX52DgD1Xtq_q9XiSHJw8Nlm5cM6MBsJz4e';
    static final string ACCOUNT_API = 'https://dev295143.service-now.com/api/now/table/incident?sysparm_query=priority=1&sysparm_limit=10';

    @AuraEnabled
    public static String fetchAuthURLServiceNow() {
        String codeChallenge = '';

        //1. Encrypt code verifier.
        Blob codeVerifierBlob = Blob.valueOf(CODE_VERIFIER);
        Blob cryptoDigest = Crypto.generateDigest('SHA-256', codeVerifierBlob);
        
        //2.Encode the code verifier in base64 URL safe format.
        codeChallenge = EncodingUtil.base64Encode(cryptoDigest)
        .replace('+', '-')
		.replace('/', '_')
		.replace('=', '')
		.replace(' ', '-');

        String authUrl = 
        AUTH_END_POINT + 
        '?grant_type=authorization_code' + 
        '&response_type=code' + 
        '&client_id=' + 
        CLIENT_ID +
        '&redirect_uri=' + 
        REDIRECT_URI + 
        '&state=123' + 
        '&code_challenge=' + 
        codeChallenge + 
        '&code_challenge_method=S256';

        return authUrl;
    }

    @AuraEnabled
    public static string exchangeAuthCodeForToken(String authCode){
        try {
            String requestBody = 
                'grant_type=authorization_code' + 
                '&code=' + 
                EncodingUtil.urlEncode(authCode, 'UTF-8') + 
                '&client_id=' + 
                CLIENT_ID + 
                '&client_secret=' + 
                EncodingUtil.urlEncode(CLIENT_SECRET, 'UTF-8') + 
                '&redirect_uri=' + 
                EncodingUtil.urlEncode(REDIRECT_URI, 'UTF-8') + 
                '&code_verifier=' +
                EncodingUtil.urlEncode(CODE_VERIFIER, 'UTF-8');

            System.debug('EncodingUtil.urlencode(CODE_VERIFIER, \'UTF-8\')  '+ EncodingUtil.urlencode(CODE_VERIFIER, 'UTF-8'));
            System.debug('requestBody '+ requestBody);
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(TOKEN_ENDPOINT);
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setBody(requestBody);

            HttpResponse res = http.send(req);
            if(res.getStatusCode() == 200) {
                Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                String token = (String)resMap.get('access_token');
                return getAccounts(token);
            } else {
                return 'Error while getting access token for service now::' + res.getStatusCode() + '::' + res.getBody();
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static String getAccounts(String token) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(ACCOUNT_API);
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Accept', 'application/json');

        HttpResponse res = http.send(req);
        if(res.getStatusCode() == 200) {
            return res.getBody();
        } else {
            return 'Error while getting access token for service now::' + res.getStatusCode() + '::' + res.getBody();
        }
    }
}