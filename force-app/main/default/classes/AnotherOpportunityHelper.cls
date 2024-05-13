public with sharing class AnotherOpportunityHelper {
    public AnotherOpportunityHelper() {

    }

    // public void setOpportunityType(List<Opportunity> oppList) {
    //     for(Opportunity opp : oppList) {
    //         if(opp.Type == null) {
    //             opp.Type = 'New Customer';
    //         }
    //     }
    // }

    // public void preventClosedOppDeletion(List<Opportunity> oppList) {
    //     for(Opportunity opp : oppList) {
    //         if(opp.isClosed) {
    //             opp.addError('Cannot delete closed opportunity');
    //         }
    //     }
    // }

    // public void createOppTask(List<Opportunity> oppList) {
    //     List<Task> oppTaskList = new List<Task>();
    //     for(Opportunity opp : oppList) {
    //         Task tsk = new Task();
    //         tsk.Subject = 'Call Primary Contact';
    //         tsk.WhatId = opp.Id;
    //         tsk.WhoId = opp.Primary_Contact__c;
    //         tsk.OwnerId = opp.OwnerId;
    //         tsk.ActivityDate = Date.today().addDays(3);
    //         oppTaskList.add(tsk);
    //     }
    //     Database.insert(oppTaskList);
    // }

    // public void updateOppDescriptionOnStageChange(List<Opportunity> oppList) {
    //     for(Opportunity opp : oppList) {
    //         if(opp.StageName != null) {
    //             opp.Description += '\n Stage Change:' + opp.StageName + ':' + DateTime.now().format();
    //         }
    //     }
    // }

    // public void notifyOwnersOpportunityDeleted(List<Opportunity> opps) {
    //     List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    //     Set<Id> oppId = new Set<Id>();
    //     for(Opportunity opp : opps) {
    //         oppId.add(opp.OwnerId);
    //     }
    //     Map<Id, User> ownerEmailIdMap = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN :oppId]);

    //     for (Opportunity opp : opps){
    //         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    //         String[] toAddresses = new String[] {ownerEmailIdMap.get(opp.OwnerId).Email};
    //         mail.setToAddresses(toAddresses);
    //         mail.setSubject('Opportunity Deleted : ' + opp.Name);
    //         mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
    //         mails.add(mail);
    //     }        
        
    //     try {
    //         Messaging.sendEmail(mails);
    //     } catch (Exception e){
    //         System.debug('Exception: ' + e.getMessage());
    //     }
    // }

    // public void assignPrimaryContact(Map<Id, SObject> oppNewMap) {        
    //     Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
    //     Set<Id> oppAccountIds = new Set<Id>();
    //     for(Opportunity opp : (List<Opportunity>)oppNewMap.values()) {
    //         oppAccountIds.add(opp.AccountId);
    //     }
    //     Map<Id, Account> primaryContactByAccountId = new Map<Id, Account>([SELECT Id, (SELECT Id from Contacts WHERE Title = 'VP Sales') from Account where Id IN :oppAccountIds]);

    //     for (Opportunity opp : (List<Opportunity>)oppNewMap.values()){            
    //         if (opp.Primary_Contact__c == null){
    //             Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
    //             oppToUpdate.Primary_Contact__c = primaryContactByAccountId.get(opp.AccountId).Contacts.get(0).Id;
    //             oppMap.put(opp.Id, oppToUpdate);
    //         }
    //     }
    //     update oppMap.values();
    // }
}