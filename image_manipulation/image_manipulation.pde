PImage madison;
float x, y, a, b, r=1, th;
int numPoint = 100;
int blur = 30;
int time_to_dis = 5; //a time to dissipation
float[][] pointsFromCircle = new float[numPoint][numPoint];
float[][] pointsFromInnerCircle = new float[numPoint][numPoint];
float[][] pointsFromOuterCircle = new float[numPoint][numPoint];
boolean waves = false;

void setup() {
  size(720, 720);
  background(0);
  madison = loadImage("madison.jpg");
  background(0);
  smooth();
  stroke(255, 15);
  noFill();
  frameRate(30);
}

void draw() {
  //reset the background on each run through
  image(madison, -280, 0);
  
  //start a new circle when the old one is done
  if (waves == false) {
    waves = true;
    a = random(width);
    b = random(height);
    r=1;
  }

  //find points on circle and put them in array
  for (int i = 0; i < numPoint; i++) {
    th = th + 360/numPoint;
    pointsFromCircle[i][0] = a + r*cos(th);
    pointsFromCircle[i][1] = b + r*sin(th);
    pointsFromInnerCircle[i][0] = a + (r-blur/1.5)*cos(th);
    pointsFromInnerCircle[i][1] = b + (r-blur/1.5)*sin(th);
    pointsFromOuterCircle[i][0] = a + (r+blur/1.5)*cos(th);
    pointsFromOuterCircle[i][1] = b + (r+blur/1.5)*sin(th);
  }
  //sample and blur points around circle
  for (int i = 0; i < numPoint; i++) {
    // Pick a point on the circle
    int x = int(round(pointsFromCircle[i][0]));
    int y = int(round(pointsFromCircle[i][1]));
    int loc = x + y*madison.width;
    int xInner = int(round(pointsFromInnerCircle[i][0]));
    int yInner = int(round(pointsFromInnerCircle[i][1]));
    int locInner = xInner + yInner*madison.width;
    int xOuter = int(round(pointsFromOuterCircle[i][0]));
    int yOuter = int(round(pointsFromOuterCircle[i][1]));
    int locOuter = xOuter + yOuter*madison.width;

    //skip this point if x or y are out of bounds
    if (x >= width | x <= 0 | y >= height | y <= 0) {
      //check if points are beyond corner boundary
      //if (loc > 3*(width + height*width)) { //too processor intesive to run it all the way to the edge
      if (r > 200) {
        waves = false;
        break;
      } else continue;
    } else ///println("x:"+x + "| y:"+y);

    // Look up the RGB color in the source image
    loadPixels();
    float r = red(madison.pixels[loc]);
    float rPlus = red(madison.pixels[loc]);
    float rMinus = red(madison.pixels[locInner]);
    float g = green(madison.pixels[loc]);
    float gPlus = green(madison.pixels[loc]);
    float gMinus = green(madison.pixels[locInner]);
    float b = blue(madison.pixels[loc]);
    float bPlus = blue(madison.pixels[loc]);
    float bMinus = blue(madison.pixels[locInner]);

    //make sure they are in bounds
    /*if (locInner > 0 && locInner < 921000) {
      rMinus = red(madison.pixels[locInner]);
      gMinus = green(madison.pixels[locInner]);
      bMinus = blue(madison.pixels[locInner]);
    }*/  //can't think of any times when the inner circle will be out of bounds
    if (locOuter < 921000 && locOuter > 0) {
      rPlus = red(madison.pixels[locOuter]);
      gPlus = green(madison.pixels[locOuter]);
      bPlus = blue(madison.pixels[locOuter]);
    }
    noStroke();

    // Draw an ellipse at that location with that color
    fill(r, g, b, 100);
    ellipse(x, y, blur, blur);
    //outer circle
    fill(rPlus, gPlus, bPlus, 50);
    ellipse(xOuter, yOuter, blur, blur);
    //inner circle
    fill(rMinus, gMinus, bMinus, 50);
    ellipse(xInner, yInner, blur, blur);
  }

  r += 10;
  println(frameRate);
}