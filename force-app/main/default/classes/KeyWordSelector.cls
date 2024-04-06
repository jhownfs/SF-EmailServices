public with sharing class KeyWordSelector {
  public List<Key_Word__c> KeyWordSelector() {
    List<Key_Word__c> lstKeyWords = new List<Key_Word__c>();

    lstKeyWords = [
      SELECT
        Key_Word__c,
        Support_Manager__r.Skill__c,
        Support_Manager__r.Queue_manager__c
      FROM Key_Word__c
    ];
    return lstKeyWords;
  }
}
