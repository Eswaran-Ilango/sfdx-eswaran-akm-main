public with sharing class SpotifyClientCredentialsController {
    static final string SPOTIFY_AUTH_ENDPOINT = 'https://accounts.spotify.com/api/token';
    static final string SPOTIFY_NEW_RELEASES_ENDPOINT = 'https://api.spotify.com/v1/browse/new-releases?offset=0&limit=1';
    static final string CLIENT_ID = 'b9613f4dd0294ac3a806d2edcca5a25a';
    static final string CLIENT_SECRET = '73be3ea6843b417e9c5748998985bf95';

    @AuraEnabled
    public static string getNewReleases(){
        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(SPOTIFY_AUTH_ENDPOINT);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            
            String requestBody = 
            'grant_type=client_credentials' + 
            '&client_id=' + 
            CLIENT_ID + 
            '&client_secret=' 
            + CLIENT_SECRET;
            
            req.setBody(requestBody);

            HttpResponse res = http.send(req);
            if(res.getStatusCode() == 200) {
                Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                String accessToken = (String)resMap.get('access_token');
                return getNewReleasesWithToken(accessToken);
            } else {
                return 'Error while getting access token for Spotify::' + res.getStatusCode() + '::' + res.getBody();
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    static String getNewReleasesWithToken(String accessToken) {
        Http http = new Http();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(SPOTIFY_NEW_RELEASES_ENDPOINT);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');

        HttpResponse res = http.send(req);
        if(res.getStatusCode() == 200) {
            return paraseGetNewReleases(res.getBody());
            //return res.getBody();
        } else {
            return 'Error while getting access token for Spotify::' + res.getStatusCode() + '::' + res.getBody();
        }
    }

    class NewReleaseWrap {
        @AuraEnabled
        public String albumName;
        @AuraEnabled
        public String albumImgUrl;
        @AuraEnabled
        public String artistName;
    }

    static String paraseGetNewReleases(String resBody) {
        List<NewReleaseWrap> albumsList = new List<NewReleaseWrap>();

    Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(resBody);
    Map<String, Object> albums = (Map<String, Object>) jsonMap.get('albums');
    List<Object> items = (List<Object>) albums.get('items');

    for (Object obj : items) {
        Map<String, Object> item = (Map<String, Object>) obj;
        NewReleaseWrap albumWrap = new NewReleaseWrap();

        albumWrap.albumName = (String) item.get('name');

        // Artists
        List<Object> artists = (List<Object>) item.get('artists');
        if (!artists.isEmpty()) {
            Map<String, Object> firstArtist = (Map<String, Object>) artists[0];
            albumWrap.artistName = (String) firstArtist.get('name');
        }

        // Images
        List<Object> images = (List<Object>) item.get('images');
        if (!images.isEmpty()) {
            Map<String, Object> firstImage = (Map<String, Object>) images[0];
            albumWrap.albumImgUrl = (String) firstImage.get('url');
        }

        albumsList.add(albumWrap);
    }

    return JSON.serialize(albumsList);
    }
}