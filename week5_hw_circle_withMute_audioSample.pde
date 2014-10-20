import beads.*;
import org.jaudiolibs.beads.*;
import ddf.minim.*;
import ddf.minim.ugens.*;

Minim minim;
AudioOutput out;
AudioSample kick;
AudioSample snare;

float beatLength;
int beatWidth;

int x, y, w, h;
PFont f;

int bpm; 
Clock clock;
int beatsPerMeasure;

int currentMeasure;
int currentBeat; 
float howFarInMeasure;
//int value;
int theNote;

AudioContext ac;

Step[][] steps;
Mute[] muteButton;

void setup(){
  beatsPerMeasure = 8;
  
  steps = new Step[beatsPerMeasure][beatsPerMeasure];
  muteButton = new Mute[beatsPerMeasure];
  
  minim = new Minim(this);
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();
  
  //minium audio sample
  // load BD.wav from the data folder
  kick = minim.loadSample( "BD.mp3",  512);
                         
  // if a file doesn't exist, loadSample will return null
  if ( kick == null ) println("Didn't get kick!");
  
  // load SD.wav from the data folder
  snare = minim.loadSample("SD.wav", 512);
  if ( snare == null ) println("Didn't get snare!");
  
  ac = new AudioContext();
  bpm = 120;
  
  beatLength = 60000.0/bpm;
  clock = new Clock(ac, beatLength); 
  clock.setClick(true); 
  clock.addMessageListener(
    new Bead(){
      public void messageReceived(Bead message){
        Clock c = (Clock)message;
        onClock(c);
      }
    }
  );
  ac.out.addDependent(clock);
  ac.start();
  
  //interface
  size(720, 720);
  x = 20;
  y = 20;
  w = width - 120;
  h = height - 120;
  theNote = 0;
  f = createFont("Helvetica", 10);
  textAlign(TOP, LEFT);
  textFont(f);
  beatWidth = floor(w/beatsPerMeasure);
  
  //create matrix
  for(int i=0; i < beatsPerMeasure; i++){    
    for(int j=0; j < beatsPerMeasure; j++){
      steps[i][j] = new Step(900, false, false, false, false);
      steps[i][j].x = beatWidth*i; 
      steps[i][j].y = beatWidth*j; 
      steps[i][j].w = beatWidth; 
      steps[i][j].h = beatWidth;
//     println("w: " + w + "; h: " + h);     
    }  
  } 
 
 //create a mute column
  for(int a=0; a <beatsPerMeasure; a++){
   muteButton[a] = new Mute(false);
   muteButton[a].x = beatWidth*beatsPerMeasure;
   muteButton[a].y = beatWidth*a;
   muteButton[a].w = beatWidth;
   muteButton[a].h = beatWidth;
  } 
}

void draw(){
   background(50);
  
  pushMatrix();
  translate(x, y);
  
  noFill();
  stroke(100);
  //rect(0, 0, w, h);
  
  beatWidth = floor(w/(float)beatsPerMeasure);
  
  //draw grid lines
   for(int col = 0; col < beatsPerMeasure; col++){
    for(int row = 0; row < beatsPerMeasure; row++){
      stroke(100);
      float beatPosX = beatWidth * col;
      float beatPosY = beatWidth * row;
      //line(beatPosX, 0, beatPosX, h);
      //line(0, beatPosY, w, beatPosY);
      
      //now let's label them:
      text(currentMeasure + "." + col, beatPosX, -2);
      text(beatLength*col/1000 + "s", beatPosX, h + 10); 
 
      //highlight current beat       
      if(col == currentBeat){    
        steps[col][row].playheadOn = true;    
        if(steps[col][row].isOn && !steps[col][row].isPlaying){
          steps[col][row].isPlaying = true;
        
           if(!steps[col][row].isMute){
             if(row < 6){
               out.playNote(steps[col][row].frequency);
             }else if(row == 6){
               steps[col][row].triggerSnare();
             }else if(row == 7){
               steps[col][row].triggerKick();
             }
           }//end of if !isMute
        }//end of if isOn && !isPlaying 
      }//end of if currentBeat
      else{
        steps[col][row].playheadOn = false;
        if(steps[col][row].isPlaying){
         steps[col][row].isPlaying = false;         
       }
      }//end of else 
      steps[col][row].draw();
    }//end of row for loop       
  }//end of col for loop   

  //draw mute buttons
  for(int muteRow = 0; muteRow < beatsPerMeasure; muteRow++){
      muteButton[muteRow].draw();
  }
  //draw playhead
    //see how 'howFarInMeasure' (a number between 0 and 1) is calculated in the onClock function below.
    stroke(219, 38, 118);
    float playheadPos = map((float)howFarInMeasure, 0, 1, 0, w);
    line(playheadPos, 0, playheadPos, h); 
  
  popMatrix();
  
}

void onClock(Clock c){
  currentBeat = c.getBeatCount() % beatsPerMeasure;
  currentMeasure = c.getBeatCount() / beatsPerMeasure;
  
  //calculate how many ticks are in a measure
  float ticksPerMeasure = beatsPerMeasure * c.getTicksPerBeat();
  //get a number between 0 and 1 to tell us how far we are
  howFarInMeasure = (c.getCount()%ticksPerMeasure)/ticksPerMeasure;
 
}

//is mouse clicked, save the mouseX and Y value, toggle the button color and on/off
void mouseClicked(){
  
    if(mouseX<beatWidth*beatsPerMeasure){
    int selectButtonX = floor(mouseX/beatWidth);
    int selectButtonY = floor(mouseY/beatWidth);
    steps[selectButtonX][selectButtonY].isOn = !steps[selectButtonX][selectButtonY].isOn;
    steps[selectButtonX][selectButtonY].frequency = floor(900/(selectButtonY+1));
    }
    //if selected a mute button 
    else if(mouseX > beatWidth*beatsPerMeasure + 20 && mouseX < width - 20){
      //find which mute button is checked
      int selectMuteY = floor(mouseY/beatWidth);
      muteButton[selectMuteY].isCheck = !muteButton[selectMuteY].isCheck;
      //mute the entire row 
      for(int s=0; s<beatsPerMeasure; s++){
        steps[s][selectMuteY].isMute = !steps[s][selectMuteY].isMute;
      }
    }
}

void drawHighlight(){
  fill(200);
  noStroke();
  float currentBeat_x = currentBeat * beatWidth;  
  rect(currentBeat_x, 0, beatWidth, h); 
}
