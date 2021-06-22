//*********************************************
// Example Code for Interactive Intelligent Products
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************

//OBJECTS WITH SUFFIX "S" BELONG TO THE SOUND RECOGNITION CODE
//OBJECTS WITH SUFFIX "P" BELONG TO THE POSTURE RECOGNITION CODE

//AUDIO CODE BEGIN***************************************
import papaya.*;

import ddf.minim.analysis.*;
import ddf.minim.*;
//AUDIO CODE END********************************************

import Weka4P.*;
Weka4P wpP;
Weka4P wpS;

//AUDIO CODE BEGIN***********************************************
Minim minim;
AudioInput in;
FFT fft;

int streamSize = 500;
float sampleRate = 7000;
int numBins = 1025;
int bufferSize = (numBins-1)*2;
//FFT parameters
float[][] FFTHist;
final int LOW_THLD = 1; //low threshold of band-pass frequencies
final int HIGH_THLD = 200; //high threshold of band-pass frequencies 
int numBands = HIGH_THLD-LOW_THLD+1; //number of feature
float[] modeArray = new float[streamSize]; //classification to show
float[] thldArray = new float[streamSize]; //diff calculation: substract

//segmentation parameters
float energyMax = 0;
float energyThld = 5;
float[] energyHist = new float[streamSize]; //history data to show//segmentation parameters

//window
int windowSize = 20; //The size of data window
float[][] windowArray = new float[numBands][windowSize]; //data window collection
boolean b_sampling = false; //flag to keep data collection non-preemptive
int sampleCnt = 0; //counter of samples

//Statistical Features
float[] windowM = new float[numBands]; //mean
float[] windowSD = new float[numBands]; //standard deviation

//Save
Table csvData;
boolean b_saveCSV = false;
String dataSetName = "new_MicSVC"; 
String[] attrNames;
boolean[] attrIsNominal;
int labelIndex = 0;

String lastPredY = "";

void setDataType() {
  attrNames =  new String[numBands+1];
  attrIsNominal = new boolean[numBands+1];
  for (int j = 0; j < numBands; j++) {
    attrNames[j] = "f_"+j;
    attrIsNominal[j] = false;
  }
  attrNames[numBands] = "label";
  attrIsNominal[numBands] = true;
}
//AUDIO CODE END***************************************************


import processing.serial.*;
Serial port; 

double timer;    //millis()*10e-3;
double time_elapsed;
boolean closing = false;
double duration = 10;
int sensorNum = 6;
int[] rawData = new int[sensorNum];
boolean dataUpdated = false;
PImage correct;
PImage front;
PImage back;
PImage left;
PImage right;

//Pwindow
PWindow win = null;

//code to prevent glitching
String YPprev = "x";
int SameInstances = 50;
boolean Switch = false;
int InstancesSwitch = 0;

void settings() {
  size(500, 500);
}

void setup() {  
  surface.setLocation(20, 20);
  wpP = new Weka4P(this); //Posture weka object
  wpS = new Weka4P(this); //Audio weka object

  //AUDIO CODE BEGINS**************************************************
  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO, bufferSize, sampleRate);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.window(FFT.NONE);
  FFTHist = new float[numBands][streamSize]; //history data to show
  for (int i = 0; i < modeArray.length; i++) { //Initialize all modes as null
    modeArray[i] = -1;
  }
  wpS.loadTrainARFF("MicTrain.arff"); //load a ARFF dataset
  wpS.loadModel("AudioSVC.model"); //load a pretrained model.
  //AUDIO CODE ENDS********************************************************

  //Initialize the serial port
  for (int i = 0; i < Serial.list().length; i++) println("[", i, "]:", Serial.list()[i]);
  //String portName = Serial.list()[Serial.list().length-1];//MAC: check the printed list
  String portName = Serial.list()[0];//WINDOWS: check the printed list
  port = new Serial(this, portName, 115200);
  port.bufferUntil('\n'); // arduino ends each data packet with a carriage return 
  port.clear();           // flush the Serial buffer

  wpP.loadTrainARFF("Acc_Data_compiled_updated.arff"); //load a ARFF dataset
  wpP.trainKNN(1);             //train a SV classifier with K = 1
  wpP.saveModel("Posture_KNN_doubleupdated.model"); //save the model


  // load images
  correct = loadImage("images/correct.png");
  front = loadImage("images/front.png");
  back = loadImage("images/back.png");
  left= loadImage("images/left.png");
  right = loadImage("images/right.png");
  background(52);
}

void draw() {
 if(closing == true){
    setclosing();
 }
   
  

  if (dataUpdated) {
    background(#E9B2FF);
    fill(255);
    float[] XP = {rawData[0], rawData[1], rawData[2], rawData[3], rawData[4], rawData[5]}; 
    String YP = wpP.getPrediction(XP);
    textSize(24);
    textAlign(CENTER, CENTER);
    fill(0);
    text("Program running!", width/2, height/8); 
    String text = "Posture classification: "+YP;
    imageMode(CENTER);
    text(text, width/2, 110);


    if (YP != YPprev) {
      InstancesSwitch=0;
      YPprev=YP;
      Switch=false;
    } else if (YP==YPprev) {
      InstancesSwitch=InstancesSwitch+1;
      //println("InstancesSwitch = " +InstancesSwitch);
      YPprev=YP;
    }
    if (InstancesSwitch==SameInstances) {
      Switch = true;
    }

    if (YP != null && Switch==true) {
      //println("closing = " + closing);
      imageMode(CENTER);
      if (closing == false) {
        switch(YP) {
        case "A": //if(counting==true){resettimer();counting=false;}
          image(correct, width/2, height/2, width/2, height/2);
          if (win != null) {
            win.update(YP);
          }
          break;
        case "B": //if(counting==false){timerbegin();counting=true;}
          //else if(counting==true){timerend();if(time_elapsed>5){counting=false;}}
          image(left, width/2, height/2, width/2, height/2);

          if (win == null) {
            win = new PWindow(YP);
          } else {
            win.update(YP);
          }
          break;
        case "C": //if(counting==false){timerbegin();counting=true;}
          image(right, width/2, height/2, width/2, height/2);
          if (win == null) {
            win = new PWindow(YP);
          } else {
            win.update(YP);
          }
          break;
        case "D": //if(counting==false){timerbegin();counting=true;}
          image(front, width/2, height/2, width/2, height/2);
          if (win == null) {
            win = new PWindow(YP);
          } else {
            win.update(YP);
          }
          break;
        case "E": //if(counting==false){timerbegin();counting=true;}
          image(back, width/2, height/2, width/2, height/2);
          if (win == null) {
            win = new PWindow(YP);
          } else {
            win.update(YP);
          }
          break;
        default: 
          break;
        }
      }
      dataUpdated = false;
    }

    //AUDIO CODE BEGIN*********************************************
    fft.forward(in.mix.toArray());

    float[] XS = new float[numBands]; //Form a feature vector XS;

    energyMax = 0; //reset the measurement of energySum
    for (int i = 0; i < HIGH_THLD-LOW_THLD; i++) {
      float x = fft.getBand(i+LOW_THLD);
      if (x>energyMax) energyMax = x;
      if (b_sampling == true) {
        if (x>XS[i]) XS[i] = x; //simple windowed max
        windowArray[i][sampleCnt-1] = x; //windowed statistics
      }
    }

    if (energyMax>energyThld) {
      if (b_sampling == false) { //if not sampling
        b_sampling = true; //do sampling
        sampleCnt = 0; //reset the counter
        for (int j = 0; j < numBands; j++) {
          XS[j] = 0; //reset the feature vector
          for (int k = 0; k < windowSize; k++) {
            (windowArray[j])[k] = 0; //reset the window
          }
        }
      }
    } 

    if (b_sampling == true) {
      ++sampleCnt;
      if (sampleCnt == windowSize) {
        for (int j = 0; j < numBands; j++) {
          windowM[j] = Descriptive.mean(windowArray[j]); //mean
          windowSD[j] = Descriptive.std(windowArray[j], true); //standard deviation
          XS[j] = max(windowArray[j]);
        }
        b_sampling = false;
        lastPredY = wpS.getPrediction(XS);
        double yID = wpS.getPredictionIndex(XS);
        for (int n = 0; n < windowSize; n++) {
          appendArrayTail(modeArray, (float)yID);
        }
      }
    } else {
      appendArrayTail(modeArray, -1); //the class is null without mouse pressed.
    }
    // String YS = lastPredY;
    showInfo("Sound classification: " +wpS.getPrediction(XS), 120, 150, 24);
    drawFFTInfo(250, height-100, 18);
    //AUDIO CODE ENDS***********************************************


    //Cases Sound
    if (lastPredY !=null && closing==false) {
      imageMode(CENTER);
      switch(lastPredY) {
      case "A": //if(counting==true){resettimer();counting=false;}
        closing=true;
        timerbegin();
        //win.setDefaultClosePolicy(this, true);
        win.update("A");
        break;
      case "B": //if(counting==false){timerbegin();counting=true;}
        //else if(counting==true){timerend();if(time_elapsed>5){counting=false;}}

        break;
      case "C": //if(counting==false){timerbegin();counting=true;}

        break;
      }
    }
  }
}

void serialEvent(Serial port) {   
  String inData = port.readStringUntil('\n');  // read the serial string until seeing a carriage return
  if (!dataUpdated) 
  {
    if (inData.charAt(0) == 'A') {
      rawData[0] = int(trim(inData.substring(1)));
    }
    if (inData.charAt(0) == 'B') {
      rawData[1] = int(trim(inData.substring(1)));
    }
    if (inData.charAt(0) == 'C') {
      rawData[2] = int(trim(inData.substring(1)));
      dataUpdated = true;
    }
    if (inData.charAt(0) == 'D') {
      rawData[3] = int(trim(inData.substring(1)));
    }
    if (inData.charAt(0) == 'E') {
      rawData[4] = int(trim(inData.substring(1)));
    }
    if (inData.charAt(0) == 'F') {
      rawData[5] = int(trim(inData.substring(1)));
      dataUpdated = true;
    }
  }
  return;
}


//AUDIO CODE BEGIN****************************************
void stop()
{
  // always close Minim audio classes when you finish with them
  in.close();
  minim.stop();
  super.stop();
}
//AUDIO CODE END******************************************

//Papplet window begin ******************************************

class PWindow extends PApplet {

  String caseVar = "A";

  PWindow(String Y) {
    super();
    caseVar = Y;
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void settings() {
    size(250, 250);
  }

  void update(String Y) {
    caseVar = Y;
    redraw();
  }

  void setup() {
    background(250);
    surface.setLocation(1650, 700);
    setDefaultClosePolicy(this, false);
    noLoop();
  }

  void draw() {
    //println("hey");
    fill(0);
    background(255);
    imageMode(CENTER);
    textAlign(CENTER);
    textSize(15);
    switch(caseVar) {
    case "A": 
      //surface.setVisible(false);
      //  System.exit(2);
      setDefaultClosePolicy(this, true);
      surface.setVisible(false);
      break;
    case "B": 
      surface.setVisible(true);
      text("You are leaning to the left.", width/2, height/10);
      image(left, width/2, height/2, width, height);
      break;
    case "C": 
      surface.setVisible(true);
      text("You are Leaning to the right.", width/2, height/10);
      image(right, width/2, height/2, width, height);
      break;
    case "D": 
      surface.setVisible(true);
      text("You are to close to your screen.", width/2, height/10);
      image(front, width/2, height/2, width, height);
      break;
    case "E":
      surface.setVisible(true);
      text("You are laying back.", width/2, height/10);
      image(back, width/2, height/2, width, height);
      break;
    default: 
      break;
    }
    dataUpdated = false;
  }

  void exit()
  {
    dispose();
    win = null;
  }
  void stop()
  {
    println("In stop");
    win.dispose();
    this.exit();
    win = null;
  }

  final void setDefaultClosePolicy(PApplet pa, boolean keepOpen) {
    final Object surf = pa.getSurface().getNative();
    final PGraphics canvas = pa.getGraphics();

    if (canvas.isGL()) {
      final com.jogamp.newt.Window w = (com.jogamp.newt.Window) surf;

      for (com.jogamp.newt.event.WindowListener wl : w.getWindowListeners())
        if (wl.toString().startsWith("processing.opengl.PSurfaceJOGL"))
          w.removeWindowListener(wl); 

      w.setDefaultCloseOperation(keepOpen?
        com.jogamp.nativewindow.WindowClosingProtocol.WindowClosingMode
        .DO_NOTHING_ON_CLOSE :
        com.jogamp.nativewindow.WindowClosingProtocol.WindowClosingMode
        .DISPOSE_ON_CLOSE);
    } else if (canvas instanceof processing.awt.PGraphicsJava2D) {
      final javax.swing.JFrame f = (javax.swing.JFrame)
        ((processing.awt.PSurfaceAWT.SmoothCanvas) surf).getFrame(); 

      for (java.awt.event.WindowListener wl : f.getWindowListeners())
        if (wl.toString().startsWith("processing.awt.PSurfaceAWT"))
          f.removeWindowListener(wl);

      f.setDefaultCloseOperation(keepOpen?
        f.DO_NOTHING_ON_CLOSE : f.DISPOSE_ON_CLOSE);
    }
  }

  public void makeVisible()
  {
    surface.setVisible(true);
  }
}
//Papplet window end ******************************************
