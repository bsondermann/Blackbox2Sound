import processing.sound.*;
import drop.*;
import java.nio.file.Files;
import java.io.InputStreamReader;
import java.util.LinkedList;
import javax.sound.sampled.*;
import java.io.*;
import java.nio.ByteBuffer;
SoundManager sound;
SDrop drop;
File[] logs;
GuiController gc;
PImage istop,iplay;
int sel=0;
float vol=0.2;
float dur;
String filename="NO FILE LOADED!";
float rate;
LogSelector ls;
void setup() {
  size(1280, 720);
  sound = new SoundManager(this);
  drop = new SDrop(this);
  istop=loadImage(sketchPath()+"/assets/stop.png");
  iplay=loadImage(sketchPath()+"/assets/play.png");
  background(50);
  clearTemp();
  ls=new LogSelector(20,20);
  gc=new GuiController();
}      

void draw() {
  
  
  rectMode(CENTER);
  background(50);
  if(!filename.equals("NO FILE LOADED!")&&!filename.equals("LOADING FILE...")){
  if(sel!=0){
    if(sel==1){
      sound.jump(map(constrain(mouseX,50,width-50),50,width-50,0,sound.getDuration()));
    }
  }
  ls.show();
  rectMode(CENTER);
  noStroke();
  fill(100);
  rect(20,height-20,25,25);
  stroke(0);
  noStroke();
  fill(255);
  imageMode(CENTER);
  if(sound.getPlaying()){
    image(istop,20,height-20,20,20);
  }else{
    image(iplay,20,height-20,20,20);
  }
  fill(255,0,0);
  
  
  fill(0);
  textSize(15);
  textAlign(CENTER,CENTER);
  
  text("Vol: "+String.format("%.1f",vol),width-30,15);
  text("R | P | Y",width-85,35);
  fill(100);
  rect(width/2,height-65,200,30);
  fill(0);
  text(sound.getTimeCode(),width/2,height-67);
  sound.show();
  if(sound.getPlaying()){
    if(sound.getPosition()+0.1>sound.getDuration()){
      sound.cue(0);
    }
  }
  gc.show();

  }
  
  rectMode(CENTER);
  
  fill(100);
  stroke(0);
  textSize(30);
  rect(width/2,75,max(400,textWidth(filename)+20),50);
  textAlign(CENTER,CENTER);
  fill(0);
  
  text(filename,width/2,70);
  
}
void mousePressed(){
  gc.clicked(mouseX,mouseY);
  float pos=sound.getDuration();
  
  if(mouseX>map(sound.getPosition(),0,pos,50,width-50)-5&&mouseX<map(sound.getPosition(),0,pos,50,width-50)+5&&mouseY>height-35&&mouseY<height-5){
    sel=1;
    sound.pause();
  }
  if(mouseX>10&&mouseX<30&&mouseY>height-30&&mouseY<height-10){
    
    if(sound.getPlaying()){
      sound.pause();
    }else{
      sound.resume();  
    }
    sound.applyVolumes();
  }

  if(ls.click(mouseX,mouseY)){
    sound.pause();
        sound.loadLog(logs[ls.getCurrentLog()]);
        filename=logs[ls.getCurrentLog()].getName().substring(0,logs[0].getName().length()-7)+" LOADED!";
      }
}

void mouseReleased(){
  if(sel==1){sound.applyVolumes();}
  sel=0;
  gc.released();
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
        ls.setNumlogs(logs.length);
        sound.loadLog(logs[ls.getCurrentLog()]);
        filename=logs[ls.getCurrentLog()].getName().substring(0,logs[0].getName().length()-7)+" LOADED!";
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
