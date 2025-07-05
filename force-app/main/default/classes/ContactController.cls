public with sharing class ContactController {
    
    @AuraEnabled
    public static ContactWrapper getContacts() {
        try{
            List<Contact> contList = [
                SELECT Id, Name 
                FROM Contact
                LIMIT 10
            ];
            
            ContactWrapper contWrap = new ContactWrapper();
            if(contList.size() > 0) {
                contWrap.contactList = contList;
                contWrap.contactListExists = contList.size() > 0;
            }
            return contWrap;
        }catch(Exception ex) {
            system.debug('ex'+ex.getMessage());
            throw ex;
        }    
    }

    public class ContactWrapper{
        @AuraEnabled
        public List<Contact> contactList;

        @AuraEnabled
        public boolean contactListExists;
      
        public ContactWrapper() {
            this.contactList = new List<Contact>();
            this.contactListExists = contactList.size() > 0;
        }
    }

    
    @AuraEnabled
    public static List<Contact> getContacts2(id recordId) {
        List<Contact> contList = [
                SELECT Id, Name 
                FROM Contact
                where id = :recordId
            ];
            return contList;
    }


}