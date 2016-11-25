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
 * BaseMicroTrigger
 * @Description: Base Class for MicroTriggers
 * @Author: Kofi Johnson - https://github.com/kofijohnson
 */

public abstract class BaseMicroTrigger {
	/** The developer name of this MicroTrigger */
	public String DeveloperName  {get; private set;}

	/** The SObject type that this MicroTrigger will execute against */
	public String SObjectName    {get; private set;}

	/** Whether to allow recursive calls into this MicroTrigger */
	public Boolean Recursive     {get; private set;}

	/** Whether the MicroTrigger is active or not */
	public Boolean IsActive      {get; private set;}

	/** The name of the criteria class type. */
	private String criteriaClass;

	/** A list of all the action class types */
	private List<String> actionsClasses;

	/**
   * class constructor.  Initializes trigger process
   * @param microTriggerDeveloperName The developer name for this MicroTrigger
   * @param microTriggerSObjectName the SObject type that this trigger will execute against
   */
	public BaseMicroTrigger(String microTriggerDeveloperName, String microTriggerSObjectName) {
		DeveloperName  = microTriggerDeveloperName;
		SObjectName    = microTriggerSObjectName;
		Recursive      = true;
		IsActive       = true;
		criteriaClass  = '';
		actionsClasses = new List<String>();
	}

	/**
	* Set the criteria class for this MicroTrigger.  Throws an error if the criteria class doesnt exist
	* @param criteriaClass the class name of the criteria class
	**/
	public BaseMicroTrigger setCriteria(String criteriaClass) {
		System.assert(
			String.isNotBlank(criteriaClass) && Type.forName(criteriaClass) != null,
			'ERROR MicroTrigger "' + this.DeveloperName + '" Invalid Criteria Class "' + criteriaClass + '"'
		);
		this.criteriaClass = criteriaClass;
		return this;
	}

	/**
	* Add an action class for this MicroTrigger.  Throws an error if the action class doesnt exist
	* @param actionClass the class name of the action class
	**/
	public BaseMicroTrigger addAction(String actionClass) {
		System.assert(
			String.isNotBlank(actionClass) || Type.forName(actionClass) != null,
			'ERROR MicroTrigger "' + this.DeveloperName + '" Invalid Action Class "' + actionClass + '"'
		);
		actionsClasses.add(actionClass);
		return this;
	}

	/**
	* Returns true if given action class is within this MicroTrigger's action class list
	* @param actionClass the class name of the action class
	* @return Boolean value indicating whether given action class is in action class list
	**/
	public Boolean containsAction(String actionClass) {
		return (new Set<String>(actionsClasses)).contains(actionClass);
	}

	/**
	* Prevent recursive calls to this MicroTrigger
	**/
	public BaseMicroTrigger preventRecursive() {
		Recursive = false;
		return this;
	}

	/**
	* Allow recursive calls to this MicroTrigger
	**/
	public BaseMicroTrigger allowRecursive() {
		Recursive = true;
		return this;
	}

	/**
	* Activate this MicroTrigger
	**/
	public BaseMicroTrigger activate() {
		IsActive = true;
		return this;
	}

	/**
	* Deactivate this MicroTrigger
	**/
	public BaseMicroTrigger deactivate() {
		IsActive = false;
		return this;
	}

	/**
	* Execute this MicroTrigger. First, run Criteria class for this MicroTrigger, and if any qualified records
	* are returned, then pass those records to the action classes and run each one after the other.
	* @return an instance of MicroTriggerResult indicating the results from the MicroTrigger execution
	**/
	public MicroTriggerResult execute() {
		// result object for return
		MicroTriggerResult result = new MicroTriggerResult(this.DeveloperName);
		
		// return if microtrigger is inactive
		result.IsActive = IsActive;
		if(IsActive == false)
			return result;
		
		// run criteria class, return if no qualified records
		List<SObject> qualifiedRecords = runCriteria(criteriaClass);
		if(qualifiedRecords == null || qualifiedRecords.isEmpty())
			return result;

		// criteria is met
    result.CriteriaIsMet = true;
    if(Recursive == false)
			this.deactivate();

		// run each of the action classes and then return reult
    for(String actionClass :actionsClasses) {
  		Boolean success = runAction(actionClass, qualifiedRecords);
  		if(success)
  			result.SuccessActions.add(actionClass);
  	}
  	return result;
	}

	/** Set up the criteria context for the MicroTrigger.  Implemented by subclasses like TriggerBeforeInsert */
	protected abstract List<SObject> runCriteria(String criteriaClass);

	/** Set up the action context for the MicroTrigger.  Implemented by subclasses like TriggerBeforeInsert */
	protected abstract Boolean runAction(String actionClass, List<SObject> qualifiedRecords);
}