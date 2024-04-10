global class EmailServiceInbound implements Messaging.InboundEmailHandler {
  global Messaging.InboundEmailResult handleInboundEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

    try {
      Contact contactToCase = ContactSelector.getContactFromEmailAddress(
        email.FromAddress
      )[0];

      if (contactToCase == null) {
        ContactFactory newContact = new ContactFactory();
        contactToCase = newContact.createContact(
          email.FromAddress,
          email.fromName
        );

        Database.insert(contactToCase);
      }

      Case upsertCase = new Case(id = CaseFactory.getCaseIdFromEmail(email));
      CaseFactory factoryCase = new CaseFactory();

      if (upsertCase.id == null) {
        factoryCase.createCase(email, contactToCase);
        database.insert(upsertCase);
      }

      Map<String, ContentVersion> mapContentVersionToChangeURL = new Map<String, ContentVersion>();
      List<ContentVersion> lstContentVersionToInsert = new List<ContentVersion>();
      List<ContentDocumentLink> lstContentLinkToInsert = new List<ContentDocumentLink>();

      Map<String, String> headersMap = new Map<String, String>();
      EmailServiceHelper EmailHelper = new EmailServiceHelper();

      if (email.binaryAttachments != null) {
        for (
          Messaging.InboundEmail.binaryAttachment binAttach : email.binaryAttachments
        ) {
          headersMap = EmailHelper.getBinaryAttahemnts(
            binAttach,
            binAttach.headers
          );

          ContentVersionFactory factoryContentVersion = new ContentVersionFactory();
          lstContentVersionToInsert.add(
            factoryContentVersion.createContentVersion(
              binAttach.fileName,
              binAttach.fileName,
              binAttach.body
            )
          );
        }
      }

      database.insert(lstContentVersionToInsert);

      for (ContentVersion vContentVersion : [
        SELECT Id, ContentDocumentId, Title
        FROM ContentVersion
        WHERE Id IN :lstContentVersionToInsert
      ]) {
        mapContentVersionToChangeURL.put(
          vContentVersion.Title,
          vContentVersion
        );
      }

      for (
        ContentVersion newContentVersion : mapContentVersionToChangeURL.values()
      ) {
        String newUrl =
          '/sfc/servlet.shepherd/version/download/' + newContentVersion.id;
        email.htmlBody = email.htmlBody.replaceAll(
          'cid:' + headersMap.get(newContentVersion.Title),
          newUrl
        );
      }

      EmailMessageFactory factoryEmailMessage = new EmailMessageFactory();
      EmailMessage newEmailMessage = factoryEmailMessage.createEmailMessage(
        email.toAddresses,
        email.fromAddress,
        email.fromName,
        email.subject,
        email.htmlBody,
        email.plainTextBody,
        upsertCase.Id
      );

      database.insert(newEmailMessage);

      for (
        Messaging.InboundEmail.binaryAttachment binAttach : email.binaryAttachments
      ) {
        ContentVersion newContentVersion = mapContentVersionToChangeURL.get(
          binAttach.fileName
        );

        ContentVersionFactory factoryContentLink = new ContentVersionFactory();

        lstContentLinkToInsert.add(
          factoryContentLink.createContentDocumentLink(
            newEmailMessage.Id,
            newContentVersion.ContentDocumentId
          )
        );
      }

      database.insert(lstContentLinkToInsert);

      //TO DO: send to Queue or skill based on keyword

      //TO DO: send email to support
      result.success = true;
    } catch (Exception e) {
      result.success = false;
      system.debug('error message ' + e.getMessage());
    }

    return result;
  }
}
