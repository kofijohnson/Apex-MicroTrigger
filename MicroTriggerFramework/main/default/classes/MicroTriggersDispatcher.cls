/**
 * MicroTrigger Framework https://github.com/kofijohnson/Apex-MicroTrigger
 * Copyright (C) 2016  Kofi Johnson (www.kofijohnson.com)
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*******************************************************************************************************
* @Description: Class that loads and executes the MicroTriggers.
* @Author: Kofi Johnson - https://github.com/kofijohnson
********************************************************************************************************/

public class MicroTriggersDispatcher {
    public static  List<MicroTriggerResult> ExecutionResults;

    private MicroTriggersLoader microTriggerLoader;

    /*******************************************************************************************************
    * @description Constructor.
    ********************************************************************************************************/    
    public MicroTriggersDispatcher() {
        if(ExecutionResults == null)
            ExecutionResults = new List<MicroTriggerResult>();
        microTriggerLoader  = MicroTriggersLoader.getInstance();
    }

    /*******************************************************************************************************
    * @description Gets and runs the appropriates MicroTriggers.
    ********************************************************************************************************/
    public void dispatch(String triggerName) {
        MicroTriggerLogging.LogEvent triggerLogEvent = new MicroTriggerLogging.LogEvent(triggerName, 'Trigger');
        MicroTriggerLogging.emitLogStarted(triggerLogEvent);

        String sObjectName = getTriggerSObject();
        List<BaseMicroTrigger> contextMicroTriggers = getContextMicroTriggers(sObjectName);
        for(BaseMicroTrigger currentMicroTrigger :contextMicroTriggers) {
            MicroTriggerResult currentMicroTriggerResult = currentMicroTrigger.execute();
            if(currentMicroTriggerResult.IsActive) {
                ExecutionResults.add(currentMicroTriggerResult);
            }
        }

        MicroTriggerLogging.emitLogCompleted(triggerLogEvent);
    }
    
    /*******************************************************************************************************
    * @description Returns the current Trigger SObject Type.
    * @return String SObject Type.
    ********************************************************************************************************/
    private String getTriggerSObject() {
        String result = null;

        if(Trigger.new != null && Trigger.new.isEmpty() == false)
            result = Trigger.new[0].getSObjectType().getDescribe().getName();
        else if(Trigger.old != null && Trigger.old.isEmpty() == false)
            result = Trigger.old[0].getSObjectType().getDescribe().getName();
        
        return result;
    }

    /*******************************************************************************************************
    * @description Gets a list of configured MicroTriggers given an SObject name and the current trigger context.
    * @param String SObject Name.
    * @return List<BaseMicroTrigger> MicroTrigger objects for the given SObject type and current trigger context.
    ********************************************************************************************************/ 
    private List<BaseMicroTrigger> getContextMicroTriggers(String sObjectName) {
        List<BaseMicroTrigger> result = new List<BaseMicroTrigger>();

        switch on Trigger.operationType() {

            when BEFORE_INSERT {
                result = microTriggerLoader.getBeforeInsertMicroTriggers(sObjectName);
            }
            when AFTER_INSERT {
                result = microTriggerLoader.getAfterInsertMicroTriggers(sObjectName);                
            }
            when BEFORE_UPDATE {
                result = microTriggerLoader.getBeforeUpdateMicroTriggers(sObjectName);                  
            }
            when AFTER_UPDATE {
                result = microTriggerLoader.getAfterUpdateMicroTriggers(sObjectName);                
            }
            when BEFORE_DELETE {
                result = microTriggerLoader.getBeforeDeleteMicroTriggers(sObjectName);                
            }
            when AFTER_DELETE {
                result = microTriggerLoader.getAfterDeleteMicroTriggers(sObjectName);                
            }
            when AFTER_UNDELETE {
                result = microTriggerLoader.getAfterUndeleteMicroTriggers(sObjectName);                
            }
        }

        return result;
    }
}