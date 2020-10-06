import processing.sound.*;
import drop.*;
import java.nio.file.Files;
import java.io.InputStreamReader;
import java.util.LinkedList;
SoundManager sound;
SDrop drop;
File[] logs;
PImage istop,iplay;
int sel=0;
int dt=0;
float time;
float vol=0.2;
float dur;
String filename="NO FILE LOADED!";
float rate;
void setup() {
  size(640, 360);
  sound = new SoundManager(this);
  drop = new SDrop(this);
  istop=loadImage(sketchPath()+"/assets/stop.png");
  iplay=loadImage(sketchPath()+"/assets/play.png");
  time=millis();
  background(50);
  clearTemp();
  // Create an array and manually write a single sine wave oscillation into it.
  dt=millis();
}      

void draw() {
  
  
  rectMode(CENTER);
  background(50);
  if(!filename.equals("NO FILE LOADED!")&&!filename.equals("LOADING FILE...")){
    float pos=sound.getDuration();
  if(sel!=0){
    if(sel==1){
      time = map(constrain(mouseX,50,width-50),50,width-50,0,pos);
      sound.jump(time);
    }else if(sel==2){
      vol = map(constrain(mouseY,50,height-50),50,height-50,1,0);
      sound.applyVolumes();
    }
  }
  noStroke();
  fill(100);
  rect(20,height-20,25,25);
  stroke(0);
  
  fill(100);
  rect(70,150,30,15);
  //FILTER CHECK BOX
  fill(255,0,0);
  if(sound.getFilterActive()){
    rect(62.5,150,15,15);
  }else{
    rect(77.5,150,15,15);
  }
  //ROLL CHECK BOX
  if(sound.getActive("ROLL")){fill(255,0,0);}else{fill(100);}
  rect(20,200,15,15);
  if(sound.getActive("PITCH")){fill(255,0,0);}else{fill(100);}
  rect(70,200,15,15);
  if(sound.getActive("YAW")){fill(255,0,0);}else{fill(100);}
  rect(120,200,15,15);
  
  noStroke();
  fill(255);
  imageMode(CENTER);
  if(sound.getPlaying()){
    image(istop,20,height-20,20,20);
  }else{
    image(iplay,20,height-20,20,20);
  }
  rect(width/2,height-20,width-100,10);
  rect(width-20,height/2,10,height-100);
  fill(255,0,0);
  
  rect(map(time,0,pos,50,width-50),height-20,10,30);
  rect(width-20,map(vol,0,1,height-50,50),30,10);
  
  fill(0);
  textSize(15);
  text("roll | pitch | yaw",70,220);
  
  text("Vol: "+String.format("%.1f",vol),width-30,20);
  text("   filtered | unfiltered",70,168);
  text(sound.getTimeCode(),width/2,height-60);
  sound.show();
  if(sound.getPlaying()){
    time+=(float(millis())-dt)/1000;
    dt=millis();
    if(time>sound.getDuration()){
      sound.stopSample();
      time=0;
    }
  }}
  
  
  
  fill(100);
  stroke(0);
  rect(width/2,75,400,50);
  textAlign(CENTER,CENTER);
  fill(0);
  textSize(30);
  text(filename,width/2,70);
  
  
}
void mousePressed(){
  float pos=sound.getDuration();
  
  if(mouseX>map(time,0,pos,50,width-50)-5&&mouseX<map(time,0,pos,50,width-50)+5&&mouseY>height-35&&mouseY<height-5){
    sel=1;
    sound.pause();
  }
  if(mouseX>width-35&&mouseX<width-5&&mouseY>map(vol,0,1,height-50,50)-5&&mouseY<map(vol,0,1,height-50,50)+5){sel=2;}
  if(mouseX>10&&mouseX<30&&mouseY>height-30&&mouseY<height-10){
    
    if(sound.getPlaying()){
      sound.pause();
    }else{
      sound.resume();  
    }
  }
  if(mouseX>55&&mouseX<85&&mouseY>142&&mouseY<158){
    sound.toggleFiltered();
  }
  if(mouseX>12&&mouseX<28&&mouseY>192&&mouseY<208){sound.setActive(!sound.getActive("ROLL"),"ROLL");}
  if(mouseX>12+50&&mouseX<28+50&&mouseY>192&&mouseY<208){sound.setActive(!sound.getActive("PITCH"),"PITCH");}
  if(mouseX>12+100&&mouseX<28+100&&mouseY>192&&mouseY<208){sound.setActive(!sound.getActive("YAW"),"YAW");}
}

void mouseReleased(){
  sel=0;
}
void dropEvent(DropEvent e){
  if(e.isFile()){
    File f = e.file();
    if(!f.isDirectory()){
      filename="LOADING FILE...";
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
        sound.loadLog(logs[0]);
        filename=logs[0].getName().substring(0,logs[0].getName().length()-7)+" LOADED!";
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
  try{sound.pause();}catch(Exception e){}
  surface.setVisible(false);
  delay(2000);
  clearTemp();
  super.exit();
  
}
