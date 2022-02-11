import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'dart:async';
import 'package:wakelock/wakelock.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  String wifiNetwork = "loadcellesp";
  bool isWifiConnected = false;
  bool isMobileInternet = false;
  bool ledstatus = false;
  Socket channel;
  String reciever = "";
  String status = "";

  Future<void> check() async {
    print("check called");
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      print("Better to Turn off mobile internet.");
      setState(() {
        isMobileInternet = true;
      });
    } else
      setState(() {
        isMobileInternet = false;
      });
    bool a = await WiFiForIoTPlugin.isEnabled();
    String c = wifiNetwork;
    String b = await WiFiForIoTPlugin.getSSID();
    if (!a) {
      await WiFiForIoTPlugin.setEnabled(true);
    } else if (b != c) {
      connectWifi();
    }
    if (isMobileInternet) {
      setState(() {
        status = "Better to Turn off mobile internet";
      });
    } else if ((b != c)) {
      setState(() {
        status = "reconnecting wifi";
      });
    } else {
      setState(() {
        status = "Connected";
      });
    }
  }

  Future<void> connectWifi() async {
    isWifiConnected = await WiFiForIoTPlugin.connect(wifiNetwork,
        security: NetworkSecurity.WPA, password: "123456789");
    if (isWifiConnected == false) {
      connectWifi();
    } else {
      print("iswificonnected = $isWifiConnected , channel called");
      channelconnect();
    }
  }

  Future<void> channelconnect() async {
    try {
      // ignore: close_sinks
      Socket _channel = await Socket.connect('192.168.43.230', 80);
      setState(() {
        channel = _channel;
      });
      channel.listen(
        (message) {
          String s = String.fromCharCodes(message);
          print("prinitng recieving object");
          print(s);

          Fluttertoast.showToast(msg: "$s");

          setState(() {
            reciever = s;
          });
        },
        onError: (error) {
          print("err " + error.toString());
        },
      );
    } catch (_) {
      print("error on connecting to websocket.");
    }
  }

  Timer timer;
  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    connectWifi();
    timer = Timer.periodic(Duration(seconds: 8), (Timer t) => check());
    ledstatus = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        SizedBox(
          height: 50,
        ),
        Container(
            child: HoldDetector(
          onHold: () {
            channel.write("Forward");
          },
          holdTimeout: Duration(microseconds: 200),
          enableHapticFeedback: true,
          child: Container(
              margin: EdgeInsets.only(top: 30),
              child: ElevatedButton(
                  onPressed: () {
                    channel.write("Forward");
                  },
                  child: Text("Forward"))),
        )),
        HoldDetector(
          onHold: () {
            channel.write("Backward");
          },
          holdTimeout: Duration(microseconds: 200),
          enableHapticFeedback: true,
          child: Container(
              margin: EdgeInsets.only(top: 30),
              child: ElevatedButton(
                  onPressed: () {
                    channel.write("Backward");
                  },
                  child: Text("Backward"))),
        ),
        HoldDetector(
          onHold: () {
            channel.write("Left");
          },
          holdTimeout: Duration(microseconds: 200),
          enableHapticFeedback: true,
          child: Container(
              margin: EdgeInsets.only(top: 30),
              child: ElevatedButton(
                  onPressed: () {
                    channel.write("Left");
                  },
                  child: Text("Left"))),
        ),
        HoldDetector(
          onHold: () {
            channel.write("Right");
          },
          holdTimeout: Duration(microseconds: 200),
          enableHapticFeedback: true,
          child: Container(
              margin: EdgeInsets.only(top: 30),
              child: ElevatedButton(
                  onPressed: () {
                    channel.write("Right");
                  },
                  child: Text("Right"))),
        )
      ]),
    );
  }
}
