class SoundManager {
  GyroSound roll, pitch, yaw;
  Spectrum spectrum;
  PApplet applet;
  RamTable table;
  int samplesize=256;
  LevelMeter meterRoll, meterPitch, meterYaw;
  SoundManager(PApplet applet) {
    this.applet = applet;

    meterRoll = new LevelMeter(width-110, 50, height-100, 10);

    meterPitch = new LevelMeter(width-90, 50, height-100, 10);

    meterYaw = new LevelMeter(width-70, 50, height-100, 10);
    spectrum = new Spectrum(samplesize,3,340,175);
  }
  boolean getFilterActive() {
    return roll.getFilterActive();
  }
  boolean getPlaying() {
    return roll.getPlaying();
  }
  float getPosition() {
    return roll.getPosition();
  }
  void cue(float pos) {
    roll.cue(pos);
    pitch.cue(pos);
    yaw.cue(pos);
  }
  float getDuration() {
    return roll.getDuration();
  }
  void jump(float time) {
    roll.jump(time);
    pitch.jump(time);
    yaw.jump(time);
  }
  void applyVolumes() {
    roll.unmute();
    pitch.unmute();
    yaw.unmute();
  }
  void setFiltered(boolean f) {
    roll.setFilterActive(f);

    pitch.setFilterActive(f);

    yaw.setFilterActive(f);
  }
  String getTimeCode() {
    return roll.getTimeCode();
  }
  void mute() {
    roll.mute();
    pitch.mute();
    yaw.mute();
  }
  void pause() {
    roll.pause();
    pitch.pause();
    yaw.pause();
  }
  void resume() {
    roll.play(); 
    pitch.play(); 
    yaw.play();
  }
  float getAmplitude(String axis) {
    if (roll!=null&&pitch!=null&&yaw!=null) {
      if (axis.equals("ROLL")) {
        return roll.getAmplitude();
      }
      if (axis.equals("PITCH")) {
        return pitch.getAmplitude();
      }
      if (axis.equals("YAW")) {
        return yaw.getAmplitude();
      }
    }
    return 0;
  }
  void loadLog(File log) {

    table = new RamTable(log.getAbsolutePath());
    if(table.getRowCount()>2){
    dur=Long.parseLong(table.getRow(table.getRowCount()-1).getString(1).trim())-Long.parseLong(table.getRow(1).getString(1).trim());

    rate=(float(table.getRowCount())-1)/(dur/1000000);
    int[]indexes = new int[8];
    for(int i = 0; i< table.getRow(0).getLength();i++){
      if(table.getRow(0).getString(i).contains("axisD[0]")){indexes[0]=i;}
      if(table.getRow(0).getString(i).contains("axisD[1]")){indexes[1]=i;}
      if(table.getRow(0).getString(i).contains("gyroADC[0]")){indexes[2]=i;}
      if(table.getRow(0).getString(i).contains("gyroADC[1]")){indexes[3]=i;}
      if(table.getRow(0).getString(i).contains("gyroADC[2]")){indexes[4]=i;}
      if(table.getRow(0).getString(i).contains("debug[0]")){indexes[5]=i;}
      if(table.getRow(0).getString(i).contains("debug[1]")){indexes[6]=i;}
      if(table.getRow(0).getString(i).contains("debug[2]")){indexes[7]=i;}
    }
    if(indexes[6]==0&&indexes[7]==0&&indexes[5]==0){indexes[5]=indexes[2];indexes[6]=indexes[3];indexes[7]=indexes[4];}
    float[] vrfiltered = new float[table.getRowCount()-2];
    for (int i = 0; i < vrfiltered.length; i++) {
      vrfiltered[i] =float(Integer.parseInt(table.getRow(i+1).getString(indexes[2]).trim()));
    }
    float[] unrfiltered = new float[table.getRowCount()-2];
    for (int i = 0; i < unrfiltered.length; i++) {
      unrfiltered[i] =float(Integer.parseInt(table.getRow(i+1).getString(indexes[5]).trim()));
    }
    float[] vpfiltered = new float[table.getRowCount()-2];
    for (int i = 0; i < vpfiltered.length; i++) {
      vpfiltered[i] =float(Integer.parseInt(table.getRow(i+1).getString(indexes[3]).trim()));
    }
    float[] unpfiltered = new float[table.getRowCount()-2];
    for (int i = 0; i < unrfiltered.length; i++) {
      unpfiltered[i] =float(Integer.parseInt(table.getRow(i+1).getString(indexes[6]).trim()));
    }
    float[] vyfiltered = new float[table.getRowCount()-2];
    for (int i = 0; i < vrfiltered.length; i++) {
      vyfiltered[i] =float(Integer.parseInt(table.getRow(i+1).getString(indexes[4]).trim()));
    }
    float[] unyfiltered = new float[table.getRowCount()-2];
    for (int i = 0; i < unrfiltered.length; i++) {
      unyfiltered[i] =float(Integer.parseInt(table.getRow(i+1).getString(indexes[7]).trim()));
    }
    float[] dtermroll = new float[table.getRowCount()-2];
    for (int i = 0; i < unrfiltered.length; i++) {
      dtermroll[i] =float(Integer.parseInt(table.getRow(i+1).getString(indexes[0]).trim()));
    }
    float[] dtermpitch = new float[table.getRowCount()-2];
    for (int i = 0; i < unrfiltered.length; i++) {
      dtermpitch[i] =float(Integer.parseInt(table.getRow(i+1).getString(indexes[1]).trim()));
    }
    float[] dtermyaw = new float[table.getRowCount()-2];
    for (int i = 0; i < unrfiltered.length; i++) {
      dtermyaw[i] =0;
    }

    roll=pitch=yaw=null;
    roll=new GyroSound(applet, vrfiltered, unrfiltered, dtermroll, "roll", int(rate));
    pitch=new GyroSound(applet, vpfiltered, unpfiltered, dtermpitch, "pitch", int(rate));
    yaw=new GyroSound(applet, vyfiltered, unyfiltered, dtermyaw, "yaw", int(rate));
  }else{
    roll=pitch=yaw=null;
    roll=new GyroSound(applet,new float[]{0}, new float[]{0},new float[]{0}, "roll", 0);
    pitch=new GyroSound(applet, new float[]{0}, new float[]{0},new float[]{0}, "pitch", 0);
    yaw=new GyroSound(applet, new float[]{0}, new float[]{0}, new float[]{0}, "yaw", 0);
    }
    
  }
  void show() {
    if (vol>0) {
      meterRoll.setLevel(getAmplitude("ROLL")*(1/vol));
    } else {
      meterRoll.setLevel(0);
    }
    meterRoll.show();
    if (vol>0) {
      meterPitch.setLevel(getAmplitude("PITCH")*(1/vol));
    } else {
      meterPitch.setLevel(0);
    }
    meterPitch.show();
    if (vol>0) {
      meterYaw.setLevel(getAmplitude("YAW")*(1/vol));
    } else {
      meterYaw.setLevel(0);
    }
    meterYaw.show();
    if(yaw.getPlaying()){
      updateSpectrum();
    }
    spectrum.show();
    
  }
  void updateSpectrum(){
    float[] data = new float[samplesize];
    float[]droll = roll.getFrame(samplesize);
    float[]dpitch = pitch.getFrame(samplesize);
    float[]dyaw = yaw.getFrame(samplesize);
    
    for(int i = 0; i<data.length; i++){
      data[i]= droll[i]+dpitch[i]+dyaw[i];
    }
    spectrum.update(data);
  }
  boolean getActive(String axis) { 
    if (roll!=null&&pitch!=null&&yaw!=null) {
      if (axis.equals("ROLL")) {
        return roll.getActive();
      }
      if (axis.equals("PITCH")) {
        return pitch.getActive();
      }
      if (axis.equals("YAW")) {
        return yaw.getActive();
      }
    }
    return false;
  }
  void setActive(boolean active, String axis) {

    if (roll!=null&&pitch!=null&&yaw!=null) {

      if (axis.equals("ROLL")) {
        roll.setActive(active);
      }
      if (axis.equals("PITCH")) {
        pitch.setActive(active);
      }
      if (axis.equals("YAW")) {
        yaw.setActive(active);
      }
    }
  }
  void setGyro(boolean gyro) {
    roll.setGyro(gyro);
    pitch.setGyro(gyro);
    yaw.setGyro(gyro);
  }
  boolean getGyro() {
    return roll.getGyro();
  }
  void exportSound(String path) {
    new File(path).mkdir();
    roll.saveAudio(path);
    pitch.saveAudio(path);
    yaw.saveAudio(path);
  }
 
}
