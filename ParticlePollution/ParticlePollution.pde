
import java.util.*;
import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeFormatter;

// === GLOBAL VARIBALES ===

Table pm25Table;
Table windSpeedTable;
Table windDirectionTable;
Table locationTable;

LocalDate startDate = getLocalDate("Enter the starting date: "+"\nformat: yyyy-mm-dd\ne.g. 2020-01-03"+"\ntime range: 2020-01-01 ~ 2020-12-31");
LocalDate endDate = getLocalDate("Enter the end date: "+"\nformat: yyyy-mm-dd\ne.g. 2020-01-03"+"\ntime range: 2020-01-01 ~ 2020-12-31");
int speed = 200;
int period = Period.between(startDate, endDate).getDays() * speed;
int day = 0;
int count = 1;

PanZoomMap panZoomMap;

void setup() {
  // Size of the graphics window
  size(1600,900);

  // Load tables
  loadRawDataTables();

  // Construct a new PanZoomMap object
  panZoomMap = new PanZoomMap(32.0, -125.0, 43.0, -114.0);

  // Drop the frame
  // frameRate(30);

  // For the test
  // noLoop();
}

void draw() {
  // Clear the screen
  background(230);

  // Draw the bounds of the map
  fill(250);
  stroke(111, 87, 0);
  rectMode(CORNERS);
  float mapX1 = panZoomMap.longitudeToScreenX(-125.0);
  float mapY1 = panZoomMap.latitudeToScreenY(32.0);
  float mapX2 = panZoomMap.longitudeToScreenX(-114.0);
  float mapY2 = panZoomMap.latitudeToScreenY(43.0);
  rect(mapX1, mapY1, mapX2, mapY2);

  // Draw the location points
  
  // for Summary 
  int countCity = 0;
  String[] cityName = new String[0];
  
  for (TableRow locationRow : locationTable.rows()) {
    DataManipulation locationData = new DataManipulation(locationRow, panZoomMap, "location");
    
    // Draw city points
    fill(232, 81, 21);
    noStroke();
    ellipseMode(RADIUS);
    circle(locationData.screenX, locationData.screenY, 2);

    // Draw texts for the local site name
    textSize(12);
    textAlign(LEFT, CENTER);
    float xTextOffset = 2 + 4; // Move the text to the right of the circle
    fill(111, 87, 0);
    text(locationData.localSiteName, locationData.screenX + xTextOffset, locationData.screenY);
    
    // for Summary 
    countCity += 1; //total num of city
    cityName = append(cityName, locationData.localSiteName);
    
  }
  
  // for Summary 
  float[] totalValue = new float[countCity];
  int numDays = Period.between(startDate, endDate).getDays();
  float[] avgValue = new float[countCity];
  

  if (count < period) {
    println("Count: "+count);

    if (count % speed == 0) {
      day += 1;
    }
    println("Date: "+startDate.plusDays(day));
    String stringDate = startDate.plusDays(day).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    textSize(30);
    textAlign(CENTER, CENTER);
    fill(0);
    text(stringDate, 100, 20);
    
    int numCity = 1; // the _th city

    for (TableRow pm25Row : pm25Table.findRows(stringDate, "Date Local")) {
      DataManipulation pm25Data = new DataManipulation(pm25Row, panZoomMap, "pm25");
      
      // for Summary 
      totalValue[numCity] += pm25Data.pm25;
      numCity += 1;

      noStroke();
      fill(pm25Data.lerpColor);
      ellipseMode(RADIUS);
      circle(pm25Data.screenX, pm25Data.screenY, pm25Data.radius);
    }

    count += 1;
  } else {
    // background(230);
    println("Reach the maximum");
  }
  
  // for Summary 
  for (int i = 0; i < countCity; i++){
    avgValue[i] = totalValue[i] / numDays;
  }
  //for Summary - find top 5
  String [] top5Name = new String[5];
  float [] top5Value = new float[5];
  for( int top = 0; top < 5; top++){
    int maxIndex = 0;
    for (int findMax = 0; findMax <avgValue.length; findMax++){
      if (avgValue[findMax] > avgValue[maxIndex]){
        maxIndex = findMax; 
      }
    }
    top5Name[top] = cityName[maxIndex];
    top5Value[top] = avgValue[maxIndex];
    avgValue[maxIndex] = 0;
  }  
  
  //rectangle with details
  fill(250);
  stroke(111, 87, 0);
  rect(1100, -10, 1610, 910);
  
  //Summary
  fill(0);
  textSize(20);
  textAlign(LEFT, CENTER);
  text("Top 5 Average", 1120, 20);
  line(1130, 40, 1130, 300);
  line(1130, 300, 1550, 300);
  fill(0);
  textSize(10);
  textAlign(CENTER, CENTER);
  text("0.0",1140, 310);
  text("0.5",1240, 310);
  text("1.0",1340, 310);
  text("1.5",1440, 310);
  text("2.0",1540, 310);
  for(int top5=0; top5 <5; top5++){
    float amt = top5Value[top5]/2; 
    float bar = lerp(0,400,amt);
    fill(#5E5F5F);
    rect(1140, 60+(top5*50), 1140+bar, 60+(top5*50)+25);
    fill(0);
    textSize(10);
    textAlign(LEFT, CENTER);
    text(top5Name[top5]+": "+top5Value[top5], 1140, 60+(top5*50)-10);
  }

}

void keyPressed() {
  if (key == ' ') {
    println("current scale: ", panZoomMap.scale, " current translation: ", panZoomMap.translateX, "x", panZoomMap.translateY);
  }
}

void mousePressed() {
  panZoomMap.mousePressed();
}

void mouseDragged() {
  panZoomMap.mouseDragged();
}

void mouseWheel(MouseEvent e) {
  panZoomMap.mouseWheel(e);
}

void loadRawDataTables() {
  // Load the pm25 table
  pm25Table = loadTable("daily_88101_2020_california_filtered_drop_duplicates.csv", "header");
  println("pm25 table:", pm25Table.getRowCount(), "x", pm25Table.getColumnCount());
  // Print several rows of the pm25 table
  TableUtils.printNRowFromTable(pm25Table, 3);
  
  println();
  println();
  println();
  
  // Load the wind speed table
  windSpeedTable = loadTable("daily_WIND_2020_california_speed.csv", "header");
  println("wind speed table:", windSpeedTable.getRowCount(), "x", windSpeedTable.getColumnCount());
  // Print several rows of the wind speed table
  TableUtils.printNRowFromTable(windSpeedTable, 3);

  println();
  println();
  println();

  // Load the wind direction table
  windDirectionTable = loadTable("daily_WIND_2020_california_direction.csv", "header");
  println("wind direction table:", windDirectionTable.getRowCount(), "x", windDirectionTable.getColumnCount());
  // Print several rows of the wind table
  TableUtils.printNRowFromTable(windDirectionTable, 3);

  println();
  println();
  println();

  // Load the location table
  locationTable = loadTable("locations.csv", "header");
  println("location table:", locationTable.getRowCount(), "x", locationTable.getColumnCount());
  // Print several rows of the locations table
  TableUtils.printNRowFromTable(locationTable, 3);
}

void computeDerivedData() {
  // Minimum and maximum of PM 2.5 values
  // minPm25 = TableUtils.findMinFloatInColumn(pm25Table, "Arithmetic Mean");
  // maxPm25 = TableUtils.findMaxFloatInColumn(pm25Table, "Arithmetic Mean");
  // println("PM 2.5 range:", minPm25, "to", maxPm25);
}
