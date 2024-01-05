public with sharing class MicroTriggerAsyncEvent {
    // INSTANCE PRIVATE VARIABLES
    private String microTriggerTypeName;
    private String sObjectName;
    private Integer size;
    private List<SObject> newList;
    private Map<Id, SObject> newMap;
    private List<SObject> oldList;
    private Map<Id, SObject> oldMap;
    private Map<String, Set<Id>> actionNameToFilteredCriteriaIdsMap;

    // INSTANCE PUBLIC GETTERS
    public Map<String, List<SObject>> getActionContextMap {
        get {
            Map<String, List<SObject>> actionContextMap = new Map<String, List<SObject>>();
            for (String actionName : actionNameToFilteredCriteriaIdsMap.keySet()) {
                Set<Id> filteredSObjectIds = actionNameToFilteredCriteriaIdsMap.get(actionName);
                List<SObject> filteredSObjects = new List<SObject>();
                for (SObject sObjectRecord : newList) {
                    if (filteredSObjectIds.contains(sObjectRecord.Id)) {
                        filteredSObjects.add(sObjectRecord);
                    }
                }
                actionContextMap.put(actionName, filteredSObjects);
            }
            return actionContextMap;
        }
        private set;
    }

    public TriggerAfterInsert.Context getAfterInsertContext {
        get {
            return new TriggerAfterInsert.Context(this.newList, this.newMap, this.size);
        }
    }

    public TriggerAfterUpdate.Context getAfterUpdateContext {
        get {
            return new TriggerAfterUpdate.Context(this.newList, this.newMap, this.oldList, this.oldMap, this.size);
        }
    }

    public TriggerOperation event {
        get { 
            return event; 
        }
        private set;
    }

    // CONSTRUCTORS
    /**
     * @description Base constructor that initializes all maps (even if they're not needed for the trigger context) 
     * so that they can be serialized and deserialized without errors
     */
    public MicroTriggerAsyncEvent() {
        this.actionNameToFilteredCriteriaIdsMap = new Map<String, Set<Id>>();
        this.newList = new List<SObject>();
        this.newMap = new Map<Id, SObject>();
        this.oldList = new List<SObject>();
        this.oldMap = new Map<Id, SObject>();
    }
    
    /**
     * @description Contructor used to instantiate an after insert microtrigger's context
     * @param microTriggerTypeName `String` name passed to the dispatcher
     * @param context `TriggerAfterInsert.Context` context of the after insert microtrigger
     */
    public MicroTriggerAsyncEvent(String microTriggerTypeName, String sObjectName, TriggerAfterInsert.Context context) {
        this();
        this.microTriggerTypeName = microTriggerTypeName;
        this.sObjectName = sObjectName;
        this.event = TriggerOperation.AFTER_INSERT;
        this.newList = context.newList;
        this.newMap = context.newMap;
        this.size = context.size;
    }

    /**
     * @description Contructor used to instantiate an after update microtrigger's context
     * @param microTriggerTypeName `String` name passed to the dispatcher
     * @param context `TriggerAfterInsert.Context` context of the after update microtrigger
     */
    public MicroTriggerAsyncEvent(String microTriggerTypeName, String sObjectName, TriggerAfterUpdate.Context context) {
        this();
        this.microTriggerTypeName = microTriggerTypeName;
        this.sObjectName = sObjectName;
        this.event = TriggerOperation.AFTER_UPDATE;
        this.newList = context.newList;
        this.newMap = context.newMap;
        this.oldList = context.oldList;
        this.oldMap = context.oldMap;
        this.size = context.size;
    }

    // INSTANCE PUBLIC METHODS
    /**
     * @description Used to populate the action context map. It is possible for multiple
     * criterias to call the same action so we need to support the same action being put 
     * into the map multiple times.
     * @param microTriggerActionName `String` the microtrigger action's class name
     * @param sObjects `List<SObject>` sObjects that passed the criteria class
     */
    public void putActionContext(String microTriggerActionName, List<SObject> sObjects) {
        Set<Id> filteredCriteriaIds = actionNameToFilteredCriteriaIdsMap.containsKey(microTriggerActionName) ? actionNameToFilteredCriteriaIdsMap.get(microTriggerActionName) : new Set<Id>();
        filteredCriteriaIds.addAll(getSObjectIdsFromSObjectList(sObjects));
        actionNameToFilteredCriteriaIdsMap.put(microTriggerActionName, filteredCriteriaIds);
    }

    /**
     * @description Parses this object to a MicroTrigger Async Event
     * @return  `MicroTrigger_Async_Event__e` the platform event
     */
    public MicroTrigger_Async_Event__e toPlatformEvent() {
        return new MicroTrigger_Async_Event__e(
            MicroTrigger_Type_Name__c = this.microTriggerTypeName,
            SObject_Name__c = this.sObjectName,
            Event__c = String.valueOf(this.event),
            Trigger_New__c = JSON.serialize(newList),
            Trigger_NewMap__c = JSON.serialize(newMap),
            Trigger_Old__c = JSON.serialize(oldList),
            Trigger_OldMap__c = JSON.serialize(oldMap),
            Trigger_Size__c = this.size,
            Action_Context__c = JSON.serialize(actionNameToFilteredCriteriaIdsMap)
        );
    }

    /**
     * @description Parses a MicroTrigger Async Event to an instance of this object
     * @param event `MicroTrigger_Async_Event__e` the MicroTrigger Async Event
     * @return  `MicroTriggerAsyncEvent` instance of this object that was parsed from the event
     */
    public MicroTriggerAsyncEvent fromPlatformEvent(MicroTrigger_Async_Event__e microTriggerAsyncEvent) {
        String sObjectName = microTriggerAsyncEvent.SObject_Name__c;
        this.microTriggerTypeName = microTriggerAsyncEvent.MicroTrigger_Type_Name__c;
        this.sObjectName = sObjectName;
        this.event = TriggerOperation.valueOf(microTriggerAsyncEvent.Event__c);
        this.newList = deserializeSObjectList(sObjectName, microTriggerAsyncEvent.Trigger_New__c);
        this.newMap = deserializeSObjectMap(sObjectName, microTriggerAsyncEvent.Trigger_NewMap__c);
        this.oldList = deserializeSObjectList(sObjectName, microTriggerAsyncEvent.Trigger_Old__c);
        this.oldMap = deserializeSObjectMap(sObjectName, microTriggerAsyncEvent.Trigger_OldMap__c);
        this.size = Integer.valueOf(microTriggerAsyncEvent.Trigger_Size__c);
        this.actionNameToFilteredCriteriaIdsMap = (Map<String, Set<Id>>) JSON.deserialize(microTriggerAsyncEvent.Action_Context__c, Map<String, Set<Id>>.class);
        return this;
    }

    // INSTANCE PRIVATE METHODS
    /**
     * @description Helper method to get a set of SObject Ids from a list of SObjects
     * @param sObjects `List<SObject>` the list of SObjects to get Ids from
     * @return  `Set<Id>` the set of ids from the list of SObjects
     */
    private Set<Id> getSObjectIdsFromSObjectList(List<SObject> sObjects) {
        Set<Id> sObjectIds = new Set<Id>();
        for (SObject sObjectRecord : sObjects) {
            sObjectIds.add(sObjectRecord.Id);
        }
        return sObjectIds;
    }

    /**
     * @description Used to deserialize to a list of SObjects
     * @param sObjectName `String` SObject type to deserialize to
     * @param serializedSObjectList `String` serialized SObject list
     * @return  `List<SObject>` deserialized SObject list
     */
    private List<SObject> deserializeSObjectList(String sObjectName, String serializedSObjectList) {
        String listTypeString = String.format(
            'List<{0}>',
            new List<String>{ sObjectName }
        );
        Type listType = Type.forName(listTypeString);
        return (List<SObject>) JSON.deserialize(serializedSObjectList, listType);
    }

    /**
     * @description Used to deserialize to a map of SObjects
     * @param sObjectName `String` SObject type to deserialize to
     * @param serializedSObjectMap `String` serialized SObject map
     * @return  `Map<Id, SObject>` deserialized SObject map
     */
    private Map<Id, SObject> deserializeSObjectMap(String sObjectName, String serializedSObjectMap) {
        String mapTypeString = String.format(
            'Map<Id, {0}>',
            new List<String>{ sObjectName }
        );
        Type mapType = Type.forName(mapTypeString);
        return (Map<Id, SObject>) JSON.deserialize(serializedSObjectMap, mapType);
    }
}