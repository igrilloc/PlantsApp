@isTest
private class PlantTriggerTest {
  @isTest
  static void insertPlant_lastWateredSetup_nextWateringDateCalculatedCorrectly() {
    // GIVEN
    Species__c poto = new Species__c(
      Name = 'Poto',
      Winter_Watering_Frequency__c = 'Every other week',
      Summer_Watering_Frequency__c = 'Every other week'
    );

    insert poto;

    // WHEN
    Plant__c plant1 = new Plant__c(
      Last_Fertilized__c = System.today(),
      Last_Watered__c = System.today(),
      Species__c = poto.Id
    );

    Test.startTest();
    insert plant1;
    Test.stopTest();

    // THEN
    plant1 = [
      SELECT Next_Water__c
      FROM Plant__c
      WHERE Id = :plant1.Id
    ];

    System.assertEquals(System.today().addDays(15), plant1.Next_Water__c);
  }
}
