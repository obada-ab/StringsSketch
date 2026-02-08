import algorithms.noise.*;
import java.util.ArrayList;

OpenSimplexNoiseKS generatorX;
OpenSimplexNoiseKS generatorY;
float rez = 240;

float theta;
float mainTheta;
float sf = 0.0052f;
float tf = 0.73f;
int loopFrames = 300;
float maxOffset = 50;

int nLines = 10;
float startX, startY, endX, endY;

float noiseThresh = 0.3;
float noiseMag = 90;

float xMul = 1.3;

boolean recording = true;

ArrayList<WavyLine> wavyLines = new ArrayList<WavyLine>();

class WavyLine {
  int id;
  color c;
  
  WavyLine(int id, color c) {
    this.id = id;
    this.c = c;
  }

  public void draw() {
    float initialX = -100, initialY = -100;
    PShape group;
    group = createShape(GROUP);
    PShape red = createShape();
    PShape green = createShape();
    PShape blue = createShape();
    red.beginShape();
    green.beginShape();
    blue.beginShape();
    red.stroke(255, 0, 0);
    green.stroke(0, 255, 0);
    blue.stroke(0, 0, 255);
    for (int i = 0; i < rez; i++) {
      theta = map(i, 0, rez, 0, TWO_PI);
  
      float x = (float)(generatorX.eval(this.id * 1000 + tf * sin(theta), tf * cos(theta), tf * sin(mainTheta), tf * cos(mainTheta)));
      if (initialX < -5) {
        initialX = x;
      }
      x -= initialX;
      x = map(x, -2, 2, startX - width * 0.5, startX + width * 0.5);
  
      float xOffset = endX - x;
      float xOffsetPercent = pow(2 * map(float(i), 0.0, rez - 1.0, 0.0, 1.0) - 1, 2.0);
  
      xOffset *= xOffsetPercent;
      x += xOffset;
      x = width / 2 + (x - width / 2) * xMul;
  
      float y = map(i, 0, rez - 1, startY, endY);

      float xNoise = (float)(generatorX.eval(this.id * -1000 + tf * sin(theta), tf * cos(theta), tf * sin(mainTheta), tf * cos(mainTheta)));
      if (xNoise >= noiseThresh) {
        xNoise = map(xNoise, noiseThresh, 1, 0, 1);
        xNoise *= noiseMag;
      } else {
        xNoise = 0;
      }
      float param = abs(x - width / 2.0) / (width / 2.0);
      float distPercent = (1 - pow(2 * param - 1, 2.0));
      xNoise *= distPercent;
      
      red.curveVertex(x + xNoise / 2,  y);
      green.curveVertex(x,  y);
      blue.curveVertex(x + xNoise,  y);
    }
    red.endShape();
    green.endShape();
    blue.endShape();
    group.addChild(red);
    group.addChild(green);
    group.addChild(blue);
    shape(group, 0, 0);
  }
}

public void setup() {
  size(1080, 1920, P2D);
  frameRate(60);
  generatorX = new OpenSimplexNoiseKS(426);
  generatorY = new OpenSimplexNoiseKS(42669);
  strokeWeight(7);
  noFill();
  blendMode(ADD);

  startX = width / 2;
  startY = 0;
  endX = width / 2;
  endY = height;

  for (int i = 0; i < nLines; i++) {
    wavyLines.add(new WavyLine(i + 1, 255));
  }
}

public void draw() {
  background(0);
  int frame = (frameCount - 1) % loopFrames;

  mainTheta = map(frame, 0, loopFrames, 0, TWO_PI);

  for (int j = 0; j < nLines; j++) {
    wavyLines.get(j).draw();
  }

  
  if (recording) {
    saveFrame("output/frame-####.png");
    if (frameCount == loopFrames) {
        noLoop();
    }
  }
}
