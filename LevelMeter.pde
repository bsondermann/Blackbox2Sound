class LevelMeter{
  private int x,y,h,w;
  private float level;
  LevelMeter(int x, int y, int h,int w){
    this.x=x;
    this.y=y;
    this.h=h;
    this.w=w;
  }
  void setLevel(float lvl){
    this.level=constrain(lvl,0,1);
  }
  void show(){
    rectMode(CORNER);
    noStroke();
    fill(0);
    rect(x,y,w,h);
    fill(255);
    rect(x,y+h,w,-(map(level,0,1,0,h)));
    fill(0,255,0,127);
    rect(x,y+h/3,w,h*(2.0/3)+0.5);
    fill(255,255,0,127);
    rect(x,y+h/6,w,h*(1.0/6));
    fill(255,0,0,127);
    rect(x,y,w,h*(1.0/6));
  }
}
