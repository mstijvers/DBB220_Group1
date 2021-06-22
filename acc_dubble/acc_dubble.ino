// (c) Michael Schoeffler 2017, http://www.mschoeffler.de

#include "Wire.h" // This library allows you to communicate with I2C devices.

const int MPU_ADDR1 = 0x68; // I2C address of the MPU-6050. If AD0 pin is set to HIGH, the I2C address will be 0x69.
const int MPU_ADDR2 = 0x69;

// Vars for first accelerometer
int16_t accelerometer_x_1, accelerometer_y_1, accelerometer_z_1; // variables for accelerometer raw data
int16_t gyro_x_1, gyro_y_1, gyro_z_1; // variables for gyro raw data

// Vars for second accelerometer
int16_t accelerometer_x_2, accelerometer_y_2, accelerometer_z_2; // variables for accelerometer raw data
int16_t gyro_x_2, gyro_y_2, gyro_z_2; // variables for gyro raw data

//time
int sampleRate = 100; //samples per second
int sampleInterval = 1000000/sampleRate; //Inverse of SampleRate
long timer = micros(); //timer

char tmp_str[7]; // temporary variable used in convert function

int ledOn = 0; //to control the LED.

char* convert_int16_to_str(int16_t i) { // converts int16 to string. Moreover, resulting strings will have the same length in the debug monitor.
  sprintf(tmp_str, "%6d", i);
  return tmp_str;
}

void setup() {
  Serial.begin(115200);
  Wire.begin();
  Wire.beginTransmission(MPU_ADDR1); // Begins a transmission to the I2C slave (GY-521 board)
  Wire.write(0x6B); // PWR_MGMT_1 register
  Wire.write(0); // set to zero (wakes up the MPU-6050)
  Wire.endTransmission(true);

  Wire.beginTransmission(MPU_ADDR2);
  Wire.write(0x6B);
  Wire.write(0);
  Wire.endTransmission(true);

  timer = micros();
}
void loop() {
  Wire.beginTransmission(MPU_ADDR1);
  Wire.write(0x3B); // starting with register 0x3B (ACCEL_XOUT_H) [MPU-6000 and MPU-6050 Register Map and Descriptions Revision 4.2, p.40]
  Wire.endTransmission(false); // the parameter indicates that the Arduino will send a restart. As a result, the connection is kept active.
  Wire.requestFrom(MPU_ADDR1, 7*2, true); // request a total of 7*2=14 registers
  
  // "Wire.read()<<8 | Wire.read();" means two registers are read and stored in the same variable
  accelerometer_x_1 = Wire.read()<<8 | Wire.read(); // reading registers: 0x3B (ACCEL_XOUT_H) and 0x3C (ACCEL_XOUT_L)
  accelerometer_y_1 = Wire.read()<<8 | Wire.read(); // reading registers: 0x3D (ACCEL_YOUT_H) and 0x3E (ACCEL_YOUT_L)
  accelerometer_z_1 = Wire.read()<<8 | Wire.read(); // reading registers: 0x3F (ACCEL_ZOUT_H) and 0x40 (ACCEL_ZOUT_L)
  gyro_x_1 = Wire.read()<<8 | Wire.read(); // reading registers: 0x43 (GYRO_XOUT_H) and 0x44 (GYRO_XOUT_L)
  gyro_y_1 = Wire.read()<<8 | Wire.read(); // reading registers: 0x45 (GYRO_YOUT_H) and 0x46 (GYRO_YOUT_L)
  gyro_z_1 = Wire.read()<<8 | Wire.read(); // reading registers: 0x47 (GYRO_ZOUT_H) and 0x48 (GYRO_ZOUT_L)
  
  // print out data
//  Serial.print("aX = "); Serial.print(convert_int16_to_str(accelerometer_x));
//  Serial.print(" | aY = "); Serial.print(convert_int16_to_str(accelerometer_y));
//  Serial.print(" | aZ = "); Serial.print(convert_int16_to_str(accelerometer_z));
////  // the following equation was taken from the documentation [MPU-6000/MPU-6050 Register Map and Description, p.30]
////  Serial.print(" | tmp = "); Serial.print(temperature/340.00+36.53);
//  Serial.print(" | gX = "); Serial.print(convert_int16_to_str(gyro_x));
//  Serial.print(" | gY = "); Serial.print(convert_int16_to_str(gyro_y));
//  Serial.print(" | gZ = "); Serial.print(convert_int16_to_str(gyro_z));
//  Serial.println();

  Wire.beginTransmission(MPU_ADDR2);
  Wire.write(0x3B);
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR2, 7*2, true);
  accelerometer_x_2 = Wire.read()<<8 | Wire.read(); // reading registers: 0x3B (ACCEL_XOUT_H) and 0x3C (ACCEL_XOUT_L)
  accelerometer_y_2 = Wire.read()<<8 | Wire.read(); // reading registers: 0x3D (ACCEL_YOUT_H) and 0x3E (ACCEL_YOUT_L)
  accelerometer_z_2 = Wire.read()<<8 | Wire.read(); // reading registers: 0x3F (ACCEL_ZOUT_H) and 0x40 (ACCEL_ZOUT_L)
  gyro_x_2 = Wire.read()<<8 | Wire.read(); // reading registers: 0x43 (GYRO_XOUT_H) and 0x44 (GYRO_XOUT_L)
  gyro_y_2 = Wire.read()<<8 | Wire.read(); // reading registers: 0x45 (GYRO_YOUT_H) and 0x46 (GYRO_YOUT_L)
  gyro_z_2 = Wire.read()<<8 | Wire.read(); // reading registers: 0x47 (GYRO_ZOUT_H) and 0x48 (GYRO_ZOUT_L)

  
  
  if (micros() - timer >= sampleInterval) { //Timer: send sensor data in every 10ms
    timer = micros();

//    Serial.println("=== 68 ===");
    sendDataToProcessing('A', map(accelerometer_x_1,-32768,32767,0,500));
    sendDataToProcessing('B', map(accelerometer_y_1,-32768,32767,0,500));
    sendDataToProcessing('C', map(accelerometer_z_1,-32768,32767,0,500));

//    Serial.println("=== 69 ===");
    sendDataToProcessing('D', map(accelerometer_x_2,-32768,32767,0,500));
    sendDataToProcessing('E', map(accelerometer_y_2,-32768,32767,0,500));
    sendDataToProcessing('F', map(accelerometer_z_2,-32768,32767,0,500));
  }
}

void sendDataToProcessing(char symbol, int data) {
  Serial.print(symbol);  // symbol prefix of data type
  Serial.println(data);  // the integer data with a carriage return
}

void getDataFromProcessing() {
  while (Serial.available()) {
    char inChar = (char)Serial.read();
    if (inChar == 'a') { //when an 'a' charactor is received.
      ledOn = 1;
      digitalWrite(LED_BUILTIN, ledOn); //turn on the built in LED on Arduino Uno
    }
    if (inChar == 'b') { //when an 'b' charactor is received.
      ledOn = 0;
      digitalWrite(LED_BUILTIN, 0); //turn on the built in LED on Arduino Uno
    }
    if (inChar == 'c') { //when an 'b' charactor is received.
      ledOn = 0;
      digitalWrite(LED_BUILTIN, 0); //turn on the built in LED on Arduino Uno
    }
    if (inChar == 'd') { //when an 'b' charactor is received.
      ledOn = 0;
      digitalWrite(LED_BUILTIN, 0); //turn on the built in LED on Arduino Uno
    }
  }
}
