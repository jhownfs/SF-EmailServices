@istest
private class EmailServiceInboundTest {
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
    email.subject = 'Email InboundTest';
    email.fromAddress = 'someaddress@email.com';
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
