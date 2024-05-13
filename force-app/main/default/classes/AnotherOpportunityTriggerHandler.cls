public  class AnotherOpportunityTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        // new AnotherOpportunityHelper().setOpportunityType(Trigger.new);
    }

    public override void afterInsert() {
        // new AnotherOpportunityHelper().createOppTask(Trigger.new);
    }

    public override void beforeUpdate() {
        // new AnotherOpportunityHelper().updateOppDescriptionOnStageChange(Trigger.new);
    }

    public override void beforeDelete() {
        // new AnotherOpportunityHelper().preventClosedOppDeletion(Trigger.old);
    }

    public override void afterDelete() {
        // new AnotherOpportunityHelper().notifyOwnersOpportunityDeleted(Trigger.old);
    }

    public override void afterUndelete() {
        // new AnotherOpportunityHelper().assignPrimaryContact(Trigger.newMap);
    }
}