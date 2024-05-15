public class OpportunityTriggerHandler extends TriggerHandler{
    public OpportunityTriggerHandler() {

    }

    public override void beforeInsert() {
        new OpportunityHelper().setOpportunityType(Trigger.new);
    }

    public override void afterInsert() {
        new OpportunityHelper().createOppTask(Trigger.new);
    }


    public override void beforeUpdate() {
        new OpportunityHelper().updateOppDescriptionOnStageChange(Trigger.new);
        new OpportunityHelper().updateOppPrimaryContactAsCEO(Trigger.newMap);
        new OpportunityHelper().validateOpportunityAmount(Trigger.new);
    }

    public override void beforeDelete() {
        new OpportunityHelper().preventClosedOppDeletion(Trigger.oldMap);
    }

    public override void afterDelete() {
        new OpportunityHelper().notifyOwnersOpportunityDeleted(Trigger.old);
    }

    public override void afterUndelete() {
        new OpportunityHelper().assignPrimaryContact(Trigger.new);
    }

}