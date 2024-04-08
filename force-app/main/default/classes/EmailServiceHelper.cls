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

  public void SearchByKeyWordAndSendToQueueOrSKill(Case caseCreatedorUpdated) {
    KeyWordSearchServices keyWordServicesInstace = new KeyWordSearchServices();
    Key_Word__c foundKeyWord = keyWordServicesInstace.searchByKeyWordInTextField(
      caseCreatedorUpdated.Description
    );
    foundKeyWord = keyWordServicesInstace.searchByKeyWordInTextField(
      caseCreatedorUpdated.subject
    );

    //TO DO refactoring to clean code, using interface pattern and strategy pattern
    if (foundKeyWord != null) {
      PendingServiceRouting pendingServiceToRouting = new PendingServiceRouting();
      pendingServiceToRouting.CapacityWeight = 1;
      pendingServiceToRouting.GroupId = foundKeyWord.Support_Manager__r.Queue_manager__c;
      pendingServiceToRouting.SkillId = foundKeyWord.Support_Manager__r.Skill__c;
      pendingServiceToRouting.WorkItemId = caseCreatedorUpdated.id;
      pendingServiceToRouting.RoutingModel = 'MostAvailable';
      pendingServiceToRouting.RoutingPriority = 1;
      pendingServiceToRouting.ServiceChannelId = '0N94W000000p0ea'; //Change this value for your organization
      pendingServiceToRouting.IsReadyForRouting = false;
    }

    //TO DO add ServiceSkill to routing
  }
}
