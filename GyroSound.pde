class GyroSound{
  private PApplet applet;
  private Amplitude rmsu,rmsf,rmsd;
  private float[] valFiltered,valUnfiltered,dtermval;
  private String name;
  private AudioSample hpfFiltered,hpfUnfiltered,dterm;
  private HighPass hpFiltered, hpUnfiltered,hpfDterm;
  private int sampleRate;
  private int cutoff=150;
  private boolean filterActive=false;
  private boolean active=true;
  private boolean gyroactive=true;
  GyroSound(PApplet applet,float[] f,float[]u,float[]d, String name, int sampleRate){
    this.applet = applet;
    /*float maxf=0.0;
    float maxu=0.0;
    for(int i = 0; i< f.length;i++){
      if(f[i]>maxf){maxf=f[i];}
      if(u[i]>maxu){maxu=u[i];}
    }*/
    valFiltered=new float[f.length];
    valUnfiltered=new float[u.length];
    dtermval = new float[d.length];
    
    for(int i = 0; i<valUnfiltered.length;i++){
      valFiltered[i] = (f[i]/50);
      valUnfiltered[i] = (u[i]/50);
      dtermval[i] = d[i]/50;
    }
    this.name = name;
    this.sampleRate = sampleRate;
    
    hpfFiltered = new AudioSample(this.applet,this.valFiltered,this.sampleRate);
    hpfUnfiltered = new AudioSample(this.applet,this.valUnfiltered,this.sampleRate);
    dterm = new AudioSample(this.applet,this.dtermval,this.sampleRate);
    hpFiltered = new HighPass(this.applet);
    hpFiltered.process(hpfFiltered,this.cutoff);
    hpUnfiltered = new HighPass(this.applet);
    hpUnfiltered.process(hpfUnfiltered,this.cutoff);
    hpfDterm = new HighPass(this.applet);
    hpfDterm.process(dterm,this.cutoff);
    
    rmsu = new Amplitude(applet);
    rmsu.input(hpfUnfiltered);
    rmsf = new Amplitude(applet);
    rmsf.input(hpfFiltered);
    rmsd = new Amplitude(applet);
    rmsd.input(dterm);
    mute();
  }
  AudioSample[] getSamples(){
    AudioSample[]ret = new AudioSample[3];
    ret[0]=hpfFiltered;
    ret[1]=hpfUnfiltered;
    ret[2]=dterm;
    return ret;
  }
  void jump(float t){

    hpfFiltered.jump(t);
    hpfUnfiltered.jump(t);
    dterm.jump(t);
    play();
    
  }
  float getDuration(){
    return hpfFiltered.duration();
  }
  float getPosition(){return hpfFiltered.position();}
  
  void mute(){
    hpfFiltered.amp(0);
    hpfUnfiltered.amp(0);
    dterm.amp(0);
  }
  void unmute(){
  if(active){
    if(gyroactive){
    if(filterActive){
    hpfFiltered.amp(vol);
    hpfUnfiltered.amp(0);
    }else{
    hpfFiltered.amp(0);
    hpfUnfiltered.amp(vol);
    }}else{
      dterm.amp(vol);
    }
  }
  }
  
  void setFilterActive(boolean filter){
    filterActive=filter;

      unmute();
    
  }
  String getTimeCode(){
    String sec1="0";
    String sec2="00";
    String sec21="0:";
    if(int(hpfFiltered.duration())%60<10){sec2="0"+int(hpfFiltered.duration())%60;}else{sec2=int(hpfFiltered.duration())%60+"";}
      sec21=int(hpfFiltered.duration())/60+":";
    if(sound.getPosition()%60<10)
      {sec1="0"+int(sound.getPosition())%60;}
    else{sec1=int(sound.getPosition())%60+"";}
    return (int(sound.getPosition())/60+":"+sec1+"    |    "+sec21+sec2);
  }
  void play(){
    if(!hpfFiltered.isPlaying()){
    hpfFiltered.play();
    hpfUnfiltered.play();
    dterm.play();
    }
    unmute();
    
    
  }
  void pause(){

    mute();
    if(hpfFiltered.isPlaying()){
      hpfFiltered.pause();
      hpfUnfiltered.pause();
      dterm.pause();
    }
    
    }
  boolean getFilterActive(){return filterActive;}
  boolean getPlaying(){return hpfFiltered.isPlaying();}

  void setActive(boolean val){
    this.active = val;
    if(val==false){mute();}else{unmute();}
  }
  boolean getActive(){return this.active;}
  float getAmplitude(){
    return rmsu.analyze()+rmsf.analyze()+rmsd.analyze();
  }
  void cue(float pos){
    hpfFiltered.cue(pos);
    hpfUnfiltered.cue(pos);
    dterm.cue(pos);
  }
  void setGyro(boolean gyromode){gyroactive = gyromode;mute();unmute();}
  boolean getGyro(){return this.gyroactive;}
}



/*
filtered.
    unfiltered.
    hpfFiltered.
    hpfUnfiltered.
    */
