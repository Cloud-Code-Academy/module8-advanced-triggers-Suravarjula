public class AccountTriggerHandler extends TriggerHandler {
 /*   List<Account> accountList;

    public AccountTriggerHandler() {
        this.accountList = (List<Account>) Trigger.new;
    }
*/
    public override void beforeInsert() {
        AccountHelper acctHelper = new AccountHelper();
        acctHelper.setTypeProspect(Trigger.new);
        acctHelper.addressCopy(Trigger.new);
        acctHelper.setRating(Trigger.new);
    }
/*
    public override void beforeUpdate() {
        
    }

    public override void beforeDelete() {
        
    }
*/
    public override void afterInsert() {
        new AccountHelper().defaultContact(Trigger.newMap.keySet());
    }

 /*   public override void afterUpdate() {
        
    }

    public override void afterDelete() {
        
    }

    public override void afterUndelete() {
        
    } */
}