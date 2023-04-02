
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


// Returns the municipality currently under the mouse cursor so that it can be highlighted or selected
// with a mouse click.  If the municipalities overlap and more than one is under the cursor, the
// smallest municipality will be returned, since this is usually the hardest one to select.
String getLocationUnderMouse(Table locationTable, PanZoomMap panZoomMap) {
  float smallestRadiusSquared = Float.MAX_VALUE;
  String underMouse = "";
  for (TableRow locationRow : locationTable.rows()) {
    String localSiteName = locationRow.getString("Local Site Name");
    float latitude = locationRow.getFloat("Latitude");
    float longitude = locationRow.getFloat("Longitude");
    float screenX = panZoomMap.longitudeToScreenX(longitude);
    float screenY = panZoomMap.latitudeToScreenY(latitude);
    float distSquared = (mouseX-screenX)*(mouseX-screenX) + (mouseY-screenY)*(mouseY-screenY);
    float radius = 8; // fixed radius different with the original one
    float radiusSquared = constrain(radius*radius, 1, height);
    if ((distSquared <= radiusSquared) && (radiusSquared < smallestRadiusSquared)) {
      underMouse = localSiteName;
      smallestRadiusSquared = radiusSquared;
    }
  }
  return underMouse;  
}

// Hightlighting function

void highlightingLocations(DataManipulation manipulatedData, String highlightedLocation, String selectedLocation1, String selectedLocation2) {
    // Highlight the location when hovering the mouse on the location
    // If two locations are already selected, do not show the highlights
    if (manipulatedData.localSiteName.equals(highlightedLocation) && !(selectedLocation1 != "" && selectedLocation2 != "")) {
        noStroke();
        fill(0, 0, 128);
        ellipseMode(RADIUS);

        // Decide the radius size
        float radius = 0;
        if (manipulatedData.type.equals("location")) {
            radius = 2;
        } else if (manipulatedData.type.equals("pm25")) {
            radius = manipulatedData.radius;
        }

        circle(manipulatedData.screenX, manipulatedData.screenY, radius + 5);

        showLocalSiteName(manipulatedData);
    }

    // Highlight the selected locations
    if (selectedLocation1.equals(manipulatedData.localSiteName) || selectedLocation2.equals(manipulatedData.localSiteName)) {
        noStroke();
        fill(0, 0, 0);
        ellipseMode(RADIUS);

        // Decide the radius size
        float radius = 0;
        if (manipulatedData.type.equals("location")) {
            radius = 2;
        } else if (manipulatedData.type.equals("pm25")) {
            radius = manipulatedData.radius;
        }

        circle(manipulatedData.screenX, manipulatedData.screenY, radius + 5);

        // Show the filtered area if we select the pivot location
        if (selectedLocation1.equals(manipulatedData.localSiteName)) {
            textSize(15);
            textAlign(CENTER, CENTER);
            fill(0);
            text("Pivot Location", manipulatedData.screenX, manipulatedData.screenY - 25);
            showLocalSiteName(manipulatedData);
        // Show the comparing location
        } else if (selectedLocation2.equals(manipulatedData.localSiteName)) {
            textSize(15);
            textAlign(CENTER, CENTER);
            fill(0);
            text("Comparing Location", manipulatedData.screenX, manipulatedData.screenY + 25);
            showLocalSiteName(manipulatedData);
        }
    }
}

void showLocalSiteName(DataManipulation manipulatedData) {
    textSize(14);
    textAlign(LEFT, CENTER);
    float xTextOffset = 18; // Move the text to the right of the circle
    fill(111, 87, 0);
    text(manipulatedData.localSiteName, manipulatedData.screenX + xTextOffset, manipulatedData.screenY);
}