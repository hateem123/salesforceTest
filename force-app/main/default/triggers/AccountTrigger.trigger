trigger AccountTrigger on Account (after update) {
	AccountTriggerHandler.OnAfterUpdate(trigger.new, trigger.oldMap);
}