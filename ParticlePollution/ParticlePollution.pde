
import java.util.*;
import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeFormatter;

// === GLOBAL VARIBALES ===

Table pm25Table;
Table windTable;
Table locationTable;
PImage map;

float maxY;

LocalDate startDate = getLocalDate("Enter the starting date: "+"\nformat: yyyy-mm-dd\ne.g. 2020-01-03"+"\ntime range: 2020-01-01 ~ 2020-12-31");
LocalDate endDate = getLocalDate("Enter the end date: "+"\nformat: yyyy-mm-dd\ne.g. 2020-01-03"+"\ntime range: 2020-01-01 ~ 2020-12-31");
float speed = 50;
int totalDays = Period.between(startDate, endDate).getDays() + 1;
float period = (totalDays-1) * speed;
int day = 0;
float count = 0;
boolean status = false; // Paused in the beginning
boolean windStatus = true; // Option for showing the wind data
boolean firstMousePress = false;

// Scroll bar variables
float xPosScrollbar, yPosScrollbar;
int widthScrollbar, heightScrollbar;

String highlightedLocation = "";
String selectedLocation1 = "";
color colorForSelectedLocation1 = color(255, 174, 66); // Yellow Orange
String selectedLocation2 = "";
color colorForSelectedLocation2 = color(0, 57, 153); // Medium Dark Shade of Cyan Blue

String [] top5Name; // summary
float [] top5Value; // summary

PanZoomMap panZoomMap;
DataBuckets summaryPm25;
DataBuckets summaryWind;

HScrollbar hScrollbar;

// Graph variables
float xGraphZeroPoint = 1140;
float yGraphZeroPoint = 850;
float graphHeight = 410;
float graphWidth = 430;

// Info Graph - Input Variables (with initialization)
float[] pm25InfoLocation1 = new float[totalDays];
float[] pm25InfoLocation2 = new float[totalDays]; 
float[] windSpeedInfoLocation1 = new float[totalDays];
float[] windSpeedInfoLocation2 = new float[totalDays];
float[] windDirectionInfoLocation1 = new float[totalDays];
float[] windDirectionInfoLocation2 = new float[totalDays];
String[] arrayStringDate = new String[totalDays];

void setup() {
  // Size of the graphics window
  size(1600,900);

  // Load a California map
  map = loadImage("california_simple_map.png");

  // Load tables
  loadRawDataTables();

  // Construct a new PanZoomMap object
  panZoomMap = new PanZoomMap(32.0, -125.0, 43.0, -114.0);
  
  summaryPm25 = new DataBuckets("pm25", locationTable, pm25Table, startDate, endDate);
  top5Name = summaryPm25.pm25TopName(5);
  top5Value = summaryPm25.pm25TopValue(5);

  summaryWind = new DataBuckets("wind", locationTable, windTable, startDate, endDate);

  // Info Graph
  Arrays.fill(pm25InfoLocation1,-1);
  Arrays.fill(pm25InfoLocation2,-1);
  Arrays.fill(windSpeedInfoLocation1,-1);
  Arrays.fill(windSpeedInfoLocation2,-1);
  Arrays.fill(windDirectionInfoLocation1,-1);
  Arrays.fill(windDirectionInfoLocation2,-1);

  for (int countDay = 0; countDay < (totalDays); countDay++){
    String stringDate = startDate.plusDays(countDay).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    arrayStringDate[countDay] = stringDate.replace("2020-", "");
  }

  // Scroll bar
  xPosScrollbar = 100;
  yPosScrollbar = height-50;
  widthScrollbar = 900;
  heightScrollbar = 10;
  hScrollbar = new HScrollbar(xPosScrollbar, yPosScrollbar, widthScrollbar, heightScrollbar, 1, arrayStringDate, speed);
}

void draw() {
  // Clear the screen
  background(230);

  // Get highlighted location
  highlightedLocation = getLocationUnderMouse(locationTable, panZoomMap);

  // Draw the bounds of the map
  fill(250);
  stroke(111, 87, 0);
  rectMode(CORNERS);
  float mapX1 = panZoomMap.longitudeToScreenX(-125.0);
  float mapY1 = panZoomMap.latitudeToScreenY(32.0);
  float mapX2 = panZoomMap.longitudeToScreenX(-114.0);
  float mapY2 = panZoomMap.latitudeToScreenY(43.0);
  rect(mapX1, mapY1, mapX2, mapY2);

  // Draw the California map
  imageMode(CORNERS);
  image(map, mapX1, mapY1, mapX2, mapY2);

  fill(0);
  textSize(20);
  textAlign(LEFT, CENTER);
  text("From: "+startDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")), 50, 70);
  text("To  : "+endDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")), 50, 100);

  // Draw the location points
  for (TableRow locationRow : locationTable.rows()) {
    DataManipulation locationData = new DataManipulation(locationRow, panZoomMap, "location");

    // Highlight the locations
    highlightingLocations(panZoomMap, locationData, highlightedLocation, selectedLocation1, selectedLocation2);

    // If the pivot location is selected, filter out the remaining area
    if (selectedLocation1.equals(locationData.localSiteName)) {
      noStroke();
      fill(211, 211, 211, 60);
      ellipseMode(RADIUS);
      circle(locationData.screenX, locationData.screenY, panZoomMap.mapLengthToScreenLength(0.5));
    }
    
    // Draw city points
    fill(232, 81, 21);
    noStroke();
    ellipseMode(RADIUS);
    circle(locationData.screenX, locationData.screenY, panZoomMap.mapLengthToScreenLength(0.01));
  }

  // Store the current coordination
  pushMatrix();

  if (count == 0) {
    fill(0);
    textSize(25);
    textAlign(LEFT, CENTER);
    text("Average Overview", 50, 30);

    // Draw the average PM25 data on the summary map
    for (TableRow summaryPm25Row : summaryPm25.summaryTable.rows()) {
      DataManipulation summaryPm25Data = new DataManipulation(summaryPm25Row, panZoomMap, "pm25");
      
      // Highlight the locations
      highlightingLocations(panZoomMap, summaryPm25Data, highlightedLocation, selectedLocation1, selectedLocation2);

      noStroke();
      fill(summaryPm25Data.lerpColor, 220);
      ellipseMode(RADIUS);
      circle(summaryPm25Data.screenX, summaryPm25Data.screenY, panZoomMap.mapLengthToScreenLength(summaryPm25Data.radius*0.01));
    }

    // Draw the average wind data on the summary map
    for (TableRow summaryWindRow : summaryWind.summaryTable.rows()) {
      DataManipulation summaryWindData = new DataManipulation(summaryWindRow, panZoomMap, "wind");
      
      pushMatrix();
      translate(summaryWindData.screenX, summaryWindData.screenY); // Translate to the center of the location
      rotate(radians(summaryWindData.windDirection - 180));
      rectMode(CORNERS);
      noStroke();
      fill(30, 144, 255); // Dodgerblue
      rect(-1, 7, 1, -7);

      pushMatrix();
      translate(0, 7); // Translate to the top of the rectangle
      rotate(frameCount * summaryWindData.rotationSpeed);
      noStroke();
      fill(0, 191, 255); // Deepskyblue
      star(0, 0, 3, 7, 5);
      popMatrix();

      popMatrix();
    }

    if (status == true) {
      count += 1;
    }
  } else if (count != 0) {
    if (count % speed == 0 && status == true && day < (period / speed)) {
      day += 1;
      println("Day: "+day);
      String stringDate2 = startDate.plusDays(day).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
      println("Date: "+stringDate2);
    }
    String stringDate = startDate.plusDays(day).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    textSize(30);
    textAlign(CENTER, CENTER);
    fill(0);
    text(stringDate, 100, 20);

    for (TableRow pm25Row : pm25Table.findRows(stringDate, "Date Local")) {
      DataManipulation pm25Data = new DataManipulation(pm25Row, panZoomMap, "pm25");

      // Highlight the locations
      highlightingLocations(panZoomMap, pm25Data, highlightedLocation, selectedLocation1, selectedLocation2);

      noStroke();
      fill(pm25Data.lerpColor, 220);
      ellipseMode(RADIUS);
      circle(pm25Data.screenX, pm25Data.screenY, panZoomMap.mapLengthToScreenLength(pm25Data.radius*0.01));

    }

    if (windStatus == true) {
      for (TableRow windRow : windTable.findRows(stringDate, "Date Local")) {
        DataManipulation windData = new DataManipulation(windRow, panZoomMap, "wind");

        pushMatrix();
        translate(windData.screenX, windData.screenY); // Translate to the center of the location
        rotate(radians(windData.windDirection - 180));
        rectMode(CORNERS);
        noStroke();
        fill(30, 144, 255); // Dodgerblue
        rect(-1, 7, 1, -7);

        pushMatrix();
        translate(0, 7); // Translate to the top of the rectangle
        rotate(frameCount * windData.rotationSpeed);
        noStroke();
        fill(0, 191, 255); // Deepskyblue
        star(0, 0, 3, 7, 5);
        popMatrix();

        popMatrix();
      }
    }

    if (status == true) {
      count += 1;
    }
  }

  hScrollbar.update(count, firstMousePress, status);
  hScrollbar.display();
  // if (hScrollbar.count != count) {
  //   count = hScrollbar.count;
  //   day = (int) count / (int) speed;
  // }


  // Restore the first coordination
  popMatrix();
  
  //rectangle with details
  fill(250);
  stroke(111, 87, 0);
  rectMode(CORNERS);
  rect(1100, -10, 1610, 910);
  
  // summary
  fill(0);
  textSize(20);
  textAlign(LEFT, CENTER);
  text("Top 5 Average", 1120, 20);
  line(1130, 40, 1130, 300);
  line(1130, 300, 1550, 300);
  fill(0);
  textSize(10);
  textAlign(LEFT, CENTER);
  text("0",1140, 310);
  text(top5Value[0]/2,1340, 310);
  text(top5Value[0],1540, 310);
  for(int top5=0; top5 <5; top5++){
    float amt = top5Value[top5]/top5Value[0]; 
    float bar = lerp(0,400,amt);
    fill(#5E5F5F);
    rect(1140, 60+(top5*50), 1140+bar, 60+(top5*50)+25);
    fill(0);
    textSize(10);
    textAlign(LEFT, CENTER);
    text(top5Name[top5]+": "+top5Value[top5], 1140, 60+(top5*50)-10);
  }

  // Info Graph - PM25 Input
  if (selectedLocation1 != ""){
    for (TableRow loc1 : pm25Table.findRows(selectedLocation1, "Local Site Name")){
      DataManipulation selectedPM = new DataManipulation(loc1, panZoomMap, "pm25");
      for (int countDay = 0; countDay < (totalDays); countDay++){
        String stringDate = startDate.plusDays(countDay).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        if (selectedPM.date.equals(stringDate)){
          pm25InfoLocation1[countDay] = selectedPM.pm25;
        }
      }
    }
  }
   if (selectedLocation2 != ""){
    for (TableRow loc2 : pm25Table.findRows(selectedLocation2, "Local Site Name")){
      DataManipulation selectedPM = new DataManipulation(loc2, panZoomMap, "pm25");
      for (int countDay = 0; countDay < (totalDays); countDay++){
        String stringDate = startDate.plusDays(countDay).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        if (selectedPM.date.equals(stringDate)){
          pm25InfoLocation2[countDay] = selectedPM.pm25;
        }
      }
    }
  }
  
  // Info Graph - wind Input
  if (selectedLocation1 != ""){
    for (TableRow loc1 : windTable.findRows(selectedLocation1, "Local Site Name")){
      DataManipulation selectedWind = new DataManipulation(loc1, panZoomMap, "wind");
      for (int countDay = 0; countDay < (totalDays); countDay++){
        String stringDate = startDate.plusDays(countDay).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        if (selectedWind.date.equals(stringDate)){
          windSpeedInfoLocation1[countDay] = selectedWind.windSpeed;
          windDirectionInfoLocation1[countDay] = selectedWind.windDirection;
        }   
      }
    }
  }
  if (selectedLocation2 != ""){
    for (TableRow loc2 : windTable.findRows(selectedLocation2, "Local Site Name")){
      DataManipulation selectedWind = new DataManipulation(loc2, panZoomMap, "wind");
      for (int countDay = 0; countDay < (totalDays); countDay++){
        String stringDate = startDate.plusDays(countDay).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        if (selectedWind.date.equals(stringDate)){
          windSpeedInfoLocation2[countDay] = selectedWind.windSpeed;
          windDirectionInfoLocation2[countDay] = selectedWind.windDirection;
        }   
      }
    }
  }

  // daily line graph
  fill(0);
  textSize(20);
  textAlign(LEFT, CENTER);
  text("Daily Data for Selected Cities", 1120, 360);
  textSize(15);
  text("Pivot Location", 1140, 395);
  text("Comparing Location",1140, 415);

  fill(colorForSelectedLocation1);
  text("(Color Yellow)", 1232, 395);
  fill(colorForSelectedLocation2);
  text("(Color Blue)", 1270, 415);
  
  fill(0);
  text(": " + selectedLocation1, 1322, 395);
  text(": " + selectedLocation2, 1348, 415);

  line(xGraphZeroPoint, yGraphZeroPoint-graphHeight, xGraphZeroPoint, yGraphZeroPoint); // y axis
  line(xGraphZeroPoint, yGraphZeroPoint, xGraphZeroPoint+graphWidth, yGraphZeroPoint); // x axis

  if (selectedLocation1 == "" && selectedLocation2 == ""){
    maxY = 0;
  } else if (selectedLocation2 == ""){
    maxY = max(pm25InfoLocation1);
  } else if (selectedLocation1 == ""){
    maxY = max(pm25InfoLocation2);
  }else{
    maxY = max(max(pm25InfoLocation1), max(pm25InfoLocation2));
  }

  

  if (selectedLocation1 != "" && count != 0) {
    DailyGraph dailyGraph1 = new DailyGraph(
      pm25InfoLocation1, 
      windSpeedInfoLocation1, 
      windDirectionInfoLocation1, 
      arrayStringDate, 
      maxY, 
      colorForSelectedLocation1, 
      day, 
      -10, 
      1
    );
    dailyGraph1.drawGraph();
  }

  if (selectedLocation2 != "" && count != 0) {
    DailyGraph dailyGraph2 = new DailyGraph(
      pm25InfoLocation2, 
      windSpeedInfoLocation2,
      windDirectionInfoLocation2,
      arrayStringDate, 
      maxY, 
      colorForSelectedLocation2, 
      day, 
      10,
      2
    );
    dailyGraph2.drawGraph();
  }

  // For pressing the scroll bar
  if (firstMousePress) {
    firstMousePress = false;
  }
}

void keyPressed() {
  if (key == ' ') {
    println("current scale: ", panZoomMap.scale, " current translation: ", panZoomMap.translateX, "x", panZoomMap.translateY);
  } else if (key == ENTER || key == RETURN) {
    // Play and stop by the enter or return key
    if (status == true) {
      status = false;
      println("pause");
    } else if (status == false) {
      status = true;
      println("play");
    }
  }
}

void mousePressed() {
  // For pressing the scroll bar
  if (mouseX >= xPosScrollbar && mouseX <= (xPosScrollbar+widthScrollbar) && mouseY >= (yPosScrollbar+heightScrollbar) && mouseY <= yPosScrollbar) {
    if (!firstMousePress) {
      firstMousePress = true;
    }
  }

  // Select the pivot location
  if (highlightedLocation != "" && selectedLocation1.equals("") && !selectedLocation2.equals(highlightedLocation)) {
    selectedLocation1 = highlightedLocation;
    println("Selected Location 1: " + selectedLocation1);
  // Select the comparing location
  } else if (highlightedLocation != "" && selectedLocation2.equals("") && !selectedLocation1.equals(highlightedLocation)) {
    selectedLocation2 = highlightedLocation;
    println("Selected Location 2: " + selectedLocation2);
  // Unselect the pviot location
  } else if (highlightedLocation.equals(selectedLocation1)) {
    println("Unselect the Location 1: "+selectedLocation1);
    selectedLocation1 = "";
  // Unselect the comparing location
  } else if (highlightedLocation.equals(selectedLocation2)) {
    println("Unselect the Location 2: "+selectedLocation2);
    selectedLocation2 = "";
  }

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
  pm25Table = loadTable("daily_88101_2020_california_final.csv", "header");
  println("pm25 table:", pm25Table.getRowCount(), "x", pm25Table.getColumnCount());
  // Print several rows of the pm25 table
  TableUtils.printNRowFromTable(pm25Table, 3);
  
  println();
  println();
  println();
  
  // Load the wind table
  windTable = loadTable("daily_WIND_2020_california_integrated_final.csv", "header");
  println("wind table:", windTable.getRowCount(), "x", windTable.getColumnCount());
  // Print several rows of the wind speed table
  TableUtils.printNRowFromTable(windTable, 3);

  println();
  println();
  println();

  // Load the location table
  locationTable = loadTable("locations_final.csv", "header");
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

void star(float x, float y, float radius1, float radius2, int npoints) {
  float angle = TWO_PI / npoints;
  float halfAngle = angle/2.0;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius2;
    float sy = y + sin(a) * radius2;
    vertex(sx, sy);
    sx = x + cos(a+halfAngle) * radius1;
    sy = y + sin(a+halfAngle) * radius1;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}
