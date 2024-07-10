trigger CaseTrigger on Case (before insert, before update, before delete, after delete, after insert, after update, after undelete) {
    CaseTriggerHandler handler = new CaseTriggerHandler();
    TriggerDispatcher.run(handler);
}