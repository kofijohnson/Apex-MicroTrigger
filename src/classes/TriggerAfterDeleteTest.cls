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
 * TriggerAfterDeleteTest
 * @Description: Test for MicroTrigger After Delete Namespace Classes.
 * @Author: Kofi Johnson - https://github.com/kofijohnson/Apex-MicroTrigger
 */

@isTest
private class TriggerAfterDeleteTest {
	private static final String VALID_CRITERIA   = 'TEST RECORD';
	private static final String INVALID_CRITERIA = 'NOT TEST RECORD';

	@isTest static void testMockMicroTriggerWithValidCriteria() {
		// MicroTrigger configuration.
		// Add the Criteria class and the Action class to run.
		BaseMicroTrigger microTrigger = new TriggerAfterDelete.MicroTrigger('TriggerAfterDeleteTestMicroTrigger', 'MicroTriggerTestingMock__c');
		microTrigger.setCriteria('TriggerAfterDeleteTest.MockCriteria')
					.addAction('TriggerAfterDeleteTest.MockAction')
					.allowRecursive()
					.activate();

		// Then we pass the MicroTrigger to the MicroTriggerLoader.
		// This will make the Loader to discard any load from Custom Metadata Type
		// and load only the TriggerAfterDeleteTestMicroTrigger.
		MicroTriggersLoader.microTriggerMocks = new List<BaseMicroTrigger>{microTrigger};

		// Insert a record that meet the Criteria.
		MicroTriggerTestingMock__c microTriggerSObjectMock = new MicroTriggerTestingMock__c(
			Name = VALID_CRITERIA
		);
		insert microTriggerSObjectMock;
		// Then delete it. This will make the Action run. (The Action creates a new clone of the deleted record)
		delete microTriggerSObjectMock;

		// Make sure that the MicroTrigger run, by getting the execution result from the Dispatcher.
		List<MicroTriggerResult> executionResults = MicroTriggersDispatcher.ExecutionResults;
		System.assertEquals(1, executionResults.size(), 'Only 1 MicroTrigger (TriggerAfterDeleteTestMicroTrigger) should run ');
		// Because the record we deleted (microTriggerSObjectMock) meets the Criteria, "CriteriaIsMet" will be equal to "true"
		System.assert(executionResults[0].CriteriaIsMet, 'TriggerAfterDeleteTestMicroTrigger Criteria (MockCriteria) should be met');
		System.assertEquals(1, executionResults[0].SuccessActions.size(), 'TriggerAfterDeleteTestMicroTrigger Action (MockAction) should have run');
		System.assertEquals('TriggerAfterDeleteTest.MockAction', executionResults[0].SuccessActions[0], 'TriggerAfterDeleteTestMicroTrigger Action should have run');
		
		// Check if a clone is created for the deleted record
		List<MicroTriggerTestingMock__c> cloneRecords = [
			SELECT Name FROM MicroTriggerTestingMock__c
			WHERE Id != :microTriggerSObjectMock.Id
		];
		System.assertEquals(1, cloneRecords.size(),'The clone (new created) record should exist');
		System.assertEquals(microTriggerSObjectMock.Name + ' (DELETED CLONE)', cloneRecords[0].Name, 'The new created record Name should have " (DELETED CLONE)" appended');
	}

	@isTest static void testMockMicroTriggerWithInvalidCriteria() {
		// MicroTrigger configuration.
		// Add the Criteria class and the Action class to run. 
		BaseMicroTrigger microTrigger = new TriggerAfterDelete.MicroTrigger('TriggerAfterDeleteTestMicroTrigger', 'MicroTriggerTestingMock__c');
		microTrigger.setCriteria('TriggerAfterDeleteTest.MockCriteria')
					.addAction('TriggerAfterDeleteTest.MockAction')
					.allowRecursive()
					.activate();

		// Then we pass the MicroTrigger to the MicroTriggerLoader. This will make the Loader to discard any load from Custom Metadata Type and load only the TriggerAfterDeleteTestMicroTrigger.
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
		System.assertEquals(1, executionResults.size(), 'Only 1 MicroTrigger (TriggerAfterDeleteTestMicroTrigger) should run');
		// Because the record deleted (microTriggerSObjectMock) does NOT meet the Criteria, "CriteriaIsMet" will be equal to "false"
		System.assertEquals(false, executionResults[0].CriteriaIsMet, 'TriggerAfterDeleteTestMicroTrigger Criteria (MockCriteria) should NOT be met');
		System.assertEquals(0, executionResults[0].SuccessActions.size(), 'Since the Criteria is not met, no Action should have run');

		// Check if the clone record is created
		List<MicroTriggerTestingMock__c> cloneRecords = [
			SELECT Name FROM MicroTriggerTestingMock__c
			WHERE Id != :microTriggerSObjectMock.Id
		];
		// The Action did not run. No new record is created.
		System.assertEquals(0, cloneRecords.size(),'The Action did not run. No new record is created');
	}

	@isTest static void testMicroTriggerWithValidCriteria() {
		MicroTriggersLoader loader = MicroTriggersLoader.getInstance();
		if(loader.contains('TriggerAfterDeleteTestMicroTrigger') == false ||
			loader.getMicroTrigger('TriggerAfterDeleteTestMicroTrigger').containsAction('TriggerAfterDeleteTest.MockAction') == false)
			return;

		// Load and Disable All MicroTriggers except the "TriggerAfterDeleteTestMicroTrigger".
		for(BaseMicroTrigger currentMicroTrigger :loader.getMicroTriggers()) {
			if(currentMicroTrigger.DeveloperName != 'TriggerAfterDeleteTestMicroTrigger')
				currentMicroTrigger.deactivate();
		}

		// Insert a record that meet the Criteria.
		MicroTriggerTestingMock__c microTriggerSObjectMock = new MicroTriggerTestingMock__c(
			Name = VALID_CRITERIA
		);
		insert microTriggerSObjectMock;
		// Then delete it. This will make the Action run. (The Action creates a new clone of the deleted record)
		delete microTriggerSObjectMock;

		// Make sure that the MicroTrigger run, by getting the execution result from the Dispatcher.
		List<MicroTriggerResult> executionResults = MicroTriggersDispatcher.ExecutionResults;
		System.assertEquals(1, executionResults.size(), 'Only 1 MicroTrigger (TriggerAfterDeleteTestMicroTrigger) should run ');
		// Because the record we deleted (microTriggerSObjectMock) meets the Criteria, "CriteriaIsMet" will be equal to "true"
		System.assert(executionResults[0].CriteriaIsMet, 'TriggerAfterDeleteTestMicroTrigger Criteria (MockCriteria) should be met');
		System.assertEquals(1, executionResults[0].SuccessActions.size(), 'TriggerAfterDeleteTestMicroTrigger Action (MockAction) should have run');
		System.assertEquals('TriggerAfterDeleteTest.MockAction', executionResults[0].SuccessActions[0], 'TriggerAfterDeleteTestMicroTrigger Action should have run');
		
		// Check if a clone is created for the deleted record
		List<MicroTriggerTestingMock__c> cloneRecords = [
			SELECT Name FROM MicroTriggerTestingMock__c
			WHERE Id != :microTriggerSObjectMock.Id
		];
		System.assertEquals(1, cloneRecords.size(),'The clone (new created) record should exist');
		System.assertEquals(microTriggerSObjectMock.Name + ' (DELETED CLONE)', cloneRecords[0].Name, 'The new created record Name should have " (DELETED CLONE)" appended');
	}
	
    /****************************************************** Criteria Class for this Test Class. ****************************************/

    // The MockCriteria filters the inserted records to get only the records
    // that have the Name equal to VALID_CRITERIA (TEST RECORD)

	public class MockCriteria implements TriggerAfterDelete.Criteria {
	    public List<MicroTriggerTestingMock__c> run(TriggerAfterDelete.Context context) {
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
    // and creates a clone record for each deleted record with name containing ' (DELETED CLONE)'.

	public class MockAction implements TriggerAfterDelete.Action {
		public Boolean run(TriggerAfterDelete.Context context, List<MicroTriggerTestingMock__c> scope) {
			List<MicroTriggerTestingMock__c> recordsDeletedClone = new List<MicroTriggerTestingMock__c>();
	        for(MicroTriggerTestingMock__c currentMicroTriggerTestingMock :scope) {
	        	recordsDeletedClone.add(
	        		new MicroTriggerTestingMock__c(
	        			Name = currentMicroTriggerTestingMock.Name + ' (DELETED CLONE)'
	        		)
	        	);
	        }
	        insert recordsDeletedClone;
	        return true;
	    }
	}
}