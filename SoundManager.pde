class SoundManager{
  GyroSound roll,pitch,yaw;
  Spectrum spectrum;
  PApplet applet;
RamTable table;
  SoundManager(PApplet applet){
    this.applet = applet;
  }
  boolean getFilterActive(){return roll.getFilterActive();}
  boolean getPlaying(){return roll.playing;}
  void stopSample(){
    roll.pause();
    pitch.pause();
    yaw.pause();
  }
  float getDuration(){
    return roll.getDuration();
  }
  void jump(float time){
    roll.jump(time);
    pitch.jump(time);
    yaw.jump(time);
  }
  void applyVolumes(){
    roll.unmute();
    pitch.unmute();
    yaw.unmute();
  }
  void toggleFiltered(){
    roll.setFilterActive(!roll.getFilterActive());
 
    pitch.setFilterActive(!pitch.getFilterActive());

    yaw.setFilterActive(!yaw.getFilterActive());

  }
  String getTimeCode(){
    return roll.getTimeCode();
  }
  void mute(){
    roll.mute();
    pitch.mute();
    yaw.mute();
  }
  void pause(){
    roll.pause();
    pitch.pause();
    yaw.pause();
  }
  void resume(){
  roll.play(); 
  pitch.play(); 
  yaw.play(); 
  }
  void loadLog(File log){
  
    table = new RamTable(log.getAbsolutePath());
      dur=Long.parseLong(table.getRow(table.getRowCount()-1).getString(1).trim())-Long.parseLong(table.getRow(1).getString(1).trim());
      rate = Math.round(table.getRowCount()/(dur/1000000)/1000);
    float[] vrfiltered = new float[table.getRowCount()-2];
    for (int i = 0; i < vrfiltered.length; i++) {
      vrfiltered[i] =float(Integer.parseInt(table.getRow(i+1).getString(25).trim()));
    }
    float[] unrfiltered = new float[table.getRowCount()-2];
    for (int i = 0; i < unrfiltered.length; i++) {
      unrfiltered[i] =float(Integer.parseInt(table.getRow(i+1).getString(31).trim()));
    }
    float[] vpfiltered = new float[table.getRowCount()-2];
    for (int i = 0; i < vpfiltered.length; i++) {
      vpfiltered[i] =float(Integer.parseInt(table.getRow(i+1).getString(26).trim()));
    }
    float[] unpfiltered = new float[table.getRowCount()-2];
    for (int i = 0; i < unrfiltered.length; i++) {
      unpfiltered[i] =float(Integer.parseInt(table.getRow(i+1).getString(32).trim()));
    }
    float[] vyfiltered = new float[table.getRowCount()-2];
    for (int i = 0; i < vrfiltered.length; i++) {
      vyfiltered[i] =float(Integer.parseInt(table.getRow(i+1).getString(27).trim()));
    }
    float[] unyfiltered = new float[table.getRowCount()-2];
    for (int i = 0; i < unrfiltered.length; i++) {
      unyfiltered[i] =float(Integer.parseInt(table.getRow(i+1).getString(33).trim()));
    }
    roll=new GyroSound(applet,vrfiltered,unrfiltered,"roll",int(rate)*1000);
    pitch=new GyroSound(applet,vpfiltered,unpfiltered,"pitch",int(rate)*1000);
    yaw=new GyroSound(applet,vyfiltered,unyfiltered,"yaw",int(rate)*1000);

  }
  void show(){
    if(spectrum!=null){spectrum.show();}
  }
  boolean getActive(String axis){ 
    if(roll!=null&&pitch!=null&&yaw!=null){
    if(axis.equals("ROLL")){
      return roll.getActive();
    }
    if(axis.equals("PITCH")){
      return pitch.getActive();
    }
    if(axis.equals("YAW")){
      return yaw.getActive();
    }}
    return false;
  }
  void setActive(boolean active, String axis){
  
  if(roll!=null&&pitch!=null&&yaw!=null){
    
    if(axis.equals("ROLL")){
      roll.setActive(active);
    }
    if(axis.equals("PITCH")){
      pitch.setActive(active);
    }
    if(axis.equals("YAW")){
      yaw.setActive(active);
    }}
  }
}
