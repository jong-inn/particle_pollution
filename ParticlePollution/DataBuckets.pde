
class DataBuckets{
  
  String city;
  LocalDate start = LocalDate.of(2020,1,1); 
  LocalDate end = LocalDate.of(2020,12,31);
  String[] cityName;
  float[] pm25AvgValue;
  float[] windAvgValue;
  float[] windAvgDirection;
  int[] pm25Top;
  Table summaryTable;
  Table pm25Table;
  Table windTable;
  
  public DataBuckets(String dataTarget, Table locationTable, Table dataTable){
    this.summaryTable = locationTable;
    if (dataTarget.equals("pm25")){
      summaryTable.addColumn("PM25 Average", Table.FLOAT); // add a average column
      this.pm25Table = dataTable;
      pm25CalcAvg();
    }
    if (dataTarget.equals("wind")){
      summaryTable.addColumn("Wind Value Average", Table.FLOAT); // add a average column
      summaryTable.addColumn("Wind Direction Average", Table.FLOAT); // add a average column
      this.windTable = dataTable;
      windCalcAvg();
    }
  }
  
  public DataBuckets(String dataTarget, Table locationTable, Table dataTable, LocalDate start, LocalDate end){
    this.summaryTable = locationTable;
    this.start = start;
    this.end = end;
    if (dataTarget.equals("pm25")){
      summaryTable.addColumn("PM25 Average", Table.FLOAT); // add a average column
      this.pm25Table = dataTable;
      pm25CalcAvg();
    }
    if (dataTarget.equals("wind")){
      summaryTable.addColumn("Wind Value Average", Table.FLOAT); // add a average column
      summaryTable.addColumn("Wind Direction Average", Table.FLOAT); // add a average column
      this.windTable = dataTable;
      windCalcAvg();
    }
  }
  
  //for Summary
  void pm25CalcAvg(){ 
    // cityName
    int countCity = 0;
    cityName = new String[0];
    for (TableRow summaryRow : summaryTable.rows()) {
      DataManipulation summaryData = new DataManipulation(summaryRow, panZoomMap, "location");
      countCity += 1; //total num of city
      cityName = append(cityName, summaryData.localSiteName);
    }

    // totalValue / avgValue
    float[] totalValue = new float[countCity];
    pm25AvgValue = new float[countCity];
    for (int day = 0; day < Period.between(startDate, endDate).getDays(); day++){
      String targetDate = startDate.plusDays(day).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
      for (TableRow pm25Row : pm25Table.findRows(targetDate, "Date Local")){
        DataManipulation pm25Data = new DataManipulation(pm25Row , panZoomMap, "pm25");
        for (int numCity = 0; numCity < countCity; numCity++ ) {
          if (pm25Data.localSiteName.equals(cityName[numCity])){
            totalValue[numCity] += pm25Data.pm25;
          }
        }   
      }
    }
    for (int i = 0; i < countCity; i++){
      pm25AvgValue[i] = totalValue[i] / Period.between(startDate, endDate).getDays();
    }

    // put averages into the average column
    for (int i=0; i<cityName.length; i++) {
      TableRow summaryRow = summaryTable.findRow(cityName[i], "Local Site Name"); // find the row containing the specific Local Site Name
      summaryRow.setFloat("PM25 Average", pm25AvgValue[i]); // put the average into the PM25 Average column
    }
  }
  
  void windCalcAvg(){
    // cityName
    int countCity = 0;
    cityName = new String[0];
    for (TableRow summaryRow : summaryTable.rows()) {
      DataManipulation summaryData = new DataManipulation(summaryRow, panZoomMap, "location");
      countCity += 1; //total num of city
      cityName = append(cityName, summaryData.localSiteName);
    }

    // totalValue / avgValue
    float[] totalValue = new float[countCity];
    float[] totalDirection = new float[countCity];
    windAvgValue = new float[countCity];
    windAvgDirection = new float[countCity];
    for (int day = 0; day < Period.between(startDate, endDate).getDays(); day++){
      String targetDate = startDate.plusDays(day).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
      for (TableRow windRow : windTable.findRows(targetDate, "Date Local")){
        DataManipulation windData = new DataManipulation(windRow , panZoomMap, "wind");
        for (int numCity = 0; numCity < countCity; numCity++ ) {
          if (windData.localSiteName.equals(cityName[numCity])){
            totalValue[numCity] += windData.windSpeed;
            totalDirection[numCity] += windData.windDirection;
          }
        }   
      }
    }
    for (int i = 0; i < countCity; i++){
      windAvgValue[i] = totalValue[i] / Period.between(startDate, endDate).getDays();
      windAvgDirection[i] = totalDirection[i] / Period.between(startDate, endDate).getDays();
    }

    // put averages into the average column
    for (int i=0; i<cityName.length; i++) {
      TableRow summaryRow = summaryTable.findRow(cityName[i], "Local Site Name"); // find the row containing the specific Local Site Name
      summaryRow.setFloat("Wind Value Average", windAvgValue[i]); // put the average into the Wind Value Average column
      summaryRow.setFloat("Wind Direction Average", windAvgDirection[i]); // put the average into the Wind Direction Average column
    }
  }
  
  void pm25TopIndex(int size){
    pm25Top = new int[size];
    float[] temp = Arrays.copyOf(pm25AvgValue, pm25AvgValue.length);
    for( int i = 0; i < size; i++){
      int maxIndex = 0;
      for (int findMax = 0; findMax <pm25AvgValue.length; findMax++){
        if (temp[findMax] > temp[maxIndex]){
          maxIndex = findMax; 
        }
      }
      pm25Top[i] = maxIndex;
      temp[maxIndex] = 0;
    }
  }
  
  String[] pm25TopName(int size){
    pm25TopIndex(size);
    String[] topName = new String[size];
    for (int i=0; i < pm25Top.length; i++){
      int index = pm25Top[i];
      topName[i] = cityName[index];
    }
    return topName;
  }
  
  float[] pm25TopValue(int size){
    pm25TopIndex(size);
    float[] topValue = new float[size];
    for (int i=0; i < pm25Top.length; i++){
      int index = pm25Top[i];
      topValue[i] = pm25AvgValue[index];
    }
    return topValue;
  }
  
  float pm25GetAvg(String city){
    this.city = city;
    float targetAvg = pm25AvgValue[0];
    for (int i=0; i < cityName.length; i++){
      if (cityName[i].equals(city)){
        targetAvg = pm25AvgValue[i];
      }
    }
    return targetAvg;
  }
   
}
