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
		}

		update accounts;

		System.assert(
			[
				SELECT Id
				FROM Field_History__c
				WHERE Tracked_Field_API__c = 'BillingCountry'
			]
			?.size() > 0
		);
	}
}
