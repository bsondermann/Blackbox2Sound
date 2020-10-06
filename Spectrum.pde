class Spectrum{
  FFT fft;
  int bands = 2048;
  float smoothingFactor=1;
  float[] sum = new float[bands];
  int scale = 200;
float barWidth=1;
  Spectrum(PApplet applet, AudioSample sample){
    fft = new FFT(applet,bands);
    fft.input(sample);
  }  
  void show(){
    fill(255);
    stroke(0);
  rectMode(CORNER);
  // Perform the analysis
  fft.analyze();

  for (int i = 0; i < bands; i++) {
    // Smooth the FFT spectrum data by smoothing factor
    sum[i] += (fft.spectrum[i] - sum[i]) * smoothingFactor;

    // Draw the rectangles, adjust their height using the scale factor
    float h = constrain(pow(sum[i],1.0/3),0,1)*scale;
    if(100+i*barWidth<width-100){
    rect(100+i*barWidth, height-80, barWidth, -h);
  }}
  }
  void setSample(AudioSample sample){
    fft.input(sample);
  }
}
