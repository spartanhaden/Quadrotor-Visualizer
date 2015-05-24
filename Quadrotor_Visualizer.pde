import processing.serial.*;

Serial myPort;

final boolean HEARTBEATS_ENABLED = false;

final int VIEW_SIZE_X = 1200;
final int VIEW_SIZE_Y = 700;
final int LINE_LENGTH = 2;
int x = 0;

String[] accel = { 
    "0.0", "0.0", "0.0"
};

float[] accelVals = new float[3];
float[] lastAccel = {
    0f, 0f, 0f
};

float rotate = .5;

void setup() {
    size(VIEW_SIZE_X, VIEW_SIZE_Y);
    //size(VIEW_SIZE_X, VIEW_SIZE_Y,P3D);
    myPort = new Serial(this, Serial.list()[Serial.list().length - 1], 57600);
    delay(100);
    myPort.clear();
    myPort.bufferUntil('\n');
    background(0);
    noLoop();
}

void draw() {}

void box() {
    background(0);
    translate(width/2, height/2, -100);
    rotateX(accelVals[0]*PI);
    rotateY(accelVals[1]*PI);
    rotateZ(accelVals[2]*PI);
    stroke(255);
    noFill();
    box(200);
}

void serialEvent(Serial p) {
    if (p.available() > 2) {
        String[] temp = p.readString().split(",");
        if (temp.length == 3) {
            temp[2] = temp[2].substring(0, temp[2].length()-1);
            accel = temp;
            accelVals[0] = float(accel[0]) / 180.0;
            accelVals[1] = float(accel[1]) / 180.0;
            accelVals[2] = float(accel[2]) / 180.0;
            angle();
            //plotSphere();
            //lineGraph();
            //pointGraph();
            redraw();
            if(HEARTBEATS_ENABLED)
                p.write('a');
        }
    }
}

void angle() {
    textSize(25);
    textAlign(LEFT, TOP);
    background(0);
    stroke(0, 0, 0);
    fill(0, 0, 0);
    rect(25, 25, 225, 25);
    rect(25, 75, 225, 25);
    rect(25, 125, 225, 25);
    strokeWeight(5);

    stroke(255, 0, 0);
    fill(255, 0, 0);
    line(width / 2, height / 2, (width / 2) + sin(accelVals[0]*PI) * 200, (height / 2) + cos(accelVals[0]*PI) * 200);
    rect(25, 25, 100 + (100 * accelVals[0]), 25);
    text("X    " + accelVals[0], 250, 25);

    stroke(0, 255, 0);
    fill(0, 255, 0);
    line(width / 2, height / 2, (width / 2) + sin(accelVals[1]*PI) * 200, (height / 2) + cos(accelVals[1]*PI) * 200);
    rect(25, 75, 100 + (100 * accelVals[1]), 25);
    text("Y    " + accelVals[1], 250, 75);

    stroke(0, 0, 255);
    fill(0, 0, 255);
    line(width / 2, height / 2, (width / 2) + sin(accelVals[2]*PI) * 200, (height / 2) + cos(accelVals[2]*PI) * 200);
    rect(25, 125, 100 + (100 * accelVals[2]), 25);
    text("Z    " + accelVals[2], 250, 125);
    text("FPS    " + frameRate, 250, 175);
}

void lineGraph() {
    stroke(255, 0, 0);
    line(x, (accelVals[0]*height/2) + height/2, x-LINE_LENGTH, lastAccel[0]);
    stroke(0, 255, 0);
    line(x, (accelVals[1]*height/2) + height/2, x-LINE_LENGTH, lastAccel[1]);
    stroke(0, 0, 255);
    line(x, (accelVals[2]*height/2) + height/2, x-LINE_LENGTH, lastAccel[2]);

    lastAccel[0] = (accelVals[0]*height/2) + height/2;
    lastAccel[1] = (accelVals[1]*height/2) + height/2;
    lastAccel[2] = (accelVals[2]*height/2) + height/2;
    if (x>=width) {
        x = 0;
        background(0);
    }
    x+=LINE_LENGTH;
}

void pointGraph() {
    stroke(255, 0, 0);
    point(x, (accelVals[0]*height)/2 + height/2);
    stroke(0, 255, 0);
    point(x, (accelVals[1]*height)/2 + height/2);
    stroke(0, 0, 255);
    point(x, (accelVals[2]*height)/2 + height/2);
    if (x>=width) {
        x = 0;
        background(0);
    }
    x++;
}

