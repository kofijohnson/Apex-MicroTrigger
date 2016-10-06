/**
 * MicroTrigger Framework https://github.com/kofijohnson/Apex-MicroTrigger
 * Copyright (C) 2016  Kofi Johnson (www.kofijohnson.com)
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * MicroTriggersLoader
 * @Description: Class that loads the MicroTriggers
 * @Author: Kofi Johnson - https://github.com/kofijohnson
 */

public class MicroTriggersLoader {

    /** Static Variables/members. */

	private static final String BEFORE_INSERT  = 'Before Insert';
    private static final String AFTER_INSERT   = 'After Insert';
    private static final String BEFORE_UPDATE  = 'Before Update';
    private static final String AFTER_UPDATE   = 'After Update';
    private static final String BEFORE_DELETE  = 'Before Delete';
    private static final String AFTER_DELETE   = 'After Delete';
    private static final String AFTER_UNDELETE = 'After Undelete';

    // microTriggerMocks can only be used from Test Class. It helps to inject MicroTriggers from Test Class
    @TestVisible private static List<BaseMicroTrigger> microTriggerMocks;

    /** Static Variables/members. Used for as Singleton Pattern */

    // Singleton Pattern, using static variable and getInstance
    private static MicroTriggersLoader currentMicroTriggersLoader;

    /**
     * return singleton instance of this class
     * @returns MicroTriggersLoader the singleton instande
     */
    public static MicroTriggersLoader getInstance() {
        if(currentMicroTriggersLoader == null)
            currentMicroTriggersLoader = new MicroTriggersLoader();
        
        return currentMicroTriggersLoader;
    }

    /** Non Static Variables/members. */

    private Map<String,BaseMicroTrigger> microTriggers;

    /**
     * Private Constructor. Singleton Pattern, used to prevent this class to be instantianted outside from this class.
     */
	private MicroTriggersLoader() {
        microTriggers = new Map<String,BaseMicroTrigger>();
		if(microTriggerMocks != null) {
            for(BaseMicroTrigger aMicroTriggerMock :microTriggerMocks)
                microTriggers.put(aMicroTriggerMock.DeveloperName, aMicroTriggerMock);
        }
        else {
            for(MicroTrigger__mdt aMicroTriggerMetadata :loadCustomMetaDataTypes()) 
                microTriggers.put(aMicroTriggerMetadata.DeveloperName, convertToMicroTrigger(aMicroTriggerMetadata));
        }
	}

    /**
     * Returns true if a microtrigger with given name exists in the microtrigger loader
     * @param microTriggerName the Name of the MicroTrigger to look for
     * @return Boolean true if microtrigger loader contains the MicroTrigger
     */
    public Boolean contains(String microTriggerName) {
        return microTriggers.containsKey(microTriggerName);
    }

    /**
     * Returns Microtrigger with given name if it exists in the microtrigger loader
     * @param microTriggerName the Name of the MicroTrigger to look for
     * @return BaseMicroTrigger The MicroTrigger object or NULL if the microtrigger wasn't found
     */
    public BaseMicroTrigger getMicroTrigger(String microTriggerName) {
        return microTriggers.get(microTriggerName);
    }

    /**
     * Returns all Microtriggers that were loaded by the microtrigger loader
     */
    public List<BaseMicroTrigger> getMicroTriggers() {
        return microTriggers.values();
    }

    /**
     * Returns all Microtriggers for the given SObject type and the Before Insert context
     * @param the SObject Type for which to return microtriggers
     * @return List<BaseMicroTrigger> a list of microtriggers. Empty list returned if none found
     */
    public List<BaseMicroTrigger> getBeforeInsertMicroTriggers(String sObjectName) {
        List<BaseMicroTrigger> result = new List<BaseMicroTrigger>();
        for(BaseMicroTrigger currentMicroTrigger :microTriggers.values()) {
            if(currentMicroTrigger.SObjectName == sObjectName && currentMicroTrigger instanceOf TriggerBeforeInsert.MicroTrigger)
                result.add(currentMicroTrigger);
        }
        return result;
    }

    /**
     * Returns all Microtriggers for the given SObject type and the After Insert context
     * @param the SObject Type for which to return microtriggers
     * @return List<BaseMicroTrigger> a list of microtriggers. Empty list returned if none found
     */
    public List<BaseMicroTrigger> getAfterInsertMicroTriggers(String sObjectName) {
        List<BaseMicroTrigger> result = new List<BaseMicroTrigger>();
        for(BaseMicroTrigger currentMicroTrigger :microTriggers.values()) {
            if(currentMicroTrigger.SObjectName == sObjectName && currentMicroTrigger instanceOf TriggerAfterInsert.MicroTrigger)
                result.add(currentMicroTrigger);
        }
        return result;
    }

    /**
     * Returns all Microtriggers for the given SObject type and the Before Update context
     * @param the SObject Type for which to return microtriggers
     * @return List<BaseMicroTrigger> a list of microtriggers. Empty list returned if none found
     */
    public List<BaseMicroTrigger> getBeforeUpdateMicroTriggers(String sObjectName) {
        List<BaseMicroTrigger> result = new List<BaseMicroTrigger>();
        for(BaseMicroTrigger currentMicroTrigger :microTriggers.values()) {
            if(currentMicroTrigger.SObjectName == sObjectName && currentMicroTrigger instanceOf TriggerBeforeUpdate.MicroTrigger)
                result.add(currentMicroTrigger);
        }
        return result;
    }

    /**
     * Returns all Microtriggers for the given SObject type and the After Update context
     * @param the SObject Type for which to return microtriggers
     * @return List<BaseMicroTrigger> a list of microtriggers. Empty list returned if none found
     */
    public List<BaseMicroTrigger> getAfterUpdateMicroTriggers(String sObjectName) {
        List<BaseMicroTrigger> result = new List<BaseMicroTrigger>();
        for(BaseMicroTrigger currentMicroTrigger :microTriggers.values()) {
            if(currentMicroTrigger.SObjectName == sObjectName && currentMicroTrigger instanceOf TriggerAfterUpdate.MicroTrigger)
                result.add(currentMicroTrigger);
        }
        return result;
    }

    /**
     * Returns all Microtriggers for the given SObject type and the Before Delete context
     * @param the SObject Type for which to return microtriggers
     * @return List<BaseMicroTrigger> a list of microtriggers. Empty list returned if none found
     */
    public List<BaseMicroTrigger> getBeforeDeleteMicroTriggers(String sObjectName) {
        List<BaseMicroTrigger> result = new List<BaseMicroTrigger>();
        for(BaseMicroTrigger currentMicroTrigger :microTriggers.values()) {
            if(currentMicroTrigger.SObjectName == sObjectName && currentMicroTrigger instanceOf TriggerBeforeDelete.MicroTrigger)
                result.add(currentMicroTrigger);
        }
        return result;
    }

    /**
     * Returns all Microtriggers for the given SObject type and the After Delete context
     * @param the SObject Type for which to return microtriggers
     * @return List<BaseMicroTrigger> a list of microtriggers. Empty list returned if none found
     */
    public List<BaseMicroTrigger> getAfterDeleteMicroTriggers(String sObjectName) {
        List<BaseMicroTrigger> result = new List<BaseMicroTrigger>();
        for(BaseMicroTrigger currentMicroTrigger :microTriggers.values()) {
            if(currentMicroTrigger.SObjectName == sObjectName && currentMicroTrigger instanceOf TriggerAfterDelete.MicroTrigger)
                result.add(currentMicroTrigger);
        }
        return result;
    }

    /**
     * Returns all Microtriggers for the given SObject type and the After Undelete Insert context
     * @param the SObject Type for which to return microtriggers
     * @return List<BaseMicroTrigger> a list of microtriggers. Empty list returned if none found
     */
    public List<BaseMicroTrigger> getAfterUndeleteMicroTriggers(String sObjectName) {
        List<BaseMicroTrigger> result = new List<BaseMicroTrigger>();
        for(BaseMicroTrigger currentMicroTrigger :microTriggers.values()) {
            if(currentMicroTrigger.SObjectName == sObjectName && currentMicroTrigger instanceOf TriggerAfterUndelete.MicroTrigger)
                result.add(currentMicroTrigger);
        }
        return result;
    }

    /**
     * Returns a list of MicroTrigger__mdt Custom Metadata object.  Each record represents a MicroTrigger
     * @return List<MicroTrigger__mdt> A list of MicroTrigger custom metadata records
     */
    private List<MicroTrigger__mdt> loadCustomMetaDataTypes() {
        return [
            SELECT DeveloperName, Active__c, SObject__c, Event__c, Criteria__c, PreventRecursive__c,
            	(
            		SELECT Active__c, ApexClass__c, OrderOfExecution__c
            		FROM MicroTriggerActions__r
            		WHERE Active__c = true
            	)
            FROM MicroTrigger__mdt
            WHERE Active__c = true
            ORDER BY OrderOfExecution__c
        ];
    }

    /**
     * Given a MicroTrigger__mdt Custom Metadata record, build and return the appropriate MicroTrigger object instance
     * @param customMetadataType a single MicroTrigger__mdt custom metadata record
     * @return BaseMicroTrigger An instance of the BaseMicroTrigger object
     */
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
                currentMicroTrigger.addAction(actionCustomMetadataType.ApexClass__c);
        }

        if(customMetadataType.PreventRecursive__c)
            currentMicroTrigger.preventRecursive();

        return currentMicroTrigger;
    }

    /**
     * Given a List of MicroTriggerAction__mdt Custom Metadata, return a sorted List
     * @param List of MicroTriggerAction__mdt custom metadata
     * @return Sorted List of MicroTriggerAction__mdt custom metadata
     */
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

    /**
     * TriggerActionMetadataType implements Comparable, 
     * so we can sort the MicroTriggerAction__mdt based on OrderOfExecution__c.
     */
    class TriggerActionMetadataType implements Comparable {
        public MicroTriggerAction__mdt currentRecord {get; private set;}
        
        // Constructor
        TriggerActionMetadataType(MicroTriggerAction__mdt action) {
            currentRecord = action;
        }
        
        // Compare TriggerAction based on the field Order Of Execution.
        public Integer compareTo(Object compareTo) {
            TriggerActionMetadataType compareTriggerActionMetadataType = (TriggerActionMetadataType) compareTo;
            
            if (currentRecord.OrderOfExecution__c > compareTriggerActionMetadataType.currentRecord.OrderOfExecution__c)
                return 1;
            else
                return -1;

        }
    }
}