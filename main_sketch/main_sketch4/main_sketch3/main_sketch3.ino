#include <WiFi.h>
#include <String.h>
#include <stdint.h>
//#include "uptime_formatter.h"
const char *ssid =  "loadcellesp";   //Wifi SSID (Name)
const char *pass =  "123456789"; //wifi password

char *delim = ".";
#include <Wire.h>
#include "MAX30105.h"

MAX30105 particleSensor;


WiFiServer wifiServer(80);
void setup() {
  Serial.begin(115200);

  delay(1000);

  //  WiFi.begin(ssid, password);
  IPAddress apIP(192, 168, 43, 230); //Static IP for wifi gateway
  WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0)); //set Static IP gateway on NodeMCU
  WiFi.softAP(ssid, pass); //turn on WIFI



  wifiServer.begin();
  Serial.println("connnected");
////////////////
  // Initialize sensor
  if (!particleSensor.begin(Wire, I2C_SPEED_FAST)) //Use default I2C port, 400kHz speed
  {
    Serial.println("MAX30105 was not found. Please check wiring/power. ");
    while (1);
  }

  //Setup to sense a nice looking saw tooth on the plotter
  byte ledBrightness = 0x1F; //Options: 0=Off to 255=50mA
  byte sampleAverage = 8; //Options: 1, 2, 4, 8, 16, 32
  byte ledMode = 3; //Options: 1 = Red only, 2 = Red + IR, 3 = Red + IR + Green
  int sampleRate = 100; //Options: 50, 100, 200, 400, 800, 1000, 1600, 3200
  int pulseWidth = 411; //Options: 69, 118, 215, 411
  int adcRange = 4096; //Options: 2048, 4096, 8192, 16384

  particleSensor.setup(ledBrightness, sampleAverage, ledMode, sampleRate, pulseWidth, adcRange); //Configure sensor with these settings

  //Arduino plotter auto-scales annoyingly. To get around this, pre-populate
  //the plotter with 500 of an average reading from the sensor

  //Take an average of IR readings at power up
  const byte avgAmount = 64;
  long baseValue = 0;
  for (byte x = 0 ; x < avgAmount ; x++)
  {
    baseValue += particleSensor.getIR(); //Read the IR value
  }
  baseValue /= avgAmount;

  //Pre-populate the plotter so that the Y scale is close to IR values
  for (int x = 0 ; x < 500 ; x++)
    Serial.println(baseValue);
    /////////////////
  

}

void loop() {

  WiFiClient client = wifiServer.available();
  String command = "";


  if (client) {
    while (client.connected()) {
      while (client.available() > 0) {
        char c = client.read();
        if (c == '\n') {
          break;
        }
        command += c;
        Serial.write(c);
      }

      char cmd[command.length()];
      command.toCharArray(cmd, command.length());



        delay(1000);
        client.write(const_cast<char*>(concat2strings("strap1", particleSensor.getIR()).c_str()));

      command = "";
      delay(10);

    }
    client.stop();
    Serial.println("Client disconnected");


  }
  Serial.println(particleSensor.getIR()); //Send raw data to plotter
}

String concat2strings(String fixed, int n) { //strap 1 as fixed
  String str2 = String(n);
  String concatStr2 = fixed + str2;
  return concatStr2;

}
