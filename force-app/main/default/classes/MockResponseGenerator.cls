global with sharing class MockResponseGenerator implements HttpCalloutMock {
  global HTTPResponse respond(HTTPRequest req) {
    HTTPResponse res;
    if (req.getMethod() == 'GET') {
      res = getMethodSkill();
    } else if (req.getMethod() == 'POST' || req.getMethod() == 'PATCH') {
      res = postPatchMethodSkill();
    }
    return res;
  }

  private HttpResponse getMethodSkill() {
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody(
      '{"totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "Skill", "url" : "/services/data/v58.0/sobjects/Skill/test" }, "Id" : "test" } ] }'
    );
    res.setStatusCode(200);

    return res;
  }

  private HttpResponse postPatchMethodSkill() {
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody('{"Id" : "test"}');
    res.setStatusCode(200);

    return res;
  }
}
