global class EmailServiceInbound implements Messaging.InboundEmailHandler {
  global Messaging.InboundEmailResult handleInboundEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

    try {
      Case upsertCase = new Case(id = CaseFactory.getCaseIdFromEmail(email));
      CaseFactory factoryCase = new CaseFactory();

      if (upsertCase.id == null) {
        factoryCase.createCase(
          email.subject,
          email.plainTextBody,
          email.FromAddress
        );
        database.insert(upsertCase);
      }

      Map<String, ContentVersion> mapContent = new Map<String, ContentVersion>();
      List<ContentVersion> lstContentVersion = new List<ContentVersion>();
      List<ContentDocumentLink> lstContentLink = new List<ContentDocumentLink>();

      Map<String, String> headersMap = new Map<String, String>();

      if (email.binaryAttachments != null) {
        for (
          Messaging.InboundEmail.binaryAttachment binAttach : email.binaryAttachments
        ) {
          List<Messaging.InboundEmail.Header> headersList = binAttach.headers;

          for (Messaging.InboundEmail.Header header : headersList) {
            if (header != null && header.name == 'Content-ID') {
              headersMap.put(
                binAttach.fileName,
                header.value.replaceAll('<', '').replaceAll('>', '')
              );
            }
          }

          ContentVersionFactory factoryContentVersion = new ContentVersionFactory();
          lstContentVersion.add(
            factoryContentVersion.createContentVersion(
              binAttach.fileName,
              binAttach.fileName,
              binAttach.body
            )
          );
        }

        database.insert(lstContentVersion);

        for (ContentVersion vContentVersion : [
          SELECT Id, ContentDocumentId, Title
          FROM ContentVersion
          WHERE Id IN :lstContentVersion
        ]) {
          mapContent.put(vContentVersion.Title, vContentVersion);
        }

        for (ContentVersion newContentVersion : mapContent.values()) {
          String newUrl =
            '/sfc/servlet.shepherd/version/download/' + newContentVersion.id;
          email.htmlBody = email.htmlBody.replaceAll(
            'cid:' + headersMap.get(newContentVersion.Title),
            newUrl
          );
        }
      }

      EmailMessage newEmailMessage = new EmailMessage();
      newEmailMessage.ToAddress = String.join(email.toAddresses, ',');
      newEmailMessage.FromAddress = email.FromAddress;
      newEmailMessage.FromName = email.FromName;
      newEmailMessage.Subject = email.subject;
      newEmailMessage.status = '2';
      newEmailMessage.HtmlBody = email.htmlBody;
      newEmailMessage.Incoming = true;
      newEmailMessage.TextBody = email.plainTextBody;
      newEmailMessage.ParentId = upsertCase.id;
      insert newEmailMessage;

      for (
        Messaging.InboundEmail.binaryAttachment binAttach : email.binaryAttachments
      ) {
        ContentVersion newContentVersion = mapContent.get(binAttach.fileName);

        ContentVersionFactory factoryContentLink = new ContentVersionFactory();

        lstContentLink.add(
          factoryContentLink.createContentDocumentLink(
            newEmailMessage.Id,
            newContentVersion.ContentDocumentId
          )
        );
      }

      database.insert(lstContentLink);
      result.success = true;
    } catch (Exception e) {
      result.success = false;
      system.debug('error message ' + e.getMessage());
    }

    return result;
  }

  public list<Contact> getContactFromEmailAddress(String emailAddress) {
    List<Contact> lstContacts = [
      SELECT Id
      FROM contact
      WHERE email = :emailAddress
    ];

    return lstContacts;
  }
}
