/**
 * @author: Eswaran
 * @description: Sample REST API callouts using public APIs.
 * @date: 30/11/2024
 **/ 
public class RESTAPIDemo {
    public static final String TRAILHEAD_ANIMALS_API = System.Label.TrailHeadAnimalsAPI;
    public static final String US_PUBLIC_DATA_API = System.Label.USPublicDataAPI;
    
    public static void callTrailHeadAnimalsAPI() {
        structureResponseAnimalsAPI(getAPIMethod(TRAILHEAD_ANIMALS_API));
    }
    
    public static void callUSPublicDataAPI() {
        structureResponseUSPublicDataAPI(getAPIMethod(US_PUBLIC_DATA_API));
    }
    
    public static String getAPIMethod(String endpoint) {
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        
        try{
            response = http.send(req);
            if(response.getStatusCode() == 200) {
                System.debug(response.getBody());
                return response.getBody();
            }else {
                throwAuraHandledException('Error status code:::' + response.getStatusCode());
            }
            
        }catch(Exception e) {
            throwAuraHandledException(e.getMessage());
        }
        
        return null;
    }
    
    public static void structureResponseAnimalsAPI(String responseBody) {
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        List<Object> animalsList = (List<Object>)results.get('animals');
        for(Object animal: animalsList) {
            System.debug(animal);
        }
    }
    
    public static void structureResponseUSPublicDataAPI(String responseBody) {
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        List<Object> dataList = (List<Object>)results.get('data');
        for(Object data: dataList) {
            Map<String, Object> usData = (Map<String, Object>)data;
            System.debug(usData.get('ID Nation'));
            System.debug(usData.get('ID Year'));
            System.debug(usData.get('Population'));
        }
    }
    
	public static void throwAuraHandledException(String exceptionMsg) {
        AuraHandledException auraExpObj = new AuraHandledException(exceptionMsg);
        auraExpObj.setMessage(exceptionMsg);
        throw auraExpObj;
    }
}