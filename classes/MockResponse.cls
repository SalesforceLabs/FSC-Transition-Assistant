@IsTest
public class MockResponse implements HttpCalloutMock {
    protected List<Integer> code;
    protected List<String> status;
    protected List<String> body;
    protected List<Map<String, String>> responseHeaders;

    public MockResponse(Integer code, String body) {
        this.code = new List<Integer>{code};
        this.status = new List<String>();
        this.body = new List<String>{body};
        this.responseHeaders = new List<Map<String, String>>();
    }

    public MockResponse(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = new List<Integer>{code};
        this.status = new List<String>{status};
        this.body = new List<String>{body};
        this.responseHeaders = new List<Map<String, String>>{responseHeaders};
    }

    public void addResponse(Integer code, String body) {
        this.code.add(code);
        this.body.add(body);
    }

    public void addResponse(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code.add(code);
        this.status.add(status);
        this.body.add(body);
        this.responseHeaders.add(responseHeaders);
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if (!responseHeaders.isEmpty()) {
            for(String key : responseHeaders[0].keySet()) {
                String value = responseHeaders[0].get(key);
                res.setHeader(key, value);
            }
            this.responseHeaders.remove(0);        
        }
        if (!status.isEmpty()) {
            res.setStatus(this.status.remove(0));
        }

        res.setBody(this.body.remove(0));
        res.setStatusCode(this.code.remove(0));

        //prevent failure if another callout performed no mock
        if (this.body.isEmpty()) {
            this.body.add('');
        }
        if (this.code.isEmpty()) {
            this.code.add(0);
        }

        return res;
    }
}