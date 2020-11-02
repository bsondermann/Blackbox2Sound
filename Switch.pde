class Switch{
  int posx,posy,states,currentState;
  String name;
  boolean isLocked=false;
  Switch(int px,int py, String name, int states,int state){
    this.posx=px;
    this.posy=py;
    this.name=name;
    this.states=states;
    currentState=state;
  }
  int getCurrentState(){return currentState;}
  void setCurrentState(int s){currentState=s;}
  void setLocked(boolean locked){
    isLocked=locked;
  }
  void show(){
    rectMode(CORNER);
    fill(100);
    stroke(0);
    for(int i = 0; i<states;i++){
      rect(posx+i*15,posy,15,15);
    }
    if(!isLocked){
      fill(255,0,0);
    }else{
      fill(255/2,255/3,255/3);
    }
    rect(posx+currentState*15,posy,15,15);
    fill(0);
    textAlign(CENTER,CENTER);
    text(name,posx+(float(states)/2)*15,posy+28);
  }
  int clicked(float px,float py){
    if(!isLocked){
      if(px>posx&&px<posx+states*15&&py>posy&&py<posy+15){
        currentState= (int)((px-posx)/15);
        return currentState; 
      }
    }
    return -1;
  }
}
