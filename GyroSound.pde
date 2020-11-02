class GyroSound{
  private PApplet applet;
  private Amplitude rmsu,rmsf,rmsd;
  private float[] valFiltered,valUnfiltered,dtermval;
  private String name;
  private AudioSample hpfFiltered,hpfUnfiltered,dterm;
  private int sampleRate;
  private int cutoff=150;
  private boolean filterActive=false;
  private boolean active=true;
  private boolean gyroactive=true;
  private int sampleRateExport=44100;
  GyroSound(PApplet applet,float[] f,float[]u,float[]d, String name, int sampleRate){
    this.applet = applet;
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
    valFiltered = hpf(valFiltered,10);
    valUnfiltered = hpf(valUnfiltered,10);
    dtermval = hpf(dtermval,10);
    
    hpfFiltered = new AudioSample(this.applet,valFiltered,this.sampleRate);
    hpfUnfiltered = new AudioSample(this.applet,valUnfiltered,this.sampleRate);
    dterm = new AudioSample(this.applet,dtermval,this.sampleRate);
   // new File(sketchPath()+"/export/").mkdir();
    //saveAudio(sketchPath()+"/export/");
    
    rmsu = new Amplitude(applet);
    rmsu.input(hpfUnfiltered);
    rmsf = new Amplitude(applet);
    rmsf.input(hpfFiltered);
    rmsd = new Amplitude(applet);
    rmsd.input(dterm);
    mute();
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
    if(valFiltered.length==1){return "Logging paused, no data!";}
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
  float[] lpf(float[]array,float factor){
  factor = max(1,factor);
  float val = array[0];
  float[] ret = new float[array.length];
  System.arraycopy(array,0,ret,0,array.length-1);
  for(int i = 0; i<array.length;i++){
    float currentValue = ret[i];
    val +=((currentValue - val))/factor;
    ret[i] = val;
  }
  return ret;
}
float[] hpf(float[]array,float factor){
  factor = max(1,factor);
  float val = array[0];
  float[] ret = new float[array.length];
  float[] lpf = lpf(array,factor);
  System.arraycopy(array,0,ret,0,array.length-1);
  for(int i = 0; i< array.length; i++){
    ret[i]-=lpf[i];
  }
  return ret;
}
double[][] float2double(float[]in){
  double[][]ret = new double[1][(int)(float(in.length)*(sampleRateExport/rate))];
  float maxval=0;
  for(int i = 0; i< in.length; i++){
    maxval=max(abs(in[i]),maxval);
  }
  for(int i = 0; i< ret[0].length; i++){
    ret[0][i] = map(in[constrain((int)(float(i)*(rate/sampleRateExport)),0,in.length-1)],-maxval,maxval,-1,1);
  }
  return ret;
}
void saveAudio(String path){ 
  String fullpath=path+"/"+name;
  new File(fullpath).mkdir();
  
  try{
        long numFrames = (long)(valUnfiltered.length*(sampleRateExport/rate));
    WavFile wavFile = WavFile.newWavFile(new File(fullpath+"/filtered.wav"),1,numFrames,32,sampleRateExport);

    long frameCounter = 0; 
    
     double[][] buffer = float2double(valFiltered);


            // Write the buffer
            wavFile.writeFrames(buffer, (int)numFrames);
         

         // Close the wavFile
         wavFile.close();
  }catch(Exception e){e.printStackTrace();}
  
  try{
        long numFrames = (long)(valUnfiltered.length*(sampleRateExport/rate));
    WavFile wavFile = WavFile.newWavFile(new File(fullpath+"/unfiltered.wav"),1,numFrames,32,sampleRateExport);

    long frameCounter = 0; 
    
     double[][] buffer = float2double(valUnfiltered);


            // Write the buffer
            wavFile.writeFrames(buffer, (int)numFrames);
         

         // Close the wavFile
         wavFile.close();
  }catch(Exception e){e.printStackTrace();}
  if(!name.equals("yaw")){
  try{
        long numFrames = (long)(valUnfiltered.length*(sampleRateExport/rate));
    WavFile wavFile = WavFile.newWavFile(new File(fullpath+"/dterm.wav"),1,numFrames,32,sampleRateExport);

    long frameCounter = 0; 
    
     double[][] buffer = float2double(dtermval);


            // Write the buffer
            wavFile.writeFrames(buffer, (int)numFrames);
         

         // Close the wavFile
         wavFile.close();
    }catch(Exception e){e.printStackTrace();}
  }}
  float[] getFrame(int buflength){
    float[]ret = new float[buflength];
    for(int i = 0; i< buflength;i++){
      if(active){
        if(gyroactive){
          if(filterActive){
          ret[i]=valFiltered[(int)min(i+(getPosition()*rate),valFiltered.length-1)];
        }else{      
          ret[i]=valUnfiltered[(int)min(i+(getPosition()*rate),valUnfiltered.length-1)];
        }
      }else{
        
        ret[i]=dtermval[(int)min(i+(getPosition()*rate),dtermval.length-1)];
      }
      }else{ret[i]=0;}
    }
  
  return ret;
  }
}



/*
filtered.
    unfiltered.
    hpfFiltered.
    hpfUnfiltered.
    */
