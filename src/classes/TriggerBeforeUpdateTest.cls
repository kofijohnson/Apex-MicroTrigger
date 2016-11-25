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
 * TriggerBeforeUpdateTest
 * @Description: Test for MicroTrigger Before Update Namespace Classes.
 * @Author: Kofi Johnson - https://github.com/kofijohnson
 */

@isTest
private class TriggerBeforeUpdateTest {
	private static final String VALID_CRITERIA   = 'TEST RECORD';
	private static final String INVALID_CRITERIA = 'NOT TEST RECORD';

	@isTest static void testMockMicroTriggerWithValidCriteria() {
		// MicroTrigger configuration.
		// Add the Criteria class and the Action class to run.
		BaseMicroTrigger microTrigger = new TriggerBeforeUpdate.MicroTrigger('TriggerBeforeUpdateTestMicroTrigger', 'MicroTriggerTestingMock__c');
		microTrigger.setCriteria('TriggerBeforeUpdateTest.MockCriteria')
					.addAction('TriggerBeforeUpdateTest.MockAction')
					.allowRecursive()
					.activate();

		// Then we pass the MicroTrigger to the MicroTriggerLoader.
		// This will make the Loader to discard any load from Custom Metadata Type
		// and load only the TriggerBeforeUpdateTestMicroTrigger.
		MicroTriggersLoader.microTriggerMocks = new List<BaseMicroTrigger>{microTrigger};

		// Test the MicroTrigger by inserting a record that does not meet the Criteria
		MicroTriggerTestingMock__c microTriggerSObjectMock = new MicroTriggerTestingMock__c(
			Name = INVALID_CRITERIA
		);
		insert microTriggerSObjectMock;
		// Then update it to meet the criteria.
		// The record will meet the criteria, because we update the Name field to a valid value
		microTriggerSObjectMock.Name = VALID_CRITERIA;
		update microTriggerSObjectMock;

		// Make sure that the MicroTrigger run, by getting the execution result from the Dispatcher.
		List<MicroTriggerResult> executionResults = MicroTriggersDispatcher.ExecutionResults;
		System.assertEquals(1, executionResults.size(), 'Only 1 MicroTrigger (TriggerBeforeUpdateTestMicroTrigger) should run ');
		// Because the record we updated (microTriggerSObjectMock) meets the Criteria, "CriteriaIsMet" will be equal to "true"
		System.assert(executionResults[0].CriteriaIsMet, 'TriggerBeforeUpdateTestMicroTrigger Criteria (MockCriteria) should be met');
		System.assertEquals(1, executionResults[0].SuccessActions.size(), 'TriggerBeforeUpdateTestMicroTrigger Action (MockAction) should have run');
		System.assertEquals('TriggerBeforeUpdateTest.MockAction', executionResults[0].SuccessActions[0], 'TriggerBeforeUpdateTestMicroTrigger Action should have run');
		
		// Check if the record is updated
		List<MicroTriggerTestingMock__c> updatedRecord = [
			SELECT Name FROM MicroTriggerTestingMock__c
			WHERE Id = :microTriggerSObjectMock.Id
		];
		System.assertEquals(1, updatedRecord.size(),'The new created record should exist');
		System.assertEquals(microTriggerSObjectMock.Name + ' (UPDATED)', updatedRecord[0].Name, 'The new record Name should have " (UPDATED)" appended');
	}

	@isTest static void testMockMicroTriggerWithInvalidCriteria() {
		// MicroTrigger configuration.
		// Add the Criteria class and the Action class to run. 
		BaseMicroTrigger microTrigger = new TriggerBeforeUpdate.MicroTrigger('TriggerBeforeUpdateTestMicroTrigger', 'MicroTriggerTestingMock__c');
		microTrigger.setCriteria('TriggerBeforeUpdateTest.MockCriteria')
					.addAction('TriggerBeforeUpdateTest.MockAction')
					.allowRecursive()
					.activate();

		// Then we pass the MicroTrigger to the MicroTriggerLoader.
		// This will make the Loader to discard any load from Custom Metadata Type
		// and load only the TriggerBeforeUpdateTestMicroTrigger.
		MicroTriggersLoader.microTriggerMocks = new List<BaseMicroTrigger>{microTrigger};

		// Test the MicroTrigger by inserting a record that meets the Criteria
		MicroTriggerTestingMock__c microTriggerSObjectMock = new MicroTriggerTestingMock__c(
			Name = VALID_CRITERIA
		);
		insert microTriggerSObjectMock;
		// Then update it to NOT meet the criteria.
		microTriggerSObjectMock.Name = INVALID_CRITERIA;
		update microTriggerSObjectMock;

		// Get the execution result from the Dispatcher.
		List<MicroTriggerResult> executionResults = MicroTriggersDispatcher.ExecutionResults;
		// Check that the MicroTrigger run (when it runs, it should have a MicroTriggerResult)
		System.assertEquals(1, executionResults.size(), 'Only 1 MicroTrigger (TriggerBeforeUpdateTestMicroTrigger) should run ');
		// Because the record we inserted (microTriggerSObjectMock) does not meet the Criteria, "CriteriaIsMet" will be equal to "false"
		System.assertEquals(false, executionResults[0].CriteriaIsMet, 'TriggerBeforeUpdateTestMicroTrigger Criteria (MockCriteria) should NOT be met');
		System.assertEquals(0, executionResults[0].SuccessActions.size(), 'Since the Criteria is not met, no Action should have run');

		// Check if the record is updated
		List<MicroTriggerTestingMock__c> updatedRecord = [
			SELECT Name FROM MicroTriggerTestingMock__c
			WHERE Id = :microTriggerSObjectMock.Id
		];
		System.assertEquals(1, updatedRecord.size(),'The new created record should exist');
		System.assertEquals(microTriggerSObjectMock.Name, updatedRecord[0].Name, 'The name should not be updated, because the Criteria is not met');
	}

	@isTest static void testMicroTriggerWithValidCriteria() {
		MicroTriggersLoader loader = MicroTriggersLoader.getInstance();
		if(loader.contains('TriggerBeforeUpdateTestMicroTrigger') == false ||
			loader.getMicroTrigger('TriggerBeforeUpdateTestMicroTrigger').containsAction('TriggerBeforeUpdateTest.MockAction') == false)
			return;

		// Load and Disable All MicroTriggers except the "TriggerBeforeUpdateTestMicroTrigger".
		for(BaseMicroTrigger currentMicroTrigger :loader.getMicroTriggers()) {
			if(currentMicroTrigger.DeveloperName != 'TriggerBeforeUpdateTestMicroTrigger')
				currentMicroTrigger.deactivate();
		}

		// Test the MicroTrigger by inserting a record that does not meet the Criteria
		MicroTriggerTestingMock__c microTriggerSObjectMock = new MicroTriggerTestingMock__c(
			Name = INVALID_CRITERIA
		);
		insert microTriggerSObjectMock;
		// Then update it to meet the criteria.
		// The record will meet the criteria, because we update the Name field to a valid value
		microTriggerSObjectMock.Name = VALID_CRITERIA;
		update microTriggerSObjectMock;

		// Make sure that the MicroTrigger run, by getting the execution result from the Dispatcher.
		List<MicroTriggerResult> executionResults = MicroTriggersDispatcher.ExecutionResults;
		System.assertEquals(1, executionResults.size(), 'Only 1 MicroTrigger (TriggerBeforeUpdateTestMicroTrigger) should run ');
		// Because the record we updated (microTriggerSObjectMock) meets the Criteria, "CriteriaIsMet" will be equal to "true"
		System.assert(executionResults[0].CriteriaIsMet, 'TriggerBeforeUpdateTestMicroTrigger Criteria (MockCriteria) should be met');
		System.assertEquals(1, executionResults[0].SuccessActions.size(), 'TriggerBeforeUpdateTestMicroTrigger Action (MockAction) should have run');
		System.assertEquals('TriggerBeforeUpdateTest.MockAction', executionResults[0].SuccessActions[0], 'TriggerBeforeUpdateTestMicroTrigger Action should have run');
		
		// Check if the record is updated
		List<MicroTriggerTestingMock__c> updatedRecord = [
			SELECT Name FROM MicroTriggerTestingMock__c
			WHERE Id = :microTriggerSObjectMock.Id
		];
		System.assertEquals(1, updatedRecord.size(),'The new created record should exist');
		System.assertEquals(microTriggerSObjectMock.Name + ' (UPDATED)', updatedRecord[0].Name, 'The new record Name should have " (UPDATED)" appended');
	}
	
    /****************************************************** Criteria Class for this Test Class. ****************************************/

    // The MockCriteria filters the inserted records to get only the records
    // that have the Name equal to VALID_CRITERIA (TEST RECORD)

	public class MockCriteria implements TriggerBeforeUpdate.Criteria {
	    public List<MicroTriggerTestingMock__c> run(TriggerBeforeUpdate.Context context) {
	        List<MicroTriggerTestingMock__c> qualifiedRecords = new List<MicroTriggerTestingMock__c>();
	        for(MicroTriggerTestingMock__c newRecord :(List<MicroTriggerTestingMock__c>) context.newList) {
	        	MicroTriggerTestingMock__c oldRecord = ((Map<Id, MicroTriggerTestingMock__c>) context.oldMap).get(newRecord.Id);    
	            if(oldRecord.Name == INVALID_CRITERIA && newRecord.Name == VALID_CRITERIA)          
	                qualifiedRecords.add(newRecord);
	        }
	        return qualifiedRecords;
	    }
	}
	
	/****************************************************** Action Class for this Test Class. ****************************************/

    // MockAction takes all the records that have Name equal to VALID_CRITERIA (from the MockCriteria)
    // and updates their Name field by appending (UPDATED)

	public class MockAction implements TriggerBeforeUpdate.Action {
		public Boolean run(TriggerBeforeUpdate.Context context, List<MicroTriggerTestingMock__c> scope) {
	        for(MicroTriggerTestingMock__c currentMicroTriggerTestingMock :scope) {
	        	currentMicroTriggerTestingMock.Name += ' (UPDATED)';
	        }
	        return true;
	    }
	}
}