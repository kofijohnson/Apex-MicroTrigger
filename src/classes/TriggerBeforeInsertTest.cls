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
 * TriggerBeforeInsertTest
 * @Description: Test for MicroTrigger Before Insert Namespace Classes.
 * @Author: Kofi Johnson - https://github.com/kofijohnson
 */

@isTest
private class TriggerBeforeInsertTest {
	private static final String VALID_CRITERIA   = 'TEST RECORD';
	private static final String INVALID_CRITERIA = 'NOT TEST RECORD';

	@isTest static void testMockMicroTriggerWithValidCriteria() {
		// MicroTrigger configuration.
		// Add the Criteria class and the Action class to run.
		BaseMicroTrigger microTrigger = new TriggerBeforeInsert.MicroTrigger('TriggerBeforeInsertTestMicroTrigger', 'MicroTriggerTestingMock__c');
		microTrigger.setCriteria('TriggerBeforeInsertTest.MockCriteria')
					.addAction('TriggerBeforeInsertTest.MockAction')
					.allowRecursive()
					.activate();

		// Then we pass the MicroTrigger to the MicroTriggerLoader.
		// This will make the Loader to discard any load from Custom Metadata Type
		// and load only the TriggerBeforeInsertTestMicroTrigger.
		MicroTriggersLoader.microTriggerMocks = new List<BaseMicroTrigger>{microTrigger};

		// Test the MicroTrigger by inserting a record that will meet the Criteria.
		MicroTriggerTestingMock__c microTriggerSObjectMock = new MicroTriggerTestingMock__c(
			Name = VALID_CRITERIA
		);
		insert microTriggerSObjectMock;

		// Make sure that the MicroTrigger run, by getting the execution result from the Dispatcher.
		List<MicroTriggerResult> executionResults = MicroTriggersDispatcher.ExecutionResults;
		System.assertEquals(1, executionResults.size(), 'Only 1 MicroTrigger (TriggerBeforeInsertTestMicroTrigger) should run ');
		// Because the record we inserted (microTriggerSObjectMock) meets the Criteria, "CriteriaIsMet" will be equal to "true"
		System.assert(executionResults[0].CriteriaIsMet, 'TriggerBeforeInsertTestMicroTrigger Criteria (MockCriteria) should be met');
		System.assertEquals(1, executionResults[0].SuccessActions.size(), 'TriggerBeforeInsertTestMicroTrigger Action (MockAction) should have run');
		System.assertEquals('TriggerBeforeInsertTest.MockAction', executionResults[0].SuccessActions[0], 'TriggerBeforeInsertTestMicroTrigger Action should have run');
		
		// Check if the new record's Name is updated
		List<MicroTriggerTestingMock__c> createdRecord = [
			SELECT Name FROM MicroTriggerTestingMock__c
			WHERE Id = :microTriggerSObjectMock.Id
		];
		System.assertEquals(1, createdRecord.size(),'The new created record should exist');
		System.assertEquals(microTriggerSObjectMock.Name + ' (NEW RECORD)', createdRecord[0].Name, 'The new record Name should have " (NEW RECORD)" appended');
	}

	@isTest static void testMockMicroTriggerWithInvalidCriteria() {
		// MicroTrigger configuration.
		// Add the Criteria class and the Action class to run. 
		BaseMicroTrigger microTrigger = new TriggerBeforeInsert.MicroTrigger('TriggerBeforeInsertTestMicroTrigger', 'MicroTriggerTestingMock__c');
		microTrigger.setCriteria('TriggerBeforeInsertTest.MockCriteria')
					.addAction('TriggerBeforeInsertTest.MockAction')
					.allowRecursive()
					.activate();

		// Then we pass the MicroTrigger to the MicroTriggerLoader.
		// This will make the Loader to discard any load from Custom Metadata Type
		// and loads only the TriggerBeforeInsertTestMicroTrigger.
		MicroTriggersLoader.microTriggerMocks = new List<BaseMicroTrigger>{microTrigger};

		// Test the MicroTrigger by inserting a record that will NOT meet the Criteria.
		MicroTriggerTestingMock__c microTriggerSObjectMock = new MicroTriggerTestingMock__c(
			Name = INVALID_CRITERIA
		);
		insert microTriggerSObjectMock;

		// Getting the execution result from the Dispatcher.
		List<MicroTriggerResult> executionResults = MicroTriggersDispatcher.ExecutionResults;
		// Check that the MicroTrigger run (when it runs, it should have a MicroTriggerResult)
		System.assertEquals(1, executionResults.size(), 'Only 1 MicroTrigger (TriggerBeforeInsertTestMicroTrigger) should run ');
		// Because the record we inserted (microTriggerSObjectMock) does not meet the Criteria, "CriteriaIsMet" will be equal to "false"
		System.assertEquals(false, executionResults[0].CriteriaIsMet, 'TriggerBeforeInsertTestMicroTrigger Criteria (MockCriteria) should NOT be met');
		System.assertEquals(0, executionResults[0].SuccessActions.size(), 'Since the Criteria is not met, no Action should have run');

		// Check if a new record is created
		List<MicroTriggerTestingMock__c> createdRecord = [
			SELECT Name FROM MicroTriggerTestingMock__c
			WHERE Id = :microTriggerSObjectMock.Id
		];
		// No new record's Name is updated
		System.assertEquals(1, createdRecord.size(),'The new created record should exist');
		System.assertEquals(microTriggerSObjectMock.Name, createdRecord[0].Name, 'The name should not be updated, because the Criteria is not met');
	}

	@isTest static void testMicroTriggerWithValidCriteria() {
		MicroTriggersLoader loader = MicroTriggersLoader.getInstance();
		if(loader.contains('TriggerBeforeInsertTestMicroTrigger') == false ||
			loader.getMicroTrigger('TriggerBeforeInsertTestMicroTrigger').containsAction('TriggerBeforeInsertTest.MockAction') == false)
			return;

		// Load and Disable All MicroTriggers except the "TriggerBeforeInsertTestMicroTrigger".
		for(BaseMicroTrigger currentMicroTrigger :loader.getMicroTriggers()) {
			if(currentMicroTrigger.DeveloperName != 'TriggerBeforeInsertTestMicroTrigger')
				currentMicroTrigger.deactivate();
		}

		// Test the MicroTrigger by inserting a record that will meet the Criteria.
		MicroTriggerTestingMock__c microTriggerSObjectMock = new MicroTriggerTestingMock__c(
			Name = VALID_CRITERIA
		);
		insert microTriggerSObjectMock;

		// Make sure that the MicroTrigger run, by getting the execution result from the Dispatcher.
		List<MicroTriggerResult> executionResults = MicroTriggersDispatcher.ExecutionResults;
		System.assertEquals(1, executionResults.size(), 'Only 1 MicroTrigger (TriggerBeforeInsertTestMicroTrigger) should run ');
		// Because the record we inserted (microTriggerSObjectMock) meets the Criteria, "CriteriaIsMet" will be equal to "true"
		System.assert(executionResults[0].CriteriaIsMet, 'TriggerBeforeInsertTestMicroTrigger Criteria (MockCriteria) should be met');
		System.assertEquals(1, executionResults[0].SuccessActions.size(), 'TriggerBeforeInsertTestMicroTrigger Action (MockAction) should have run');
		System.assertEquals('TriggerBeforeInsertTest.MockAction', executionResults[0].SuccessActions[0], 'TriggerBeforeInsertTestMicroTrigger Action should have run');
		
		// Check if the new record's Name is updated
		List<MicroTriggerTestingMock__c> createdRecord = [
			SELECT Name FROM MicroTriggerTestingMock__c
			WHERE Id = :microTriggerSObjectMock.Id
		];
		System.assertEquals(1, createdRecord.size(),'The new created record should exist');
		System.assertEquals(microTriggerSObjectMock.Name + ' (NEW RECORD)', createdRecord[0].Name, 'The new record Name should have " (NEW RECORD)" appended');
	}

    /****************************************************** Criteria Class for this Test Class. ****************************************/

    // The MockCriteria filters the inserted records to get only the records
    // that have the Name equal to VALID_CRITERIA (TEST RECORD)

	public class MockCriteria implements TriggerBeforeInsert.Criteria {
	    public List<MicroTriggerTestingMock__c> run(TriggerBeforeInsert.Context context) {
	        List<MicroTriggerTestingMock__c> qualifiedRecords = new List<MicroTriggerTestingMock__c>();
	        for(MicroTriggerTestingMock__c newRecord :(List<MicroTriggerTestingMock__c>) context.newList) {     
	            if(newRecord.Name == VALID_CRITERIA)          
	                qualifiedRecords.add(newRecord);
	        }
	        return qualifiedRecords;
	    }
	}

    /****************************************************** Action Class for this Test Class. ****************************************/

    // MockAction takes all the records that have Name equal to VALID_CRITERIA (from the MockCriteria)
    // and updates their Name field by appending (NEW RECORD)

	public class MockAction implements TriggerBeforeInsert.Action {
		public Boolean run(TriggerBeforeInsert.Context context, List<MicroTriggerTestingMock__c> scope) {
	        for(MicroTriggerTestingMock__c currentMicroTriggerTestingMock :scope) {
	        	currentMicroTriggerTestingMock.Name += ' (NEW RECORD)';
	        }
	        return true;
	    }
	}
}