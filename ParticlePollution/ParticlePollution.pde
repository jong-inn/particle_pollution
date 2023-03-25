
import java.util.*;
import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeFormatter;

// === GLOBAL VARIBALES ===

Table pm25Table;
Table windSpeedTable;
Table windDirectionTable;
Table locationTable;

float minLatitude, maxLatitude;
float minLongitude, maxLongitude;
float minPm25, maxPm25;
LocalDate startDate = getLocalDate("Enter the starting date: "+"\nformat: yyyy-mm-dd\ne.g. 2020-01-03");
LocalDate endDate = getLocalDate("Enter the end date: "+"\nformat: yyyy-mm-dd\ne.g. 2020-01-03");
int period = Period.between(startDate, endDate).getDays();
int count = 0;

PanZoomMap panZoomMap;

void setup() {
  // Size of the graphics window
  size(1600,900);

  // Load tables
  loadRawDataTables();

  // Preprocess tables
  computeDerivedData();

  panZoomMap = new PanZoomMap(32.0, -125.0, 43.0, -114.0);

  // Drop the frame
  frameRate(1);
}

void draw() {
  // Radiuses for pm 2.5
  float minRadius = 20;
  float maxRadius = 200;
  
  if (count < period) {
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

    println("Date: "+startDate.plusDays(count));
    String stringDate = startDate.plusDays(count).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    for (TableRow row : pm25Table.findRows(stringDate, "Date Local")) {
      String localSiteName = row.getString("Local Site Name");
      // println("Local Site Name: "+localSiteName);
      float latitude = row.getFloat("Latitude");
      float longitude = row.getFloat("Longitude");
      float screenX = panZoomMap.longitudeToScreenX(longitude);
      float screenY = panZoomMap.latitudeToScreenY(latitude);
      float pm25 = row.getFloat("Arithmetic Mean");
      float pm25Normalized = (pm25 - minPm25) / (maxPm25- minPm25);
      if (localSiteName.equals("Livermore")) {
        println("PM 2.5: "+pm25Normalized);
      }
      
      // Draw city points
      fill(232, 81, 21);
      noStroke();
      ellipseMode(RADIUS);
      circle(screenX, screenY, 2);

      // Draw circles for PM 2.5
      float radius = lerp(minRadius, maxRadius, pm25Normalized);
      stroke(0);
      noFill();
      ellipseMode(RADIUS);
      circle(screenX, screenY, radius);

      // Draw texts for the local site name
      textAlign(LEFT, CENTER);
      float xTextOffset = 2 + 4; // Move the text to the right of the circle
      fill(111, 87, 0);
      text(localSiteName, screenX + xTextOffset, screenY);
    }

    count += 1;
  } else {
    background(230);
    println("Reach the maximum");
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
  pm25Table = loadTable("daily_88101_2020_california_filtered.csv", "header");
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
  minPm25 = TableUtils.findMinFloatInColumn(pm25Table, "Arithmetic Mean");
  maxPm25 = TableUtils.findMaxFloatInColumn(pm25Table, "Arithmetic Mean");
  println("PM 2.5 range:", minPm25, "to", maxPm25);
}