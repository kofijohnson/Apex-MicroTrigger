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
 * TriggerAfterUpdateTest
 * @Description: Test for MicroTrigger After Insert Namespace Classes.
 * @Author: Kofi Johnson - https://github.com/kofijohnson
 */

@isTest
private class TriggerAfterUpdateTest {
	private static final String VALID_CRITERIA   = 'TEST RECORD';
	private static final String INVALID_CRITERIA = 'NOT TEST RECORD';

	@isTest static void testMockMicroTriggerWithValidCriteria() {
		// MicroTrigger configuration.
		// Add the Criteria class and the Action class to run.
		BaseMicroTrigger microTrigger = new TriggerAfterUpdate.MicroTrigger('TriggerAfterUpdateTestMicroTrigger', 'MicroTriggerTestingMock__c');
		microTrigger.setCriteria('TriggerAfterUpdateTest.MockCriteria')
					.addAction('TriggerAfterUpdateTest.MockAction')
					.allowRecursive()
					.activate();

		// Then we pass the MicroTrigger to the MicroTriggerLoader.
		// This will make the Loader to discard any load from Custom Metadata Type
		// and load only the TriggerAfterUpdateTestMicroTrigger.
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
		System.assertEquals(1, executionResults.size(), 'Only 1 MicroTrigger (TriggerAfterUpdateTestMicroTrigger) should run ');
		// Because the record we inserted (microTriggerSObjectMock) meets the Criteria, "CriteriaIsMet" will be equal to "true"
		System.assert(executionResults[0].CriteriaIsMet, 'TriggerAfterUpdateTestMicroTrigger Criteria (MockCriteria) should be met');
		System.assertEquals(1, executionResults[0].SuccessActions.size(), 'TriggerAfterUpdateTestMicroTrigger Action (MockAction) should have run');
		System.assertEquals('TriggerAfterUpdateTest.MockAction', executionResults[0].SuccessActions[0], 'TriggerAfterUpdateTestMicroTrigger Action should have run');
		
		// Check if a duplicate record is created
		List<MicroTriggerTestingMock__c> duplicateRecord = [
			SELECT Name FROM MicroTriggerTestingMock__c
			WHERE Id != :microTriggerSObjectMock.Id
		];
		System.assertEquals(1, duplicateRecord.size(),'A new record (duplicate) should be created');
		System.assertEquals(microTriggerSObjectMock.Name + ' (DUPLICATE)', duplicateRecord[0].Name, 'The new record Name should have " DUPLICATE" appended');
	}

	@isTest static void testMockMicroTriggerWithInvalidCriteria() {
		// MicroTrigger configuration.
		// Add the Criteria class and the Action class to run. 
		BaseMicroTrigger microTrigger = new TriggerAfterUpdate.MicroTrigger('TriggerAfterUpdateTestMicroTrigger', 'MicroTriggerTestingMock__c');
		microTrigger.setCriteria('TriggerAfterUpdateTest.MockCriteria')
					.addAction('TriggerAfterUpdateTest.MockAction')
					.allowRecursive()
					.activate();

		// Then we pass the MicroTrigger to the MicroTriggerLoader. This will make the Loader to discard any load from Custom Metadata Type and load only the TriggerAfterUpdateTestMicroTrigger.
		MicroTriggersLoader.microTriggerMocks = new List<BaseMicroTrigger>{microTrigger};

		// Test the MicroTrigger by inserting a record that will meet the Criteria.
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
		System.assertEquals(1, executionResults.size(), 'Only 1 MicroTrigger (TriggerAfterUpdateTestMicroTrigger) should run ');
		// Because the record we inserted (microTriggerSObjectMock) does not meet the Criteria, "CriteriaIsMet" will be equal to "false"
		System.assertEquals(false, executionResults[0].CriteriaIsMet, 'TriggerAfterUpdateTestMicroTrigger Criteria (MockCriteria) should NOT be met');
		System.assertEquals(0, executionResults[0].SuccessActions.size(), 'Since the Criteria is not met, no Action should have run');

		// Check if a new record is created
		List<MicroTriggerTestingMock__c> duplicateRecord = [
			SELECT Name FROM MicroTriggerTestingMock__c
			WHERE Id != :microTriggerSObjectMock.Id
		];
		// No new record is created.
		System.assertEquals(0, duplicateRecord.size(),'No duplicate record should be created, since the Criteria is not met.');
	}

	@isTest static void testMicroTriggerWithValidCriteria() {
		MicroTriggersLoader loader = MicroTriggersLoader.getInstance();
		if(loader.contains('TriggerAfterUpdateTestMicroTrigger') == false ||
			loader.getMicroTrigger('TriggerAfterUpdateTestMicroTrigger').containsAction('TriggerAfterUpdateTest.MockAction') == false)
			return;

		// Load and Disable All MicroTriggers except the "TriggerAfterUpdateTestMicroTrigger".
		for(BaseMicroTrigger currentMicroTrigger :loader.getMicroTriggers()) {
			if(currentMicroTrigger.DeveloperName != 'TriggerAfterUpdateTestMicroTrigger')
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
		System.assertEquals(1, executionResults.size(), 'Only 1 MicroTrigger (TriggerAfterUpdateTestMicroTrigger) should run ');
		// Because the record we inserted (microTriggerSObjectMock) meets the Criteria, "CriteriaIsMet" will be equal to "true"
		System.assert(executionResults[0].CriteriaIsMet, 'TriggerAfterUpdateTestMicroTrigger Criteria (MockCriteria) should be met');
		System.assertEquals(1, executionResults[0].SuccessActions.size(), 'TriggerAfterUpdateTestMicroTrigger Action (MockAction) should have run');
		System.assertEquals('TriggerAfterUpdateTest.MockAction', executionResults[0].SuccessActions[0], 'TriggerAfterUpdateTestMicroTrigger Action should have run');
		
		// Check if a duplicate record is created
		List<MicroTriggerTestingMock__c> duplicateRecord = [
			SELECT Name FROM MicroTriggerTestingMock__c
			WHERE Id != :microTriggerSObjectMock.Id
		];
		System.assertEquals(1, duplicateRecord.size(),'A new record (duplicate) should be created');
		System.assertEquals(microTriggerSObjectMock.Name + ' (DUPLICATE)', duplicateRecord[0].Name, 'The new record Name should have " DUPLICATE" appended');
	}
	
    /****************************************************** Criteria Class for this Test Class. ****************************************/

    // The MockCriteria filters the inserted records to get only the records
    // that have the Name equal to VALID_CRITERIA (TEST RECORD)

	public class MockCriteria implements TriggerAfterUpdate.Criteria {
	    public List<MicroTriggerTestingMock__c> run(TriggerAfterUpdate.Context context) {
	        List<MicroTriggerTestingMock__c> qualifiedRecords = new List<MicroTriggerTestingMock__c>();
	        for(MicroTriggerTestingMock__c newRecord :(List<MicroTriggerTestingMock__c>) context.newList) {     
	            if(newRecord.Name == VALID_CRITERIA)          
	                qualifiedRecords.add(newRecord);
	        }
	        return qualifiedRecords;
	    }
	}
	
	/****************************************************** Action Class for this Test Class. ****************************************/

	// MockAction takes all the filtered records that have Name equal to VALID_CRITERIA (from the MockCriteria)
    // and creates a duplicate for each filtered records.

	public class MockAction implements TriggerAfterUpdate.Action {
		public Boolean run(TriggerAfterUpdate.Context context, List<MicroTriggerTestingMock__c> scope) {
			List<MicroTriggerTestingMock__c> newRecordsToInsert = new List<MicroTriggerTestingMock__c>();
	        for(MicroTriggerTestingMock__c currentMicroTriggerTestingMock :scope) {
	        	newRecordsToInsert.add(
	        		new MicroTriggerTestingMock__c (
		        		Name = currentMicroTriggerTestingMock.Name + ' (DUPLICATE)'
		        	)
	        	);
	        }
	        insert newRecordsToInsert;
	        return true;
	    }
	}
}