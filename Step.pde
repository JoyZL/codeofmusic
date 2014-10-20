


class Step{
  int x, y, w, h;
  int frequency;
  boolean isOn;
  boolean playheadOn;
  boolean isPlaying;
  boolean isMute;
  //int pitch;
  Step(int _frequency, boolean _isOn, boolean _playheadOn, boolean _isPlaying, boolean _isMute){
    frequency = _frequency;
    isOn = _isOn;
    playheadOn = _playheadOn;
    isPlaying = _isPlaying;
    isMute = _isMute;
  }
  
  void draw(){
    stroke(100);
    strokeWeight(2);
    if(playheadOn){
      fill(255);
    }
    if(isOn){
      fill(0, 255, 255);      
    }
    else if(isMute){
     fill(155);
    } 
    else{
      fill(50);      
    }
    
    //rect(x, y, w, h);
   ellipseMode(CORNER); 
   ellipse(x,y,w-4,h-4);
    
  }
  
  void triggerSnare(){
    snare.trigger();
  }
  
  void triggerKick(){
    kick.trigger();
  }
}
