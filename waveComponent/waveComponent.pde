int waveSize = 100;
int d = 0; //starting diameter
int speed = 25; //spped of expansion
float cx = random(width);
float cy = random(height);

void setup(){
    size(500,500);
    smooth();
    
    background(255);    
    frameRate(60);
}

void draw(){
    background(255);
    stroke(0);
    fill(0,0,0,0);

    drawWave(cx, cy, d);
    d += speed;  //speed of expansion
    if(d > width*2){
      d = 0;
      cx = random(width);
      cy = random(height);
    }
}

void drawWave(float cx, float cy, int diameter){
    ellipse(cx,cy,diameter,diameter);
    
    float factor = 355/waveSize;
    //inner piece
    for(int i = 0; i < waveSize; i++){
      float inner = diameter - i;
      
      stroke(factor*i);
      ellipse(cx,cy,inner,inner);
    }
    //outer piece
    for(int i = 0; i < waveSize; i++){
     float outer = diameter + i;
     
     stroke(factor*i);
     ellipse(cx,cy,outer,outer);
    }
}