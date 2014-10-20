class Mute{
  int x, y, w, h;
  boolean isCheck;

  Mute(boolean _isCheck){
    
    isCheck = _isCheck;
  
  }
  
  void draw(){
    
    if(isCheck){
      fill(255);      
    } 
    else{
      fill(155);      
    }
    //rect(x, y, w, h); 
    stroke(100);
    strokeWeight(2);
    ellipseMode(CORNER);
    ellipse(x, y, w-4, h-4);  
    
  }
  
}
