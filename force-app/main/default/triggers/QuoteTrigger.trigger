trigger QuoteTrigger on Quote (before delete, before insert, before update, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.Run(new QuoteTriggerHandler());
}