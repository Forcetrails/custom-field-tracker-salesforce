/* 
    Singleton Class implements the custom field history
    tracking dynamically through custom metadata configuration
*/
public without sharing class FieldTrackerService {
	// Static members
	private static FieldTrackerService instance;

	public static FieldTrackerService getInstance(String objectName) {
		if (instance == null) {
			instance = new FieldTrackerService(objectName);
		}
		return instance;
	}

	// instance members
	private String objectName;
	private Set<String> fields;
	private List<Field_Tracker_Field__mdt> trackedFields;
	private Field_Tracker_Object__mdt ftObject;

	private FieldTrackerService(String objectName) {
		this.objectName = objectName;

		ftObject = Field_Tracker_Object__mdt.getInstance(objectName);

		if (ftObject.Is_Active__c) {
			trackedFields = [
				SELECT Field__c, Field_Label__c, Is_Long_Text__c
				FROM Field_Tracker_Field__mdt
				WHERE
					Field_Tracker_Object__c = :ftObject.Id
					AND Is_Active__c = TRUE
			];
			fields = Schema.getGlobalDescribe()
				.get(objectName)
				.getDescribe()
				.fields.getMap()
				.keySet();
		}
	}

	// OldMap should be null in case of Insert trigger.
	public void saveFieldHistories(
		List<SObject> records,
		Map<Id, SObject> oldMap
	) {
		if (
			ftObject != null &&
			ftObject.Is_Active__c &&
			trackedFields != null &&
			!trackedFields.isEmpty()
		) {
			List<Field_History__c> fieldHistories = new List<Field_History__c>();
			Boolean isNew = oldMap == null;
			for (SObject record : records) {
				SObject oldRecord = oldMap?.get(record.Id);
				for (Field_Tracker_Field__mdt trackedField : trackedFields) {
					if (
						String.isNotBlank(trackedField.Field__c) &&
						fields.contains(trackedField.Field__c.toLowerCase()) &&
						(isNew && record.get(trackedField.Field__c) != null ||
						!isNew &&
						oldRecord.get(trackedField.Field__c) !=
						record.get(trackedField.Field__c))
					) {
						Field_History__c history = new Field_History__c(
							Tracked_Object__c = objectName,
							Tracked_Field_Label__c = trackedField.Field_Label__c,
							Tracked_Field_API__c = trackedField.Field__c,
							Tracked_Record_Id__c = record.Id
						);

						if (!trackedField.Is_Long_Text__c) {
							history.New_Value__c = String.valueOf(
								record.get(trackedField.Field__c)
							);
							history.Old_Value__c = String.valueOf(
								oldRecord?.get(trackedField.Field__c)
							);
						} else {
							history.New_Value_Long_Text__c = String.valueOf(
								record.get(trackedField.Field__c)
							);
							history.Old_Value_Long_Text__c = String.valueOf(
								oldRecord?.get(trackedField.Field__c)
							);
							history.Is_Long_Text__c = true;
						}
						fieldHistories.add(history);
					}
				}
			}
			insert fieldHistories;
		}
	}
}
