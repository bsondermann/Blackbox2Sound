class Button{
  int posx,posy;
  String name;
  boolean clicked=false;
  Button(int px, int py, String name){
    posx=px;
    posy=py;
    this.name=name;
  }
  void show(){
    rectMode(CENTER);
    if(!clicked){
      fill(100);
    }else{
      fill(50);
    }
    stroke(0);
    textSize(15);
    rect(posx,posy,textWidth(name)+30,30);
    fill(0);
    textAlign(CENTER,CENTER);
    text(name,posx,posy-3);
  }
  boolean clicked(float px,float py){
    textSize(15);
    if(px>posx-(textWidth(name)+10)/2.0&&px<posx+(textWidth(name)+10)/2.0&&py>posy-15&&py<posy+15){
      clicked=true;
      return true;
    }
    return false;
  }
  void released(){
    clicked=false;
  }
}
