/**
 * MicroTrigger Framework https://github.com/kofijohnson/Apex-MicroTrigger
 * Copyright (C) 2016  Kofi Johnson (www.kofijohnson.com)
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * TriggerBeforeDeleteTest
 * @Description: Test for MicroTrigger Before Delete Namespace Classes.
 * @Author: Kofi Johnson - https://github.com/kofijohnson
 */

@isTest
private class TriggerBeforeDeleteTest {
	private static final String VALID_CRITERIA   = 'TEST RECORD';
	private static final String INVALID_CRITERIA = 'NOT TEST RECORD';

	@isTest static void testMockMicroTriggerWithValidCriteria() {
		// MicroTrigger configuration.
		// Add the Criteria class and the Action class to run.
		BaseMicroTrigger microTrigger = new TriggerBeforeDelete.MicroTrigger('TriggerBeforeDeleteTestMicroTrigger', 'MicroTriggerTestingMock__c');
		microTrigger.setCriteria('TriggerBeforeDeleteTest.MockCriteria')
					.addAction('TriggerBeforeDeleteTest.MockAction')
					.allowRecursive()
					.activate();

		// Then we pass the MicroTrigger to the MicroTriggerLoader.
		// This will make the Loader to discard any load from Custom Metadata Type
		// and load only the TriggerBeforeDeleteTestMicroTrigger.
		MicroTriggersLoader.microTriggerMocks = new List<BaseMicroTrigger>{microTrigger};

		// Insert a record that meet the Criteria.
		MicroTriggerTestingMock__c microTriggerSObjectMock = new MicroTriggerTestingMock__c(
			Name = VALID_CRITERIA
		);
		insert microTriggerSObjectMock;
		// Then delete it to meet the criteria. This will make the Action run.
		delete microTriggerSObjectMock;

		// Make sure that the MicroTrigger run, by getting the execution result from the Dispatcher.
		List<MicroTriggerResult> executionResults = MicroTriggersDispatcher.ExecutionResults;
		System.assertEquals(1, executionResults.size(), 'Only 1 MicroTrigger (TriggerBeforeDeleteTestMicroTrigger) should run ');
		// Because the record we deleted (microTriggerSObjectMock) meets the Criteria, "CriteriaIsMet" will be equal to "true"
		System.assert(executionResults[0].CriteriaIsMet, 'TriggerBeforeDeleteTestMicroTrigger Criteria (MockCriteria) should be met');
		System.assertEquals(1, executionResults[0].SuccessActions.size(), 'TriggerBeforeDeleteTestMicroTrigger Action (MockAction) should have run');
		System.assertEquals('TriggerBeforeDeleteTest.MockAction', executionResults[0].SuccessActions[0], 'TriggerBeforeDeleteTestMicroTrigger Action should have run');
		
		// Check if the deleted record's name is updated (by having ' (DELETED)' appended to the Name)
		List<MicroTriggerTestingMock__c> createdRecord = [
			SELECT Name FROM MicroTriggerTestingMock__c
			WHERE Id = :microTriggerSObjectMock.Id ALL ROWS
		];
		System.assertEquals(1, createdRecord.size(),'The deleted record should exist');
		System.assertEquals(microTriggerSObjectMock.Name + ' (DELETED)', createdRecord[0].Name, 'The deleted record Name should have " (DELETED)" appended');
	}

	@isTest static void testMockMicroTriggerWithInvalidCriteria() {
		// MicroTrigger configuration.
		// Add the Criteria class and the Action class to run. 
		BaseMicroTrigger microTrigger = new TriggerBeforeDelete.MicroTrigger('TriggerBeforeDeleteTestMicroTrigger', 'MicroTriggerTestingMock__c');
		microTrigger.setCriteria('TriggerBeforeDeleteTest.MockCriteria')
					.addAction('TriggerBeforeDeleteTest.MockAction')
					.allowRecursive()
					.activate();

		// Then we pass the MicroTrigger to the MicroTriggerLoader.
		// This will make the Loader to discard any load from Custom Metadata Type
		// and load only the TriggerBeforeDeleteTestMicroTrigger.
		MicroTriggersLoader.microTriggerMocks = new List<BaseMicroTrigger>{microTrigger};

		// Insert a record that does not meet the Criteria
		MicroTriggerTestingMock__c microTriggerSObjectMock = new MicroTriggerTestingMock__c(
			Name = INVALID_CRITERIA
		);
		insert microTriggerSObjectMock;
		// Then delete. The record will NOT meet the criteria, because it has Name equals to INVALID_CRITERIA
		delete microTriggerSObjectMock;

		// Get the execution result from the Dispatcher.
		List<MicroTriggerResult> executionResults = MicroTriggersDispatcher.ExecutionResults;
		// Check that the MicroTrigger run (when it runs, it should have a MicroTriggerResult)
		System.assertEquals(1, executionResults.size(), 'Only 1 MicroTrigger (TriggerBeforeDeleteTestMicroTrigger) should run ');
		// Because the record deleted (microTriggerSObjectMock) does NOT meet the Criteria, "CriteriaIsMet" will be equal to "false"
		System.assertEquals(false, executionResults[0].CriteriaIsMet, 'TriggerBeforeDeleteTestMicroTrigger Criteria (MockCriteria) should NOT be met');
		System.assertEquals(0, executionResults[0].SuccessActions.size(), 'Since the Criteria is not met, no Action should have run');

		// Check if the record is deleted
		List<MicroTriggerTestingMock__c> createdRecord = [
			SELECT Name FROM MicroTriggerTestingMock__c
			WHERE Id = :microTriggerSObjectMock.Id ALL ROWS
		];
		// The record is deleted.
		System.assertEquals(1, createdRecord.size(),'The deleted record should exist');
		System.assertEquals(microTriggerSObjectMock.Name, createdRecord[0].Name, 'The name should not be updated, because the Criteria is not met');
	}

	@isTest static void testMicroTriggerWithValidCriteria() {
		MicroTriggersLoader loader = MicroTriggersLoader.getInstance();
		if(loader.contains('TriggerBeforeDeleteTestMicroTrigger') == false ||
			loader.getMicroTrigger('TriggerBeforeDeleteTestMicroTrigger').containsAction('TriggerBeforeDeleteTest.MockAction') == false)
			return;

		// Load and Disable All MicroTriggers except the "TriggerBeforeDeleteTestMicroTrigger".
		for(BaseMicroTrigger currentMicroTrigger :loader.getMicroTriggers()) {
			if(currentMicroTrigger.DeveloperName != 'TriggerBeforeDeleteTestMicroTrigger')
				currentMicroTrigger.deactivate();
		}

		// Insert a record that meet the Criteria.
		MicroTriggerTestingMock__c microTriggerSObjectMock = new MicroTriggerTestingMock__c(
			Name = VALID_CRITERIA
		);
		insert microTriggerSObjectMock;
		// Then delete it to meet the criteria. This will make the Action run.
		delete microTriggerSObjectMock;

		// Make sure that the MicroTrigger run, by getting the execution result from the Dispatcher.
		List<MicroTriggerResult> executionResults = MicroTriggersDispatcher.ExecutionResults;
		System.assertEquals(1, executionResults.size(), 'Only 1 MicroTrigger (TriggerBeforeDeleteTestMicroTrigger) should run ');
		// Because the record we deleted (microTriggerSObjectMock) meets the Criteria, "CriteriaIsMet" will be equal to "true"
		System.assert(executionResults[0].CriteriaIsMet, 'TriggerBeforeDeleteTestMicroTrigger Criteria (MockCriteria) should be met');
		System.assertEquals(1, executionResults[0].SuccessActions.size(), 'TriggerBeforeDeleteTestMicroTrigger Action (MockAction) should have run');
		System.assertEquals('TriggerBeforeDeleteTest.MockAction', executionResults[0].SuccessActions[0], 'TriggerBeforeDeleteTestMicroTrigger Action should have run');
		
		// Check if the deleted record's name is updated (by having ' (DELETED)' appended to the Name)
		List<MicroTriggerTestingMock__c> createdRecord = [
			SELECT Name FROM MicroTriggerTestingMock__c
			WHERE Id = :microTriggerSObjectMock.Id ALL ROWS
		];
		System.assertEquals(1, createdRecord.size(),'The deleted record should exist');
		System.assertEquals(microTriggerSObjectMock.Name + ' (DELETED)', createdRecord[0].Name, 'The deleted record Name should have " (DELETED)" appended');
	}
	
    /****************************************************** Criteria Class for this Test Class. ****************************************/

    // The MockCriteria filters the inserted records to get only the records
    // that have the Name equal to VALID_CRITERIA (TEST RECORD)

	public class MockCriteria implements TriggerBeforeDelete.Criteria {
	    public List<MicroTriggerTestingMock__c> run(TriggerBeforeDelete.Context context) {
	        List<MicroTriggerTestingMock__c> qualifiedRecords = new List<MicroTriggerTestingMock__c>();
	        for(MicroTriggerTestingMock__c oldRecord :(List<MicroTriggerTestingMock__c>) context.oldList) {
	            if(oldRecord.Name == VALID_CRITERIA)         
	                qualifiedRecords.add(oldRecord);
	        }
	        return qualifiedRecords;
	    }
	}
	
	/****************************************************** Action Class for this Test Class. ****************************************/

	// MockAction takes all the filtered records that have Name equal to VALID_CRITERIA (from the MockCriteria)
    // and updates the Name by appending ' (DELETED)'.

	public class MockAction implements TriggerBeforeDelete.Action {
		public Boolean run(TriggerBeforeDelete.Context context, List<MicroTriggerTestingMock__c> scope) {
			List<MicroTriggerTestingMock__c> recordsDeleted = [
				SELECT Name FROM MicroTriggerTestingMock__c WHERE Id IN :(new Map<Id, MicroTriggerTestingMock__c>(scope)).keySet()
			];
	        for(MicroTriggerTestingMock__c currentMicroTriggerTestingMock :recordsDeleted) {
	        	currentMicroTriggerTestingMock.Name += ' (DELETED)';
	        }
	        update recordsDeleted;
	        return true;
	    }
	}
}