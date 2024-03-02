// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents


// CHILD-TO-PARENT QUERY: tabla ppal child
List<Plant__c> listplants = [SELECT Name, Acquisition_Date__c FROM Plant__c];
System.debug(listplants);



// Filtrar por un campo del padre
List<Plant__c> listplants = [SELECT Name, Acquisition_Date__c FROM Plant__c WHERE Species__r.Name = 'Aloe Vera'];
System.debug(listplants);



// Filtrar por padres multiples
List<Plant__c> listplants = [SELECT Name, Acquisition_Date__c FROM Plant__c WHERE Species__r.Name = 'Aloe Vera' OR Species__r = 'Poto'];
System.debug(listplants);

List<Plant__c> listplants = [SELECT Name, Acquisition_Date__c FROM Plant__c WHERE Species__r.Name IN ('Aloe Vera', 'Poto')];
System.debug(listplants);

List<String> speciesName = new List<String> {'Aloe Vera', 'Poto'};
List<Plant__c> listplants = [SELECT Name, Acquisition_Date__c FROM Plant__c WHERE Species__r.Name IN :speciesName];
System.debug(listplants);

List<Species__c> species = [SELECT Id FROM Species__c WHERE Name IN ('Aloe Vera', 'Poto')];
List<Plant__c> listplants = [SELECT Name, Acquisition_Date__c FROM Plant__c WHERE Species__r.Name IN :species];
System.debug(listplants);

// Utilizando subquerys:
List<Plant__c> listplants = [SELECT Name, Acquisition_Date__c FROM Plant__c WHERE Species__r.Name IN (SELECT Id FROM Species__c WHERE Name IN ('Aloe Vera', 'Poto'))];
System.debug(listplants);



List<Plant__c> listplants = Database.query('SELECT Name, Acquisition_Date__c FROM Plant__c');
System.debug(listplants);


List<sObject> listplants = Database.query('SELECT Name, Acquisition_Date__c FROM Plant__c');
System.debug(listplants);


Date acquisitionDate = Date.newInstance(2024, 1, 1);
List<Plant__c> listplants = [
    SELECT Name, Acquisition_Date__c 
    FROM Plant__c 
    WHERE Acquisition_Date__c >= :acquisitionDate  
    ORDER BY Acquisition_Date__c 
    LIMIT 3
];

System.debug(listplants);


List<Plant__c> listplants = [SELECT Name, Acquisition_Date__c, Species__r.Name FROM Plant__c];
System.debug(listplants);


// Mapeo de quiery
Map<Id, Plant__c> mapPlantsById = new Map<Id, Plant__c> ([SELECT Name, Acquisition_Date__c FROM Plant__c]);
System.debug(mapPlantsById);



// PARENT-TO-CHILD QUERY: tabla ppal parent
List<Species__c> listplants = [SELECT Name, (SELECT Name FROM Plants__r) FROM Species__c];

for (Species__c specie : listplants) {
    System.debug('SPECIE: ' + specie.Name);
    for (Plant__c plant : specie.Plants__r) {
        System.debug('Plant: ' + plant.Name);
    }
}



// Forma sencilla --> AVG, MIN, MAX, SUM
Integer allPoto = [SELECT COUNT() FROM Plant__c WHERE Species__r.Name = 'Poto'];
System.debug(allPoto);

List<AggregateResult> groupedResult = [SELECT AVG(Max_Temperature__c) avgTemp FROM Species__c];

for (AggregateResult aggr : groupedResult) {
    System.debug('Average Temperature: ' + aggr.get('avgTemp'));
}


// Forma agrupada --> Type: 'Edible' or 'Ornamental'
Integer allPoto = [SELECT COUNT() FROM Plant__c WHERE Species__r.Name = 'Poto'];
System.debug(allPoto);

List<AggregateResult> groupedResult = [SELECT AVG(Max_Temperature__c) avgTemp, Type__c FROM Species__c GROUP BY Type__c LIMIT 5];

for (AggregateResult aggr : groupedResult) {
    System.debug('Type__c: ' + aggr.get('Type__c'));
    System.debug('Average Temperature: ' + aggr.get('avgTemp'));
}


// DML: insert, update, delete, undelete, merge
Species__c newSpecie = new Species__c();
newSpecie.Name = 'Tomamte';
insert newSpecie;


// Rollback
Savepoint sp = Database.setSavepoint();

try {

    Species__c newSpecies = new Species__c(Name = 'Rucula');
    insert newSpecies;

    Plant__c newPlant = new Plant__c();
    newPlant.Description__c = 'Nueva Rucula';
    newPlant.Species__c = newSpecies.Id; // Id gets automatically populated on insert
    insert newPlant;

} catch (DmlException e) {
    // Process exception here, for instance log it and show a frendly message to the user...
    Database.rollback(sp);
}

