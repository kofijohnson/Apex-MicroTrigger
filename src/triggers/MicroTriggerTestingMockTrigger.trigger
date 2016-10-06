trigger MicroTriggerTestingMockTrigger on MicroTriggerTestingMock__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    MicroTriggersDispatcher dispatcher = new MicroTriggersDispatcher();
    dispatcher.dispatch();
}