public class ApiIntegration {
    @Future(Callout = true)
    public static void sendPatchCallout(Set<Id> listCntIds) {
        try {
            String endpointUrl = 'https://fxyozmgb2xs5iogcheotxi6hoa0jdhiz.lambda-url.eu-central-1.on.aws';
            String authToken = 'salesforceAuthToken';
            
            List<ContactCalloutWrapper> requestBody = new List<ContactCalloutWrapper>();
            for(Id cntId: listCntIds){
                requestBody.add(new ContactCalloutWrapper(cntId, false)); // Example entry
                
            }
            
            // Serialize the request body
            String serializedBody = JSON.serialize(requestBody);
            
            // Prepare the HTTP request
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpointUrl);
            request.setMethod('PATCH');
            request.setHeader('Authorization', 'Bearer ' + authToken);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(serializedBody);
            System.debug('hhhhhhh  '+serializedBody);
            
            // Send the request
            HttpResponse response = http.send(request);
            
            // Handle the response
            if (response.getStatusCode() == 200 || response.getStatusCode() == 204) {
                System.debug('PATCH request successful: ' + response.getBody());
            } else {
                System.debug('Failed PATCH request: ' + response.getStatusCode() + ' ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception during PATCH callout: ' + e.getMessage());
        }
    }
}