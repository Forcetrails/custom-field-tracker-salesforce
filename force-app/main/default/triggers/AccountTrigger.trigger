trigger AccountTrigger on Account(after insert, after update) {
	AccountTriggerHandler.saveFieldHistories(Trigger.new, Trigger.oldMap);
}
