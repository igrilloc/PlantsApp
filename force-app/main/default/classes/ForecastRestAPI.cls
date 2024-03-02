@RestResource(urlMapping='/checkForecast')
global with sharing class ForecastRestAPI {
  @HttpGet
  global static void doGet() {
    ForecastService.postNotifications();
  }
}
