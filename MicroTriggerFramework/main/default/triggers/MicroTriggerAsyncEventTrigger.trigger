/**
 * Created by tristanmartin on 2/22/23.
 */

trigger MicroTriggerAsyncEventTrigger on MicroTrigger_Async_Event__e (after insert) {
    MicroTriggersDispatcher dispatcher = new MicroTriggersDispatcher();
    dispatcher.dispatchAsync(new MicroTriggerAsyncEvent().fromPlatformEvent(Trigger.new[0]));
}