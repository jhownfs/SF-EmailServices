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
    system.debug('caseCreatedorUpdated = ' + caseCreatedorUpdated);

    Key_Word__c foundKeyWord = keyWordServicesInstace.searchByKeyWordInTextField(
      caseCreatedorUpdated.Description
    );

    system.debug('foundKeyWord = ' + foundKeyWord);

    if (String.isblank(foundKeyWord.Key_word__c)) {
      foundKeyWord = keyWordServicesInstace.searchByKeyWordInTextField(
        caseCreatedorUpdated.subject
      );
    }

    system.debug('foundKeyWord = ' + foundKeyWord);

    //TO DO refactoring to clean code, using interface pattern and strategy pattern
    PendingServiceRouting pendingServiceToRouting = new PendingServiceRouting();

    if (String.isnotblank(foundKeyWord.Key_word__c)) {
      pendingServiceToRouting.CapacityWeight = 1;
      pendingServiceToRouting.WorkItemId = caseCreatedorUpdated.id;
      pendingServiceToRouting.RoutingModel = 'MostAvailable';
      pendingServiceToRouting.RoutingPriority = 1;
      pendingServiceToRouting.ServiceChannelId = '0N94W000000p0ea'; //Change this value for your channel in organization
      pendingServiceToRouting.IsReadyForRouting = false;

      Database.insert(pendingServiceToRouting);
    }

    //TO DO add ServiceSkill to routing
    if (!String.isblank(foundKeyWord.Support_Manager__r.Skill__c)) {
      SkillRequirement skillReqToCase = new SkillRequirement();
      skillReqToCase.SkillId = foundKeyWord.Support_Manager__r.Skill__c;
      skillReqToCase.RelatedRecordId = pendingServiceToRouting.Id;
      skillReqToCase.SkillLevel = 1;
      Database.insert(skillReqToCase);
    }

    pendingServiceToRouting.IsReadyForRouting = true;
    Database.update(pendingServiceToRouting);
  }
}
