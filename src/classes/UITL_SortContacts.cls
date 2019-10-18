public class UITL_SortContacts implements Comparable{
    public String FirstName; 
    public String LastName; 
    public Contact contactRecord; 
    
    public UITL_SortContacts(Contact c) {
        System.debug('InsideSortCont -->'); 
        FirstName = c.FirstName;
        LastName = c.LastName;
        contactRecord = c; 
    }
    
    public Integer compareTo(Object compareTo) {
        System.debug('CompareTOMethod -->'); 
        return sortByLastNameFirstName(compareTo); 
    }
    
    public Integer sortByLastNameFirstName(Object compareTo) {
        System.debug('sortByLastNameFirstName Method -->'); 
        UITL_SortContacts contactToCompare = (UITL_SortContacts)compareTo; 
		
        if (this.LastName == contactToCompare.LastName) {
            return sortByFirstName(contactToCompare); 
        } else {
            return sortByLastName(contactToCompare); 
        }
             
    }
    
    public Integer sortByFirstName(UITL_SortContacts contactToCompare) {
        System.debug('sortByFirstName Method -->'); 
        if (this.FirstName == contactToCompare.FirstName) {
            return 0; 
        } else if (this.FirstName > contactToCompare.FirstName) {
            return 1; 
        } else {
            return -1; 
        }
    }
    
    public Integer sortByLastName(UITL_SortContacts contactToCompare) {
        System.debug('sortByLastName Method -->'); 
        if (this.LastName == contactToCompare.LastName) {
            return 0;
        } else if (this.LastName > contactToCompare.LastName) {
            return 1; 
        } else {
            return -1; 
        }
    }
}