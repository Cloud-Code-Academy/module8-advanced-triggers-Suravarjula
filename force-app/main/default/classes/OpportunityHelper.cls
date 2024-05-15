public with sharing class OpportunityHelper {    
    public OpportunityHelper() {

    }

    public void validateOpportunityAmount(List<Opportunity> oppList) {
        for(Opportunity oppRec : oppList) {
            if(oppRec.Amount <= 5000) {
                oppRec.Amount.addError(Label.Opp_Amount_More_Than_5000);
            }
        }  
    }

    public void preventClosedOppDeletion(Map<Id, SObject> oppMap) {
        Set<Id> oppIds = oppMap.keySet();
        Set<Id> bankingAccountIds = getOpportunityAccountsForIndustry(oppIds, 'Banking');

        for(Opportunity opp : (List<Opportunity>)oppMap.values()) {
            if(opp.isClosed)  {
                if(bankingAccountIds.size() > 0 && bankingAccountIds.contains(opp.AccountId)) {
                    opp.addError(Label.Prevent_Opportunity_Deletion_For_Banking);
                }
                else {
                    opp.addError('Cannot delete closed opportunity');
                }        
            }
        }
    }

    public void updateOppPrimaryContactAsCEO(Map<Id, SObject> oppMap) {
        Set<Id> oppIds = oppMap.keySet();
        List<Opportunity> oppList = (List<Opportunity>)oppMap.values();
        Map<Id, Id> ceoContactByAccount = getCEOContactForAccount(oppIds);
        for(Opportunity opp : oppList) {
            if(opp.Primary_Contact__c == null && ceoContactByAccount.get(opp.AccountId) != null) {
                opp.Primary_Contact__c = ceoContactByAccount.get(opp.AccountId);
            }
        }
    }

    public void setOpportunityType(List<Opportunity> oppList) {
        for(Opportunity opp : oppList) {
            if(opp.Type == null) {
                opp.Type = 'New Customer';
            }
        }
    }

    public void createOppTask(List<Opportunity> oppList) {
        List<Task> oppTaskList = new List<Task>();
        for(Opportunity opp : oppList) {
            Task tsk = new Task();
            tsk.Subject = 'Call Primary Contact';
            tsk.WhatId = opp.Id;
            tsk.WhoId = opp.Primary_Contact__c;
            tsk.OwnerId = opp.OwnerId;
            tsk.ActivityDate = Date.today().addDays(3);
            oppTaskList.add(tsk);
        }
        Database.insert(oppTaskList);
    }

    public void updateOppDescriptionOnStageChange(List<Opportunity> oppList) {
        for(Opportunity opp : oppList) {
            if(opp.StageName != null) {
                opp.Description += '\n Stage Change:' + opp.StageName + ':' + DateTime.now().format();
            }
        }
    }

    public void notifyOwnersOpportunityDeleted(List<Opportunity> opps) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Set<Id> oppId = new Set<Id>();
        for(Opportunity opp : opps) {
            oppId.add(opp.OwnerId);
        }
        Map<Id, User> ownerEmailIdMap = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN :oppId]);
        
        for (Opportunity opp : opps){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {ownerEmailIdMap.get(opp.OwnerId).Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Opportunity Deleted : ' + opp.Name);
            mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
            mails.add(mail);
        }        
        
        try {
            Messaging.sendEmail(mails);
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    }

    public void assignPrimaryContact(List<SObject> undeleteOppList) {  
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        Set<Id> oppAccountIds = new Set<Id>();
        for(Opportunity opp : (List<Opportunity>)undeleteOppList) {
            oppAccountIds.add(opp.AccountId);
        }
        Map<Id, Account> primaryContactByAccountId = new Map<Id, Account>([SELECT Id, (SELECT Id from Contacts WHERE Title = 'VP Sales') from Account where Id IN :oppAccountIds]);
        System.debug('primaryContactByAccountId : ' + primaryContactByAccountId);
        System.debug('primaryContact : ' + primaryContactByAccountId.values().get(0).Contacts);
        //System.debug('primaryContactByAccountId Map Size : ' + primaryContactByAccountId.size());
        for (Opportunity opp : (List<Opportunity>)undeleteOppList){            
            if (opp.Primary_Contact__c == null){
                Opportunity oppToUpdate = new Opportunity(Id = opp.Id, Name = opp.Name,
                                                            StageName = opp.StageName,
                                                            CloseDate = opp.CloseDate,
                                                            AccountId = opp.AccountId,
                                                            Primary_Contact__c = primaryContactByAccountId.get(opp.AccountId).Contacts.get(0).Id);
              //  System.debug('Primary_Contact__c is : ' + opp.Primary_Contact__c + ' and Contact Id : ' + primaryContactByAccountId.get(opp.AccountId).Contacts.get(0).Id);
             // oppToUpdate.Primary_Contact__c = primaryContactByAccountId.get(opp.AccountId).Contacts.get(0).Id;
              //  System.debug(oppToUpdate);
              oppListToUpdate.add(oppToUpdate);
            }
        }
        Database.saveResult[] updateResult = Database.update(oppListToUpdate);
        // System.debug('Update Result : ' + updateResult.size());
        for (Database.SaveResult sr : updateResult) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated Opportunity : ' + sr);
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
    
    private Set<Id> getOpportunityAccountsForIndustry(Set<Id> opportunityIds, String industry) {
        return (new Map<Id, Account>([SELECT Id from Account where Id in (SELECT AccountId from Opportunity where Id in :opportunityIds) and Industry = :industry])).keySet();
    }

    private Map<Id, Id> getCEOContactForAccount(Set<Id> opportunityIds) {
        Map<Id, Id> accountContact = new Map<Id, Id>();
        for (Contact contactRec : [SELECT Id, AccountId from Contact where AccountId in (SELECT AccountId from Opportunity where Id in :opportunityIds)  and Title = 'CEO']) {
            accountContact.put(contactRec.AccountId, contactRec.Id);
        }
        return accountContact;
    }
}