@isTest
class AccountTriggerTest {
	@TestSetup
	static void makeData() {
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < 200; i++) {
			Account acc = new Account(
				Name = 'Account FTS ' + i,
				BillingCountry = 'United States'
			);
			accounts.add(acc);
		}

		insert accounts;
	}

	@IsTest
	static void testAfterInsertHistory() {
		Set<Id> accountIds = new Map<Id, Account>(
				[SELECT Id FROM Account WHERE Name LIKE 'Account FTS %']
			)
			.keySet();

		Test.startTest();
		System.assertEquals(
			[
					SELECT Id
					FROM Field_History__c
					WHERE
						Tracked_Field_API__c = 'BillingCountry'
						AND Tracked_Record_Id__c IN :accountIds
						AND Old_Value__c = NULL
				]
				?.size(),
			200,
			'Field history records not found'
		);
		Test.stopTest();
	}

	@IsTest
	static void testAfterUpdateHistory() {
		Account[] accounts = [
			SELECT Id
			FROM Account
			WHERE Name LIKE 'Account FTS %'
		];

		Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();

		for (Account acc : accounts) {
			acc.BillingCountry = 'India';
			acc.Description = 'Test Description';
		}

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
