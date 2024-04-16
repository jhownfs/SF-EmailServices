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
      HttpRequest req = new HttpRequest();
      req.setEndpoint(
        URL.getOrgDomainURL().toExternalForm() +
        '/services/data/v58.0/sobjects/Skill'
      );
      req.setMethod('POST');
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

      Map<String, Object> responseMapToString = (Map<String, Object>) JSON.deserializeUntyped(
        res.getBody()
      );

      skillToUpdate.SkillId__c = (String) responseMapToString.get('id');

      Database.update(skillToUpdate);
    } catch (Exception e) {
      system.debug('e => ' + e.getMessage());
      system.debug('e => ' + e.getStackTraceString());
    }
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
