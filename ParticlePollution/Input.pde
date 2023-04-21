
import javax.swing.*;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

String prompt(String s) {
    println(s);
    String entry = JOptionPane.showInputDialog(s);
    if (entry == null) {
        return null;
    }
    println(entry);
    return entry;
}

String getString(String s) {
    return prompt(s);
}

LocalDate getLocalDate(String s) {
    while (true) {
        try {
            LocalDate date = LocalDate.parse(prompt(s));
            return date;
        } catch (DateTimeParseException e) {
            println("Please try again.");
        }
    }
}

// Beginning Page format
void beginningPage(boolean goingToEnter, String start, String end){
   
   background(50);
   rectMode(CORNERS);
   fill(255, 60); 
   rect( 200, 150, 1400, 750);
   textAlign(LEFT, CENTER);
   textSize(50);
   fill(255);
   text("The Relationship\nbetween PM2.5 and Wind\nin California", 250, 300);
   textSize(20);
   fill(255);
   text("Enter the period: \n  format: yyyy-mm-dd  e.g. 2020-01-03\n  time range: 2020-01-01 ~ 2020-12-31", 300, 550);
   text("Start Date:", 800, 525);
   text("End Date:", 800, 575);
   
   color startBoxColor, endBoxColor;
   color startDateColor, endDateColor;
   if ( !goingToEnter ){
     startBoxColor = color(255, 95);
     endBoxColor = color(255, 95);
     startDateColor = color(0);
     endDateColor = color(0);
     fill(255);
     rect(900, 620, 1060, 652, 2.5, 2.5, 2.5, 2.5);
     fill(0);
     textAlign(CENTER, CENTER);
     text("Enter", 980, 633);
     
   } else {
     startBoxColor = color(255, 30);
     endBoxColor = color(255, 30);
     startDateColor = color(255);
     endDateColor = color(255);
     fill(255);
     rect(900, 620, 1060, 652, 2.5, 2.5, 2.5, 2.5);
     fill(0);
     textAlign(CENTER, CENTER);
     text("Start", 980, 633);
   }
   
   noStroke();
   fill(startBoxColor);
   rect(900, 510, 1050, 545);
   fill(endBoxColor);
   rect(900, 560, 1050, 595);
   textAlign(LEFT, CENTER);
   fill(startDateColor);
   text(start, 925, 525);
   fill(endDateColor);
   text(end, 925, 575);

}


// Returns the municipality currently under the mouse cursor so that it can be highlighted or selected
// with a mouse click.  If the municipalities overlap and more than one is under the cursor, the
// smallest municipality will be returned, since this is usually the hardest one to select.
String getLocationUnderMouse(Table locationTable, PanZoomMap panZoomMap) {
  float smallestRadiusSquared = Float.MAX_VALUE;
  String underMouse = "NONE";
  for (TableRow locationRow : locationTable.rows()) {
    String localSiteName = locationRow.getString("Local Site Name");
    float latitude = locationRow.getFloat("Latitude");
    float longitude = locationRow.getFloat("Longitude");
    float screenX = panZoomMap.longitudeToScreenX(longitude);
    float screenY = panZoomMap.latitudeToScreenY(latitude);
    float distSquared = (mouseX-screenX)*(mouseX-screenX) + (mouseY-screenY)*(mouseY-screenY);
    float radius = panZoomMap.mapLengthToScreenLength(0.1); // fixed radius different with the original one
    float radiusSquared = constrain(radius*radius, 1, height);
    if ((distSquared <= radiusSquared) && (radiusSquared < smallestRadiusSquared)) {
      underMouse = localSiteName;
      smallestRadiusSquared = radiusSquared;
    }
  }
  return underMouse;  
}

// Hightlighting function

void highlightingLocations(PanZoomMap panZoomMap, DataManipulation manipulatedData, String highlightedLocation, String selectedLocation1, String selectedLocation2) {
    // Highlight the location when hovering the mouse on the location
    // If two locations are already selected, do not show the highlights
    if (manipulatedData.localSiteName.equals(highlightedLocation) && !(selectedLocation1 != "" && selectedLocation2 != "")) {
        // Draw the circle
        noStroke();
        fill(140, 146, 172); // Cool Gray
        ellipseMode(RADIUS);

        // Decide the radius size
        float radius = 0;
        if (manipulatedData.type.equals("location")) {
            radius = 2;
        } else if (manipulatedData.type.equals("pm25")) {
            radius = manipulatedData.radius;
        }

        circle(manipulatedData.screenX, manipulatedData.screenY, panZoomMap.mapLengthToScreenLength((radius + 5)*0.01));

        showLocalSiteName(manipulatedData);
    }

    // Highlight the selected locations
    if (selectedLocation1.equals(manipulatedData.localSiteName) || selectedLocation2.equals(manipulatedData.localSiteName)) {

        // Decide the radius size
        float radius = 0;
        if (manipulatedData.type.equals("location")) {
            radius = 2;
        } else if (manipulatedData.type.equals("pm25")) {
            radius = manipulatedData.radius;
        }

        // Show the info of pivot location
        if (selectedLocation1.equals(manipulatedData.localSiteName)) {
            // Draw the circle
            noStroke();
            fill(255, 174, 66); // Yellow Orange
            ellipseMode(RADIUS);
            circle(manipulatedData.screenX, manipulatedData.screenY, panZoomMap.mapLengthToScreenLength((radius + 5)*0.01));

            showLocalSiteName(manipulatedData);
        // Show the info of comparing location
        } else if (selectedLocation2.equals(manipulatedData.localSiteName)) {
            // Draw the circle
            noStroke();
            fill(0, 57, 153); // Medium Dark Shade of Cyan Blue
            ellipseMode(RADIUS);
            circle(manipulatedData.screenX, manipulatedData.screenY, panZoomMap.mapLengthToScreenLength((radius + 5)*0.01));

            showLocalSiteName(manipulatedData);
        }
    }
}

void showLocalSiteName(DataManipulation manipulatedData) {
    textSize(14);
    textAlign(LEFT, CENTER);
    float xTextOffset = 0.2; // Move the text to the right of the circle
    fill(255, 0, 0);
    text(manipulatedData.locationShownName, manipulatedData.screenX + panZoomMap.mapLengthToScreenLength(xTextOffset), manipulatedData.screenY);
}
