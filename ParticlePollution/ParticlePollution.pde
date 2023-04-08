
import java.util.*;
import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeFormatter;

// === GLOBAL VARIBALES ===

Table pm25Table;
Table windTable;
Table locationTable;
PImage map;

Table mantecaPm25Table;
Table mantecaWindTable;
Table modestoPm25Table;
Table modestoWindTable;

float[] data1; 
float[] data2;
int lineDataNum;
float maxY;
int graphCount = 0;

LocalDate startDate = getLocalDate("Enter the starting date: "+"\nformat: yyyy-mm-dd\ne.g. 2020-01-03"+"\ntime range: 2020-01-01 ~ 2020-12-31");
LocalDate endDate = getLocalDate("Enter the end date: "+"\nformat: yyyy-mm-dd\ne.g. 2020-01-03"+"\ntime range: 2020-01-01 ~ 2020-12-31");
float speed = 50;
float period = Period.between(startDate, endDate).getDays() * speed;
int day = -1;
float count = 0;
boolean status = false; // Paused in the beginning
boolean windStatus = true; // Option for showing the wind data

String highlightedLocation = "";
String selectedLocation1 = "";
color colorForSelectedLocation1 = color(255, 174, 66); // Yellow Orange
String selectedLocation2 = "";
color colorForSelectedLocation2 = color(0, 57, 153); // Medium Dark Shade of Cyan Blue

float[] location1Pm25 = new float[11];
float[] location1WindSpeed = new float[11];
float[] location1WindDirection = new float[11];
float[] location2Pm25 = new float[11];
float[] location2WindSpeed = new float[11];
float[] location2WindDirection = new float[11];
String[] arrayStringDate = new String[11];

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

void setup() {
  // Size of the graphics window
  size(1600,900);

  // Load a California map
  map = loadImage("california_simple_map.png");

  // Load tables
  loadRawDataTables();

  // Temporal tables for testing
  mantecaPm25Table = loadTable("manteca_pm25_test.csv", "header");
  mantecaWindTable = loadTable("manteca_wind_test.csv", "header");
  modestoPm25Table = loadTable("modesto_pm25_test.csv", "header");
  modestoWindTable = loadTable("modesto_wind_test.csv", "header");
  for (int i=0; i<mantecaPm25Table.getRowCount(); i++) {
    location1Pm25[i] = mantecaPm25Table.getRow(i).getFloat("Arithmetic Mean");
    location1WindSpeed[i] = mantecaWindTable.getRow(i).getFloat("Arithmetic Mean Speed");
    location1WindDirection[i] = mantecaWindTable.getRow(i).getFloat("Arithmetic Mean Direction");

    location2Pm25[i] = modestoPm25Table.getRow(i).getFloat("Arithmetic Mean");
    location2WindSpeed[i] = modestoWindTable.getRow(i).getFloat("Arithmetic Mean Speed");
    location2WindDirection[i] = modestoWindTable.getRow(i).getFloat("Arithmetic Mean Direction");

    arrayStringDate[i] = mantecaPm25Table.getRow(i).getString("Date Local").replace("2020-", "");
  }

  data1 = Arrays.copyOf(location1Pm25, location1Pm25.length);
  data2 = Arrays.copyOf(location2Pm25, location2Pm25.length);

  // Construct a new PanZoomMap object
  panZoomMap = new PanZoomMap(32.0, -125.0, 43.0, -114.0);
  
  summaryPm25 = new DataBuckets("pm25", locationTable, pm25Table, startDate, endDate);
  top5Name = summaryPm25.pm25TopName(5);
  top5Value = summaryPm25.pm25TopValue(5);

  summaryWind = new DataBuckets("wind", locationTable, windTable, startDate, endDate);

  // Line Graph
  lineDataNum = 0;
  if (data1 == null && data2 == null){
    println("empty"); 
  }else if ( data2 != null){
    if (max(data1) > max(data2)){
      maxY = max(data1);
    } else {
      maxY = max(data2);
    }
  }else{
    maxY = max(data1);
  }

  // Scroll bar
  hScrollbar = new HScrollbar(100, height-50, 900, 16, 1, arrayStringDate, speed);
}

void draw() {
  // Clear the screen
  background(230);

  // Get highlighted location
  highlightedLocation = getLocationUnderMouse(locationTable, panZoomMap);
  // println("Highlighted Location: "+highlightedLocation);

  // Prepare arrays for selected locations
  // if (selectedLocation1 != "") {
   

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

  // Draw the play/stop status
  //if (status == true) {
  //  // For the background circle
  //  fill(169, 169, 169); // Darkgray
  //  noStroke();
  //  ellipseMode(RADIUS);
  //  circle(1560, 40, 15);

  //  // For the two thin rectangles
  //  fill(0);
  //  noStroke();
  //  rectMode(CORNER);
  //  rect(1552, 30, 5, 21);
  //  rect(1563, 30, 5, 21);

  //} else if (status == false) {
  //  // For the background circle
  //  fill(169, 169, 169); // Darkgray
  //  noStroke();
  //  ellipseMode(RADIUS);
  //  circle(1560, 40, 15);

  //  // For the triangle
  //  fill(0);
  //  noStroke();
  //  beginShape();
  //  vertex(1553, 30);
  //  vertex(1553, 50);
  //  vertex(1571, 40);
  //  endShape(CLOSE);
  //}

  // Draw the location points
  for (TableRow locationRow : locationTable.rows()) {
    DataManipulation locationData = new DataManipulation(locationRow, panZoomMap, "location");

    // Highlight the locations
    highlightingLocations(locationData, highlightedLocation, selectedLocation1, selectedLocation2);

    // If the pivot location is selected, filter out the remaining area
    if (selectedLocation1.equals(locationData.localSiteName)) {
      noStroke();
      fill(211, 211, 211, 60);
      ellipseMode(RADIUS);
      circle(locationData.screenX, locationData.screenY, 50);
    }
    
    // Draw city points
    fill(232, 81, 21);
    noStroke();
    ellipseMode(RADIUS);
    circle(locationData.screenX, locationData.screenY, 2);
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
      highlightingLocations(summaryPm25Data, highlightedLocation, selectedLocation1, selectedLocation2);

      noStroke();
      fill(summaryPm25Data.lerpColor);
      ellipseMode(RADIUS);
      circle(summaryPm25Data.screenX, summaryPm25Data.screenY, summaryPm25Data.radius);
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
      highlightingLocations(pm25Data, highlightedLocation, selectedLocation1, selectedLocation2);

      noStroke();
      fill(pm25Data.lerpColor);
      ellipseMode(RADIUS);
      circle(pm25Data.screenX, pm25Data.screenY, pm25Data.radius);

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

  println("Count: "+count);
  // println()
  hScrollbar.update(count);
  hScrollbar.display();
  if (hScrollbar.count != count) {
    count = hScrollbar.count;
    day = (int) count / (int) speed;
  }


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
  maxY = max(max(data1), max(data2));

  if (selectedLocation1 != "" && count != 0) {
    DailyGraph dailyGraph1 = new DailyGraph(
      data1, 
      location1WindSpeed, 
      location1WindDirection, 
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
      data2, 
      location2WindSpeed,
      location2WindDirection,
      arrayStringDate, 
      maxY, 
      colorForSelectedLocation2, 
      day, 
      10,
      2
    );
    dailyGraph2.drawGraph();
  }

  // if (data1 == null && data2 == null) {
  //   println("empty");
  // } 

  // if (status == true) {
  //   // Line Graph
  //   if (data1 == null && data2 == null){
  //     println("empty");
  //   }else if (lineDataNum == data1.length){
  //     // show the last graph
  //     // int[] number = new int[lineDataNum+1];
  //     // for (int pos=0; pos < lineDataNum+1; pos++){
  //     //     number[pos] = pos+1;    
  //     //   }
  //     if (data1 != null){
  //       float[] temp1 = Arrays.copyOfRange(data1, data1.length-4, data1.length);
  //       color c1 = color(0,0,0);
  //       // drawLine = new LineGraph(temp1, number, maxY, c1);
  //       drawLine = new LineGraph(temp1, arrayStringDate, maxY, c1, graphCount, -10);
  //       drawLine.drawinging();
  //     }
  //     if (data2 != null){
  //       float[] temp2 = Arrays.copyOfRange(data2, data1.length-4, data1.length);
  //       color c2 = color(50,60,200);
  //       // drawLine = new LineGraph(temp2, number, maxY, c2);
  //       drawLine = new LineGraph(temp2, arrayStringDate, maxY, c2, graphCount, 10);
  //       drawLine.drawinging();
  //     }
  //     println("end");
  //   }else if (lineDataNum < 4){
  //     //for the first four data
  //     // int[] number = new int[lineDataNum+1];
  //     // for (int pos=0; pos < lineDataNum+1; pos++){
  //     //     number[pos] = pos+1;    
  //     //   }
  //     if (data1 != null){
  //       float[] temp1 = Arrays.copyOf(data1, lineDataNum+1);
  //       color c1 = color(0,0,0);
  //       // drawLine = new LineGraph(temp1, number, maxY, c1);
  //       drawLine = new LineGraph(temp1, arrayStringDate, maxY, c1, graphCount, -10);
  //       drawLine.drawinging();
  //     }
  //     if (data2 != null){
  //       float[] temp2 = Arrays.copyOf(data2, lineDataNum+1);
  //       color c2 = color(50,60,200);
  //       // drawLine = new LineGraph(temp2, number, maxY, c2);
  //       drawLine = new LineGraph(temp2, arrayStringDate, maxY, c2, graphCount, 10);
  //       drawLine.drawinging();
  //     }
  //     lineDataNum++;
  //   }else{
  //     // for the latest four
  //     // int[] number = new int[lineDataNum+1];
  //     // for (int pos=0; pos < lineDataNum+1; pos++){
  //     //     number[pos] = pos+1;    
  //     // }
  //     if (data1 != null){
  //       float[] temp1 = Arrays.copyOfRange(data1, lineDataNum-3, lineDataNum+1);
  //       color c1 = color(0,0,0);
  //       // drawLine = new LineGraph(temp1, number, maxY, c1);
  //       drawLine = new LineGraph(temp1, arrayStringDate, maxY, c1, graphCount, -10);
  //       drawLine.drawinging();
  //     }
  //     if (data2 != null){
  //       float[] temp2 = Arrays.copyOfRange(data2, lineDataNum-3, lineDataNum+1);
  //       color c2 = color(50,60,200);
  //       // drawLine = new LineGraph(temp2, number, maxY, c2);
  //       drawLine = new LineGraph(temp2, arrayStringDate, maxY, c2, graphCount, 10);
  //       drawLine.drawinging();
  //     }
  //     lineDataNum++;
  //   }
  // }
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
  } else if (key == DELETE || key == BACKSPACE) {
    graphCount += 1;
  }
}

void mousePressed() {
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
