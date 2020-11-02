class GuiController{
  Slider volslider,timeslider,spectrumSlider;
  CheckBox checkRoll,checkPitch,checkYaw;
  Switch filterSwitch, modeSwitch;
  Button exportButton;
  GuiController(){
    volslider=new Slider(width-20,50,height-100,0.2,true);
    timeslider = new Slider(50,height-20,width-100,0,false);
    spectrumSlider = new Slider(300,175,height-330,0.2,true);
    sound.spectrum.setScale(map(spectrumSlider.getValue(),0,1,20,0.5));
    exportButton=new Button(115,550,"Export Sound");
    checkRoll = new CheckBox(65,200,true,"Roll");
    checkPitch = new CheckBox(115,200,true,"Pitch");
    checkYaw = new CheckBox(165,200,true,"Yaw");
    filterSwitch=new Switch(100,140,"    Filtered | Unfiltered",2,1);
    modeSwitch=new Switch(100,245,"   Gyro | DTerm",2,0);
  }
  void clicked(float px,float py){
    volslider.clicked(px,py);
    timeslider.clicked(px,py);
    spectrumSlider.clicked(px,py);
    if(checkRoll.clicked(px,py)){
      sound.setActive(checkRoll.getChecked(),"ROLL");
    }
    if(checkPitch.clicked(px,py)){
      sound.setActive(checkPitch.getChecked(),"PITCH");
    }
    if(checkYaw.clicked(px,py)){
      sound.setActive(checkYaw.getChecked(),"YAW");
    }
    if(filterSwitch.clicked(px,py)!=-1){
      sound.setFiltered(filterSwitch.getCurrentState()==0);
    }
    if(modeSwitch.clicked(px,py)!=-1){
      sound.setGyro(modeSwitch.getCurrentState()==0);
      if(modeSwitch.getCurrentState()==1){
        filterSwitch.setCurrentState(1);
        filterSwitch.setLocked(true);
      }else{
        filterSwitch.setLocked(false);
        sound.setFiltered(filterSwitch.getCurrentState()==0);
      }
    }
    if(exportButton.clicked(px,py)){
      exportButton.show();
      sound.exportSound(sketchPath()+"/export/");
    }
  }
  void released(){
    if(volslider.released()){
      vol=volslider.getValue();
      sound.applyVolumes();
    }
    timeslider.released();
    spectrumSlider.released();
    exportButton.released();
  }
  void show(){
    volslider.show();
    if(volslider.dragging){
      vol=volslider.getValue();
      sound.applyVolumes();
    }
    if(spectrumSlider.dragging){
      sound.spectrum.setScale(map(spectrumSlider.getValue(),0,1,20,0.5));
    }
    timeslider.show();
    if(timeslider.dragging){
      sound.jump(map(timeslider.getValue(),0,1,0,sound.getDuration()));
    }else{
      timeslider.setPosition(map(sound.getPosition(),0,sound.getDuration(),0,1));
    }
    checkRoll.show();
    checkPitch.show();
    checkYaw.show();
    filterSwitch.show();
    modeSwitch.show();
    spectrumSlider.show();
    exportButton.show();
  }
}
