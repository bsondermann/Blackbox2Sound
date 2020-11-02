class CheckBox{
  int posx,posy;
  boolean checked;
  String name;
  CheckBox(int px,int py,boolean check, String na){
    posx=px;
    posy=py;
    checked =check;
    name = na;
  }
 
  void show(){
    rectMode(CENTER);
    stroke(0);
    if(checked){fill(255,0,0);}else{fill(100);}
    rect(posx,posy,15,15);
    textSize(15);
    textAlign(CENTER,CENTER);
    fill(0);
    text(name,posx,posy+20);
  }
  boolean clicked(float px,float py){
    if(px>posx-7.5&&px<posx+7.5&&py>posy-7.5&&py<posy+7.5){checked=!checked;}
    return true;
  }
  boolean getChecked(){return checked;}
  
}
