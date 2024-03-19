global class EmailServiceInbound implements Messaging.InboundEmailHandler {
  global Messaging.InboundEmailResult handleInboundEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

    Case updCase = new Case(Id = this.getCaseIdFromEmail(email));

    if (updCase.id == null) {
      updCase = this.createCase(
        email.subject,
        email.plainTextBody,
        email.FromAddress
      );
      database.insert(updCase);
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

        //ajustar isso aqui//
        for (Messaging.InboundEmail.Header header : headersList) {
          if (header != null && header.name == 'Content-ID') {
            headersMap.put(
              binAttach.fileName,
              header.value.replaceAll('<', '').replaceAll('>', '')
            );
          }
        }

        ContentVersion newContentVersion = new ContentVersion();
        newContentVersion.VersionData = binAttach.body;
        newContentVersion.Title = binAttach.fileName;
        newContentVersion.PathOnClient = binAttach.fileName;

        lstContentVersion.add(newContentVersion);
      }

      database.insert(lstContentVersion);

      for (ContentVersion vContentVersion : [
        SELECT Id, ContentDocumentId, Title
        FROM ContentVersion
        WHERE Id IN :lstContentVersion
      ]) {
        mapContent.put(vContentVersion.Title, vContentVersion);
      }

      system.debug('mapContent = ' + mapContent);
      for (ContentVersion newContentVersion : mapContent.values()) {
        String newUrl =
          '/sfc/servlet.shepherd/version/download/' + newContentVersion.id;
        email.htmlBody = email.htmlBody.replaceAll(
          'cid:' + headersMap.get(newContentVersion.Title),
          newUrl
        );
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
      newEmailMessage.ParentId = updCase.id;
      insert newEmailMessage;

      for (
        Messaging.InboundEmail.binaryAttachment binAttach : email.binaryAttachments
      ) {
        ContentVersion newContentVersion = mapContent.get(binAttach.fileName);

        ContentDocumentLink newContentLink = new ContentDocumentLink();
        newContentLink.LinkedEntityId = newEmailMessage.Id;
        newContentLink.ContentDocumentId = newContentVersion.ContentDocumentId;
        newContentLink.ShareType = 'V';
        lstContentLink.add(newContentLink);
      }

      database.insert(lstContentLink);
    }

    result.success = true;
    return result;
  }

  public Id getCaseIdFromEmail(Messaging.InboundEmail email) {
    Id caseId = EmailMessages.getRecordIdFromEmail(
      email.subject,
      email.plainTextBody,
      email.htmlBody
    );

    if (String.isBlank(caseId) && email.headers != null) {
      caseId = Cases.getCaseIdFromEmailHeaders(email.headers);
    }

    return caseId;
  }

  public Case createCase(
    String subject,
    String description,
    String emailAddress
  ) {
    Case newCase = new Case();
    newCase.Subject = subject;
    newCase.Description = description;
    newCase.SuppliedEmail = emailAddress;
    newCase.status = 'new';

    return newCase;
  }
}
