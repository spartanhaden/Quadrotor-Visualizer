import processing.serial.*;

Serial myPort;

final boolean HEARTBEATS_ENABLED = false;
final int VIEW_SIZE_X = 1200;
final int VIEW_SIZE_Y = 700;
final int LINE_LENGTH = 2;
final int HZ_UPDATE_MILLIS = 500;
final int VISUALIZER = 2;
// 0 = cube, 1 = angle, 2 = line graph
int x = 0;
int packets = 0;
long time;
float hz = 0;

float[] accel = new float[3];
float[] lastAccel = {
    0f, 0f, 0f
};

void setup() {
    colorMode(RGB, 1);
    textFont(loadFont("Menlo-Regular-25.vlw"));
    if (VISUALIZER == 0)
        size(VIEW_SIZE_X, VIEW_SIZE_Y, P3D);
    else
        size(VIEW_SIZE_X, VIEW_SIZE_Y);
    myPort = new Serial(this, Serial.list()[Serial.list().length - 1], 57600);
    delay(100);
    myPort.clear();
    myPort.bufferUntil('\n');
    background(0);
    //noLoop();
}

void draw() {
    dataRate();
    if (VISUALIZER == 0) {
        cube();
    } else if (VISUALIZER == 1)
        angle();
    else if (VISUALIZER == 2)
        lineGraph();
}

void serialEvent(Serial p) {
    if (p.available() > 2) {
        String[] accelRaw = p.readString().split(",");
        if (accelRaw.length == 3) {
            accelRaw[2] = accelRaw[2].substring(0, accelRaw[2].length() - 1);
            accel[0] = float(accelRaw[0]) / 180.0;
            accel[1] = float(accelRaw[1]) / 180.0;
            accel[2] = float(accelRaw[2]) / 180.0;
            packets++;
            long newTime = millis();
            if (newTime - time > HZ_UPDATE_MILLIS){
                hz = packets / ((newTime - time) / 1000.0);
                time = newTime;
                packets = 0;
            }
            if (HEARTBEATS_ENABLED)
                p.write('a');
        }
    }
}

void dataRate() {
    noStroke();
    textSize(25);
    textAlign(LEFT, TOP);
    if (VISUALIZER == 0)
        background(0);
    else if (VISUALIZER == 1)
        background(0);
    else if (VISUALIZER == 2) {
        fill(0, 0, 0);
        rect(0, 0, 375, 150);
    }
    fill(0.5, 0.25, 0.25);
    rect(10, 10, 200, 25);
    fill(0.25, 0.5, 0.25);
    rect(10, 45, 200, 25);
    fill(0.25, 0.25, 0.5);
    rect(10, 80, 200, 25);

    fill(1, 0, 0);
    rect(10, 10, 100 + (100 * accel[0]), 25);
    fill(0, 1, 0);
    rect(10, 45, 100 + (100 * accel[1]), 25);
    fill(0, 0, 1);
    rect(10, 80, 100 + (100 * accel[2]), 25);

    fill(1, 0, 0);
    text("X " + nfs(accel[0], 1, 3), 225, 13);
    fill(0, 1, 0);
    text("Y " + nfs(accel[1], 1, 3), 225, 48);
    fill(0, 0, 1);
    text("Z " + nfs(accel[2], 1, 3), 225, 83);
    fill(1, 1, 1);
    text(nf(hz, 3, 1) + " Hz", 225, 115);
}

void cube() {
    pushMatrix();
    translate(width / 2, height / 2, -30);
    rotateX(accel[0] * PI);
    rotateY(accel[1] * PI);
    rotateZ(accel[2] * PI);

    scale(150);
    beginShape(QUADS);

    fill(0, 1, 1); 
    vertex(-1, 1, 1);
    fill(1, 1, 1); 
    vertex( 1, 1, 1);
    fill(1, 0, 1); 
    vertex( 1, -1, 1);
    fill(0, 0, 1); 
    vertex(-1, -1, 1);

    fill(1, 1, 1); 
    vertex( 1, 1, 1);
    fill(1, 1, 0); 
    vertex( 1, 1, -1);
    fill(1, 0, 0); 
    vertex( 1, -1, -1);
    fill(1, 0, 1); 
    vertex( 1, -1, 1);

    fill(1, 1, 0); 
    vertex( 1, 1, -1);
    fill(0, 1, 0); 
    vertex(-1, 1, -1);
    fill(0, 0, 0); 
    vertex(-1, -1, -1);
    fill(1, 0, 0); 
    vertex( 1, -1, -1);

    fill(0, 1, 0); 
    vertex(-1, 1, -1);
    fill(0, 1, 1); 
    vertex(-1, 1, 1);
    fill(0, 0, 1); 
    vertex(-1, -1, 1);
    fill(0, 0, 0); 
    vertex(-1, -1, -1);

    fill(0, 1, 0); 
    vertex(-1, 1, -1);
    fill(1, 1, 0); 
    vertex( 1, 1, -1);
    fill(1, 1, 1); 
    vertex( 1, 1, 1);
    fill(0, 1, 1); 
    vertex(-1, 1, 1);

    fill(0, 0, 0); 
    vertex(-1, -1, -1);
    fill(1, 0, 0); 
    vertex( 1, -1, -1);
    fill(1, 0, 1); 
    vertex( 1, -1, 1);
    fill(0, 0, 1); 
    vertex(-1, -1, 1);

    endShape();

    popMatrix();
}

void angle() {
    strokeWeight(5);

    stroke(1, 0, 0);
    line(width / 2, height / 2, (width / 2) + sin(accel[0] * PI) * 200, (height / 2) + cos(accel[0] * PI) * 200);

    stroke(0, 1, 0);
    line(width / 2, height / 2, (width / 2) + sin(accel[1] * PI) * 200, (height / 2) + cos(accel[1] * PI) * 200);

    stroke(0, 0, 1);
    line(width / 2, height / 2, (width / 2) + sin(accel[2] * PI) * 200, (height / 2) + cos(accel[2] * PI) * 200);
}

void lineGraph() {
    stroke(1, 0, 0);
    line(x, (accel[0] * height / 2) + height / 2, x - LINE_LENGTH, lastAccel[0]);
    stroke(0, 1, 0);
    line(x, (accel[1] * height / 2) + height / 2, x - LINE_LENGTH, lastAccel[1]);
    stroke(0, 0, 1);
    line(x, (accel[2] * height / 2) + height / 2, x - LINE_LENGTH, lastAccel[2]);

    lastAccel[0] = (accel[0] * height / 2) + height / 2;
    lastAccel[1] = (accel[1] * height / 2) + height / 2;
    lastAccel[2] = (accel[2] * height / 2) + height / 2;
    if (x >= width) {
        x = 0;
        background(0);
    }
    x += LINE_LENGTH;
}

