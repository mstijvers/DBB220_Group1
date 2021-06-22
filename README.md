# DBB220_Group1
A smart wearable detecting bad sedentary posture.

## Description
This product was designed for the course DBB220 at the Technical University of Eindhoven at the department of Industrial Design. The product allows for posture recognition through two accelerometers. In case the system detects a posture different from a correct sedentary posture it will provide a pop-up through processing. This pop-up will automatically close when the user corrects his/her position. Additionally through sound recognition the user can clap to force quite the pop-ups for a pre-set time interval in case external events happen due to which you might not want to receive pop-ups. 

## Equipment 
In order to build the product you need: 

- 2x Accelerometer MPU-5060
- Teensy 3.2
- in build microphone
- Processing 3+
- Arduino 
- Wearable to fit the electronics

## Note
The data gathered for this product is based on 2 accelerometers which are sewed into the wearable, sewing a new wearable would most likely mean different measurements with the accelerometers and therefore false predictions. To work with this code a new wearable should be made and alongside goes a new set of training data. Additionally, the current mic data comes from a build in mic, and therefore the microphone data from other laptops might not fit the same dataset. 

