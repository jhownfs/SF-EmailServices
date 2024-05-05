public with sharing class KeyWordSearchServices {
  public Key_Word__c searchByKeyWordInTextField(String textField) {
    KeyWordSelector selectorKeyWords = new KeyWordSelector();
    List<Key_Word__c> lstKeyWords = selectorKeyWords.KeyWordSelector();
    Key_Word__c foundKeyWord = new Key_Word__c();
    system.debug('foundKeyWord = ' + foundKeyWord);
    system.debug('lstKeyWords = ' + lstKeyWords);
    for (Key_Word__c keyword : lstKeyWords) {
      String fixAccentsFromText = AccentsUtils.removeDiacritics(textField);
      String fixAccentsFromKeyWord = AccentsUtils.removeDiacritics(
        keyword.Key_word__c
      );

      String upperKeyWordStr = fixAccentsFromKeyWord.toUpperCase();
      String upperTextFieldStr = fixAccentsFromText.toUpperCase();

      if (upperTextFieldStr.contains(upperKeyWordStr)) {
        foundKeyWord = keyword;
        break;
      }
    }

    return foundKeyWord;
  }
}
