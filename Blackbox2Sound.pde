import processing.sound.*;
import drop.*;
import java.nio.file.Files;
import java.io.InputStreamReader;
import java.util.LinkedList;
AudioSample samplef,sampleu;
SDrop drop;
File[] logs;
RamTable table;
boolean filtered=true;
PImage istop,iplay;
int sel=0;
boolean playing=false;
int dt=0;
float time;
float vol=1;
float dur;
String text="NO FILE LOADED!";
float rate;
void setup() {
  size(640, 360);
  
  drop = new SDrop(this);
  istop=loadImage(sketchPath()+"/assets/stop.png");
  iplay=loadImage(sketchPath()+"/assets/play.png");
  
  background(50);
  clearTemp();
  // Create an array and manually write a single sine wave oscillation into it.
  dt=millis();
}      

void draw() {
  float pos =1;
  if(samplef!=null){
    pos=samplef.duration();
  }
  background(50);
  if(sel!=0){
    if(sel==1){
      time = map(constrain(mouseX,50,width-50),50,width-50,0,pos);
      if(samplef!=null){
        samplef.jump(time);
        sampleu.jump(time);
        playing = true;
      }
    }else if(sel==2){
      vol = map(constrain(mouseY,50,height-50),50,height-50,1,0);
      if(samplef!=null){
      if(filtered){
      samplef.amp(vol);
      sampleu.amp(0);
    }else{
      sampleu.amp(vol);
      samplef.amp(0);
    }
      }
    }
  }
  noStroke();
  rectMode(CENTER);
  fill(100);
  rect(20,height-20,25,25);
  stroke(0);
  if(filtered){
  fill(255,0,0);
  }else{
    fill(100);
  }
  rect(20,150,15,15);
  noStroke();
  fill(255);
  imageMode(CENTER);
  if(playing){
    image(istop,20,height-20,20,20);
  }else{
    image(iplay,20,height-20,20,20);
  }
  rect(width/2,height-20,width-100,10);
  rect(width-20,height/2,10,height-100);
  fill(255,0,0);
  
  rect(map(time,0,pos,50,width-50),height-20,10,30);
  rect(width-20,map(vol,0,1,height-50,50),30,10);
  fill(100);
  stroke(0);
  rect(width/2,75,400,50);
  textAlign(CENTER,CENTER);
  fill(0);
  textSize(30);
  text(text,width/2,70);
  textSize(15);
  text("Vol: "+String.format("%.1f",vol),width-30,20);
  text("filtered / unfiltered",100,147);
  String sec1="0";
  String sec2="00";
  String sec21="0:";
  
  if(samplef!=null){
        if(int(samplef.duration())%60<10){sec2="0"+int(samplef.duration())%60;}else{sec2=int(samplef.duration())%60+"";}
        sec21=int(samplef.duration())/60+":";
  }
  
  if(time%60<10){sec1="0"+int(time)%60;}else{sec1=int(time)%60+"";}
  text(int(time)/60+":"+sec1+"    |    "+sec21+sec2,width/2,height-60);
  if(playing){
    time+=(float(millis())-dt)/1000;
    dt=millis();
    if(time>samplef.duration()){
      playing=false;
      samplef.amp(0);
      sampleu.amp(0);
      
      time=0;
    }
  }
}
void mousePressed(){
  float pos =1;
  if(samplef!=null){
    pos=samplef.duration();
  }
  if(mouseX>map(time,0,pos,50,width-50)-5&&mouseX<map(time,0,pos,50,width-50)+5&&mouseY>height-35&&mouseY<height-5){
    sel=1;
    if(samplef!=null){
      playing=false;
      samplef.pause();
      sampleu.pause();
    }
  }
  if(mouseX>width-35&&mouseX<width-5&&mouseY>map(vol,0,1,height-50,50)-5&&mouseY<map(vol,0,1,height-50,50)+5){sel=2;}
  if(mouseX>10&&mouseX<30&&mouseY>height-30&&mouseY<height-10){
    if(samplef!=null){
      if(playing){
        samplef.pause();
        sampleu.pause();
        playing=false;
      }else{
        if(filtered){
      samplef.amp(vol);
      sampleu.amp(0);
    }else{
      sampleu.amp(vol);
      samplef.amp(0);
    }
        samplef.play();
        sampleu.play();
        dt=millis();
        playing=true;
      }
    }
  }
  if(mouseX>12&&mouseX<28&&mouseY>142&&mouseY<158){
    filtered=!filtered;
    if(filtered){
      samplef.amp(vol);
      sampleu.amp(0);
    }else{
      sampleu.amp(vol);
      samplef.amp(0);
    }
  }
}

void mouseReleased(){
  sel=0;
}
void dropEvent(DropEvent e){
  if(e.isFile()){
    File f = e.file();
    if(!f.isDirectory()){
      text="LOADING FILE...";
      createImage(1, 1, RGB).save(sketchPath()+"/temp/0/csv/temp.png");
      new File(sketchPath()+"/temp/0/csv/temp.png").delete();
      ProcessBuilder pb;
      if(System.getProperty("os.name").contains("Mac")){
        pb = new ProcessBuilder(sketchPath()+"/assets/blackbox_decode","--merge-gps",""+f.getAbsolutePath());
      }else{
        pb = new ProcessBuilder(sketchPath()+"/assets/blackbox_decode.exe","--merge-gps",""+f.getAbsolutePath());
      }
      try {
        Process process = pb.start();
        InputStream is = process.getErrorStream();
        BufferedReader reader = new BufferedReader(new InputStreamReader(is));
        String line = reader.readLine();
        while (line !=null) {
        println(line);

        line= reader.readLine();
      }

        logs = getLogs(f);
        table = new RamTable(logs[0].getAbsolutePath());
        dur=Long.parseLong(table.getRow(table.getRowCount()-1).getString(1).trim())-Long.parseLong(table.getRow(1).getString(1).trim());
        rate = Math.round(table.getRowCount()/(dur/1000000)/1000);
  float[] vfiltered = new float[table.getRowCount()-2];
  for (int i = 0; i < vfiltered.length; i++) {
    vfiltered[i] =float(Integer.parseInt(table.getRow(i+1).getString(25).trim())+Integer.parseInt(table.getRow(i+1).getString(26).trim())+Integer.parseInt(table.getRow(i+1).getString(27).trim()))/1000;
  }
  float[] unfiltered = new float[table.getRowCount()-2];
  for (int i = 0; i < unfiltered.length; i++) {
    unfiltered[i] =float(Integer.parseInt(table.getRow(i+1).getString(31).trim())+Integer.parseInt(table.getRow(i+1).getString(32).trim())+Integer.parseInt(table.getRow(i+1).getString(33).trim()))/1000;
  }
  // Create the audiosample based on the data, set framerate to play 200 oscillations/second
  samplef = new AudioSample(this, vfiltered, (int)rate*1000);
  sampleu = new AudioSample(this, unfiltered, (int)rate*1000);

  // Play the sample in a loop (but don't make it too loud)
  if(filtered){
      samplef.amp(vol);
      sampleu.amp(0);
    }else{
      sampleu.amp(vol);
      samplef.amp(0);
    }
  text=logs[0].getName().substring(0,logs[0].getName().length()-7)+" LOADED!";
      }catch(Exception ex) {
        ex.printStackTrace();
      }
    }
  }
}
File[] getLogs(File f){
    File[] files = new File(f.getParent()).listFiles();
    LinkedList<File> files2 = new LinkedList<File>();
    for(int i = 0; i< files.length;i++){
      if(files[i].getAbsolutePath().contains(".csv")&&files[i].getAbsolutePath().contains(f.getName().substring(0,f.getName().length()-4))){

        File del = new File(files[i].getAbsolutePath().substring(0,files[i].getAbsolutePath().length()-4)+".event");
        del.delete();
        del = new File(files[i].getAbsolutePath().substring(0,files[i].getAbsolutePath().length()-4)+".gps.csv");
        del.delete();
        del = new File(files[i].getAbsolutePath().substring(0,files[i].getAbsolutePath().length()-4)+".gps.gpx");
        del.delete();
        files[i].renameTo(new File(sketchPath()+"/temp/0/csv/"+files[i].getName()));
        files[i] = new File(sketchPath()+"/temp/0/csv/"+files[i].getName());
        files2.add(files[i]);
      }
    }
    files = new File[files2.size()];
    for(int i = 0; i< files.length;i++){
      files[i] = files2.get(i);
    }
    return files;
  }
void clearTemp(){
  deleteDir(new File(sketchPath()+"/temp/"));
}
void deleteDir(File file) {
    File[] contents = file.listFiles();
    if (contents != null) {
        for (File f : contents) {
            if (! Files.isSymbolicLink(f.toPath())) {
                deleteDir(f);
            }
        }
    }
    file.delete();
}

void exit(){

  surface.setVisible(false);
  delay(2000);
  clearTemp();
  super.exit();
  
}
