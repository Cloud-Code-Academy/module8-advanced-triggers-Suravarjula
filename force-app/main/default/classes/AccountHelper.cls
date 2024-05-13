/*
AccountHelper Overview

The `AccountHelper` class is designed to provide helper methods that assist in performing specific operations on Account records. 
This class is intended to modularize the logic used in the `AccountTrigger` to ensure separation of concerns, improve readability, and ease maintenance. 

This class is currently stubbed out. As part of this exercise, you are expected to:
1. Implement the method bodies to carry out the specified operations on Account records.
2. Refactor the `AccountTrigger` to utilize the methods provided in this `AccountHelper` class.

Methods:
- `setTypeProspect(SObject objects)`: 
    - Purpose: Update the 'Type' field of the given Account record to 'Prospect' if it's not already set.
    - Note: You'll likely need to adjust the method signature to accept the necessary parameters.

- `addressCopy()`: 
    - Purpose: Copy the shipping address of the Account to its billing address. 
    - Note: You'll likely need to adjust the method signature to accept the necessary parameters.

- `setRating`: 
    - Purpose: Evaluate certain conditions on the Account and assign a rating based on that evaluation. You'll need to define the method's signature and implement its logic.

- `defaultContact`: 
    - Purpose: Create a default contact related to the Account after the Account is inserted. You'll need to define the method's signature and implement its logic.

Remember:
Always ensure that your helper methods are bulk-safe to handle multiple records efficiently. 
*/
public with sharing class AccountHelper {
    List<Account> accountList;

    public void setTypeProspect(List<SObject> objects){
        accountList = (List<Account>)objects;

        /* This if condition sets Account Type as 'Prospect' for all accounts whose Type is not specified during inserting the record */        
        for(Account acctRec : accountList){
            if(String.isBlank(acctRec.type)) {
                acctRec.type = 'Prospect';
            }
        }

    }

    public void addressCopy(List<SObject> objects){
        accountList = (List<Account>)objects;

        /* This if condition copies Shipping Address to Billing Address when all fields of Shipping Address are not NULL */
        for(Account acctRec : accountList){
            if(!String.isBlank(acctRec.ShippingStreet) && !String.isBlank(acctRec.ShippingCity) && !String.isBlank(acctRec.ShippingState) 
                && !String.isBlank(acctRec.ShippingPostalCode) && !String.isBlank(acctRec.ShippingCountry)) {
                    acctRec.BillingStreet = acctRec.ShippingStreet;
                    acctRec.BillingCity = acctRec.ShippingCity;
                    acctRec.BillingState = acctRec.ShippingState;
                    acctRec.BillingPostalCode = acctRec.ShippingPostalCode;
                    acctRec.BillingCountry = acctRec.ShippingCountry;
            }
        }
    }

    public void setRating (List<SObject> objects) {
        accountList = (List<Account>)objects;
        /* This if condition sets Account Rating to 'Hot' when Phone, Website, Fax are not NULL */
        for(Account acctRec : accountList){
            if(!String.isBlank(acctRec.Phone) && !String.isBlank(acctRec.WebSite) && !String.isBlank(acctRec.Fax)){
                acctRec.Rating = 'Hot';
            }
        }
    }

    public  void defaultContact (Set<Id> accountIds) {
        List<Contact> defContactList = new List<Contact>();
        for(Id acctId : accountIds) {
            Contact defContactRec = new Contact(LastName = 'DefaultContact', Email = 'default@email.com', AccountId = acctId);
            defContactList.add(defContactRec);
        }
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(defContactList, dml);
    }
}
