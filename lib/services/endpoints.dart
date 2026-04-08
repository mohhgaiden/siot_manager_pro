class Endpoints {
  // Auth
  static const login = '/Android/login.php';
  static const access = '/Android/values​_display.php';

  // Home
  static const rooms = '/Android/list_Storage_Space.php';
  static const sensors = '/Android/Data_Space_Tags_Readings.php';

  // chart
  static const chartTag1 = '/Android/Data_Tags_Graph_Date.php';
  static const chartTag2 = '/Android/Data_Tags_Graph_Week.php';
  static const chartAll1 = '/Android/Data_Space_Graph_Date.php';
  static const chartAll2 = '/Android/Data_Space_Graph_Week.php';

  // history
  static const listTags = '/Android/list_Tags.php';
  static const historyDate = '/Android/Data_Tags_Readings_Day.php';
  static const historyWeek = '/Android/Data_Tags_Readings_Week.php';
  static const historyRange = '/Android/Data_Tags_Readings_Date_Range.php';

  // notifications
  static const alertTemp = '/Android/list_Alrt_Temp.php';
  static const alertHum = '/Android/list_Alrt_Humd.php';

  // report
  static const report = '/Android/Data_Report_Space.php';
}
