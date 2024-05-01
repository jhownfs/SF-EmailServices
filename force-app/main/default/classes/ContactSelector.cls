public with sharing class ContactSelector {
  public static list<Contact> getContactFromEmailAddress(String emailAddress) {
    List<Contact> lstContacts = new List<Contact>();
    lstContacts = [
      SELECT Id
      FROM contact
      WHERE email = :emailAddress
    ];

    return lstContacts;
  }
}
