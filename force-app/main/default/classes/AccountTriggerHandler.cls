public with sharing class AccountTriggerHandler {
	public static void saveFieldHistories(
		List<Account> newAccounts,
		Map<Id, Account> oldMap
	) {
		FieldTrackerService fts = FieldTrackerService.getInstance('Account');
		fts.saveFieldHistories(newAccounts, oldMap);
	}
}
