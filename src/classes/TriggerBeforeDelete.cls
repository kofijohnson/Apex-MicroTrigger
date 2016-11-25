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
 * TriggerBeforeDelete
 * @Description: Trigger Before Delete Namespace.
 *               It contains classes Criteria, Action, Context.
 * @Author: Kofi Johnson - https://github.com/kofijohnson
 */

public class TriggerBeforeDelete {

    /**
     * This interface is implemented to create a criteria for this trigger context
     */
    public interface Criteria {
        /**
         * Run the criteria method, given a currentContext Context object. Return SObjects which have met criteria
         * @param currentContext the current trigger context
         * @return a lis tof SObjects which pass this criteria
         */
        List<SObject> run(TriggerBeforeDelete.Context currentContext);
    }

    /**
     * This interface is implemented to create an action for this trigger context
     */
    public interface Action {
        /**
         * Run the action method, given a currentContext Context object, and a list of objects matching microtrigger criteria.
         * @param currentContext the current trigger context
         * @param scope a list of SObjects which have met criteria for the microtrigger
         * @return Boolean indicating whether action completed successfully
         */
        Boolean run(TriggerBeforeDelete.Context currentContext, List<SObject> scope);
    }

    /**
     * The Trigger Context class for this trigger context. Values from the Trigger global variable are
     * copied into an instance of this class, which is then made available to Criteria and Action interface implementors
     */
    public class Context {

        /** True if this Trigger is executing */
        public Boolean isExecuting    {get; private set;}

        /** List from Trigger.old */
        public List<SObject> oldList  {get; private set;}

        /** List from Trigger.oldMap */
        public Map<Id,SObject> oldMap {get; private set;}

        /** From Trigger.size */
        public Integer size           {get; private set;}

        /**
         * Set up this context from the global Trigger var
         */
        public Context() {
            isExecuting = Trigger.isExecuting;
            oldList     = Trigger.old;
            oldMap      = Trigger.oldMap;
            size        = Trigger.size;
        }
    }

    /**
     * MicroTrigger class implementation for the BaseMicroTrigger within a before delete context. Creates and
     * passes the appropriate Context object to the criteria and actions for this MicroTrigger
     */
    public class MicroTrigger extends BaseMicroTrigger {

        /**
         * Class constructor.  Instantiate a microtrigger using the given developer and sobject names
         * @param microTriggereveloperName the developer name for this microtrigger
         * @param microTriggerSObjectName the SObject type for this microtrigger
         */
        public MicroTrigger(String microTriggereveloperName, String microTriggerSObjectName) {
            super(microTriggereveloperName, microTriggerSObjectName);
        }

        /**
         * Runs the criteria class for this microtrigger.  Instantiates a context object, a criteria object, and
         * executes the criteria object, passing in the context object. 
         * @param criteriaClass the name of the criteria class to execute
         * @return a list of SObjects which have met the criteria
         */
        protected override List<SObject> runCriteria(String criteriaClass) {
            TriggerBeforeDelete.Context currentContext   = new TriggerBeforeDelete.Context();
            TriggerBeforeDelete.Criteria currentCriteria = (TriggerBeforeDelete.Criteria)Type.forName(criteriaClass).newInstance();
            return currentCriteria.run(currentContext);
        }

        /**
         * Runs a given action class with a given list of SObjects and returns true if successful.
         * Instantiates a context object, a action object, and executes the action object, passing in the context object and list of SObjects.  
         * @param actionClass the class name of the action class
         * @param qualifiedRecords a list of SObjects which have met criteria for this microtrigger
         * @return True if the action class ran successfully
         */
        protected override Boolean runAction(String actionClass, List<SObject> qualifiedRecords) {
            TriggerBeforeDelete.Context currentContext   = new TriggerBeforeDelete.Context();
            TriggerBeforeDelete.Action currentAction = (TriggerBeforeDelete.Action)Type.forName(actionClass).newInstance();
            return currentAction.run(currentContext, qualifiedRecords);
        }
    }
}