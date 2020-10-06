class GyroSound{
  private PApplet applet;
  private float[] valFiltered,valUnfiltered;
  private String name;
  private AudioSample filtered,unfiltered, hpfFiltered,hpfUnfiltered;
  private HighPass hpFiltered, hpUnfiltered;
  private int sampleRate;
  private int cutoff=150;
  private boolean filterActive=false;
  private boolean playing=false;
  private boolean active=false;
  GyroSound(PApplet applet,float[] f,float[]u, String name, int sampleRate){
    this.applet = applet;
    float maxf=0.0;
    float maxu=0.0;
    for(int i = 0; i< f.length;i++){
      if(f[i]>maxf){maxf=f[i];}
      if(u[i]>maxu){maxu=u[i];}
    }
    valFiltered=new float[f.length];
    valUnfiltered=new float[u.length];
    
    for(int i = 0; i<valUnfiltered.length;i++){
      valFiltered[i] = (f[i]/maxf)*100;
      valUnfiltered[i] = (u[i]/maxu)*100;
    }
    this.name = name;
    this.sampleRate = sampleRate;
    
    filtered = new AudioSample(this.applet,this.valFiltered,this.sampleRate);
    unfiltered = new AudioSample(this.applet,this.valUnfiltered,this.sampleRate);
    hpfFiltered = new AudioSample(this.applet,this.valFiltered,this.sampleRate);
    hpfUnfiltered = new AudioSample(this.applet,this.valUnfiltered,this.sampleRate);
    
    hpFiltered = new HighPass(this.applet);
    hpFiltered.process(hpfFiltered,this.cutoff);
    hpUnfiltered = new HighPass(this.applet);
    hpUnfiltered.process(hpfUnfiltered,this.cutoff);
    
    
  }
  void jump(float t){

    filtered.jump(t);
    unfiltered.jump(t);
    hpfFiltered.jump(t);
    hpfUnfiltered.jump(t);
    play();
    
  }
  float getDuration(){
    return filtered.duration();
  }
  
  void mute(){
    filtered.amp(0);
    unfiltered.amp(0);
    hpfFiltered.amp(0);
    hpfUnfiltered.amp(0);
  }
  void unmute(){

    if(filterActive){
    hpfFiltered.amp(vol);
    hpfUnfiltered.amp(0);
    }else{
    hpfFiltered.amp(0);
    hpfUnfiltered.amp(vol);
    }
  }
  
  void setFilterActive(boolean filter){
    filterActive=filter;
    if(active){
      unmute();
    }
  }
  String getTimeCode(){
    String sec1="0";
    String sec2="00";
    String sec21="0:";
    if(int(filtered.duration())%60<10){sec2="0"+int(filtered.duration())%60;}else{sec2=int(filtered.duration())%60+"";}
      sec21=int(filtered.duration())/60+":";
    if(time%60<10)
      {sec1="0"+int(time)%60;}
    else{sec1=int(time)%60+"";}
    return (int(time)/60+":"+sec1+"    |    "+sec21+sec2);
  }
  void play(){
    if(!playing){
    filtered.play();
    unfiltered.play();
    hpfFiltered.play();
    hpfUnfiltered.play();
    }
    if(active){
    unmute();
    }
    playing=true;
    
  }
  void pause(){

    mute();
    if(playing){
    filtered.pause();
    unfiltered.pause();
    hpfFiltered.pause();
    hpfUnfiltered.pause();
  }
    playing=false;
    
    }
  boolean getFilterActive(){return filterActive;}
  boolean getPlaying(){return playing;}

  void setActive(boolean val){
    this.active = val;
    if(val==false){mute();}else{unmute();}
  }
  boolean getActive(){return this.active;}
}



/*
filtered.
    unfiltered.
    hpfFiltered.
    hpfUnfiltered.
    */
