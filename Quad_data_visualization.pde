import processing.serial.*;

Serial myPort;

//final String serialPort = "/dev/cu.usbmodem1411";
//final String serialPort = "/dev/cu.usbserial-A901J2ZB";
final String serialPort = "/dev/ttyUSB1";

final int VIEW_SIZE_X = 1000;
final int VIEW_SIZE_Y = 1000;
int x = 0;

String[] accel = {
    "0.0", "0.0", "0.0"
};

float[] accelVals = new float[3];
float[] minVals = {
    0f, 0f, 0f, 200f
};
float[] maxVals = {
    0f, 0f, 0f, 0f
};
float[] lastAccel = {
    0f, 0f, 0f
};
float[] oldVals = {
    0f, 0f, 0f
};

final int lineLength = 4;

float rotate = .5;

void setup() {
    size(VIEW_SIZE_X, VIEW_SIZE_Y);
    myPort = new Serial(this, serialPort, 9600);
    delay(100);
    myPort.clear();
    myPort.bufferUntil('n');
    background(0);
}

void draw() {
    //background(0);
    //translate(width/2, height/2, -100);
    //rotateX(accelVals[0]*PI); 
    //rotateY(accelVals[1]*PI); 
    //rotateZ(accelVals[2]*PI);
    //stroke(255);
    //noFill();
    //box(200);
}

void serialEvent(Serial p) {
    if (p.available() > 2) {
        String[] temp = p.readString().split(",");
        if (temp.length == 3) {
            temp[2] = temp[2].substring(0, temp[2].length()-1);
            accel = temp;
            //accelVals[0] = float(accel[0])/16384.0;
            //accelVals[1] = float(accel[1])/16384.0;
            //accelVals[2] = float(accel[2])/16384.0;
            accelVals[0] = float(accel[0]);
            accelVals[1] = float(accel[1]);
            accelVals[2] = float(accel[2]);
            //drawText();
            plotSphere();
            //lineGraph();
            //pointGraph();
            //translate(0,0,-200);
        }
    }
}

void plotSphere() {
    stroke(oldVals[2], 255-oldVals[2], 0);
    point(oldVals[0], oldVals[1]);
    stroke(255, 255, 255);
    point(width/2, height/2);
    float x = (accelVals[0]*width)/512 + width/2;
    float y = (accelVals[1]*height)/512 + height/2;
    float z = accelVals[2]/2 + .5;
    z*=255;
    stroke(0, 0, 255);
    point(x, y);
    oldVals[0] = x;
    oldVals[1] = y;
    oldVals[2] = z;
}

void lineGraph() {
    stroke(255, 0, 0);
    line(x, (accelVals[0]*height)/4 + height/2, x-lineLength, lastAccel[0]);
    stroke(0, 255, 0);
    line(x, (accelVals[1]*height)/4 + height/2, x-lineLength, lastAccel[1]);
    stroke(0, 0, 255);
    line(x, (accelVals[2]*height)/4 + height/2, x-lineLength, lastAccel[2]);

    lastAccel[0] = (accelVals[0]*height)/4 + height/2;
    lastAccel[1] = (accelVals[1]*height)/4 + height/2;
    lastAccel[2] = (accelVals[2]*height)/4 + height/2;
    if (x>=width) {
        x = 0;
        background(0);
    }
    x+=lineLength;
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

void drawText() {
    float length = sqrt(accelVals[0]*accelVals[0]+accelVals[1]*accelVals[1]+accelVals[2]*accelVals[2]);
    if (length > maxVals[3])
        maxVals[3] = length;
    else if (length < minVals[3])
        minVals[3] = length;    
    for (int i = 0; i < 3; i++) {
        if (accelVals[i] > maxVals[i])
            maxVals[i] = accelVals[i];
        else if (accelVals[i] < minVals[i])
            minVals[i] = accelVals[i];
    }


    background(0);

    textSize(48);
    textAlign(LEFT, TOP);
    text("X: " + accel[0], 20.0, 20.0);
    text("Y: " + accel[1], 20.0, 70.0);
    text("Z: " + accel[2], 20.0, 120.0);
    text("X MIN: " + minVals[0], 20.0, 170.0);
    text("Y MIN: " + minVals[1], 20.0, 220.0);
    text("Z MIN: " + minVals[2], 20.0, 270.0);
    text("Length MIN: " + minVals[3], 20.0, 320.0);
    text("X MAX: " + maxVals[0], 20.0, 370.0);
    text("Y MAX: " + maxVals[1], 20.0, 420.0);
    text("Z MAX: " + maxVals[2], 20.0, 470.0);
    text("Length MAX: " + maxVals[3], 20.0, 520.0);
    text("Length: " + length, 20.0, 570.0);
}

