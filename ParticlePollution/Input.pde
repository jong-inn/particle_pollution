
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
    float radius = 6; // fixed radius different with the original one
    float radiusSquared = constrain(radius*radius, 1, height);
    if ((distSquared <= radiusSquared) && (radiusSquared < smallestRadiusSquared)) {
      underMouse = localSiteName;
      smallestRadiusSquared = radiusSquared;
    }
  }
  return underMouse;  
}
