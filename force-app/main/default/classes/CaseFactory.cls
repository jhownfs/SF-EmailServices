public with sharing class CaseFactory {
  public Case createCase(Messaging.InboundEmail email, Contact contactToCase) {
    Case newCase = new Case();
    newCase.Subject = email.subject;
    newCase.Description = email.plainTextBody;
    newCase.SuppliedEmail = email.FromAddress;
    newCase.ContactId = contactToCase.id;
    newCase.status = 'new';

    return newCase;
  }

  public static Id getCaseIdFromEmail(Messaging.InboundEmail email) {
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
}
