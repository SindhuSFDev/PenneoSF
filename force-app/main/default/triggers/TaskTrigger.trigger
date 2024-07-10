trigger TaskTrigger on Task (before delete, before insert, before update, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.Run(new TaskTriggerHandler());
}