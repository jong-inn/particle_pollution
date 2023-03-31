
import java.util.*;
import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeFormatter;

// === GLOBAL VARIBALES ===

Table pm25Table;
Table windTable;
Table locationTable;
PImage map;

LocalDate startDate = getLocalDate("Enter the starting date: "+"\nformat: yyyy-mm-dd\ne.g. 2020-01-03"+"\ntime range: 2020-01-01 ~ 2020-12-31");
LocalDate endDate = getLocalDate("Enter the end date: "+"\nformat: yyyy-mm-dd\ne.g. 2020-01-03"+"\ntime range: 2020-01-01 ~ 2020-12-31");
int speed = 200;
int period = Period.between(startDate, endDate).getDays() * speed;
int day = 0;
int count = 0;
boolean status = false; // Paused in the beginning
boolean windStatus = true; // Option for showing the wind data

String [] top5Name; // summary
float [] top5Value; // summary

PanZoomMap panZoomMap;
DataBuckets summary;

void setup() {
  // Size of the graphics window
  size(1600,900);

  // Load a California map
  map = loadImage("california_simple_map.png");

  // Load tables
  loadRawDataTables();

  // Construct a new PanZoomMap object
  panZoomMap = new PanZoomMap(32.0, -125.0, 43.0, -114.0);
  
  summary = new DataBuckets(locationTable, pm25Table, startDate, endDate);
  top5Name = summary.topName(5);
  top5Value = summary.topValue(5);
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

  // Draw the California map
  imageMode(CORNERS);
  image(map, mapX1, mapY1, mapX2, mapY2);

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
    
  }

  // Store the current coordination
  pushMatrix();

  if (count == 0) {
    for (TableRow summaryRow : summary.summaryTable.rows()) {
      DataManipulation summaryData = new DataManipulation(summaryRow, panZoomMap, "pm25");
      
      noStroke();
      fill(summaryData.lerpColor);
      ellipseMode(RADIUS);
      circle(summaryData.screenX, summaryData.screenY, summaryData.radius);
    }
    if (status == true) {
      count += 1;
    }
  } else if (count != 0 && count < period) {
    println("Count: "+count);

    if (count % speed == 0 && status == true) {
      day += 1;
    }
    println("Date: "+startDate.plusDays(day));
    String stringDate = startDate.plusDays(day).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    textSize(30);
    textAlign(CENTER, CENTER);
    fill(0);
    text(stringDate, 100, 20);

    for (TableRow pm25Row : pm25Table.findRows(stringDate, "Date Local")) {
      DataManipulation pm25Data = new DataManipulation(pm25Row, panZoomMap, "pm25");

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

    if (status == true) {
      count += 1;
    }
  } else {
    // background(230);
    println("Reach the maximum");
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