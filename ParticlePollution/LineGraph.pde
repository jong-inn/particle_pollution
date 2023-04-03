
class LineGraph{
  
  float[] value;
//   int[] pos;
  String[] pos;
  float maxY;
  color c;
  int dayCount;
  float textPos;
  
  // one line
  public LineGraph(float[] value, String[] pos, float maxY, color c, int dayCount, float textPos){
    this.value = value;
    this.pos = pos;
    this.maxY = maxY;
    this.c = c;
    this.dayCount = dayCount;
    this.textPos = textPos;
  }
 
  
  void drawinging(){
    int pre_x = 1140;
    float pre_y = 750 - 250*value[0]/maxY;
    fill(c);
    circle(pre_x, pre_y, 10);
    textAlign(LEFT, CENTER);
    text(value[0], pre_x+9, pre_y+textPos);
    textAlign(CENTER, CENTER);
    text(pos[0], pre_x, 860);
    if (value.length > 1){
      for(int i=1; i < dayCount+1; i++){
        fill(c);
        int recent_x = 1140 + 75*(i);
        float recent_y = 750 - 250*value[i]/maxY;
        fill(c);
        circle(recent_x, recent_y, 8);
        textAlign(LEFT, CENTER);
        text(value[i], recent_x+9, recent_y+textPos);
        line(pre_x, pre_y, recent_x, recent_y);
        textAlign(CENTER, CENTER);
        text(pos[i], recent_x, 860);
        pre_x = recent_x;
        pre_y = recent_y;
      }
    }
  }
}
