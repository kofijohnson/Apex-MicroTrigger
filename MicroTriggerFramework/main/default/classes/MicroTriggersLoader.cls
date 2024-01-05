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
* @Description: Class that loads the MicroTriggers
* @Author: Kofi Johnson - https://github.com/kofijohnson
********************************************************************************************************/

public class MicroTriggersLoader {

    /** Static Variables/members. */

    private static final String BEFORE_INSERT = 'Before Insert';
    private static final String AFTER_INSERT = 'After Insert';
    private static final String BEFORE_UPDATE = 'Before Update';
    private static final String AFTER_UPDATE = 'After Update';
    private static final String BEFORE_DELETE = 'Before Delete';
    private static final String AFTER_DELETE = 'After Delete';
    private static final String AFTER_UNDELETE = 'After Undelete';

    /** Static Variables/members. Used for as Singleton Pattern */

    // Singleton Pattern, using static variable and getInstance
    private static MicroTriggersLoader currentMicroTriggersLoader;

    /*******************************************************************************************************
    * @description Returns the Singleton instance of the MicroTriggersLoader class.
    * @return MicroTriggersLoader The singleton instance.
    ********************************************************************************************************/
    public static MicroTriggersLoader getInstance() {
        if(currentMicroTriggersLoader == null)
            currentMicroTriggersLoader = new MicroTriggersLoader();
        
        return currentMicroTriggersLoader;
    }

    /** Non Static Variables/members. */

    private Map<String, BaseMicroTrigger> microTriggers;

    /*******************************************************************************************************
    * @description Private Constructor. Singleton Pattern, it is used to prevent this class to be  
    * instantianted outside from this class.
    ********************************************************************************************************/
    private MicroTriggersLoader() {
        microTriggers = new Map<String, BaseMicroTrigger>();
        for(MicroTrigger__mdt currentMicroTriggerMetadata :loadCustomMetaDataTypes()) {
            microTriggers.put(currentMicroTriggerMetadata.DeveloperName, convertToMicroTrigger(currentMicroTriggerMetadata));
        }
    }

    /*******************************************************************************************************
    * @description Override the default MicroTriggers.
    * @param List<BaseMicroTrigger> The list of the new MicroTriggers to use.
    ********************************************************************************************************/
    public void overrideMicroTriggers(List<BaseMicroTrigger> overriddenMicroTriggers) {
        microTriggers = new Map<String, BaseMicroTrigger>();
        if(overriddenMicroTriggers != null) {
            for(BaseMicroTrigger currentMicroTriggerMock :overriddenMicroTriggers)
                microTriggers.put(currentMicroTriggerMock.DeveloperName, currentMicroTriggerMock);
        }
    }

    /*******************************************************************************************************
    * @description Returns true if a microtrigger with given name exists in the microtrigger loader.
    * @param String The Name of the MicroTrigger to look for.
    * @return Boolean. True if the microtrigger loader contains the MicroTrigger.
    ********************************************************************************************************/
    public Boolean contains(String microTriggerName) {
        return microTriggers.containsKey(microTriggerName);
    }

    /*******************************************************************************************************
    * @description Returns Microtrigger with given name if it exists in the microtrigger loader.
    * @param String The Name of the MicroTrigger to look for.
    * @return BaseMicroTrigger The MicroTrigger object or NULL if the microtrigger wasn't found.
    ********************************************************************************************************/
    public BaseMicroTrigger getMicroTrigger(String microTriggerName) {
        return microTriggers.get(microTriggerName);
    }

    /*******************************************************************************************************
    * @description Returns all Microtriggers that were loaded by the microtrigger loader.
    * @return List<BaseMicroTrigger> The Lists of the Microtriggers.
    ********************************************************************************************************/
    public List<BaseMicroTrigger> getMicroTriggers() {
        return microTriggers.values();
    }

    /*******************************************************************************************************
    * @description Returns all Microtriggers for the given SObject type and the Before Insert context.
    * @param String The SObject Type for which to return Microtriggers.
    * @return List<BaseMicroTrigger> A List of Microtriggers. Empty list returned if none found.
    ********************************************************************************************************/
    public List<BaseMicroTrigger> getBeforeInsertMicroTriggers(String sObjectName) {
        List<BaseMicroTrigger> result = new List<BaseMicroTrigger>();
        for(BaseMicroTrigger currentMicroTrigger :microTriggers.values()) {
            if(currentMicroTrigger.SObjectName == sObjectName && currentMicroTrigger instanceOf TriggerBeforeInsert.MicroTrigger)
                result.add(currentMicroTrigger);
        }
        return result;
    }

    /*******************************************************************************************************
    * @description Returns all Microtriggers for the given SObject type and the After Insert context.
    * @param String The SObject Type for which to return Microtriggers.
    * @return List<BaseMicroTrigger> A List of Microtriggers. Empty list returned if none found.
    ********************************************************************************************************/
    public List<BaseMicroTrigger> getAfterInsertMicroTriggers(String sObjectName) {
        List<BaseMicroTrigger> result = new List<BaseMicroTrigger>();
        for(BaseMicroTrigger currentMicroTrigger :microTriggers.values()) {
            if(currentMicroTrigger.SObjectName == sObjectName && currentMicroTrigger instanceOf TriggerAfterInsert.MicroTrigger)
                result.add(currentMicroTrigger);
        }
        return result;
    }

    /*******************************************************************************************************
    * @description Returns all Microtriggers for the given SObject type and the Before Update context.
    * @param String The SObject Type for which to return Microtriggers.
    * @return List<BaseMicroTrigger> A List of Microtriggers. Empty list returned if none found.
    ********************************************************************************************************/
    public List<BaseMicroTrigger> getBeforeUpdateMicroTriggers(String sObjectName) {
        List<BaseMicroTrigger> result = new List<BaseMicroTrigger>();
        for(BaseMicroTrigger currentMicroTrigger :microTriggers.values()) {
            if(currentMicroTrigger.SObjectName == sObjectName && currentMicroTrigger instanceOf TriggerBeforeUpdate.MicroTrigger)
                result.add(currentMicroTrigger);
        }
        return result;
    }

    /*******************************************************************************************************
    * @description Returns all Microtriggers for the given SObject type and the After Update context.
    * @param String The SObject Type for which to return Microtriggers.
    * @return List<BaseMicroTrigger> A List of Microtriggers. Empty list returned if none found.
    ********************************************************************************************************/
    public List<BaseMicroTrigger> getAfterUpdateMicroTriggers(String sObjectName) {
        List<BaseMicroTrigger> result = new List<BaseMicroTrigger>();
        for(BaseMicroTrigger currentMicroTrigger :microTriggers.values()) {
            if(currentMicroTrigger.SObjectName == sObjectName && currentMicroTrigger instanceOf TriggerAfterUpdate.MicroTrigger)
                result.add(currentMicroTrigger);
        }
        return result;
    }

    /*******************************************************************************************************
    * @description Returns all Microtriggers for the given SObject type and the Before Delete context.
    * @param String The SObject Type for which to return Microtriggers.
    * @return List<BaseMicroTrigger> A List of Microtriggers. Empty list returned if none found.
    ********************************************************************************************************/
    public List<BaseMicroTrigger> getBeforeDeleteMicroTriggers(String sObjectName) {
        List<BaseMicroTrigger> result = new List<BaseMicroTrigger>();
        for(BaseMicroTrigger currentMicroTrigger :microTriggers.values()) {
            if(currentMicroTrigger.SObjectName == sObjectName && currentMicroTrigger instanceOf TriggerBeforeDelete.MicroTrigger)
                result.add(currentMicroTrigger);
        }
        return result;
    }

    /*******************************************************************************************************
    * @description Returns all Microtriggers for the given SObject type and the After Delete context.
    * @param String The SObject Type for which to return Microtriggers.
    * @return List<BaseMicroTrigger> A List of Microtriggers. Empty list returned if none found.
    ********************************************************************************************************/
    public List<BaseMicroTrigger> getAfterDeleteMicroTriggers(String sObjectName) {
        List<BaseMicroTrigger> result = new List<BaseMicroTrigger>();
        for(BaseMicroTrigger currentMicroTrigger :microTriggers.values()) {
            if(currentMicroTrigger.SObjectName == sObjectName && currentMicroTrigger instanceOf TriggerAfterDelete.MicroTrigger)
                result.add(currentMicroTrigger);
        }
        return result;
    }

    /*******************************************************************************************************
    * @description Returns all Microtriggers for the given SObject type and the After Undelete context.
    * @param String The SObject Type for which to return Microtriggers.
    * @return List<BaseMicroTrigger> A List of Microtriggers. Empty list returned if none found.
    ********************************************************************************************************/
    public List<BaseMicroTrigger> getAfterUndeleteMicroTriggers(String sObjectName) {
        List<BaseMicroTrigger> result = new List<BaseMicroTrigger>();
        for(BaseMicroTrigger currentMicroTrigger :microTriggers.values()) {
            if(currentMicroTrigger.SObjectName == sObjectName && currentMicroTrigger instanceOf TriggerAfterUndelete.MicroTrigger)
                result.add(currentMicroTrigger);
        }
        return result;
    }

    /*******************************************************************************************************
    * @description Returns a list of MicroTrigger__mdt Custom Metadata object. 
    * Each record represents a MicroTrigger.
    * @return List<MicroTrigger__mdt> A List of MicroTrigger custom metadata records.
    ********************************************************************************************************/
    private List<MicroTrigger__mdt> loadCustomMetaDataTypes() {
        return [
            SELECT DeveloperName, Active__c, SObject__c, Event__c, Criteria__c, PreventRecursive__c,
                (
                    SELECT Active__c, ApexClass__c, OrderOfExecution__c, Is_Async__c
                    FROM MicroTriggerActions__r
                    WHERE Active__c = true
                )
            FROM MicroTrigger__mdt
            WHERE Active__c = true
            ORDER BY OrderOfExecution__c
        ];
    }

    /*******************************************************************************************************
    * @description Given a MicroTrigger__mdt Custom Metadata record, build and return the appropriate
    * MicroTrigger object instance.
    * @param MicroTrigger__mdt a single MicroTrigger__mdt custom metadata record.
    * @return BaseMicroTrigger An instance of the BaseMicroTrigger Object.
    ********************************************************************************************************/
    private BaseMicroTrigger convertToMicroTrigger(MicroTrigger__mdt customMetadataType) {
        BaseMicroTrigger currentMicroTrigger;
        if(customMetadataType.Event__c == BEFORE_INSERT)
            currentMicroTrigger = new TriggerBeforeInsert.MicroTrigger(customMetadataType.DeveloperName, customMetadataType.SObject__c);
        if(customMetadataType.Event__c == AFTER_INSERT)
            currentMicroTrigger = new TriggerAfterInsert.MicroTrigger(customMetadataType.DeveloperName, customMetadataType.SObject__c);
        if(customMetadataType.Event__c == BEFORE_UPDATE)
            currentMicroTrigger = new TriggerBeforeUpdate.MicroTrigger(customMetadataType.DeveloperName, customMetadataType.SObject__c);
        if(customMetadataType.Event__c == AFTER_UPDATE)
            currentMicroTrigger = new TriggerAfterUpdate.MicroTrigger(customMetadataType.DeveloperName, customMetadataType.SObject__c);
        if(customMetadataType.Event__c == BEFORE_DELETE)
            currentMicroTrigger = new TriggerBeforeDelete.MicroTrigger(customMetadataType.DeveloperName, customMetadataType.SObject__c);
        if(customMetadataType.Event__c == AFTER_DELETE)
            currentMicroTrigger = new TriggerAfterDelete.MicroTrigger(customMetadataType.DeveloperName, customMetadataType.SObject__c);
        if(customMetadataType.Event__c == AFTER_UNDELETE)
            currentMicroTrigger = new TriggerAfterUndelete.MicroTrigger(customMetadataType.DeveloperName, customMetadataType.SObject__c);
        
        currentMicroTrigger.setCriteria(customMetadataType.Criteria__c);
        
        List<MicroTriggerAction__mdt> sortedActions = getSortedActions(customMetadataType.MicroTriggerActions__r);
        for(MicroTriggerAction__mdt actionCustomMetadataType :sortedActions) {
            if(String.isNotBlank(actionCustomMetadataType.ApexClass__c))
                currentMicroTrigger.addAction(actionCustomMetadataType.ApexClass__c, actionCustomMetadataType.Is_Async__c);
        }
        if(customMetadataType.PreventRecursive__c)
            currentMicroTrigger.preventRecursive();

        return currentMicroTrigger;
    }

    /*******************************************************************************************************
    * @description Given a List of MicroTriggerAction__mdt Custom Metadata, return a sorted List.
    * @param List<MicroTriggerAction__mdt> List of MicroTriggerAction__mdt custom metadata.
    * @return List<MicroTriggerAction__mdt> Sorted List of MicroTriggerAction__mdt custom metadata
    ********************************************************************************************************/
    private List<MicroTriggerAction__mdt> getSortedActions(List<MicroTriggerAction__mdt> actionCustomMetadataTypes) {
        List<MicroTriggerAction__mdt> result = new List<MicroTriggerAction__mdt>();

        List<TriggerActionMetadataType> actionCustomMetadataTypeWrappers = new List<TriggerActionMetadataType>();
        for(MicroTriggerAction__mdt actionCustomMetadataType :actionCustomMetadataTypes) {
            actionCustomMetadataTypeWrappers.add(
                new TriggerActionMetadataType(actionCustomMetadataType)
            );
        }
        actionCustomMetadataTypeWrappers.sort();
        for(TriggerActionMetadataType actionCustomMetadataTypeWrapper :actionCustomMetadataTypeWrappers) {
            result.add(actionCustomMetadataTypeWrapper.currentRecord);
        }

        return result;
    }

    /*******************************************************************************************************
    * @descripton TTriggerActionMetadataType implements Comparable, 
    * so we can sort the MicroTriggerAction__mdt based on OrderOfExecution__c.
    ********************************************************************************************************/
    class TriggerActionMetadataType implements Comparable {
        public MicroTriggerAction__mdt currentRecord {get; private set;}
        
        /*******************************************************************************************************
        * @description Constructor
        ********************************************************************************************************/
        TriggerActionMetadataType(MicroTriggerAction__mdt action) {
            currentRecord = action;
        }
        
        /*******************************************************************************************************
        * @description Compare TriggerAction based on the field Order Of Execution.
        * @param TriggerActionMetadataType The Object to compare.
        * @return Integer.
        ********************************************************************************************************/
        public Integer compareTo(Object compareTo) {
            return currentRecord.OrderOfExecution__c > ((TriggerActionMetadataType) compareTo).currentRecord.OrderOfExecution__c ? 1 : -1;
        }
    }
}