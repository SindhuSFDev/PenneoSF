trigger LeadTrigger on Lead (before insert, before update, before delete, after delete, after insert, after update, after undelete) {
    LeadTriggerHandler handler = new LeadTriggerHandler();
    TriggerDispatcher.run(handler);
}