trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, before delete, after delete, after undelete) {
    new OpportunityTriggerHandler().run();
}