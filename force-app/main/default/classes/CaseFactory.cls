public with sharing class CaseFactory {
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
