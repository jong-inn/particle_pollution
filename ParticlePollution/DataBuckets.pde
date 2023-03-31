
class DataBuckets{
  
  String city;
  LocalDate start = LocalDate.of(2020,1,1); 
  LocalDate end = LocalDate.of(2020,12,31);
  String[] cityName;
  float[] avgValue;
  int[] top;
  Table summaryTable;
  Table pm25Table;
  
  public DataBuckets(Table locationTable, Table pm25Table){
    this.summaryTable = locationTable;
    summaryTable.addColumn("PM25 Average", Table.FLOAT); // add a average column
    this.pm25Table = pm25Table;
    calcAvg();
  }
  
  public DataBuckets(Table locationTable, Table pm25Table, LocalDate start, LocalDate end){
    this.summaryTable = locationTable;
    summaryTable.addColumn("PM25 Average", Table.FLOAT); // add a average column
    this.pm25Table = pm25Table;
    this.start = start;
    this.end = end;
    calcAvg();
  }
  
  void calcAvg(){
    // for Summary - cityName
    int countCity = 0;
    cityName = new String[0];
    for (TableRow summaryRow : summaryTable.rows()) {
      DataManipulation summaryData = new DataManipulation(summaryRow, panZoomMap, "location");
      countCity += 1; //total num of city
      cityName = append(cityName, summaryData.localSiteName);
    }

    // for Summary - totalValue / avgValue
    float[] totalValue = new float[countCity];
    avgValue = new float[countCity];
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
      avgValue[i] = totalValue[i] / Period.between(startDate, endDate).getDays();
    }

    // put averages into the average column
    for (int i=0; i<cityName.length; i++) {
      TableRow summaryRow = summaryTable.findRow(cityName[i], "Local Site Name"); // find the row containing the specific Local Site Name
      summaryRow.setFloat("PM25 Average", avgValue[i]); // put the average into the PM25 Average column
    }
  }
  
  void topIndex(int size){
    top = new int[size];
    float[] temp = Arrays.copyOf(avgValue, avgValue.length);
    for( int i = 0; i < size; i++){
      int maxIndex = 0;
      for (int findMax = 0; findMax <avgValue.length; findMax++){
        if (temp[findMax] > temp[maxIndex]){
          maxIndex = findMax; 
        }
      }
      top[i] = maxIndex;
      temp[maxIndex] = 0;
    }
  }
  
  String[] topName(int size){
    topIndex(size);
    String[] topName = new String[size];
    for (int i=0; i < top.length; i++){
      int index = top[i];
      topName[i] = cityName[index];
    }
    return topName;
  }
  
  float[] topValue(int size){
    topIndex(size);
    float[] topValue = new float[size];
    for (int i=0; i < top.length; i++){
      int index = top[i];
      topValue[i] = avgValue[index];
    }
    return topValue;
  }
  
  float getAvg(String city){
    this.city = city;
    float targetAvg = avgValue[0];
    for (int i=0; i < cityName.length; i++){
      if (cityName[i].equals(city)){
        targetAvg = avgValue[i];
      }
    }
    return targetAvg;
  }
   
}
