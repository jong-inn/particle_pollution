
import java.util.*;
import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeFormatter;
import java.text.DecimalFormat;

// === GLOBAL VARIBALES ===

Table pm25Table;
Table windTable;
Table locationTable;
PImage map;

float maxY;

LocalDate startDate = getLocalDate("Enter the starting date: "+"\nformat: yyyy-mm-dd\ne.g. 2020-01-03"+"\ntime range: 2020-01-01 ~ 2020-12-31");
LocalDate endDate = getLocalDate("Enter the end date: "+"\nformat: yyyy-mm-dd\ne.g. 2020-01-03"+"\ntime range: 2020-01-01 ~ 2020-12-31");
float speed, period;
int totalDays = Period.between(startDate, endDate).getDays() + 1;
// float period = (totalDays-1) * speed;
int day = 0;
float count = 0;
boolean status = false; // Paused in the beginning
boolean windStatus = true; // Option for showing the wind data
boolean firstMousePress = false;
boolean minimizedInfo = false;

// Scroll bar variables
float xPosScrollbar, yPosScrollbar;
int widthScrollbar, heightScrollbar;

String highlightedLocation = "NONE";
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

 // Info Box (Date & Location) Variables
int infoBoxX_1 = 800;
int infoBoxX_2 = infoBoxX_1+250;
int infoBoxY_1 = 75;
int infoBoxY_2 = infoBoxY_1+125;
int infoBoxLineY = infoBoxY_1+45;

// Legend Variables
float legendLocX_1 = 0;
float legendLocX_2 = 130;
float legendLocX_middle = (legendLocX_1 + legendLocX_2)/2;
float legendLocY_1 = 0;
float legendLocY_2 = 400;
float legendLocY_middle = (legendLocY_1 + legendLocY_2)/2;

void setup() {
  // Size of the graphics window
  size(1600,900);

  // Load a California map
  map = loadImage("cal_map.png");

  // Load tables
  loadRawDataTables();

  // Construct a new PanZoomMap object
  panZoomMap = new PanZoomMap(32.0, -125.0, 43.0, -114.0);
  
  summaryPm25 = new DataBuckets("pm25", locationTable, pm25Table, startDate, endDate);
  top5Name = summaryPm25.pm25TopName(5);
  top5Value = summaryPm25.pm25TopValue(5);

  summaryWind = new DataBuckets("wind", locationTable, windTable, startDate, endDate);

  // Speed of the video
  speed = 50;
  period = (totalDays) * speed;

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
  xPosScrollbar = 0;
  yPosScrollbar = height-35;
  widthScrollbar = 1100;
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
  noStroke();
  rectMode(CORNERS);
  float mapX1 = panZoomMap.longitudeToScreenX(-125.0);
  float mapY1 = panZoomMap.latitudeToScreenY(32.0);
  float mapX2 = panZoomMap.longitudeToScreenX(-114.0);
  float mapY2 = panZoomMap.latitudeToScreenY(43.0);
  rect(mapX1, mapY1, mapX2, mapY2);

  // Draw the California map
  imageMode(CORNERS);
  image(map, mapX1, mapY1, mapX2, mapY2);

  // Draw the location points
  for (TableRow locationRow : locationTable.rows()) {
    DataManipulation locationData = new DataManipulation(locationRow, panZoomMap, "location");

    // Connect the map and info box 
    if (minimizedInfo == false){
      float selectedX1 = 0;
      float selectedX2 = 0;
      float selectedY1 = 0;
      float selectedY2 = 0;
      for (TableRow loc: locationTable.findRows(selectedLocation1, "Local Site Name")){
        DataManipulation connect = new DataManipulation(loc, panZoomMap, "location");
        selectedX1 = connect.screenX;
        selectedY1 = connect.screenY;
      }
      for (TableRow loc: locationTable.findRows(selectedLocation2, "Local Site Name")){
        DataManipulation connect = new DataManipulation(loc, panZoomMap, "location");
        selectedX2 = connect.screenX;
        selectedY2 = connect.screenY;
      }
      // The line between map and info box
      strokeWeight(0.1);
      stroke(111, 87, 0);
      if(selectedLocation1 != ""){
        line(selectedX1, selectedY1, infoBoxX_1-9, infoBoxLineY+2.5);
      }
      if(selectedLocation2 != ""){
        line(selectedX2, selectedY2, infoBoxX_1-9, (infoBoxLineY+infoBoxY_2)/2+2.5);
      }
    }

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
    //fill(0);
    //textSize(25);
    //textAlign(LEFT, CENTER);
    //text("Average Overview", 50, 30);

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
    if (windStatus == true) {
      for (TableRow summaryWindRow : summaryWind.summaryTable.rows()) {
        DataManipulation summaryWindData = new DataManipulation(summaryWindRow, panZoomMap, "wind");
        
        pushMatrix();
        translate(summaryWindData.screenX, summaryWindData.screenY); // Translate to the center of the location
        rotate(radians(summaryWindData.windDirection - 180));
        rectMode(CORNER);
        noStroke();
        fill(30, 144, 255); // Dodgerblue
        rect(-panZoomMap.mapLengthToScreenLength(0.02/2), -panZoomMap.mapLengthToScreenLength(0.14/2), panZoomMap.mapLengthToScreenLength(0.02), panZoomMap.mapLengthToScreenLength(0.14));

        pushMatrix();
        translate(0, panZoomMap.mapLengthToScreenLength(0.14/2)); // Translate to the top of the rectangle
        rotate(frameCount * summaryWindData.rotationSpeed);
        noStroke();
        fill(0, 191, 255); // Deepskyblue
        star(0, 0, panZoomMap.mapLengthToScreenLength(0.025), panZoomMap.mapLengthToScreenLength(0.06), 5);
        popMatrix();

        popMatrix();
      }
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
    //textSize(30);
    //textAlign(CENTER, CENTER);
    //fill(0);
    //text(stringDate, 100, 20);

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
        rectMode(CORNER);
        noStroke();
        fill(30, 144, 255); // Dodgerblue
        // rect(-1, 7, 1, -7);
        rect(-panZoomMap.mapLengthToScreenLength(0.02/2), -panZoomMap.mapLengthToScreenLength(0.14/2), panZoomMap.mapLengthToScreenLength(0.02), panZoomMap.mapLengthToScreenLength(0.14));

        pushMatrix();
        translate(0, panZoomMap.mapLengthToScreenLength(0.14/2)); // Translate to the top of the rectangle
        rotate(frameCount * windData.rotationSpeed);
        noStroke();
        fill(0, 191, 255); // Deepskyblue
        // star(0, 0, 3, 7, 5);
        star(0, 0, panZoomMap.mapLengthToScreenLength(0.025), panZoomMap.mapLengthToScreenLength(0.06), 5);
        popMatrix();

        popMatrix();
      }
    }


    // Increase count in the range from 1 to period-0.001
    if (status == true) {
      count += 1;
      count = constrain(count, 1, period-0.001);
    }

    // Stop the video in the end
    if (count == period-0.001) {
      status = false;
    }
  }

  // Display the updated scroll bar
  hScrollbar.update(count, firstMousePress, status, windStatus);
  hScrollbar.display();

  // Change the play and wind status
  status = hScrollbar.status;
  windStatus = hScrollbar.windBox;

  // Change the speed
  speed = hScrollbar.speed;
  period = (totalDays) * speed;

  // Change the count and day when returning the new playing point
  count = hScrollbar.count;
  if ((int) count == 0) {
    day = 0;
  } else {
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
  textAlign(LEFT, CENTER);
  textSize(25);
  text("Top 5 Average", 1120, 20);
  textSize(17);
  text("From: "+startDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")), 1135, 57);
  text("To  : "+endDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")), 1270, 57);
  
  line(1130, 90, 1130, 345);
  line(1130, 345, 1550, 345);
  fill(0);
  textSize(13);
  textAlign(LEFT, CENTER);
  DecimalFormat f = new DecimalFormat("##.#");
  float summaryXmin = top5Value[4]-1;
  float summaryXmax = top5Value[0]; 
  text(f.format(summaryXmin),1140, 355);
  text(f.format((summaryXmax-summaryXmin)/2),1340, 355);
  text(f.format(summaryXmax),1540, 355);
  for(int top5=0; top5 <5; top5++){
    float valueAmt = (top5Value[top5] - summaryXmin)/(summaryXmax - summaryXmin); 
    float bar = lerp(0,400,valueAmt);
    DataManipulation summary = new DataManipulation();
    float colorAmt = (constrain(top5Value[top5], summary.minPm25, summary.maxPm25) - summary.minPm25) / (summary.maxPm25 - summary.minPm25);
    color barColor = summary.lerpColorLab(summary.lowestPm25Color, summary.highestPm25Color, colorAmt);
    fill(barColor);
    noStroke();
    rect(1140, 105+(top5*50), 1140+bar, 105+(top5*50)+25);
    stroke(0); // Set the Stroke back for other parts of drawing
    fill(0);
    textSize(12);
    textAlign(LEFT, CENTER);
    text(top5Name[top5]+": "+f.format(top5Value[top5]), 1140, 105+(top5*50)-12);
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
  textSize(25);
  textAlign(LEFT, CENTER);
  text("Daily Data for Selected Cities", 1120, 405);
 

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
  
  // Info Box (Date & Location)
  rectMode(CORNERS);
  if (minimizedInfo == false){
    fill(#A5A3A3);
    stroke(1);
    rect(infoBoxX_1 ,infoBoxY_1-25, infoBoxX_2, infoBoxY_1, 5, 5, 0, 0);
    fill(#F0EDED);
    stroke(1);
    rect(infoBoxX_1 ,infoBoxY_1, infoBoxX_2, infoBoxY_2, 0, 0, 5, 5);
    fill(255);
    circle(infoBoxX_1+13 ,infoBoxY_1-13, 7);
    fill(0);
    rect(infoBoxX_1+9, infoBoxY_1-13.5, infoBoxX_1+17, infoBoxY_1-12.5);
    
    textAlign(LEFT, CENTER);
    textSize(18);
    fill(0);
    if (count == 0){
      text("Average Overview", infoBoxX_1+15, infoBoxY_1+15);
      strokeWeight(1.5);
      line(infoBoxX_1+14, infoBoxLineY-13, infoBoxX_1+150, infoBoxLineY-13); 
      strokeWeight(1); // reset the strokeWeight
    } else if (count !=0) {
      String stringDate = startDate.plusDays(day).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
      text("Date: "+stringDate, infoBoxX_1+15, infoBoxY_1+15);
      strokeWeight(1.5);
      line(infoBoxX_1+14, infoBoxLineY-13, infoBoxX_1+150, infoBoxLineY-13); 
      strokeWeight(1); // reset the strokeWeight
    }
    
    fill(0);
    circle(infoBoxX_1+19, infoBoxLineY+2.5, 2);
    circle(infoBoxX_1+19, (infoBoxLineY+infoBoxY_2)/2+2.5, 2);
    textSize(15);
    fill(0);
    text("Pivot Location", infoBoxX_1+25, infoBoxLineY);
    text("Comparing Location", infoBoxX_1+25, (infoBoxLineY+infoBoxY_2)/2);
    fill(colorForSelectedLocation1);
    text("(Color Yellow)", (infoBoxX_1+25)+91, infoBoxLineY);
    fill(colorForSelectedLocation2);
    text("(Color Blue)", (infoBoxX_1+25)+129, (infoBoxLineY+infoBoxY_2)/2);
    fill(0);
    text(": ", (infoBoxX_1+25)+178, infoBoxLineY);
    text(": ", (infoBoxX_1+25)+20 , (infoBoxLineY+infoBoxY_2)/2);
    
    String showSelectedLocation1 = "";
    String showSelectedLocation2 = "";
    for (TableRow loc: locationTable.findRows(selectedLocation1, "Local Site Name")){
      DataManipulation name = new DataManipulation(loc, panZoomMap, "location");
      showSelectedLocation1 = name.locationShownName;
    }
    for (TableRow loc: locationTable.findRows(selectedLocation2, "Local Site Name")){
      DataManipulation name = new DataManipulation(loc, panZoomMap, "location");
      showSelectedLocation2 = name.locationShownName;
    }
    fill(0);
    text(showSelectedLocation1, infoBoxX_1+26, infoBoxLineY+20);;
    text(showSelectedLocation2, infoBoxX_1+26, (infoBoxLineY+infoBoxY_2)/2+20);;

    stroke(111, 87, 0);
    if (showSelectedLocation1 != ""){
      line(infoBoxX_1-9, infoBoxLineY+2.5, infoBoxX_1+19, infoBoxLineY+2.5);
    }
    if (showSelectedLocation2 != ""){
      line(infoBoxX_1-9, (infoBoxLineY+infoBoxY_2)/2+2.5, infoBoxX_1+19, (infoBoxLineY+infoBoxY_2)/2+2.5);
    }
 
  }else{
    stroke(1);
    fill(#A5A3A3);
    rect(infoBoxX_1 ,infoBoxY_1-26, infoBoxX_2, infoBoxY_1, 5, 5, 5, 5);
    fill(255);
    circle(infoBoxX_1+13 ,infoBoxY_1-13, 7);
    fill(0);
    rect(infoBoxX_1+9, infoBoxY_1-13.5, infoBoxX_1+17, infoBoxY_1-12.5);
  }
  

  // legend
  fill(250); // CHANGED? 
  stroke(0);
  strokeWeight(1);
  //strokeWeight(4); // CHANGED (added)
  rectMode(CORNERS);
  rect(legendLocX_1-10, legendLocY_1-10, legendLocX_2, legendLocY_2);
  
  DataManipulation legend = new DataManipulation(); 
  
  // legend - PM2.5
  textSize(20);
  textAlign(RIGHT, CENTER);
  fill(0);
  text("PM 2.5", legendLocX_middle, legendLocY_1+15);
  textSize(12);
  textAlign(LEFT, CENTER);
  text("(μg/m^3)", legendLocX_middle+5, legendLocY_1+18);

  noStroke();
  float current_legendY = legendLocY_1+60;  
  
  for (int i=0; i<6; i++) {
    float amt = 1.0 - (float)i/(6 - 1);
    float radius = lerp(legend.minRadius, legend.maxRadius, amt);
    color chosenColor = legend.lerpColorLab(legend.lowestPm25Color, legend.highestPm25Color, amt);
    fill(chosenColor);
    ellipseMode(RADIUS);
    circle(legendLocX_middle-20, current_legendY+i*28, radius);
    textSize(14);
    textAlign(LEFT, CENTER);
    fill(0);
    float tmp = lerp(legend.minPm25, legend.maxPm25, amt);
    text("≥  "+f.format((double) tmp), legendLocX_middle+15, current_legendY+i*28-3);
  }
  
  // legend - wind 
  textSize(17);
  textAlign(CENTER, CENTER);
  fill(0);
  text("Wind Speed", legendLocX_middle-12, legendLocY_middle+30);
  textSize(12);
  textAlign(LEFT, CENTER);
  text("(kn)", legendLocX_middle+35, legendLocY_middle+32);
  
  // Store the original coordinate
  pushMatrix();
  translate(legendLocX_middle-20, legendLocY_middle + 52);

  for (int i=0; i < 4; i++) {
    float amt;
    if (i != 3) {
      amt = (1.0 - (float)i/(4 - 1)) * 0.7;
    } else {
      amt = 0.05;
    }
    pushMatrix();
    translate(0,20+i*30);
    rotate(radians(-60));
    rectMode(CORNERS);
    noStroke();
    fill(30, 144, 255); // Dodgerblue
    rect(-2, 15, 2, -15);

    rotate(radians(60));
    textSize(14);
    textAlign(LEFT, CENTER);
    fill(0);
    float tmp = lerp(legend.minWindSpeed, legend.maxWindSpeed, amt);
    if (i != 3) {
      text("≥  "+f.format((double) tmp), 30, 0);
    } else {
      text(">  "+f.format((double) tmp), 30, 0);
    }
    rotate(radians(-60));

    pushMatrix();
    translate(0, -15);
    rotate(frameCount * amt);
    noStroke();
    fill(0, 191, 255); // Deepskyblue
    star(0, 0, 4.5, 10.5, 5);
    popMatrix();

    popMatrix();

  }
  // Restore the original coordinate
  popMatrix();

  
  // textSize(15);
  // textAlign(CENTER, CENTER);
  // fill(0);
  // text("the star =\n the wind direction", legendLocX_middle, current_legendY+20); 

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
  if (!firstMousePress) {
    firstMousePress = true;
    println("First Mouse Press: "+firstMousePress);
  }

  // Select the pivot location
  if (!highlightedLocation.equals("NONE") && selectedLocation1.equals("") && !selectedLocation2.equals(highlightedLocation)) {
    selectedLocation1 = highlightedLocation;
    println("Selected Location 1: " + selectedLocation1);
  // Select the comparing location
  } else if (!highlightedLocation.equals("NONE") && selectedLocation2.equals("") && !selectedLocation1.equals(highlightedLocation)) {
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

  // Minimized the Info Box
  if (mouseX < infoBoxX_1+18 && mouseY < infoBoxY_1-8 && mouseX > infoBoxX_1+8 && mouseY > infoBoxY_1-18){
    if (minimizedInfo == false){ minimizedInfo = true; }
    else { minimizedInfo = false; }
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
  pm25Table = loadTable("daily_88101_2020_california_last.csv", "header");
  println("pm25 table:", pm25Table.getRowCount(), "x", pm25Table.getColumnCount());
  // Print several rows of the pm25 table
  TableUtils.printNRowFromTable(pm25Table, 3);
  
  println();
  println();
  println();
  
  // Load the wind table
  windTable = loadTable("daily_WIND_2020_california_integrated_last.csv", "header");
  println("wind table:", windTable.getRowCount(), "x", windTable.getColumnCount());
  // Print several rows of the wind speed table
  TableUtils.printNRowFromTable(windTable, 3);

  println();
  println();
  println();

  // Load the location table
  locationTable = loadTable("locations_last.csv", "header");
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
