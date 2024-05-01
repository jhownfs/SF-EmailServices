global with sharing class MockResponseGenerator implements HttpCalloutMock {
  global HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody('{"Id":"test"}');
    res.setStatusCode(200);
    return res;
  }
}
