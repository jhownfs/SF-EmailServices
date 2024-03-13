global class EmailServiceInbound implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
 

        Case updCase = new case (id = this.getCaseIdFromEmail(email));

        if(updCase == null){
            
          updCase = this.createCase(email.subject, email.plainTextBody, email.FromAddress);
          database.insert(updCase);

        }

        EmailMessage cEmailMessage = new EmailMessage();
        cEmailMessage.ToAddress =  String.join(email.toAddresses, ',');
        cEmailMessage.FromAddress = email.FromAddress;
        cEmailMessage.FromName = email.FromName;
        cEmailMessage.Subject = email.subject;
        cEmailMessage.status = '2';        
        cEmailMessage.HtmlBody = email.htmlBody;
        cEmailMessage.Incoming= True;
        cEmailMessage.TextBody = email.plainTextBody;
        cEmailMessage.ParentId = updCase.id;
        insert cEmailMessage;

        if(email.binaryAttachments != null){
          for(Messaging.InboundEmail.binaryAttachment binAttach :email.binaryAttachments){
            ContentVersion cv = new ContentVersion();
            cv.VersionData = binAttach.body;
            cv.Title = binAttach.fileName;
            cv.PathOnClient = binAttach.fileName;
            insert cv;

            cv = [select ContentDocumentId from ContentVersion where id = :cv.id limit 1];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = cEmailMessage.Id;
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.ShareType = 'V';
            insert cdl;
          }
        }
        result.success = true;
        return result;
    }


    public Id getCaseIdFromEmail(Messaging.InboundEmail email){
        
        Id caseId = EmailMessages.getRecordIdFromEmail(email.subject, email.plainTextBody, email.htmlBody);

        if(String.isBlank(caseId)){
          caseId = Cases.getCaseIdFromEmailHeaders(email.headers);
        }

        return caseId;
    }

    public Case createCase(String subject, String description, String emailAddress){

      Case newCase = new Case();
      newCase.Subject = subject;
      newCase.Description = description;
      newCase.SuppliedEmail = emailAddress;
      newCase.status = 'new';

      return newCase;
    } 

    public Contact getContactFromEmailAddress(String emailAddress){
     return null;
    }

}