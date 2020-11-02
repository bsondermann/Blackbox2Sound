class Slider{
  int posx,posy,h;
  float value;
  boolean dragging = false;
  boolean vertical;
  Slider(int px,int py,int hei, float val, boolean vert){
    posx=px;
    posy=py;
    h=hei;
    vertical=vert;
    value = val;
  }
  void show(){
    noStroke();
    fill(255);
    rectMode(CENTER);
    if(vertical){
      rect(posx,posy+h/2,10,h);
    }else{
      rect(posx+h/2,posy,h,10);
    }
    fill(255,0,0);
    if(dragging){
      if(vertical){
        value=map(constrain(mouseY,posy,posy+h),posy,posy+h,1,0);
      }else{
        value=map(constrain(mouseX,posx,posx+h),posx,posx+h,0,1);
      }
    }
    if(vertical){
      rect(posx,posy+map(value,0,1,h,0),30,10);
    }else{
      rect(posx+map(value,1,0,h,0),posy,10,30);
    }
  }
  boolean released(){
    if(dragging==true){
      dragging=false;
      return true;
    }
    return false;
  }
  float getValue(){return value;}
  void clicked(float px,float py){
    if(vertical){
      if(px>posx-15&&px<posx+15&&py>map(value,0,1,posy+h,posy)-5&&py<map(value,0,1,posy+h,posy)+5){dragging=true;}
    }else{
      if(py>posy-15&&py<posy+15&&px>map(value,1,0,posx+h,posx)-5&&px<map(value,1,0,posx+h,posx)+5){dragging=true;}
    }
  }
  void setPosition(float p){value=p;}
}
