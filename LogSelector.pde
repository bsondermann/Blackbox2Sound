class LogSelector{
  private float posx,posy;
  private int numlogs=10;
  private int currentlog=1;
  LogSelector(float px,float py){
    this.posx=px;
    this.posy=py;
  }
  
  void show(){
    rectMode(CORNER);
    fill(100);
    rect(posx,posy,120,30);
    fill(150);
    rect(posx,posy,30,30);
    rect(posx+90,posy,30,30);
    fill(0);
    rect(posx+5,posy+13,20,4);
    rect(posx+95,posy+13,20,4);
    rect(posx+103,posy+5,4,20);
    textSize(15);
    text(currentlog+" / "+numlogs,posx+60,posy+12);
  }
  boolean click(float px,float py){
    if(px>posx&&px<posx+30&&py>posy&&py<posy+30){
      if(currentlog>1){currentlog--;return true;}
    }
    if(px>posx+90&&px<posx+120&&py>posy&&py<posy+30){
      if(currentlog<numlogs){currentlog++;return true;}
    }
    return false;
  }
  void setNumlogs(int lognum){this.numlogs=lognum;currentlog=1;}
  int getCurrentLog(){return this.currentlog-1;}
}
