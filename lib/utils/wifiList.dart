import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iot/home.dart';
import 'package:wifi_iot/wifi_iot.dart';

class FlutterWifiIoT extends StatefulWidget {
  @override
  _FlutterWifiIoTState createState() => _FlutterWifiIoTState();
}

class _FlutterWifiIoTState extends State<FlutterWifiIoT> {
  @override
  Widget build(BuildContext context) {
    return Home();
  }

  List<WifiNetwork> _htResultNetwork = [];
  bool _isEnabled = false;
  bool _isConnected = false;
  String ssid = "";
  @override
  initState() {
    WiFiForIoTPlugin.setEnabled(true);
    getWifis();

    super.initState();
    // Wakelock.enable(); 
  }

  getWifis() async {
    _isEnabled = await WiFiForIoTPlugin.isEnabled();
    _isConnected = await WiFiForIoTPlugin.isConnected();
    _htResultNetwork = await loadWifiList();
    setState(() {});
    if (_isConnected) {
      WiFiForIoTPlugin.getSSID().then((value) => setState(() {
            ssid = "hasa";
          }));
    }
  }

  Future<List<WifiNetwork>> loadWifiList() async {
    List<WifiNetwork> htResultNetwork;
    try {
      htResultNetwork = await WiFiForIoTPlugin.loadWifiList();
    } on PlatformException {
      htResultNetwork = List<WifiNetwork>();
    }

    return htResultNetwork;
  }

  isRegisteredWifiNetwork(String ssid) {
    return ssid == this.ssid;
  }

  getList(contex) {
    return ListView.builder(
      itemBuilder: (builder, i) {
        var network = _htResultNetwork[i];
        var isConnctedWifi = false;
        if (_isConnected)
          isConnctedWifi = isRegisteredWifiNetwork(network.ssid);

        if (_htResultNetwork != null && _htResultNetwork.length > 0) {
          return Container(
            color: isConnctedWifi
                ? Colors.indigo.shade100
                : Colors.indigo.shade100,
            child: ListTile(
                title:
                    Text(network.ssid, style: TextStyle(color: Colors.black)),
                trailing: !isConnctedWifi
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.of(contex)
                              .push(MaterialPageRoute(builder: (_) => Home()));
                        },
                        child: Text('Connect',
                            style: TextStyle(color: Colors.black)),
                      )
                    : SizedBox()),
          );
        } else
          return Center(
            child: Text('No wifi found'),
          );
      },
      itemCount: _htResultNetwork.length,
      shrinkWrap: true,
    );
  }
}