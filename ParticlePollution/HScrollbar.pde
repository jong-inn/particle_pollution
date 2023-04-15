
class HScrollbar {
  int sWidth, sHeight;    // width and height of bar
  float xPos, yPos;       // x and y position of bar
  float sPos, newSPos;    // x position of slider
  float sPosMin, sPosMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean status = false;         // is the video playing?
  boolean windBox = true;         // is the wind on map?
  float ratio;

  String[] dateArray;
  float count;
  float speed;

  // Scrollbar components' position variables (fixed and mixed with the translate function)
  float xPlayPos = xPos + 15;
  float xResetPos = 25;
  float xPlayingDatePos = 50;
  float xWindBoxPos = 750;
  float xWindOptionPos = 45;
  float xSpeedPos = 30;
  float xNextSpeedPos = 50;
  float yBasicPos;

  HScrollbar (float xp, float yp, int sw, int sh, int l, String[] dateArray, float speed) {
    sWidth = sw;
    sHeight = sh;
    int widthtoheight = sw - sh;
    ratio = (float) sw / (float) widthtoheight;
    xPos = xp;
    yPos = yp-sHeight/2;
    sPos = xPos;
    // sPos = 0;
    newSPos = sPos;
    sPosMin = xPos;
    sPosMax = xPos + sWidth;
    loose = l;
    this.dateArray = dateArray;
    this.speed = speed;
    yBasicPos = (float) sHeight;
  }

  void update(float count, boolean firstMousePress, boolean status, boolean windBox) {
    this.status = status;
    this.windBox = windBox;

    // If the mouse is on the scroll bar and you click it, retrun the new scroll position
    if (overEvent().equals("scrollbar") && firstMousePress) {
      newSPos = constrain(mouseX, sPosMin, sPosMax);
      this.count = constrain((newSPos - xPos) / sWidth * dateArray.length * speed, 0, ((float) arrayStringDate.length) * speed);
      println("locked count: "+this.count);
    } else if (overEvent().equals("play") && firstMousePress) {
      if (this.status == true) {
        this.status = false;
      } else if (this.status == false) {
        this.status = true;
      }
    } else if (overEvent().equals("reset") && firstMousePress) {
      this.status = false;
      this.count = 0;
    } else if (overEvent().equals("wind box") && firstMousePress) {
      if (this.windBox == true) {
        this.windBox = false;
      } else if (this.windBox == false) {
        this.windBox = true;
      }
    } else if (overEvent().equals("speed 0.5") && firstMousePress) {
      this.count = constrain(count * 150 / speed, 0, ((float) arrayStringDate.length) * 150);
      speed = 150;
    } else if (overEvent().equals("speed 1.0") && firstMousePress) {
      this.count = constrain(count * 100 / speed, 0, ((float) arrayStringDate.length) * 100);
      speed = 100;
    } else if (overEvent().equals("speed 1.5") && firstMousePress) {
      this.count = constrain(count * 50 / speed, 0, ((float) arrayStringDate.length) * 50);
      speed = 50;
    } else {
      // If video is playing, scroll bar keeps going
      this.count = constrain(count, 0, ((float) arrayStringDate.length) * speed);
      newSPos = constrain(xPos + sWidth*(this.count/dateArray.length/speed), sPosMin, sPosMax);
    }
    if (abs(newSPos - sPos) > 1) {
      sPos = sPos + (newSPos-sPos)/loose;
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  String overEvent() {
    if (mouseX > xPos && mouseX < xPos+sWidth &&
    mouseY > yPos && mouseY < getYComponentPos(1)) {
      return "scrollbar";
    } else if (mouseX > xPlayPos-7.5 && mouseX < xPlayPos+7.5 &&
    mouseY > getYComponentPos(1.2) && mouseY < getYComponentPos(3.8)) {
      return "play";
    } else if (mouseX > xPlayPos+xResetPos-8 && mouseX < xPlayPos+xResetPos+8 &&
    mouseY > getYComponentPos(1.2) && mouseY < getYComponentPos(3.8)) {
      return "reset";
    } else if (mouseX > xPlayPos+xResetPos+xPlayingDatePos+xWindBoxPos-6 && mouseX < xPlayPos+xResetPos+xPlayingDatePos+xWindBoxPos+6 &&
    mouseY > getYComponentPos(1.4) && mouseY < getYComponentPos(3.6)) {
      return "wind box";
    } else if (mouseX > xPlayPos+xResetPos+xPlayingDatePos+xWindBoxPos+xWindOptionPos+xSpeedPos+xNextSpeedPos*1-20 && 
    mouseX < xPlayPos+xResetPos+xPlayingDatePos+xWindBoxPos+xWindOptionPos+xSpeedPos+xNextSpeedPos*1+20 &&
    mouseY > getYComponentPos(1.3) && mouseY < getYComponentPos(3.7)) {
      println("speed 0.5 over: true");
      return "speed 0.5";
    } else if (mouseX > xPlayPos+xResetPos+xPlayingDatePos+xWindBoxPos+xWindOptionPos+xSpeedPos+xNextSpeedPos*2-20 && 
    mouseX < xPlayPos+xResetPos+xPlayingDatePos+xWindBoxPos+xWindOptionPos+xSpeedPos+xNextSpeedPos*2+20 &&
    mouseY > getYComponentPos(1.3) && mouseY < getYComponentPos(3.7)) {
      println("speed 1.0 over: true");
      return "speed 1.0";
    } else if (mouseX > xPlayPos+xResetPos+xPlayingDatePos+xWindBoxPos+xWindOptionPos+xSpeedPos+xNextSpeedPos*3-20 && 
    mouseX < xPlayPos+xResetPos+xPlayingDatePos+xWindBoxPos+xWindOptionPos+xSpeedPos+xNextSpeedPos*3+20 &&
    mouseY > getYComponentPos(1.3) && mouseY < getYComponentPos(3.7)) {
      println("speed 1.5 over: true");
      return "speed 1.5";
    } else {
      return "NONE";
    }
  }

  void display() {
    // Draw the playing console box
    noStroke();
    fill(90, 90, 90); // Dark gray
    rectMode(CORNER);
    rect(xPos, yPos, sWidth, sHeight*4);

    // Draw the gray box for the whole play length
    noStroke();
    fill(204);
    rectMode(CORNER);
    rect(xPos, yPos, sWidth, sHeight);
    if (overEvent().equals("scrollbar")) {
      // Draw the current playing point
      noStroke();
      fill(255, 0, 0);
      ellipseMode(RADIUS);
      circle(sPos, yPos+sHeight/2, 8);

      // Show the date of the hovering point
      fill(0);
      textSize(15);
      textAlign(CENTER, CENTER);
      int stringDateIndex = (int) ((float) arrayStringDate.length * ((mouseX - xPos) / sWidth));
      text(arrayStringDate[stringDateIndex], mouseX, yPos-13);

      // Draw the white box between the current playing point and the hovering point
      if (mouseX > sPos) {
        noStroke();
        fill(240, 240, 240); // Whitesmoke
        rectMode(CORNER);
        rect(sPos+8, yPos, mouseX-sPos-8, sHeight);
      }
    }

    // Draw the red box for the current playing point
    fill(255, 0, 0);
    rect(xPos, yPos, sPos-xPos, sHeight);

    // Draw other components
    noStroke();
    fill(255, 255, 255);

    pushMatrix();
    translate(xPlayPos, getYComponentPos(2.5));
    if (status == true) {
      // Pause button
      rectMode(CORNER);
      rect(-7.5, -yBasicPos * 0.9, 5, yBasicPos * 1.8);
      rect(2.5, -yBasicPos * 0.9, 5, yBasicPos * 1.8);
    } else if (status == false) {
      // Play button
      rotate(radians(-90));
      float triangleSide = yBasicPos * 1.8;
      triangle(0, sqrt(3)/3.2*triangleSide, -triangleSide/2, -sqrt(3)/5.8*triangleSide, triangleSide/2, -sqrt(3)/5.8*triangleSide);
      rotate(radians(90));
    }

    // Reset button
    translate(xResetPos, 0);
    rectMode(CORNER);
    rect(-8, -8, 16, 16);

    // Playing date
    translate(xPlayingDatePos, -2);
    textSize(14);
    textAlign(CENTER, CENTER);
    int stringDateIndex = (int) (((float) arrayStringDate.length) * (count / ((float) arrayStringDate.length) / speed));
    text(arrayStringDate[stringDateIndex], 0, 0);
    text("/ "+arrayStringDate[arrayStringDate.length-1], 40, 0);

    // Wind check box
    translate(xWindBoxPos, 2);
    rectMode(CORNER);
    rect(-6, -6, 12, 12);

    if (windBox == true) {
      stroke(0);
      strokeWeight(3);
      line(-3, 1, -1, 3); // Check sign
      line(-1, 3, 3, -4);
      strokeWeight(1);
    }

    // Wind option text
    translate(xWindOptionPos, -3);
    textSize(14);
    textAlign(CENTER, CENTER);
    text("wind option", 0, 0);

    // Speed box
    String[] speedStringArray = {"x 0.5", "x 1.0", "x 1.5"};
    float[] speedArray = {150, 100, 50};
    translate(xSpeedPos , 3);
    for (int i=0; i<3; i++) {
      translate(xNextSpeedPos, 0);
      noStroke();
      rectMode(CORNER);
      if (speed == speedArray[i]) {
        fill(169);
      } else {
        fill(255);
      }
      rect(-20, -8, 40, 16, 2);
      if (speed == speedArray[i]) {
        fill(255);
      } else {
        fill(0);
      }
      textSize(14);
      textAlign(CENTER, CENTER);
      text(speedStringArray[i], 0, -3);
      fill(255);
    }

    popMatrix();
  }

  float getYComponentPos(float r) {
    return yPos + yBasicPos * r;
  }

  float getPos() {
    // Convert sPos to be values between
    // 0 and the total width of the scrollbar
    return sPos * ratio;
  }
}