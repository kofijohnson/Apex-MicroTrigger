## Table of Contents

- [Apex-Microtrigger](#Apex-Microtrigger)
	- [What is it?](#What-is-it)
	- [Installing the Framework in your organization](#Installing-the-Framework-in-your-organization)
- [How do I create a MicroTrigger?](#How-do-I-create-a-MicroTrigger)
    - [Creating Base Triggers](#Create-Base-Triggers)
	- [Creating Criterias](#Creating-Criterias)
	- [Creating Actions](#Creating-Actions)
	- [Creating the MicroTrigger Metadata Definition](#Creating-the-MicroTrigger-Metadata-Definition)
- [How do I manage the MicroTriggers?](#How-do-I-manage-the-MicroTriggers)
	- [Controling the MicroTriggers](#Controling-the-MicroTriggers)
	- [Getting the MicroTrigger Execution Report](#Getting-the-MicroTrigger-Execution-Report)
- [Author and Contributors](#Author-and-Contributors)
- [Development Roadmap](#Development-Roadmap)

<a name="Apex-Microtrigger">

# Apex-Microtrigger

<a name="What-is-it">

## What is it?

A trigger framework for creating and managing Apex triggers that uses microservice concepts and a mixture of programmatic and declarative tools for trigger creation, assembly, and management.

This framework introduces the concept of a ‘MicroTrigger’.  A MicroTrigger is a declaratively-assembled component, much like a Workflow, which operates on an object in Salesforce when that object is affected. MicroTriggers are composed of a single Criteria object and a list of Action objects, chained together declaratively within the MicroTrigger metadata definition.

Like a workflow, a MicroTrigger operates against an object type, in a specific execution context (when a record is inserted, updated, deleted, or undeleted) and is composed of a Criteria and a set of Actions which are performed against a set of records matching that criteria.  

Unlike Workflows, MicroTrigger Criteria and Actions are programmatically built by developers, by implementing a Criteria interface for criterias, and an Action interface for actions.  

<a name="Installing-the-Framework-in-your-organization">

## Installing the Framework in your Scratch Org

MicroTrigger Framework can be deployed by clicking this button.

[![Deploy](https://deploy-to-sfdx.com/dist/assets/images/DeployToSFDX.svg)](https://deploy-to-sfdx.com/)

<a name="How-do-I-create-a-MicroTrigger">

# How do I create a MicroTrigger?

There are three basic steps to creating a microtrigger:

1. A programmer creates the base Trigger that will support the framework concepts,
2. A programmer writes a Criteria object implementing the trigger criteria,
3. A programmer writes the action object(s) necessary to implement the trigger’s actions,
4. An administrator creates a MicroTrigger custom metadata record, and specifies the context, target object type, and criteria/action class names that implement the trigger’s functionality.

<a name="Create-Base-Triggers">

## Create Base Triggers

This part is a manual process that requires creating the base Trigger for the object being used by the framework. The code below is a template regarding how to setup your Trigger. 

```Apex

trigger AccountMicroTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    MicroTriggersDispatcher dispatcher = new MicroTriggersDispatcher();
    dispatcher.dispatch('AccountMicroTrigger');
}
```

<a name="Creating-Criterias">

## Creating Criterias

To create a criteria, implement the Criteria interface for the Trigger execution context that the criteria will be operating within. Available trigger execution contexts include:

* TriggerBeforeInsert (before insert)
* TriggerBeforeUpdate (before update)
* TriggerBeforeDelete (before delete)
* TriggerAfterInsert (after insert)
* TriggerAfterUpdate (after update)
* TriggerAfterDelete (after delete)
* TriggerAfterDelete (after delete)

Example: Implement a Criteria on before update, which selects accounts whose OwnerId’s have just changed:

```apex
/**
 * Implement Criteria object on TriggerBeforeUpdate to create a criteria that
 * will be used in a before update context to find Accounts whose OwnerIds changed
 */
public class AccountOwnerIdChangedCritera implements TriggerBeforeUpdate.Criteria {
    /**
     * The single method in the Criteria interface to implement. Return a list of
     * objects which match the desired criteria, given the trigger context object
     */
    public List<SObject> run(TriggerBeforeUpdate.Context currentContext) {
        List<Account> resultList = new List<Account>();
 
        // iterate through all changed records, and add accounts
        // whose ownerid's have just changed to the result list
        for(SObject newObject : currentContext.newList) {
            Account newAccount = (Account) newObject;
            Account oldAccount = (Account) currentContext.oldMap.get(newAccount.Id);
            if(newAccount.OwnerId != oldAccount.OwnerId) {
                resultList.add(newAccount);
            }
        }
        // return list of objects which have fulfilled the criteria
        return resultList;
    }
}
```
<a name="Creating-Actions">

## Creating Actions

To create a criteria, implement the Criteria interface for the Trigger execution context that the criteria will be operating within.   Available trigger execution contexts are the same as criteria.

Example: Implement an action on before update which sets the OwnerId of all Contact records associated with an Account to the Account’s OwnerId

```apex
/**
 * implement Action object on TriggerBeforeUpdate which sets the OwnerId
 * of all Contact records associated with an Account to the Account's OwnerId
 */
public class ContactsChangeOwnerIdAction implements TriggerBeforeUpdate.Action {
    /**
     * The single method in the Criteria interface to implement. Provides a trigger
     * context and a list of SObjects which matched the MicroTrigger criteria.
     * Returns true if action has been completed successfully
     */
    public Boolean run(TriggerBeforeUpdate.Context currentContext, List<SObject> scope) {
        Set<Id> accountIds = (new Map<Id,SObject>(scope)).keySet();
        // query for contacts with given account id's
        List<Contact> allTheContacts = [
            SELECT AccountId from Contact where AccountId in :accountIds
        ];

        // change contact ownerid's to account's ownerid
        for(SObject theObject : scope) {
            Account theAccount = (Account) theObject;
            for(Contact theContact : allTheContacts) {
                if(theAccount.Id == theContact.AccountId) {
                    theContact.OwnerId = theAccount.OwnerId;
                }
            }
        }

        // try to update contacts. If fail, print error to debug log and return false
        try {
            update allTheContacts;
        } catch (Exception e) {
            System.assert(false,e);
            return false;
        }   

        // if we got here everything worked so return true
        return true;
    }
}
```

<a name="Creating-the-MicroTrigger-Metadata-Definition">

## Creating the MicroTrigger Metadata Definition

Once you have your Criteria and your Action(s) implemented, it’s time to create the MicroTrigger metadata definition. The MicroTrigger metadata definition is the declarative ‘glue’ that binds the Criteria and Action(s) together and executes them when a record of your target object type is affected.

To create a MicroTrigger metadata definition:

1. Login into your Salesforce organization, and click on ‘Setup’ in the upper right hand corner of the screen.  
2. In the ‘quick find/search’ text input in the left sidebar, type in ‘custom metadata’ and click on ‘Custom Metadata Types
3. Click on the ‘Manage Records’ link for the ‘MicroTrigger’ metadata type
4. Click on the ‘New’ button to create a new MicroTrigger metadata type record
5. Give your MicroTrigger a name by entering it in the ‘Label’ field (MicroTrigger Name should be unique)
6. Give your MicroTrigger an optional description
7. Select the target object type that you’d like your MicroTrigger to operate against using the ‘SObject’ picklist
8. Select the trigger execution context you want your trigger to function within using the ‘Event’ picklist
9. Enter the name of the criteria class which will be used for this MicroTrigger in the ‘Criteria’ field
10. Enter a value of ‘1’ for the ‘Order of Execution’ field
11. Click the Save button to save your MicroTrigger definition
12. Repeat steps 2-3 above, but this time, click on ‘Manage Records’ next to ‘MicroTrigger Action’
13. For each action you’d like to assign to your MicroTrigger, repeat the following steps:
    1. Click ‘New’ to create a new MicroTrigger Action
    2. Enter a descriptive label for the action (MicroTrigger Action Name will be automatically populated)
    3. Select your newly-created MicroTrigger from the MicroTrigger lookup field
    4. Select the order of execution for this action by populating the Order of Execution field: If this is the first action, then add a ‘1’ in this field (The Order of execution field drives the order in which actions are executed)
    5. Check the ‘active’ checkbox to make this action active
    6. Enter the name of the Apex class that implements the action in the ‘Apex Class’ field
    7. Save the action
14. Once you’ve created the actions for your MicroTrigger, it’s time to activate it. Repeat steps 2-3, click on ‘Manage Records’ for the ‘MicroTrigger’ metadata type, and click on the MicroTrigger record you just created.  Edit the record, check the ‘active’ checkbox and save the record.
15. Congratulations - you’ve just created a MicroTrigger!

<a name="How-do-I-manage-the-MicroTriggers">

# How do I manage the MicroTriggers ?

Business process changes. The framework gives you the ability to deactivate and change the order of the execution of the MicroTriggers or Actions of a MicroTriggers. It also gives an execution report of the MicroTriggers that run in a specific transaction.

<a name="Controling-the-MicroTriggers">

## Controling the MicroTriggers

To control a MicroTrigger or Action:

1. Login into your Salesforce organization, and click on ‘Setup’ in the upper right hand corner of the screen
2. In the ‘quick find/search’ text input in the left sidebar, type in ‘custom metadata’ and click on ‘Custom Metadata Types
3. Click on the ‘Manage Records’ link for the ‘MicroTrigger’ metadata type
4. Click the MicroTrigger you want to update
5. Change the "Order of Execution" or "Active" field
6. In the "MicroTrigger Actions" related list, click the Action you want to update
7. Change the "Order of Execution" or "Active" field

<a name="Getting-the-MicroTrigger-Execution-Report">

## Getting the MicroTrigger Execution Report

When the MicroTriggers run (after a DML), the framework provides a report of all the MicroTriggers that run during the Transaction. Below is a code sample to get the execution report.

//Get the execution results from the Dispatcher.
List<MicroTriggerResult> executionResults = MicroTriggersDispatcher.ExecutionResults;

```apex
//Print each MicroTrigger Result
for(MicroTriggerResult microTriggerResult :executionResults) {
    System.debug('******************** MicroTrigger Execution ************************');
    System.debug('MicroTrigger Name = ' + microTriggerResult.MicroTriggerName);
    System.debug('Criteria Is Met = ' + microTriggerResult.CriteriaIsMet);
    
    //Print all the success Actions
    for(String successAction :microTriggerResult.SuccessActions)
    	System.debug('Success Action = ' + successAction);
}
```

<a name="Author-and-Contributors">

# Author and Contributors

Author: [Kofi Johnson](https://github.com/kofijohnson)

Contributor : [Sebastian Schepis] (https://github.com/sschepis)

<a name="Development-Roadmap">

# Development Roadmap

The following enhancements make up our immediate development roadmap.  If you have other features that you'd like to see placed on the roadmap, please contact us.

1. 'Log execution' checkbox for MicroTrigger. When this flag is set to true, all invocation and execution of the MicroTrigger is logged to the system debug log.
2. Custom MicroTrigger edit VisualForce page.  The standard Custom Metadata pages are clunky. A better UI for the management of MicroTriggers is needed.
3. Automatic creation of Apex Trigger using Metadata API.  Use the Salesforce Metadata API to automatically create and install the base triggers needed for the framework to function.


