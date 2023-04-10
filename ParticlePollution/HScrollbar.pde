
class HScrollbar {
  int sWidth, sHeight;    // width and height of bar
  float xPos, yPos;       // x and y position of bar
  float sPos, newSPos;    // x position of slider
  float sPosMin, sPosMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  boolean status = false;         // is the video playing?
  float ratio;

  String[] dateArray;
  float count;
  float speed;

  HScrollbar (float xp, float yp, int sw, int sh, int l, String[] dateArray, float speed) {
    sWidth = sw;
    sHeight = sh;
    int widthtoheight = sw - sh;
    ratio = (float) sw / (float) widthtoheight;
    xPos = xp;
    yPos = yp-sHeight/2;
    // sPos = xPos;
    sPos = 0;
    newSPos = sPos;
    sPosMin = xPos;
    sPosMax = xPos + sWidth;
    loose = l;
    this.dateArray = dateArray;
    this.speed = speed;
  }

  void update(float count, boolean firstMousePress, boolean status) {
    this.status = status;

    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (firstMousePress && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    // If the mouse is on the scroll bar and you click it, retrun the new scroll position
    if (locked) {
      newSPos = constrain(mouseX-sHeight/2, sPosMin, sPosMax);
      this.count = (newSPos - xPos) / sWidth / dateArray.length / speed;
    }
    if (abs(newSPos - sPos) > 1) {
      sPos = sPos + (newSPos-sPos)/loose;
    }
    // If video is playing, scroll bar keeps going
    this.count = constrain(count, 0, ((float) arrayStringDate.length) * speed - 0.001);
    newSPos = constrain(xPos + sWidth*(count/dateArray.length/speed), sPosMin, sPosMax);
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > xPos && mouseX < xPos+sWidth &&
      mouseY > yPos && mouseY < yPos+sHeight) {
      return true;
    } else {
      return false;
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
    if (over) {
      // Draw the current playing point
      noStroke();
      fill(255, 0, 0);
      ellipseMode(RADIUS);
      circle(sPos, yPos+sHeight/2, 8);

      // Show the date of the hovering point
      fill(0);
      textSize(12);
      textAlign(CENTER, CENTER);
      int stringDateIndex = (int) ((float) arrayStringDate.length * ((mouseX - xPos) / sWidth));
      text(arrayStringDate[stringDateIndex], mouseX, yPos-10);

      // Draw the white box between the current playing point and the hovering point
      if (mouseX > sPos) {
        noStroke();
        fill(240, 240, 240); // Whitesmoke
        rectMode(CORNER);
        rect(sPos+8, yPos, mouseX-sPos-8, sHeight);
      }
    }

    // if (over || locked) {
    //   fill(0, 0, 0);
    // //   rectMode(CORNER);
    // //   rect(sPos-sHeight, yPos-sHeight-5, 3*sHeight, sHeight, 3);
    // } else {
    //   fill(255, 0, 0);
    // }

    // Draw the red box for the current playing point
    fill(255, 0, 0);
    rect(xPos, yPos, sPos-xPos, sHeight);

    // Draw the play and stop button
    noStroke();
    fill(255, 255, 255);

    pushMatrix();
    translate(xPos+15, yPos+((float) sHeight)*2.5);
    if (status == true) {
      // Pause button
      rectMode(CORNER);
      rect(-7.5, -((float) sHeight) * 0.9, 5, ((float) sHeight) * 1.8);
      rect(2.5, -((float) sHeight) * 0.9, 5, ((float) sHeight) * 1.8);
    } else if (status == false) {
      // Play button
      rotate(radians(-90));
      float triangleSide = ((float) sHeight) * 1.8;
      triangle(0, sqrt(3)/3.2*triangleSide, -triangleSide/2, -sqrt(3)/5.8*triangleSide, triangleSide/2, -sqrt(3)/5.8*triangleSide);
      rotate(radians(90));
    }

    // Reset button
    translate(25, 0);
    rectMode(CORNER);
    rect(-8, -8, 16, 16);

    // Playing date
    translate(50, -2);
    textSize(14);
    textAlign(CENTER, CENTER);
    int stringDateIndex = (int) (((float) arrayStringDate.length) * (count / ((float) arrayStringDate.length) / speed));
    text(arrayStringDate[stringDateIndex], 0, 0);
    text("/ "+arrayStringDate[arrayStringDate.length-1], 40, 0);

    popMatrix();
  }

  float getPos() {
    // Convert sPos to be values between
    // 0 and the total width of the scrollbar
    return sPos * ratio;
  }
}