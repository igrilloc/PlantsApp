public with sharing class ForecastService {
  public static void postNotifications() {
    // 1. Mirar que temperaturas va hacer hoy
    Forecast fService = ForecastService.getTodaysTemperaturas();
    Integer maxTemperatureToday = fService.temperaturas.max;
    Integer minTemperatureToday = fService.temperaturas.min;

    // 2. Mirar si tengo alguna planta pra la cual la temp no sea adecuada

    // Query dinamica:
    // List<Plant__c> plantsWithProblem = Database.query('SELECT FROM Species__c WHERE Max_Temperature__c < :maxTemperatureToday');

    // Query estatica:
    List<Plant__c> plantsWithProblem = [
      SELECT
        Name,
        Species__r.Max_Temperature__c,
        Species__r.Min_Temperature__c,
        Species__r.Name
      FROM Plant__c
      WHERE
        Species__c IN (
          SELECT Id
          FROM Species__c
          WHERE
            Max_Temperature__c < :maxTemperatureToday
            OR Min_Temperature__c > :minTemperatureToday
        )
      WITH SECURITY_ENFORCED
    ];

    // 3. Si encuentro alguna, mandar notificacion
    for (Plant__c plantProblem : plantsWithProblem) {
      CustomNotificationType notificationType = [
        SELECT Id, DeveloperName
        FROM CustomNotificationType
        WHERE DeveloperName = 'Temperature_Alert'
        WITH SECURITY_ENFORCED
      ];

      Messaging.CustomNotification notification = new Messaging.CustomNotification();

      setNotificationMessage(
        notification,
        maxTemperatureToday,
        minTemperatureToday,
        plantProblem
      );

      notification.setNotificationTypeId(notificationType.Id);
      notification.setTargetId(plantProblem.Id);

      try {
        notification.send(new Set<String>{ UserInfo.getUserId() });
      } catch (Exception error) {
        System.debug('Problem sending notification: ' + error.getMessage());
      }

      // Send a platform event
      Plant_with_Problem__e plantProblemEvent = new Plant_with_Problem__e(
        Alert_Type__c = 'cold',
        Plant_Id__c = plantProblem.Id
      );

      List<Plant_with_Problem__e> plantsProblemEvent = new List<Plant_with_Problem__e>();
      plantsProblemEvent.add(plantProblemEvent);

      // Call method to publish events
      List<Database.SaveResult> results = EventBus.publish(plantsProblemEvent);

      // Inspect publishing result for each event
      for (Database.SaveResult rst : results) {
        if (rst.isSuccess()) {
          System.debug('Successfully published event.');
        } else {
          for (Database.Error error : rst.getErrors()) {
            System.debug(
              'Error returned: ' +
                error.getStatusCode() +
                ' - ' +
                error.getMessage()
            );
          }
        }
      }
    }
  }

  private static void setNotificationMessage(
    Messaging.CustomNotification notification,
    Integer maxTemperatureToday,
    Integer minTemperatureToday,
    Plant__c plant
  ) {
    if (plant.Species__r.Max_Temperature__c < maxTemperatureToday) {
      notification.setTitle('¡Hace mucho calor para tu planta!');
      notification.setBody(
        'Hoy el termómetro alcanzará ' +
          maxTemperatureToday +
          ' grados.\n' +
          ' La temperatura máxima que ' +
          plant.Name +
          ' (' +
          plant.Species__r.Name +
          ') soporta es ' +
          plant.Species__r.Max_Temperature__c
      );
    } else if (plant.Species__r.Min_Temperature__c > minTemperatureToday) {
      notification.setTitle('¡Hace mucho frío para tu planta!');
      notification.setBody(
        'Hoy el termómetro bajará de los ' +
          minTemperatureToday +
          ' grados.\n' +
          ' La temperatura miníma que ' +
          plant.Name +
          ' (' +
          plant.Species__r.Name +
          ') soporta es ' +
          plant.Species__r.Max_Temperature__c
      );
    }
  }

  public static Forecast getTodaysTemperaturas() {
    HttpRequest req = new HttpRequest();
    req.setEndpoint(
      'callout:El_tiempo/api/json/v2/provincias/18/municipios/18087'
    );
    req.setMethod('GET');

    Http http = new Http();
    HttpResponse res = http.send(req);
    String body = res.getBody();

    Forecast forecast = (Forecast) JSON.deserialize(body, Forecast.class);
    return forecast;
  }

  public class Forecast {
    public Temperaturas temperaturas;
  }

  public class Temperaturas {
    public Integer max;
    public Integer min;
  }
}
