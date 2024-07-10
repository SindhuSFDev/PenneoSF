/**
 * Created by yatishsalian on 03/08/21.
 */

trigger EmailMessageTrigger on EmailMessage (before insert, before update, before delete, after delete, after insert, after update, after undelete) {
    EmailMessageTriggerHandler handler = new EmailMessageTriggerHandler();
    TriggerDispatcher.run(handler);
}