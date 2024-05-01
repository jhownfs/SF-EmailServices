@istest
private class EmailServiceInboundTest {
  @TestSetup
  static void makeData() {
    test.setMock(HttpCalloutMock.class, new MockResponseGenerator());

    Queue_Manager__c queueManagementTest = new Queue_Manager__c();
    queueManagementTEst.Name = 'Test';
    queueManagementTEst.Object__c = 'Test';
    insert queueManagementTest;

    Skill__c skill = new Skill__c();
    skill.Name = 'EmailTest';
    insert skill;

    Support_Manager__c supManager = new Support_Manager__c();
    supManager.Queue_manager__c = queueManagementTest.Id;
    supManager.Skill__c = skill.Id;
    insert supManager;

    Key_Word__c keyWord = new Key_Word__c();
    keyWord.Key_word__c = 'Cartao';
    keyWord.Support_Manager__c = supManager.Id;
    insert keyWord;
  }

  static testMethod void testInboudEmail() {
    Messaging.InboundEmail email = new Messaging.InboundEmail();
    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

    List<string> emails = new List<string>{
      'someaddress@test.com',
      'someaddress123@test.com'
    };

    Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
    header.name = 'theardId::';
    header.value = '12346';
    email.headers = new List<Messaging.InboundEmail.Header>{ header };
    email.subject = 'Cartao InboundTest';
    email.fromAddress = 'someaddress@email.com';
    email.fromName = 'Test Name';
    email.toAddresses = emails;
    email.htmlBody = 'email body';
    email.plainTextBody = 'email body';
    Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
    header.name = 'Content-ID';
    header.value = 'someaddress@test.com';
    attachment.headers = new List<Messaging.InboundEmail.Header>{ header };
    attachment.body = blob.valueOf('my attachment text');
    attachment.fileName = 'textfileone.png';
    attachment.mimeTypeSubType = 'image/png';
    email.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{
      attachment
    };

    Test.startTest();

    EmailServiceInbound service = new EmailServiceInbound();
    service.handleInboundEmail(email, env);

    Test.stopTest();
  }
}
