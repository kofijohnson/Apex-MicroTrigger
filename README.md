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

A Trigger framework for creating and managing Apex Triggers that uses microservice concepts and a mixture of programmatic and declarative tools for Trigger creation, assembly, and management.

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
3. A programmer writes the Action object(s) necessary to implement the Tigger’s Tctions,
4. An administrator/developer creates a MicroTrigger custom metadata record, and specifies the context, target object type, and criteria/action class names that implement the Trigger’s functionality.

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

To create a Criteria, implement the Criteria interface for the Trigger execution context that the criteria will be operating within. Available trigger execution contexts include:

* TriggerBeforeInsert (before insert)
* TriggerBeforeUpdate (before update)
* TriggerBeforeDelete (before delete)
* TriggerAfterInsert (after insert)
* TriggerAfterUpdate (after update)
* TriggerAfterDelete (after delete)
* TriggerAfterDelete (after delete)

Example: Implement a Criteria on Before Update, which selects accounts whose OwnerId’s have just changed:

```apex
/********************************************************************************************************
* @description Criteria Object on TriggerBeforeUpdate that will be used in a
* Before Update context to find Accounts whose OwnerIds changed.
********************************************************************************************************/
public class AccountOwnerChangedCriteria implements TriggerBeforeUpdate.Criteria {

    /*******************************************************************************************************
    * @description The single method in the Criteria Interface to implement.
    * Return a list of records which match the desired criteria, given the Trigger Context object.
    * @param TriggerBeforeUpdate.Context The Before Update Trigger Context.
    * @return List<SObject> The list of the records which match the criteria. In this case, the list of 
    * accounts whose Owner have changed.
    ********************************************************************************************************/
    public List<SObject> run(TriggerBeforeUpdate.Context currentContext) {
        List<Account> accounts = new List<Account>();
 
        // Iterate through all changed records, and add accounts
        // whose ownerid's have just changed to the result list
        for(Account newAccount : (List<Account>) currentContext.newList) {
            Account oldAccount = (Account) currentContext.oldMap.get(newAccount.Id);
            if(newAccount.OwnerId != oldAccount.OwnerId) {
                accounts.add(newAccount);
            }
        }
        // return the list of records which have fulfilled the criteria.
        return accounts;
    }
}
```
<a name="Creating-Actions">

## Creating Action

To create the Action, implement the Action interface for the Trigger execution context that the Action will be operating within.

Example: Implement an Action on Before Update which sets the OwnerId of all Contact records associated with an Account to the Account’s OwnerId

```apex
/*******************************************************************************************************
* @description Action Object on TriggerBeforeUpdate that will be used in a
* Before Update context to update the description field of the  Accounts 
* whose OwnerIds changed.
********************************************************************************************************/
public class AccountTrackPreviousOwnerAction implements TriggerBeforeUpdate.Action {

    /*******************************************************************************************************
    * @description The single method in the Action Interface to implement.
    * @param TriggerBeforeUpdate.Context. The Before Update Trigger Context.
    * @param List<SObject>. List<SObject> The list of the records which match the criteria. 
    * In this case, the list of accounts whose Owner have changed.
    * @return Boolean. A flag that tells if the Action runs successfull or not.
    ********************************************************************************************************/
    public Boolean run(TriggerBeforeUpdate.Context currentContext, List<SObject> scope) {
        // Get the accounts owners.
        Set<Id> userIds = new Set<Id>();
        for (Account newAccount : (List<Account>) scope) {
            Account oldAccount = (Account) currentContext.oldMap.get(newAccount.Id);
            userIds.add(oldAccount.OwnerId);
        }
        Map<Id,User> accountsOwners = new Map<Id,User>([
            SELECT Id, FirstName, LastName 
            FROM User WHERE Id IN :userIds
        ]);
        
        // Track the previous owner on the account's description.
        for(Account newAccount : (List<Account>) scope) {
            Account oldAccount = (Account) currentContext.oldMap.get(newAccount.Id);
            User oldOwner = accountsOwners.get(oldAccount.OwnerId);
            newAccount.Description = 'Previous Owner: ' + oldOwner.FirstName + ' ' + oldOwner.LastName;
        }

        // Return true to tell the Framework that the logic runs successfully.
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

When the MicroTriggers run (after a DML), the framework provides a report of all the MicroTriggers that run during the transaction. Below is a code sample to get the execution report.

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
2. Custom MicroTrigger edit VisualForce page. The standard Custom Metadata pages are clunky. A better UI for the management of MicroTriggers is needed.
3. Automatic creation of Apex Trigger using Metadata API. Use the Salesforce Metadata API to automatically create and install the base triggers needed for the framework to function.


