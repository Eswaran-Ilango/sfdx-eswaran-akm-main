public with sharing class HubSpotController {
    static final Id LOGGED_IN_USER_ID = UserInfo.getUserId();
    static HubSpot_Token_Details__c tokenDetails = HubSpot_Token_Details__c.getInstance(LOGGED_IN_USER_ID);
    static HubSpot_Credential__mdt hubSpotCredential = HubSpot_Credential__mdt.getInstance('MyHubSpot_Credential');
    
    @AuraEnabled
    public static HubSpotTokenWrapper isAccessTokenValid(){
        try {
            
            if(tokenDetails == null || String.isBlank(tokenDetails.Access_Token__c)) {
                return new HubSpotTokenWrapper(false, false);
            }

            Datetime tokenModifiedDate = tokenDetails.lastModifiedDate;
            Datetime currentTimeStamp = Datetime.now();
            long timeDiffMilli = currentTimeStamp.gettime() - tokenModifiedDate.gettime();
            long timeDiffSec = timeDiffMilli / 1000;

            return new HubSpotTokenWrapper(true, timeDiffSec < tokenDetails.Expires_In_Sec__c);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    class HubSpotTokenWrapper {
        Boolean tokenExistForUser;
        Boolean isAccessTokenValid;

        HubSpotTokenWrapper(Boolean tokenExistForUser, Boolean isAccessTokenValid) {
            this.tokenExistForUser = tokenExistForUser;
            this.isAccessTokenValid = isAccessTokenValid;
        }
    }

    @AuraEnabled
    public static string getHubSpotCompanyInfo(String authCode, Boolean isRefreshToken) {
        String accessTokenEndPoint = 'https://api.hubapi.com/oauth/v1/token';
        try {
            
            Http http = new Http();

            HttpRequest req = new HttpRequest();
            req.setEndpoint(accessTokenEndPoint);
            req.setMethod('POST');
            req.setHeader('content-type', 'application/x-www-form-urlencoded');

            String requestBody = 'grant_type=authorization_code&code=' + authCode +
            '&redirect_uri=' + hubSpotCredential.Redirect_URI__c
             + '&client_id=' + + hubSpotCredential.Client_Id__c + '&client_secret=' + hubSpotCredential.Client_Secret__c;
            
            if (isRefreshToken) {
                requestBody = 'grant_type=refresh_token&refresh_token=' + tokenDetails.Refresh_Token__c 
                + '&client_id=' + + hubSpotCredential.Client_Id__c + '&client_secret=' + hubSpotCredential.Client_Secret__c;
                
            }
            req.setBody(requestBody);
            
            
            HttpResponse res = http.send(req);

            if(res.getStatusCode() == 200) {

                String body = res.getBody();
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(body);
                String accessToken = (String)responseMap.get('access_token');
                String refreshToken = (String)responseMap.get('refresh_token');
                Integer expiresIn = (Integer)responseMap.get('expires_in');
                
                HubSpot_Token_Details__c  hubSpotToken = new HubSpot_Token_Details__c(
                    Id = tokenDetails.Id,
                    Access_Token__c = accessToken,
                    Expires_In_Sec__c = expiresIn,
                    Refresh_Token__c = refreshToken,
                    SetupOwnerId = LOGGED_IN_USER_ID
                );
                upsert hubSpotToken;
                return 'User successfully authenticated with HubSpot. Access token details are :: ' + hubSpotToken;
                //return getBatchOfCompanies(accessToken);
            } else  {
                return 'Error::' + res.getStatusCode() + '::' + res.getBody();
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    @AuraEnabled
    public static String getAllCompaniesInfo(String accessToken) {
        String companyInfoEndPoint = 'https://api.hubapi.com/crm/v3/objects/companies?limit=10&propertiesWithHistory=name&archived=false';
        Http http  = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(companyInfoEndPoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');

        HttpResponse res = http.send(req);

        if(res.getStatusCode() == 200) {
            return res.getBody();
        } else {
            return 'Something went wrong. Contact your administrator.';
        } 
    }

    @AuraEnabled
    public static String getBatchOfCompanies() {
        HubSpotTokenWrapper hbTokWrap = isAccessTokenValid();
        
        if(!hbTokWrap.tokenExistForUser) {
            throw new AuraHandledException('no token found for logged in user. Please make sure you have session active with HubSpot.');
        }
        
        if(!hbTokWrap.isAccessTokenValid) {
            throw new AuraHandledException('token expired for logged in user. Please make sure you have session active with HubSpot.');
        }

        String companyInfoEndPoint = 'https://api.hubapi.com/crm/v3/objects/companies/batch/read?archived=false';
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(companyInfoEndPoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + tokenDetails.Access_Token__c);

        BatchCompaniesRequestBody  batchCompaniesBody = new BatchCompaniesRequestBody();
        batchCompaniesBody.propertiesWithHistory = new List<String>{ 'name', 'industry' };
        batchCompaniesBody.properties = new List<String> { 'name', 'industry' };
        batchCompaniesBody.inputs = new List<Map<String, String>> { 
            new Map<String, String> { 'id' => '137912700606' }, 
            new Map<String, String> { 'id' => '139122476760' } 
        };

        //'{ "propertiesWithHistory": [ "name" ],  "inputs": [ { "id": "137912700606" } ], "properties": [ "name", "industry" ] }'
        req.setBody(JSON.serialize(batchCompaniesBody));

        HttpResponse res = http.send(req);
        if(res.getStatusCode() == 200)  {
            return deserializeBatchResponse(res.getBody());
        } else {
            return 'Something went wrong. Contact your administrator.' + res.getStatusCode() + '::' + res.getBody() + '::' ;
        }
    }

    private class BatchCompaniesRequestBody {
        List<String> propertiesWithHistory;
        List<Map<String, String>> inputs;
        List<String> properties;
    }

    static String deserializeBatchResponse(String responseBody) {
        String companyInfo = '';
        Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        List<Object> resultList = (List<Object>)resMap.get('results');
        
        for(Object resultObj: resultList) {
            Map<String, Object> companyInfoMap = (Map<String, Object>)resultObj;
            Map<String, Object> propMap = (Map<String, Object>)companyInfoMap.get('properties');

            String industry = (String)propMap.get('industry');
            String name = (String)propMap.get('name');
            companyInfo += 'Name: ' + name + '::' + 'Industry: ' + industry + '\n';
        }
        return companyInfo;       
    }

    @AuraEnabled
    public static string refreshToken() {
        String accessTokenEndPoint = 'https://api.hubapi.com/oauth/v1/token';
        try {
            
            Http http = new Http();

            HttpRequest req = new HttpRequest();
            req.setEndpoint(accessTokenEndPoint);
            req.setMethod('POST');
            req.setHeader('content-type', 'application/x-www-form-urlencoded');

            
            String requestBody = 'grant_type=refresh_token&refresh_token=' + tokenDetails.Refresh_Token__c 
            + '&client_id=' + + hubSpotCredential.Client_Id__c + '&client_secret=' + hubSpotCredential.Client_Secret__c;
            
        
            req.setBody(requestBody);
            
            
            HttpResponse res = http.send(req);

            if(res.getStatusCode() == 200) {

                String body = res.getBody();
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(body);
                String accessToken = (String)responseMap.get('access_token');
                String refreshToken = (String)responseMap.get('refresh_token');
                Integer expiresIn = (Integer)responseMap.get('expires_in');
                
                HubSpot_Token_Details__c  hubSpotToken = new HubSpot_Token_Details__c(
                    Id = tokenDetails.Id,
                    Access_Token__c = accessToken,
                    Expires_In_Sec__c = expiresIn,
                    Refresh_Token__c = refreshToken,
                    SetupOwnerId = LOGGED_IN_USER_ID
                );
                upsert hubSpotToken;
                return 'refresh token flow' + hubSpotToken;
                //return getBatchOfCompanies(accessToken);
            } else  {
                return 'Error::' + res.getStatusCode() + '::' + res.getBody();
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()); 
        }
    }
}