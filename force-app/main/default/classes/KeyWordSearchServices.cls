public with sharing class KeyWordSearchServices {
  public void searchByKeyWordInTextField(String textField) {
    KeyWordSelector selectorKeyWords = new KeyWordSelector();
    List<Key_Word__c> lstKeyWords = selectorKeyWords.KeyWordSelector();

    for (Key_Word__c keyword : lstKeyWords) {
      String upperKeyWordStr = keyword.Key_Word__c.toUpperCase();
      String upperTextFieldStr = textField.toUpperCase();
      String patternKey = '(?<!\\p{L})' + upperKeyWordStr + '(?!\\p{L})';
      pattern regex = pattern.compile(patternKey);
      Matcher matcher = regex.matcher(upperTextFieldStr);

      while (matcher.find()) {
        System.debug('Found accent character: ' + matcher.group());
      }
      system.debug('upperTextFieldStr =' + upperKeyWordStr);
      system.debug('upperTextFieldStr =' + upperTextFieldStr);
    }
  }
}
