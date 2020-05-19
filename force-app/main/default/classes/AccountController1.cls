public with sharing class AccountController1 {
  public static List<Account> getAllActiveAccounts() {
    return [SELECT Id,Name,Active__c FROM Account WHERE Active__c = 'Yes'];
  }
  
  public void display(){
    
    //test build
    System.debug('main string');
  }
}
