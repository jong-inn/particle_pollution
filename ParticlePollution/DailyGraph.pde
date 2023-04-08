
import java.text.DecimalFormat;

class DailyGraph {
  
  // Graph size and position
  float xGraphZeroPoint = 1140;
  float yGraphZeroPoint = 850;
  float graphHeight = 410;
  float graphWidth = 430;

  float yAdjustment = 80;
  float yLineGraphZeroPoint = yGraphZeroPoint - yAdjustment; // For the wind data
  float yLineGraphHeight = graphHeight - yAdjustment - 10; // For the wind data

  // For normalizing wind data
  float minWindSpeed = 0.0;
  float maxWindSpeed = 10.0;
  float minRotationSpeed = 0.0;
  float maxRotationSpeed = 1.0;

  // 
  float[] pm25Array;
  float[] windSpeedArray;
  float[] windDirectionArray;
  float[] windNormalizedSpeedArray;
  String[] dateArray;
  float maxY;
  color c;
  int dayCount;
  float textPos;
  int windPos;
  int maxDayCount = 10;
  
  // one line
  public DailyGraph(float[] pm25Array, float[] windSpeedArray, float[] windDirectionArray, String[] dateArray, float maxY, color c, int dayCount, float textPos, int windPos) {
    this.pm25Array = pm25Array;
    this.windSpeedArray = windSpeedArray;
    this.windDirectionArray = windDirectionArray;
    this.windNormalizedSpeedArray = new float[windSpeedArray.length];
    for (int i=0; i<windSpeedArray.length; i++) {
      float windNormalizedSpeed = (windSpeedArray[i] - minWindSpeed) / (maxWindSpeed - minWindSpeed);
      windNormalizedSpeedArray[i] = lerp(minRotationSpeed, maxRotationSpeed, windNormalizedSpeed);
    }
    this.dateArray = dateArray;
    this.maxY = maxY;
    this.c = c;
    this.dayCount = dayCount;
    this.textPos = textPos;
    this.windPos = windPos;
  }

  void drawPoints(float x, float y, float value) {
    noStroke();
    fill(c);
    circle(x, y, 3);
    textSize(10);
    textAlign(LEFT, CENTER);
    DecimalFormat f = new DecimalFormat("##.0");
    text(f.format((double) value), x+9, y+textPos);
  }

  void drawWinds(float x, float y, float rotationSpeed, float windDirection) {
    pushMatrix();
    translate(x, y);
    rotate(radians(windDirection - 180));
    rectMode(CORNERS);
    noStroke();
    fill(c);
    rect(-1, 7, 1, -7);

    pushMatrix();
    translate(0, 7); // Translate to the top of the rectangle
    rotate(frameCount * rotationSpeed);
    noStroke();
    fill(c); // Deepskyblue
    star(0, 0, 3, 7, 5);
    popMatrix();

    popMatrix();
  }
  
  void drawGraph() {
    // Draw 4 support lines and support values
    for (int i=0; i<6; i++) {
      // Support lines
      float supportY = yLineGraphZeroPoint - yLineGraphHeight*i/5;
      stroke(color(233, 234, 236)); // Great Ligth blue
      line(xGraphZeroPoint+2, supportY, xGraphZeroPoint+graphWidth, supportY);

      // Support values
      fill(134, 140, 151); // One of Gray
      textSize(10);
      textAlign(CENTER, CENTER);
      DecimalFormat f = new DecimalFormat("##.0");
      if (i == 0) {
        text("0.0", xGraphZeroPoint-15, supportY);
      } else {
        text(f.format((double) maxY*i/5), xGraphZeroPoint-15, supportY);
      }
      
    }

    // Draw PM 2.5 points and lines
    // If the length of x axis is less than 10
    if (dayCount <= maxDayCount-1) {
      // Set the x, y positions for drawing lines
      float prevX = 0;
      float prevY = 0;
      for (int i=0; i<dayCount+1; i++) {
        // Set the x, y positions
        float x = xGraphZeroPoint + (i+1)*graphWidth/11;
        float y = yLineGraphZeroPoint - pm25Array[i]/maxY*yLineGraphHeight;
        
        // Draw the points
        drawPoints(x, y, pm25Array[i]);

        // Draw the lines between points
        if (dayCount+1 > 1) {
          stroke(c);
          if (prevX != 0 && prevY != 0) {
            line(prevX, prevY, x, y);
          }
        }

        // Show PM 2.5 values
        fill(0);
        textSize(12);
        textAlign(CENTER, CENTER);
        text(dateArray[i], x, yGraphZeroPoint + 20);

        prevX = x;
        prevY = y;

        // Draw wind data
        if (windPos == 1) {
          drawWinds(x, yGraphZeroPoint-60, windNormalizedSpeedArray[i], windDirectionArray[i]);
        } else if (windPos == 2) {
          drawWinds(x, yGraphZeroPoint-20, windNormalizedSpeedArray[i], windDirectionArray[i]);
        }
      }
    // If the length of x axis is greater than 10
    } else if (dayCount > maxDayCount-1) {
      // Set the x, y positions for drawing lines
      float prevX = 0;
      float prevY = 0;
      int j = 1; // For x axis
      for (int i=pm25Array.length-10; i<dayCount+1; i++) {
        // Set the x, y positions
        float x = xGraphZeroPoint + j*graphWidth/11;
        float y = yLineGraphZeroPoint - pm25Array[i]/maxY*yLineGraphHeight;

        // Draw the points
        drawPoints(x, y, pm25Array[i]);

        // Draw the lines between points
        if (dayCount+1 > 1) {
          stroke(c);
          if (prevX != 0 && prevY != 0) {
            line(prevX, prevY, x, y);
          }
        }

        // Show PM 2.5 values
        fill(0);
        textSize(12);
        textAlign(CENTER, CENTER);
        text(dateArray[i], x, yGraphZeroPoint + 20);

        prevX = x;
        prevY = y;

        // Draw wind data
        if (windPos == 1) {
          drawWinds(x, yGraphZeroPoint-60, windNormalizedSpeedArray[i], windDirectionArray[i]);
        } else if (windPos == 2) {
          drawWinds(x, yGraphZeroPoint-20, windNormalizedSpeedArray[i], windDirectionArray[i]);
        }
        j += 1;
      }
    }

    // Draw wind data

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
}
