
class HScrollbar {
  int sWidth, sHeight;    // width and height of bar
  float xPos, yPos;       // x and y position of bar
  float sPos, newSPos;    // x position of slider
  float sPosMin, sPosMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;
  boolean firstMousePress = false;

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
    sPos = xPos;
    newSPos = sPos;
    sPosMin = xPos;
    sPosMax = xPos + sWidth - sHeight;
    loose = l;
    this.dateArray = dateArray;
    this.speed = speed;
  }

  void update(float count) {
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
    this.count = count;
    newSPos = xPos + sWidth*(count/dateArray.length/speed);
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
    noStroke();
    fill(204);
    rectMode(CORNER);
    rect(xPos, yPos, sWidth, sHeight);
    if (over || locked) {
      fill(0, 0, 0);
    //   rectMode(CORNER);
    //   rect(sPos-sHeight, yPos-sHeight-5, 3*sHeight, sHeight, 3);
    } else {
      fill(255, 0, 0);
    }
    rect(xPos, yPos, sPos, sHeight);
  }

  float getPos() {
    // Convert sPos to be values between
    // 0 and the total width of the scrollbar
    return sPos * ratio;
  }
}