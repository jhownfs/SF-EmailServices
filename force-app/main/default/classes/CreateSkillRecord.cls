public with sharing class CreateSkillRecord {
  @InvocableMethod(
    label='Create Skill'
    description='Create skill inside support manager object'
    category='Skill'
  )
  public static void createSkillConfiguration(
    List<CreateSkillRecordRequest> requests
  ) {
    insertSkill(
      requests[0].masterLabel,
      requests[0].developerName,
      requests[0].recordId
    );
  }

  @future(callout=true)
  private static void insertSkill(
    String masterLabel,
    String developerName,
    String recordId
  ) {
    try {
      String IdSkillExist = queryExistSkill(masterLabel);
      HttpRequest req = new HttpRequest();

      String endpoint = (String.isNotBlank(IdSkillExist))
        ? '/services/data/v58.0/sobjects/Skill/' + IdSkillExist
        : '/services/data/v58.0/sobjects/Skill';
      req.setEndpoint(URL.getOrgDomainURL().toExternalForm() + endpoint);
      String method = (String.isNotBlank(IdSkillExist)) ? 'PATCH' : 'POST';
      req.setMethod(method);
      req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
      req.setHeader('Content-Type', 'application/json');
      req.setHeader('X-PrettyPrint', '1');

      String body =
        '{"MasterLabel": "' +
        masterLabel +
        '", "DeveloperName": "' +
        developerName +
        '"}';
      req.setBody(body);

      Http http = new Http();
      HTTPResponse res = http.send(req);

      //TO DO: Add pattern for response
      Skill__c skillToUpdate = [
        SELECT id, SkillId__c
        FROM Skill__c
        WHERE id = :recordId
      ];

      Map<String, Object> responseMapToString = new Map<String, Object>();

      if (res.getStatusCode() == 200) {
        responseMapToString = (Map<String, Object>) JSON.deserializeUntyped(
          res.getBody()
        );
      }
      skillToUpdate.SkillId__c = (String.isnotblank(IdSkillExist))
        ? IdSkillExist
        : (String) responseMapToString.get('id');

      Database.update(skillToUpdate);
    } catch (Exception e) {
      system.debug('e => ' + e.getMessage());
      system.debug('e => ' + e.getStackTraceString());
    }
  }

  public static String queryExistSkill(String masterLabel) {
    String skillId = '';

    try {
      HttpRequest req = new HttpRequest();
      String endpoint =
        '/services/data/v58.0/query?q=SELECT+id+FROM+skill+where+MasterLabel=' +
        '\'' +
        masterLabel +
        '\'';
      req.setEndpoint(URL.getOrgDomainURL().toExternalForm() + endpoint);
      req.setMethod('GET');
      req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
      req.setHeader('Content-Type', 'application/json');
      req.setHeader('X-PrettyPrint', '1');
      system.debug('req = ' + req.getBody());

      Http http = new Http();
      HTTPResponse res = http.send(req);

      if (res.getStatusCode() == 200) {
        Map<String, Object> responseMapToString = (Map<String, Object>) JSON.deserializeUntyped(
          res.getBody()
        );

        List<Object> listRecords = (List<Object>) responseMapToString.get(
          'records'
        );
        Map<String, Object> mapRecords = (Map<String, Object>) listRecords[0];

        skillId = (String) mapRecords.get('Id');
      }
    } catch (Exception e) {
      system.debug('e => ' + e.getMessage());
      system.debug('e => ' + e.getStackTraceString());
    }

    return skillId;
  }

  public class CreateSkillRecordRequest {
    @InvocableVariable(label='name' description='Skill name' required=true)
    public String masterLabel;
    @InvocableVariable(
      label='developerName'
      description='Skill Developer Name'
      required=true
    )
    public String developerName;
    @InvocableVariable(label='recordId' description='Record Id' required=true)
    public String recordId;
  }
}
