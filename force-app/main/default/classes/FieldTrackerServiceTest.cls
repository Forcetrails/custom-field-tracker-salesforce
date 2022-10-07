@IsTest
class FieldTrackerServiceTest {
	@TestSetup
	static void makeData() {
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < 200; i++) {
			Account acc = new Account(
				Name = 'Account i' + i,
				BillingCountry = 'United States'
			);
			accounts.add(acc);
		}

		insert accounts;
	}

	@IsTest
	static void testAccountFTS() {
		System.assert(
			[SELECT Id FROM Field_Tracker_Field__mdt]?.size() > 0,
			'No Custom Metadata records found in Field Tracker Object and Field Tracker Field, please add to pass tests'
		);
	}

	@IsTest
	static void testAccountFTSUpdate() {
		Account[] accounts = [SELECT id FROM Account];
		for (Account acc : accounts) {
			acc.BillingCountry = 'India';
			acc.Description = 'Test Description';
		}

		Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();

		update accounts;

		Test.startTest();

		System.assertEquals(
			[
					SELECT Id
					FROM Field_History__c
					WHERE
						Tracked_Field_API__c = 'BillingCountry'
						AND Tracked_Record_Id__c IN :accountIds
						AND Old_Value__c = 'United States'
				]
				?.size(),
			200,
			'Field history records not found'
		);
		System.assertEquals(
			[
					SELECT Id
					FROM Field_History__c
					WHERE
						Tracked_Field_API__c = 'Description'
						AND Tracked_Record_Id__c IN :accountIds
				]
				?.size(),
			200,
			'Field history records not found'
		);
		Test.stopTest();
	}
}
