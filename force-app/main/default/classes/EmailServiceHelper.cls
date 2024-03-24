public with sharing class EmailServiceHelper {
  public Map<String, String> getBinaryAttahemnts(
    Messaging.InboundEmail.binaryAttachment binAttach,
    List<Messaging.InboundEmail.Header> headersList
  ) {
    Map<String, String> headersMap = new Map<String, String>();

    for (Messaging.InboundEmail.Header header : headersList) {
      if (header != null && header.name == 'Content-ID') {
        headersMap.put(
          binAttach.fileName,
          header.value.replaceAll('<', '').replaceAll('>', '')
        );
      }
    }

    return headersMap;
  }
}
