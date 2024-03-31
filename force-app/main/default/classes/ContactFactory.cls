public with sharing class ContactFactory {
  public Contact createContact(String Email, String Name) {
    Contact Contact = new Contact(
      LastName = Name.split(' ')[1],
      FirstName = Name.split(' ')[0],
      Email = Email
    );

    return Contact;
  }
}
