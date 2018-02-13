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
* @Description: Trigger After Delete Namespace.
*               It contains classes Criteria, Action, Context.
* @Author: Kofi Johnson - https://github.com/kofijohnson
********************************************************************************************************/

public class TriggerAfterDelete {

    /*******************************************************************************************************
    * @descripton The interface to implement in order to create a criteria for the After Delete Trigger.
    ********************************************************************************************************/
    public interface Criteria {
        
        /*******************************************************************************************************
        * @description Runs the criteria method, given the After Delete context.
        * And returns the SObjects that meet the criteria.
        * @param Context The After Delete context.
        * @return List<SObject> List of SObjects which have met this criteria.
        ********************************************************************************************************/
        List<SObject> run(Context currentContext);
    }

    /*******************************************************************************************************
    * @descripton This interface is implemented to create an action for this trigger context.
    ********************************************************************************************************/
    public interface Action {
        
        /*******************************************************************************************************
        * @description Runs the action method, given the After Delete context.
        * @param Context The After Delete context.
        * @param List<SObject> A List of SObjects that met the criteria for the microtrigger.
        * @return Boolean indicating whether the action completed successfully.
        ********************************************************************************************************/
        Boolean run(Context currentContext, List<SObject> scope);
    }

    /*******************************************************************************************************
    * @descripton The After Delete Trigger Context. The values from the System.Trigger are copied into an 
    * an instance of this class, then it is available to the Criterias and Actions.
    ********************************************************************************************************/
    public class Context {

        public Boolean isExecuting {get; private set;}
        public List<SObject> oldList {get; private set;}
        public Map<Id,SObject> oldMap {get; private set;}
        public Integer size {get; private set;}

        /*******************************************************************************************************
        * @description After Delete Context Constructor.
        ********************************************************************************************************/
        public Context() {
            isExecuting = Trigger.isExecuting;
            oldList = Trigger.old;
            oldMap = Trigger.oldMap;
            size = Trigger.size;
        }
    }

    /*******************************************************************************************************
    * @description After Delete MicroTrigger class implementation.
    ********************************************************************************************************/
    public class MicroTrigger extends BaseMicroTrigger {

        /*******************************************************************************************************
        * Class constructor. Instantiates the After Delete Microtrigger using it developer and SObject name
        * @param String the developer name for this Microtrigger.
        * @param String the SObject type for this Microtrigger.
        ********************************************************************************************************/
        public MicroTrigger(String microTriggereveloperName, String microTriggerSObjectName) {
            super(microTriggereveloperName, microTriggerSObjectName);
        }

        /*******************************************************************************************************
        * @description Runs the criteria class for this Microtrigger. Instantiates the After Delete Context,
        * a criteria object, and executes the criteria object by passing in the context object. 
        * @param String the name of the criteria class to execute.
        * @return List<SObject> List of SObjects which have met the criteria.
        ********************************************************************************************************/
        protected override List<SObject> runCriteria(String criteriaClass) {
            Context currentContext = new Context();
            Criteria currentCriteria = (Criteria) Type.forName(criteriaClass).newInstance();
            return currentCriteria.run(currentContext);
        }

        /*******************************************************************************************************
        * @description Runs a given action class with a given list of SObjects and returns true if successful.
        * Instantiates the After Delete Context, the Action, and executes the Action by passing in the Context
        * and list of SObjects.  
        * @param String The class name of the action class.
        * @param List<SObject> A List of SObjects which have met criteria for this Microtrigger.
        * @return Boolean True if the action class ran successfully.
        ********************************************************************************************************/
        protected override Boolean runAction(String actionClass, List<SObject> qualifiedRecords) {
            Context currentContext = new Context();
            Action currentAction = (Action) Type.forName(actionClass).newInstance();
            return currentAction.run(currentContext, qualifiedRecords);
        }
    }
}