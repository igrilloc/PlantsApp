@isTest
private class DateServiceTest {
  @isTest
  static void testGetCurrentMonth() {
    // Arrange
    Integer expectedMonth = System.today().month();
    DateService dateServiceInstance = new DateService();

    // Act
    Integer currentMonth = dateServiceInstance.getCurrentMonth();

    // Assert
    System.assertEquals(
      expectedMonth,
      currentMonth,
      'The current month should be as expected'
    );
  }
}
