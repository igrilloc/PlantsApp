@isTest
private with sharing class FrequencyServiceTest {
  @isTest
  static void getWateringDays_wateringFreqDailyAndWinter_oneDay() {
    // Mock System.today() - emular en el test en qué mes del año estoy
    DateServiceMock mock = new DateServiceMock();
    mock.monthToReturn = 1;

    DateService mockDateService = (DateService) Test.createStub(
      DateService.class,
      mock
    );

    // GIVEN - Creación de datos, escenario...
    Species__c specie = new Species__c();
    specie.Winter_Watering_Frequency__c = 'Daily';
    specie.Summer_Watering_Frequency__c = 'Weekly';

    // WHEN - llamamos al método
    Integer days = FrequencyService.getWateringDays(specie, mockDateService);

    // THEN - Chequear el resultado esperado
    Integer expectedDays = 1;
    System.assertEquals(expectedDays, days, 'Expected 1 day returned');
  }

  @isTest
  static void getWateringDays_wateringFreqDailyAndSummer_oneDay() {
    // Mock System.today() - emular en el test en qué mes del año estoy
    DateServiceMock mock = new DateServiceMock();
    mock.monthToReturn = 8;

    DateService mockDateService = (DateService) Test.createStub(
      DateService.class,
      mock
    );

    // GIVEN - Creación de datos, escenario...
    Species__c specie = new Species__c();
    specie.Winter_Watering_Frequency__c = 'Weekly';
    specie.Summer_Watering_Frequency__c = 'Daily';

    // WHEN - llamamos al método
    Integer days = FrequencyService.getWateringDays(specie, mockDateService);

    // THEN - Chequear el resultado esperado
    Integer expectedDays = 1;
    System.assertEquals(expectedDays, days, 'Expected 1 day returned');
  }

  @isTest
  static void getWateringDays_wateringFreqTwicePerWeekAndWinter_threeDays() {
    // Mock System.today() - emular en el test en qué mes del año estoy
    DateServiceMock mock = new DateServiceMock();
    mock.monthToReturn = 1;

    DateService mockDateService = (DateService) Test.createStub(
      DateService.class,
      mock
    );

    // GIVEN - Creación de datos, escenario...
    Species__c specie = new Species__c();
    specie.Winter_Watering_Frequency__c = 'Twice per week';
    specie.Summer_Watering_Frequency__c = 'Daily';

    // WHEN - llamamos al método
    Integer days = FrequencyService.getWateringDays(specie, mockDateService);

    // THEN - Chequear el resultado esperado
    Integer expectedDays = 3;
    System.assertEquals(expectedDays, days, 'Expected 3 days returned');
  }

  @isTest
  static void getFertilizationDays_fertilizationFreqMonthlyAndSummer_fiveDays() {
    // Mock System.today() - emulate in the test which month of the year it is
    DateServiceMock mock = new DateServiceMock();
    mock.monthToReturn = 6; // July

    DateService mockDateService = (DateService) Test.createStub(
      DateService.class,
      mock
    );

    // GIVEN - Data creation, scenario...
    Species__c specie = new Species__c();
    specie.Winter_Fertilization_Frequency__c = 'Monthly';
    specie.Summer_Fertilization_Frequency__c = 'Monthly';

    // WHEN - Call the method
    Integer days = FrequencyService.getFertilizationDays(
      specie,
      mockDateService
    );
  }

  @isTest
  static void getFertilizationDays_fertilizationFreqQuarterlyAndWinter_sevenDays() {
    // Mock System.today() - emulate in the test which month of the year it is
    DateServiceMock mock = new DateServiceMock();
    mock.monthToReturn = 1; // January

    DateService mockDateService = (DateService) Test.createStub(
      DateService.class,
      mock
    );

    // GIVEN - Data creation, scenario...
    Species__c specie = new Species__c();
    specie.Winter_Fertilization_Frequency__c = 'Quarterly';
    specie.Summer_Fertilization_Frequency__c = 'Bi-Weekly';

    // WHEN - Call the method
    Integer days = FrequencyService.getFertilizationDays(
      specie,
      mockDateService
    );
  }

  public class DateServiceMock implements System.StubProvider {
    public Integer monthToReturn;

    public Object handleMethodCall(
      Object stubbedObject,
      String stubbedMethodName,
      Type returnType,
      List<Type> listOfParamTypes,
      List<String> listOfParamNames,
      List<Object> listOfArgs
    ) {
      // The following debug statements show an example of logging
      // the invocation of a mocked method.

      // You can use the method name and return type to determine which method was called.
      System.debug('Name of stubbed method: ' + stubbedMethodName);
      System.debug('Return type of stubbed method: ' + returnType.getName());

      // You can also use the parameter names and types to determine which method
      // was called.
      for (integer i = 0; i < listOfParamNames.size(); i++) {
        System.debug('parameter name: ' + listOfParamNames.get(i));
        System.debug('  parameter type: ' + listOfParamTypes.get(i).getName());
      }

      // This shows the actual parameter values passed into the stubbed method at runtime.
      System.debug(
        'number of parameters passed into the mocked call: ' + listOfArgs.size()
      );
      System.debug('parameter(s) sent into the mocked call: ' + listOfArgs);

      // Emular lo que queremos que haga el metodo
      return monthToReturn;
    }
  }
}
