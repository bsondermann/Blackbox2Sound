class Spectrum{
  FFT fft;
  float scl=5;
  int sampleSize,wid,posx,posy;
  int speclength=200;
  LinkedList<float[]>spectrum = new LinkedList<float[]>();
  Spectrum(int sampleSize, int w, int px,int py){
    fft = new FFT(sampleSize,rate);
    this.sampleSize=sampleSize;
    wid=w;
    posx=px;
    posy=py;
  }
  void show(){
    stroke(200);
    fill(0);
    rect(posx,posy,speclength*wid+6,(sampleSize/2)*wid+6);
    rectMode(CORNER);
  colorMode(HSB);
  for(int i = 0;i<spectrum.size(); i++){
    for(int j = 0; j<spectrum.get(i).length;j++){
      noStroke();
      fill(map(spectrum.get(i)[j],0,scl,200,0),255,map(constrain(spectrum.get(i)[j],0,scl),0,scl/2,0,255));
      rect(posx+(-i+speclength)*wid,(spectrum.get(i).length-j)*wid+posy,wid,wid);
    }
  }
  colorMode(RGB);
  fill(0);
  textAlign(LEFT,CENTER);
  for(int i = 0; i<=10;i++){
      text(int(i*rate/20)+" Hz",posx+(speclength)*wid+20,map(i,0,10,(sampleSize/2)*wid+posy,posy));
    }
  }
  void setScale(float scale){scl=scale;}
  void update(float[]data){
    fft.forward(data);
    float[]spec=new float[sampleSize/2];
    arrayCopy(fft.getSpectrum(),0,spec,0,sampleSize/2);
    spectrum.push(spec);
    if(spectrum.size()>speclength){spectrum.removeLast();}
  }

}
