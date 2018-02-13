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
* @Description: Base Class for MicroTriggers
* @Author: Kofi Johnson - https://github.com/kofijohnson
********************************************************************************************************/

public abstract class BaseMicroTrigger {
    public String DeveloperName {get; private set;}
    public String SObjectName {get; private set;}
    public Boolean Recursive {get; private set;}
    public Boolean IsActive {get; private set;}

    private String criteriaClass;
    private List<String> actionsClasses;

    /*******************************************************************************************************
    * @description class constructor. Initializes Trigger Process.
    * @param String The developer name for this MicroTrigger.
    * @param String The SObject type that this trigger will execute against.
    ********************************************************************************************************/
    public BaseMicroTrigger(String developerName, String sObjectName) {
        this.DeveloperName = developerName;
        this.SObjectName = sObjectName;
        Recursive = true;
        IsActive = true;
        criteriaClass = '';
        actionsClasses = new List<String>();
    }

    /*******************************************************************************************************
    * @description Sets the Criteria for this MicroTrigger.
    * @param String the class name of the Criteria class.
    * @return BaseMicroTrigger.
    ********************************************************************************************************/
    public BaseMicroTrigger setCriteria(String criteriaClass) {
        this.criteriaClass = criteriaClass;
        return this;
    }

    /*******************************************************************************************************
    * @description Adds an Action for this MicroTrigger. Throws an error if the Action class doesnt exist.
    * @param String the class name of the Action class.
    * @return BaseMicroTrigger.
    ********************************************************************************************************/
    public BaseMicroTrigger addAction(String actionClass) {
        System.assert(
            String.isNotBlank(actionClass) || Type.forName(actionClass) != null,
            'ERROR MicroTrigger "' + this.DeveloperName + '" Invalid Action Class "' + actionClass + '"'
        );
        actionsClasses.add(actionClass);
        return this;
    }

    /*******************************************************************************************************
    * @description Returns true if the given Action class is within this MicroTrigger's Action class list.
    * @param String the class name of the Action class.
    * @return Boolean value indicating whether the given Action class is in the Action class list.
    ********************************************************************************************************/
    public Boolean containsAction(String actionClass) {
        return (new Set<String>(actionsClasses)).contains(actionClass);
    }

    /*******************************************************************************************************
    * @description Prevents recursive calls to this MicroTrigger.
    * @return BaseMicroTrigger.
    ********************************************************************************************************/
    public BaseMicroTrigger preventRecursive() {
        Recursive = false;
        return this;
    }

    /*******************************************************************************************************
    * @description Allows recursive calls to this MicroTrigger.
    * @return BaseMicroTrigger.
    ********************************************************************************************************/
    public BaseMicroTrigger allowRecursive() {
        Recursive = true;
        return this;
    }

    /*******************************************************************************************************
    * @description Activates this MicroTrigger.
    * @return BaseMicroTrigger.
    ********************************************************************************************************/
    public BaseMicroTrigger activate() {
        IsActive = true;
        return this;
    }

    /*******************************************************************************************************
    * @description Deactivates this MicroTrigger.
    * @return BaseMicroTrigger.
    ********************************************************************************************************/
    public BaseMicroTrigger deactivate() {
        IsActive = false;
        return this;
    }

    /*******************************************************************************************************
    * @description Executes this MicroTrigger. First, run Criteria class for this MicroTrigger, and if any 
    * qualified records are returned, then pass those records to the action classes and run each one 
    * after the other.
    * @return MicroTriggerResult. MicroTriggerResult indicating the results from the MicroTrigger execution.
    ********************************************************************************************************/
    public MicroTriggerResult execute() {
        MicroTriggerResult result = new MicroTriggerResult(this.DeveloperName);
        
        // Exit if microtrigger is inactive.
        result.IsActive = IsActive;
        if(IsActive == false) {
            return result;
        }
        
        // Run criteria class, return if no qualified records.
        List<SObject> qualifiedRecords = new List<SObject>();
        if(String.isNotBlank(criteriaClass)) {
            qualifiedRecords = runCriteria(criteriaClass);
        }
        if(String.isNotBlank(criteriaClass) && (qualifiedRecords == null || qualifiedRecords.isEmpty())) {
            return result;
        }

        result.QualifiedRecords = qualifiedRecords;

        if(Recursive == false) {
            this.deactivate();
        }
        // Run each of the action classes and then return reult.
        for(String actionClass :actionsClasses) {
            Boolean success = runAction(actionClass, qualifiedRecords);
            if(success) {
                result.SuccessActions.add(actionClass);
            }
            else {
                result.FailActions.add(actionClass);
            }
        }
        return result;
    }

    /*******************************************************************************************************
    * @description Runs the Criteria. Implemented by subclasses like TriggerBeforeInsert.
    * @param String. The name of the Criteria Class to run.
    * @return List<SObject>. The qualified records.
    ********************************************************************************************************/
    protected abstract List<SObject> runCriteria(String criteriaClass);

    /*******************************************************************************************************
    * @description Runs the Action. Implemented by subclasses like TriggerBeforeInsert.
    * @param String. The name of the Action Class to run.
    * @param List<SObject>. The List of the qualified records the Criteria returns.
    * @return Boolean. Flag that tells the framework if the Action runs successfully (true)
    * or not successfully (false).
    ********************************************************************************************************/
    protected abstract Boolean runAction(String actionClass, List<SObject> qualifiedRecords);
}