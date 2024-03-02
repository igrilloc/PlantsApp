public with sharing class PlantTriggerHandler {
  public void beforeInsert(List<Plant__c> newSObjects) {
    // Precargar información necesaria de objetos relacionados
    Set<Id> specieIds = new Set<Id>();

    for (Plant__c newPlant : newSObjects) {
      specieIds.add(newPlant.Species__c);
    }

    // Query precarga objetos relacionados
    Map<Id, Species__c> speciesById = preloadRelatedSpecies(specieIds);

    // Prepopulate required fields if not present

    // Prepopulate next frequency date
    for (Plant__c newPlant : newSObjects) {
      populateNextWateringDate(newPlant, speciesById);
      populateNextFertilizedDate(newPlant, speciesById);
    }
  }

  public void beforeUpdate(
    List<Plant__c> oldSObjects,
    Map<ID, Plant__c> oldSObjectsMap,
    List<Plant__c> updatedSObjects,
    Map<ID, Plant__c> updatedSObjectsMap
  ) {
    // Cuando se crea o actualiza una planta (cambiando su fecha riego) --> calcular sig fecha riego
    // Precargar información necesaria de objetos relacionados
    Set<Id> specieIds = new Set<Id>();

    for (Plant__c newPlant : updatedSObjects) {
      Plant__c oldPlant = oldSObjectsMap.get(newPlant.Id);

      if (oldPlant.Last_Watered__c != newPlant.Last_Watered__c) {
        specieIds.add(newPlant.Species__c);
      }

      if (oldPlant.Last_Fertilized__c != newPlant.Last_Fertilized__c) {
        specieIds.add(newPlant.Species__c);
      }
    }

    // Query precarga objetos relacionados
    Map<Id, Species__c> speciesById = preloadRelatedSpecies(specieIds);

    // Si está cambiando la fecha de riego
    // Trigger.old / Trigger.new / Trigger.oldMap / Trigger.newMap
    // Obtener valor nuevo fecha riego de Trigger.new
    // Obtener valor antiguo fecha riego de Trigger.oldMap
    for (Plant__c newPlant : updatedSObjects) {
      Plant__c oldPlant = oldSObjectsMap.get(newPlant.Id);

      if (oldPlant.Last_Watered__c != newPlant.Last_Watered__c) {
        populateNextWateringDate(newPlant, speciesById);
      }

      if (oldPlant.Last_Fertilized__c != newPlant.Last_Fertilized__c) {
        populateNextFertilizedDate(newPlant, speciesById);
      }
    }
  }

  private static Map<Id, Species__c> preloadRelatedSpecies(Set<Id> specieIds) {
    List<Species__c> species = [
      SELECT
        Summer_Watering_Frequency__c,
        Winter_Watering_Frequency__c,
        Summer_Fertilization_Frequency__c,
        Winter_Fertilization_Frequency__c
      FROM Species__c
      WHERE Id IN :specieIds
      WITH SECURITY_ENFORCED
    ];

    return new Map<Id, Species__c>(species);
  }

  private static void populateNextWateringDate(
    Plant__c newPlant,
    Map<Id, Species__c> speciesById
  ) {
    // Verificar si la planta tiene una especie asociada
    if (
      newPlant.Species__c != null &&
      speciesById.containsKey(newPlant.Species__c)
    ) {
      // Calcular la fecha de riego solo si hay una especie asociada
      Species__c specie = speciesById.get(newPlant.Species__c);
      // Pedir freq de riego para esa especie
      Integer daysToAdd = FrequencyService.getWateringDays(
        specie,
        new DateService()
      );
      // sig fecha riego = ultima fecha riego + dias devueltos
      newPlant.Next_Water__c = newPlant.Last_Watered__c.addDays(daysToAdd);
    } else {
      // Si no hay especie asociada, establecer la próxima fecha de riego como nula
      newPlant.Next_Water__c = null;
    }
  }

  private static void populateNextFertilizedDate(
    Plant__c newPlant,
    Map<Id, Species__c> speciesById
  ) {
    // Calcular sig fecha de fertilizacion
    // Ver de qué especie es mi planta
    Id specieId = newPlant.Species__c;
    // Traer objeto especie
    Species__c specie = speciesById.get(specieId);
    // Pedir freq de fertilizacion para esa especie
    Integer daysToAdd = FrequencyService.getFertilizationDays(
      specie,
      new DateService()
    );
    // sig fecha riego = ultima fecha riego + dias devueltos
    newPlant.Next_Fertilization__c = newPlant.Last_Fertilized__c.addDays(
      daysToAdd
    );
  }
}
