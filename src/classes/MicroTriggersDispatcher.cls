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

/**
 * MicroTriggersDispatcher
 * @Description: Class that loads and executes the MicroTriggers
 * @Author: Kofi Johnson - https://github.com/kofijohnson
 */

public class MicroTriggersDispatcher {
    public static  List<MicroTriggerResult> ExecutionResults;

    private MicroTriggersLoader microTriggerLoader;
    
    /**
     * class constructor. Set a reference to the processes loader.
     * @return string sobject type
     */     
    public MicroTriggersDispatcher() {
        if(ExecutionResults == null)
            ExecutionResults = new List<MicroTriggerResult>();
        microTriggerLoader  = MicroTriggersLoader.getInstance();
    }

    /**
     * Dispatch the trigger call to the appropriate trigger processes.
     * @return string sobject type
     */  
    public void dispatch() {         
        String sObjectName = getTriggerSObject();
        List<BaseMicroTrigger> contextMicroTriggers = getContextMicroTriggers(sObjectName);
        for(BaseMicroTrigger currentMicroTrigger :contextMicroTriggers) {
            MicroTriggerResult currentMicroTriggerResult = currentMicroTrigger.execute();
            if(currentMicroTriggerResult.IsActive)
                ExecutionResults.add(currentMicroTriggerResult);
        }
    }
    
    /**
     * return the sobject type of the trigger object
     * @return string sobject type
     */  
    private String getTriggerSObject() {
        String result = null;

        if(Trigger.new != null && Trigger.new.isEmpty() == false)
            result = Trigger.new[0].getSObjectType().getDescribe().getName();
        else if(Trigger.old != null && Trigger.old.isEmpty() == false)
            result = Trigger.old[0].getSObjectType().getDescribe().getName();
        
        return result;
    }

    /**
     * Get a list of configured MicroTriggers given an SObject name and the current trigger context
     * @return List<BaseMicroTrigger> A list of MicroTrigger objects for the given SObject type and current trigger context
     */  
    private List<BaseMicroTrigger> getContextMicroTriggers(String sObjectName) {
        List<BaseMicroTrigger> result = new List<BaseMicroTrigger>();
        if(Trigger.isBefore && Trigger.isInsert)
            result = microTriggerLoader.getBeforeInsertMicroTriggers(sObjectName);
        if(Trigger.isAfter && Trigger.isInsert)
            result = microTriggerLoader.getAfterInsertMicroTriggers(sObjectName);
        if(Trigger.isBefore && Trigger.isUpdate)
            result = microTriggerLoader.getBeforeUpdateMicroTriggers(sObjectName);
        if(Trigger.isAfter && Trigger.isUpdate)
            result = microTriggerLoader.getAfterUpdateMicroTriggers(sObjectName);
        if(Trigger.isBefore && Trigger.isDelete)
            result = microTriggerLoader.getBeforeDeleteMicroTriggers(sObjectName);
        if(Trigger.isAfter && Trigger.isDelete)
            result = microTriggerLoader.getAfterDeleteMicroTriggers(sObjectName);
        if(Trigger.isAfter && Trigger.isUndelete)
            result = microTriggerLoader.getAfterUndeleteMicroTriggers(sObjectName);

        return result;
    }
}