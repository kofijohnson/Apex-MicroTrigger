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
 * TriggerAfterUndeleteTest
 * @Description: Test for MicroTrigger After Undelete Namespace Classes.
 * @Author: Kofi Johnson - https://github.com/kofijohnson
 */

@isTest
private class TriggerAfterUndeleteTest {
	private static final String VALID_CRITERIA   = 'TEST RECORD';
	private static final String INVALID_CRITERIA = 'NOT TEST RECORD';

	@isTest static void testMockMicroTriggerWithValidCriteria() {
		// MicroTrigger configuration.
		// Add the Criteria class and the Action class to run.
		BaseMicroTrigger microTrigger1 = new TriggerAfterUndelete.MicroTrigger('TriggerAfterUndeleteTestMicroTrigger', 'MicroTriggerTestingMock__c');
		microTrigger1.setCriteria('TriggerAfterUndeleteTest.MockCriteria')
					.addAction('TriggerAfterUndeleteTest.MockAction')
					.allowRecursive()
					.activate();

		// Then we pass the MicroTrigger to the MicroTriggerLoader.
		// This will make the Loader to discard any load from Custom Metadata Type
		// and load only the TriggerAfterUndeleteTestMicroTrigger.
		MicroTriggersLoader.microTriggerMocks = new List<BaseMicroTrigger>{microTrigger1};

		// Insert a record that meet the Criteria
		MicroTriggerTestingMock__c microTriggerSObjectMock = new MicroTriggerTestingMock__c(
			Name = VALID_CRITERIA
		);
		insert microTriggerSObjectMock;
		// And delete it.
		delete microTriggerSObjectMock;
		List<MicroTriggerTestingMock__c> deletedMicroTriggerMock = [
			SELECT Name FROM MicroTriggerTestingMock__c
			WHERE Id = :microTriggerSObjectMock.Id ALL ROWS
		];
		// Then undelete it. This will make the Action run. (The Action creates a new clone of the deleted record.)
		undelete deletedMicroTriggerMock;

		// Make sure that the MicroTrigger run, by getting the execution result from the Dispatcher.
		List<MicroTriggerResult> executionResults = MicroTriggersDispatcher.ExecutionResults;
		System.assertEquals(1, executionResults.size(), 'Only 1 MicroTrigger (TriggerAfterUndeleteTestMicroTrigger) should run ');
		// Because the record we undelete (microTriggerSObjectMock) meets the Criteria, "CriteriaIsMet" will be equal to "true"
		System.assert(executionResults[0].CriteriaIsMet, 'TriggerAfterUndeleteTestMicroTrigger Criteria (MockCriteria) should be met');
		System.assertEquals(1, executionResults[0].SuccessActions.size(), 'TriggerAfterUndeleteTestMicroTrigger Action (MockAction) should have run');
		System.assertEquals('TriggerAfterUndeleteTest.MockAction', executionResults[0].SuccessActions[0], 'TriggerAfterUndeleteTestMicroTrigger Action should have run');
		
		// Check if the undeleted record name is updated (by having ' (UNDELETED)' appended to the Name)
		List<MicroTriggerTestingMock__c> undeletedRecord = [
			SELECT Name FROM MicroTriggerTestingMock__c
		];
		System.assertEquals(1, undeletedRecord.size(),'The undeleted record should exist');
		System.assertEquals(microTriggerSObjectMock.Name + ' (UNDELETED)', undeletedRecord[0].Name, 'The undeleted record Name should have " (UNDELETED)" appended');
	}

	@isTest static void testMockMicroTriggerWithInvalidCriteria() {
		// MicroTrigger configuration.
		// Add the Criteria class and the Action class to run. 
		BaseMicroTrigger microTrigger = new TriggerAfterUndelete.MicroTrigger('TriggerAfterUndeleteTestMicroTrigger', 'MicroTriggerTestingMock__c');
		microTrigger.setCriteria('TriggerAfterUndeleteTest.MockCriteria')
					.addAction('TriggerAfterUndeleteTest.MockAction')
					.allowRecursive()
					.activate();

		// Then we pass the MicroTrigger to the MicroTriggerLoader.
		// This will make the Loader to discard any load from Custom Metadata Type
		// and load only the TriggerAfterUndeleteTestMicroTrigger.
		MicroTriggersLoader.microTriggerMocks = new List<BaseMicroTrigger>{microTrigger};

		// Insert a record that does not meet the Criteria,
		// then delete
		MicroTriggerTestingMock__c microTriggerSObjectMock = new MicroTriggerTestingMock__c(
			Name = INVALID_CRITERIA
		);
		insert microTriggerSObjectMock;
		delete microTriggerSObjectMock;
		List<MicroTriggerTestingMock__c> deletedMicroTriggerMock = [
			SELECT Name FROM MicroTriggerTestingMock__c
			WHERE Id = :microTriggerSObjectMock.Id ALL ROWS
		];
		// The record will NOT meet the criteria, because it has Name equals to INVALID_CRITERIA
		undelete deletedMicroTriggerMock;
		// Get the execution result from the Dispatcher.
		List<MicroTriggerResult> executionResults = MicroTriggersDispatcher.ExecutionResults;
		// Check that the MicroTrigger run (when it runs, it should have a MicroTriggerResult)
		System.assertEquals(1, executionResults.size(), 'Only 1 MicroTrigger (TriggerAfterUndeleteTestMicroTrigger) should run');
		// Because the undeleted record (microTriggerSObjectMock) does NOT meet the Criteria, "CriteriaIsMet" will be equal to "false"
		System.assertEquals(false, executionResults[0].CriteriaIsMet, 'TriggerAfterUndeleteTestMicroTrigger Criteria (MockCriteria) should NOT be met');
		System.assertEquals(0, executionResults[0].SuccessActions.size(), 'Since the Criteria is not met, no Action should have run');

		// Check if the record is deleted
		List<MicroTriggerTestingMock__c> undeletedRecord = [
			SELECT Name FROM MicroTriggerTestingMock__c
		];
		// The Action did not run. The undeleted record is not updated.
		System.assertEquals(1, undeletedRecord.size(),'The undeleted record should exist');
		System.assertEquals(microTriggerSObjectMock.Name, undeletedRecord[0].Name, 'The name should not be updated, because the Criteria is not met');
	}

	@isTest static void testMicroTriggerWithValidCriteria() {
		MicroTriggersLoader loader = MicroTriggersLoader.getInstance();
		if(loader.contains('TriggerAfterUndeleteTestMicroTrigger') == false ||
			loader.getMicroTrigger('TriggerAfterUndeleteTestMicroTrigger').containsAction('TriggerAfterUndeleteTest.MockAction') == false)
			return;

		// Load and Disable All MicroTriggers except the "TriggerAfterUndeleteTestMicroTrigger".
		for(BaseMicroTrigger currentMicroTrigger :loader.getMicroTriggers()) {
			if(currentMicroTrigger.DeveloperName != 'TriggerAfterUndeleteTestMicroTrigger')
				currentMicroTrigger.deactivate();
		}

		// Insert a record that meet the Criteria
		MicroTriggerTestingMock__c microTriggerSObjectMock = new MicroTriggerTestingMock__c(
			Name = VALID_CRITERIA
		);
		insert microTriggerSObjectMock;
		// And delete it.
		delete microTriggerSObjectMock;
		List<MicroTriggerTestingMock__c> deletedMicroTriggerMock = [
			SELECT Name FROM MicroTriggerTestingMock__c
			WHERE Id = :microTriggerSObjectMock.Id ALL ROWS
		];
		// Then undelete it. This will make the Action run. (The Action creates a new clone of the deleted record.)
		undelete deletedMicroTriggerMock;

		// Make sure that the MicroTrigger run, by getting the execution result from the Dispatcher.
		List<MicroTriggerResult> executionResults = MicroTriggersDispatcher.ExecutionResults;
		System.assertEquals(1, executionResults.size(), 'Only 1 MicroTrigger (TriggerAfterUndeleteTestMicroTrigger) should run ');
		// Because the record we undelete (microTriggerSObjectMock) meets the Criteria, "CriteriaIsMet" will be equal to "true"
		System.assert(executionResults[0].CriteriaIsMet, 'TriggerAfterUndeleteTestMicroTrigger Criteria (MockCriteria) should be met');
		System.assertEquals(1, executionResults[0].SuccessActions.size(), 'TriggerAfterUndeleteTestMicroTrigger Action (MockAction) should have run');
		System.assertEquals('TriggerAfterUndeleteTest.MockAction', executionResults[0].SuccessActions[0], 'TriggerAfterUndeleteTestMicroTrigger Action should have run');
		
		// Check if the undeleted record name is updated (by having ' (UNDELETED)' appended to the Name)
		List<MicroTriggerTestingMock__c> undeletedRecord = [
			SELECT Name FROM MicroTriggerTestingMock__c
		];
		System.assertEquals(1, undeletedRecord.size(),'The undeleted record should exist');
		System.assertEquals(microTriggerSObjectMock.Name + ' (UNDELETED)', undeletedRecord[0].Name, 'The undeleted record Name should have " (UNDELETED)" appended');
	}
	
    /****************************************************** Criteria Class for this Test Class. ****************************************/

    // The MockCriteria filters the inserted records to get only the records
    // that have the Name equal to VALID_CRITERIA (TEST RECORD)

	public class MockCriteria implements TriggerAfterUndelete.Criteria {
	    public List<MicroTriggerTestingMock__c> run(TriggerAfterUndelete.Context context) {
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
    // and updates the Name by appending ' (UNDELETED)'.

	public class MockAction implements TriggerAfterUndelete.Action {
		public Boolean run(TriggerAfterUndelete.Context context, List<MicroTriggerTestingMock__c> scope) {
			List<MicroTriggerTestingMock__c> recordsDeleted = [
				SELECT Name FROM MicroTriggerTestingMock__c WHERE Id IN :(new Map<Id, MicroTriggerTestingMock__c>(scope)).keySet()
			];
	        for(MicroTriggerTestingMock__c currentMicroTriggerTestingMock :recordsDeleted) {
	        	currentMicroTriggerTestingMock.Name += ' (UNDELETED)';
	        }
	        update recordsDeleted;
	        return true;
	    }
	}
}