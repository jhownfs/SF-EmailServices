public with sharing class ContentVersionFactory {
  public ContentVersion createContentVersion(
    String title,
    String pathOnClient,
    Blob versionData
  ) {
    ContentVersion newContentVersion = new ContentVersion();
    newContentVersion.VersionData = versionData;
    newContentVersion.Title = title;
    newContentVersion.PathOnClient = pathOnClient;

    return newContentVersion;
  }

  public ContentDocumentLink createContentDocumentLink(
    Id idEmail,
    Id ContentDocumentId
  ) {
    ContentDocumentLink newContentLink = new ContentDocumentLink();
    newContentLink.LinkedEntityId = idEmail;
    newContentLink.ContentDocumentId = ContentDocumentId;
    newContentLink.ShareType = 'V';
    return newContentLink;
  }
}
