public with sharing class EmailMessageFactory {
  private final String STATUS = '2';
  private final Boolean ISINCOMING = true;

  public EmailMessage createEmailMessage(
    String[] toAddresses,
    String fromAddress,
    String FromName,
    String subject,
    String htmlBody,
    String plainTextBody,
    Id parentID
  ) {
    EmailMessage newEmailMessage = new EmailMessage();
    newEmailMessage.ToAddress = String.join(toAddresses, ',');
    newEmailMessage.FromAddress = fromAddress;
    newEmailMessage.FromName = FromName;
    newEmailMessage.Subject = subject;
    newEmailMessage.status = this.STATUS;
    newEmailMessage.HtmlBody = htmlBody;
    newEmailMessage.Incoming = this.ISINCOMING;
    newEmailMessage.TextBody = plainTextBody;
    newEmailMessage.ParentId = parentID;

    return newEmailMessage;
  }
}
