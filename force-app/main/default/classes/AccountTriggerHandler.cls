public class AccountTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        AccountHelper acctHelper = new AccountHelper();
        acctHelper.setTypeProspect(Trigger.new);
        acctHelper.addressCopy(Trigger.new);
        acctHelper.setRating(Trigger.new);
    }

    public override void afterInsert() {
        new AccountHelper().defaultContact(Trigger.newMap.keySet());
    }
}