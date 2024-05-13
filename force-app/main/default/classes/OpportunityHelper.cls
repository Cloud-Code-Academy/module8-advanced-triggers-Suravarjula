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
            opp.Primary_Contact__c = ceoContactByAccount.get(opp.AccountId);
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

    public void assignPrimaryContact(Map<Id, SObject> oppNewMap) {  
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Set<Id> oppAccountIds = new Set<Id>();
        for(Opportunity opp : (List<Opportunity>)oppNewMap.values()) {
            oppAccountIds.add(opp.AccountId);
        }
        Map<Id, Account> primaryContactByAccountId = new Map<Id, Account>([SELECT Id, (SELECT Id from Contacts WHERE Title = 'VP Sales') from Account where Id IN :oppAccountIds]);

        for (Opportunity opp : (List<Opportunity>)oppNewMap.values()){            
            if (opp.Primary_Contact__c == null){
                Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
                oppToUpdate.Primary_Contact__c = primaryContactByAccountId.get(opp.AccountId).Contacts.get(0).Id;
                oppMap.put(opp.Id, oppToUpdate);
            }
        }
        update oppMap.values();
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