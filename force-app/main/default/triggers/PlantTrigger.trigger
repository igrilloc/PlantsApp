trigger PlantTrigger on Plant__c(before insert, before update) {
  PlantTriggerHandler handler = new PlantTriggerHandler();

  if (Trigger.isInsert && Trigger.isBefore) {
    // Before Insert
    handler.beforeInsert(Trigger.new);
  } else if (Trigger.isUpdate && Trigger.isBefore) {
    // Before Update
    handler.beforeUpdate(
      Trigger.old,
      Trigger.oldMap,
      Trigger.new,
      Trigger.newMap
    );
  }
}
